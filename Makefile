# Top-level Makefile placeholder
ifeq ($(PROFILE),clang-elf)
  include mk/clang-elf.mk
endif

.PHONY: help
help:
@echo "Use PROFILE=clang-elf to enable the Clang/LLD cross toolchain."
