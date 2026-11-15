# Maintainer: SilverX <serainox@gmail.com>
pkgname=cr0-git
_repo=CR0N0S
pkgver=r5.d8a8d3c
pkgrel=1
pkgdesc="A better cron: dynamic job scheduler with conditions, hooks, reminders, history ledger and TUI"
arch=('x86_64' 'aarch64')
url="https://github.com/Szmelc-INC/CR0N0S"
license=('MIT')
makedepends=('git' 'go')
optdepends=('cronie: import/export crontab entries (cr0 cron)')
provides=('cr0')
conflicts=('cr0')
options=('!debug')
source=("git+$url.git")
sha256sums=('SKIP')

pkgver() {
  cd "$_repo"
  ( set -o pipefail
    git describe --long --tags --abbrev=7 2>/dev/null | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g' ||
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short=7 HEAD)" )
}

prepare() {
  cd "$_repo"
  export GOPATH="$srcdir/gopath" GOFLAGS="-modcacherw"
  go mod download
}

build() {
  cd "$_repo"
  export GOPATH="$srcdir/gopath" CGO_ENABLED=0 GOFLAGS="-trimpath -mod=readonly -modcacherw"
  go build -ldflags "-s -w -X github.com/sernik77/CR0N0S/internal/cli.Version=$pkgver" -o cr0 ./cmd/cr0
  for sh in bash zsh fish; do HOME="$srcdir" ./cr0 completion "$sh" > "cr0.$sh"; done
}

check() {
  cd "$_repo"
  export GOPATH="$srcdir/gopath" GOFLAGS="-mod=readonly -modcacherw"
  HOME="$srcdir" go test ./...
}

package() {
  cd "$_repo"
  install -Dm755 cr0 "$pkgdir/usr/bin/cr0"
  install -Dm644 cr0.bash "$pkgdir/usr/share/bash-completion/completions/cr0"
  install -Dm644 cr0.zsh "$pkgdir/usr/share/zsh/site-functions/_cr0"
  install -Dm644 cr0.fish "$pkgdir/usr/share/fish/vendor_completions.d/cr0.fish"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
  install -Dm644 examples/*.toml -t "$pkgdir/usr/share/doc/$pkgname/examples/"
}
