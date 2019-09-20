# centos-vault-scl

Custom vault based scl (and rh) yum repositories.

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
yum install -y devtoolset-3
```

## Development

To generate the `*.repo` files from the template, run
`bash template-to-repos.sh`. These generated `*.repo` should then be committed,
replacing existing/old ones.