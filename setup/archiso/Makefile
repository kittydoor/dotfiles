SRC := $(shell find archlive/ -type f)

.PHONY: shell
shell:
	podman build . -t arch
	podman run --rm -it arch

.PHONY: build
build: arch.iso

arch.iso: $(SRC)
	foo
