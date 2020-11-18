#!/bin/bash

# from https://github.com/golang/go/blob/master/src/go/build/syslist.go
GOOSES=(aix android darwin dragonfly freebsd hurd illumos ios js linux nacl netbsd openbsd plan9 solaris windows zos)
GOARCHES=(386 amd64 amd64p32 arm armbe arm64 arm64be ppc64 ppc64le mips mipsle mips64 mips64le mips64p32 mips64p32le ppc riscv riscv64 s390 s390x sparc sparc64 wasm)

GOVERSION=$(go version | cut -d " " -f 3 | cut -b 3-6)

errored=false
for goos in "${GOOSES[@]}"; do
	if [[ $goos == "android" ]]; then continue; fi 		# cross-compiling for android is a pain...
	for goarch in "${GOARCHES[@]}"; do
		if [[ $goarch == "sparc64" ]]; then continue; fi # for some reason sparc64 doesn't work...
		if [[ $goos == "darwin" && $goarch == "arm64" ]]; then continue; fi # ... darwin/arm64 netiher
		if [[ $GOVERSION == "1.14" && $goos == "darwin" && $goarch == "arm" ]]; then continue; fi # Go 1.14 lacks syscall.IPV6_RECVTCLASS

		ERROR=$(GOOS=$goos GOARCH=$goarch go build example/main.go 2>&1 > /dev/null)
		if [[ $ERROR =~ ^"cmd/go: unsupported GOOS/GOARCH".* ]]; then
			continue
		fi
		echo "GOOS: $goos, GOARCH: $goarch"
		if [[ -n $ERROR ]]; then
			echo -e $ERROR
			errored=true
		fi
	done
done

if [[ "$errored" = true ]]; then
	exit 1
fi
