[![master CI Build Status]][master CI link]

# centos-vault-scl

Custom vault based scl (and rh) yum repositories.

> This repository **is not** associated with the [sclorg/centos-release-scl](https://github.com/sclorg/centos-release-scl)
> repository nor the [Software Collections](https://www.softwarecollections.org/en/) organisation.

It is a third-party attempt at a 1-liner to add after `yum install -y centos-release-scl` to then
have `yum install -y devtoolset-3` (and more) install correctly since the deprecation of older `sclo` packages.

See also:

- [Issue for official centos-release-scl](https://github.com/sclorg/centos-release-scl/issues/4)
- [vfx-platform-discuss Google Groups discussion](https://groups.google.com/forum/#!msg/vfx-platform-discuss/_-_CPw1fD3c/9jls2dP-AgAJ)
- `devtoolset-6` [was dropped in CentoOS 7.7.1908](https://www.centos.org/forums/viewtopic.php?f=48&t=71663&hilit=devtoolset+6)

## Goals

- Provide yum repositories for all `http://vault.centos.org/7.*/sclo/$basearch/`

  All **disabled by default**
    - 7.1.1503
    - 7.2.1511
    - 7.3.1611
    - 7.4.1708
    - 7.5.1804
    - 7.6.1810
- Match naming convention as found from `CentOS-Vault.repo` from `centos-release`
- Repository/naming will not clash with one from `centos-release-scl*`


## Usage

Install `centos-release-scl` first, then run `activate.sh` from master branch.


```bash
yum install -y centos-release-scl
curl -sSL https://raw.githubusercontent.com/wwfxuk/centos-vault-scl/master/activate.sh | bash
```

Then you can install old, archived packages e.g. `devtoolset-3`

```bash
# Should not encounter 404 http errors for missing rpms
yum install -y devtoolset-3
```

### activate.sh

The [activate.sh](https://github.com/wwfxuk/centos-vault-scl/blob/master/activate.sh)
**should be run with enough/root permissions** to run the following:


1. `yum install` any dependencies needed (notably for CentOS 7.1):

    - `tar`, `yum-config-manager`
    - If any of those are installed, `curl` is will also be updated to the latest
      version so it can also pull/download from GitHub (more modern NSS).

1. Extract `*.repo` files from this repository into `/etc/yum.repos.d/`
1. Have `yum-config-manager` enable the relevant `C7.x.x-centos-sclo-*`
   yum repositories depending on your current CentOS 7 release.
1. If enabling was successful, the original `centos-sclo-*` repositories will
   then be disabled so `yum install` will fetch packages from our **version
   specific archive** rather than from the latest mirrors.

You will still have to manually enable the `testing`, `source` and `debuginfo`
repositories if you wish to use packages from those repositories.

They are named `C<VERSION>-centos-sclo-<VARIANT>-{testing,source,debuginfo}`,
e.g. using `yum-config-manager`

```bash
yum-config-manager --enable C7.3.1611-centos-sclo-sclo-debuginfo
```

## Development

1. Modify the `CentOS-Vault-SCLo-scl.template`.
1. Run `bash template-to-repos.sh` to generate the `*.repo` files from the template.
1. Commit those generated `*.repo` files, replacing existing/old ones.
1. Push as a new branch, submit a pull request
1. Hopefully the CI will start judge whether you are worthy

There may be cases where you might need to change the CI tests e.g. if you are
adding a new feature. The main CI workflow files is located in
`.github/workflows/test-repos.yml`.

[master CI Build Status]: https://github.com/wwfxuk/centos-vault-scl/workflows/CI/badge.svg?branch=master
[master CI link]: https://github.com/wwfxuk/centos-vault-scl/actions?query=branch%3Amaster