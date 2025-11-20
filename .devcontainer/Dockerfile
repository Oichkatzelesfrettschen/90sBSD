# Dockerfile for 386BSD i386 build environment
FROM i386/debian:stable-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    bmake \
    cmake \
    ninja-build \
    clang \
    clang-tools \
    lld \
    llvm \
    gcc-multilib \
    libc6-dev-i386 \
    qemu-system-x86 \
    qemu-utils \
    flex \
    bison \
    groff \
    doxygen \
    graphviz \
    python3 \
    python3-pip \
    git \
    rsync \
    curl \
    wget \
    sudo

# Create a non-root user
RUN useradd -m -s /bin/bash developer && \
    echo "developer:developer" | chpasswd && \
    adduser developer sudo

# Switch to the non-root user
USER developer

# Set up the workspace
WORKDIR /home/developer/workspace

# Copy the project files
COPY . .

# Set up the environment
ENV CC=clang
ENV CXX=clang++
ENV AS=clang
ENV LD=ld.lld
ENV AR=llvm-ar
ENV RANLIB=llvm-ranlib
ENV OBJCOPY=llvm-objcopy
ENV STRIP=llvm-strip
ENV CFLAGS="-target i386-unknown-elf -m32 -march=i386 -ffreestanding -fno-builtin -fno-stack-protector"
ENV LDFLAGS="-m elf_i386"

# Default command
CMD ["/bin/bash"]
