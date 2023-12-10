#!/bin/bash
AURDIR=aur

function die() {
	printf '%s' "$*"
	exit 1
}

if [[ ! -d "${AURDIR}" ]]; then
	git -c init.defaultbranch=master clone \
		ssh://aur@aur.archlinux.org/mudpack.git "${AURDIR}"
	username="$(git config user.name)"
	useremail="$(git config user.email)"
	pushd "${AURDIR}"
	git config user.name "${username}"
	git config user.email "${useremail}"
	popd
fi
if [[ $# == 0 ]]; then
	tag="$(git describe --tags)"
else
	tag=$1
	git tag -a -m "${tag}" "${tag}"
	git push --follow-tags
fi
git checkout "${tag}"
git clean -fdx makepkg
rm -rf "${AURDIR}/{*,.SRCINFO}"
cp -rv makepkg -T "${AURDIR}"
sed -i -e "s/pkgver=.*/pkgver=${tag:1}/" "${AURDIR}"/PKGBUILD
pushd "${AURDIR}"
makepkg --printsrcinfo > .SRCINFO
git add .
git status
updpkgsums
git add PKGBUILD
git commit -m "${tag}"
#git push
popd
git switch -
