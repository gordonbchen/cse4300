# ===========================================================================
# Stage 1 — Builder (ubuntu:14.04 + GCC 4.8)
# Builds the entire OS/161 toolchain with zero patches.
# This stage is discarded after the binaries are copied out.
# ===========================================================================
FROM ubuntu:14.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    bison \
    flex \
    texinfo \
    libc6-dev \
    libncurses5-dev \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    perl \
    python3 \
    ca-certificates \
    file \
    git \
    curl \
    wget \
    xz-utils \
    patch \
    && rm -rf /var/lib/apt/lists/*

ARG USER=os161user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

USER ${USER}
ENV HOME=/home/${USER}
WORKDIR ${HOME}

ENV COURSE_TOOLPREFIX=cse4300-
ENV SYS161_HOME=${HOME}/sys161
ENV TOOLS_PREFIX=${SYS161_HOME}/tools
ENV PATH=${SYS161_HOME}/bin:${TOOLS_PREFIX}/bin:${PATH}

# ---- Copy archives ----
COPY --chown=${USER}:${USER} \
    dev_env/os161-binutils.tar.gz \
    dev_env/os161-gcc.tar.gz \
    dev_env/os161-gdb.tar.gz \
    dev_env/os161-bmake.tar.gz \
    dev_env/os161-mk.tar.gz \
    dev_env/os161.tar.gz \
    dev_env/sys161.tar.gz \
    ${HOME}/src/

# ---- Binutils ----
RUN set -eux; \
    cd "${HOME}/src"; \
    tar -xzf os161-binutils.tar.gz; \
    BINUTILS_DIR="$(find . -maxdepth 1 -type d -name 'binutils-*os161*' | head -n 1)"; \
    test -n "${BINUTILS_DIR}"; \
    cd "${BINUTILS_DIR}"; \
    ./configure \
        --nfp \
        --disable-werror \
        --target=mips-harvard-os161 \
        --prefix="${TOOLS_PREFIX}"; \
    make || (find . -name '*.info' -print0 | xargs -0 touch && make); \
    make install

# ---- GCC (zero patches — GCC 4.8 uses gnu89 by default) ----
RUN set -eux; \
    cd "${HOME}/src"; \
    tar -xzf os161-gcc.tar.gz; \
    GCC_DIR="$(find . -maxdepth 1 -type d -name 'gcc-*os161*' | head -n 1)"; \
    test -n "${GCC_DIR}"; \
    cd "${GCC_DIR}"; \
    ./configure \
        --nfp \
        --disable-shared \
        --disable-threads \
        --disable-libmudflap \
        --disable-libssp \
        --disable-werror \
        --target=mips-harvard-os161 \
        --prefix="${TOOLS_PREFIX}"; \
    make; \
    make install

# ---- GDB ----
RUN set -eux; \
    cd "${HOME}/src"; \
    tar -xzf os161-gdb.tar.gz; \
    GDB_DIR="$(find . -maxdepth 1 -type d -name 'gdb-*os161*' | head -n 1)"; \
    test -n "${GDB_DIR}"; \
    cd "${GDB_DIR}"; \
    find . -name '*.info' -o -name '*.texi' | xargs touch; \
    ./configure \
        --target=mips-harvard-os161 \
        --prefix="${TOOLS_PREFIX}" \
        --disable-werror; \
    make all-gdb; \
    make install-gdb

# ---- bmake + mk ----
RUN set -eux; \
    cd "${HOME}/src"; \
    tar -xzf os161-bmake.tar.gz; \
    test -d bmake; \
    cd bmake; \
    tar -xzf ../os161-mk.tar.gz; \
    ./boot-strap --prefix="${TOOLS_PREFIX}"; \
    mkdir -p "${TOOLS_PREFIX}/bin" \
             "${TOOLS_PREFIX}/share/man/cat1" \
             "${TOOLS_PREFIX}/share/mk"; \
    cp -f Linux/bmake "${TOOLS_PREFIX}/bin/bmake"; \
    cp -f bmake.cat1  "${TOOLS_PREFIX}/share/man/cat1/bmake.1"; \
    sh mk/install-mk  "${TOOLS_PREFIX}/share/mk"

# ---- Toolchain symlinks ----
RUN set -eux; \
    mkdir -p "${SYS161_HOME}/bin"; \
    for i in "${TOOLS_PREFIX}/bin/mips-"*; do \
        base="$(basename "$i")"; \
        suffix="$(echo "$base" | cut -d- -f4-)"; \
        ln -sf "$i" "${SYS161_HOME}/bin/${COURSE_TOOLPREFIX}${suffix}"; \
    done; \
    ln -sf "${TOOLS_PREFIX}/bin/bmake" "${SYS161_HOME}/bin/bmake"

# ---- sys161 ----
RUN set -eux; \
    cd "${HOME}/src"; \
    tar -xzf sys161.tar.gz; \
    SYS161_DIR="$(find . -maxdepth 1 -type d -name 'sys161-*' | head -n 1)"; \
    test -n "${SYS161_DIR}"; \
    cd "${SYS161_DIR}"; \
    ./configure --prefix="${SYS161_HOME}" mipseb; \
    make; \
    make install; \
    ln -sf "${SYS161_HOME}/share/examples/sys161/sys161.conf.sample" \
           "${SYS161_HOME}/sys161.conf"

# ---- OS/161 source + ASST0 sanity build ----
RUN set -eux; \
    mkdir -p "${HOME}/cse4300-os161"; \
    cd "${HOME}/cse4300-os161"; \
    tar -xzf "${HOME}/src/os161.tar.gz"; \
    OS161_DIR="$(find . -maxdepth 1 -type d -name 'os161-*' | head -n 1)"; \
    test -n "${OS161_DIR}"; \
    cd "${OS161_DIR}"; \
    ./configure \
        --ostree="${HOME}/cse4300-os161/root" \
        --toolprefix="${COURSE_TOOLPREFIX}"; \
    cd kern/conf; \
    ./config ASST0; \
    cd ../compile/ASST0; \
    make depend; \
    make; \
    make install; \
    cd "${HOME}/cse4300-os161/root"; \
    cp -f "${SYS161_HOME}/sys161.conf" .; \
    timeout 15s sys161 kernel-ASST0 < /dev/null || true

# ===========================================================================
# Stage 2 — Runtime (ubuntu:22.04)
# glibc 2.35 + GLIBCXX 3.4.30 — satisfies VS Code Server requirements.
# Receives the fully built toolchain + OS/161 tree from Stage 1.
# ===========================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    # Runtime libs the cross-compiler binaries were linked against
    libgmp10 \
    libmpfr6 \
    libmpc3 \
    libncurses5 \
    # VS Code Server requirements
    curl \
    git \
    ca-certificates \
    wget \
    # Required for os161 ./configure checks
    gcc \
    build-essential \
    # General convenience
    python3 \
    sudo \
    && rm -rf /var/lib/apt/lists/*

ARG USER=os161user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} && \
    # Allow passwordless sudo for convenience in a course container
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USER}
ENV HOME=/home/${USER}
WORKDIR ${HOME}

ENV COURSE_TOOLPREFIX=cse4300-
ENV SYS161_HOME=${HOME}/sys161
ENV TOOLS_PREFIX=${SYS161_HOME}/tools
ENV PATH=${SYS161_HOME}/bin:${TOOLS_PREFIX}/bin:${PATH}

RUN echo 'export SYS161_HOME="$HOME/sys161"'                           >> "${HOME}/.bashrc" && \
    echo 'export PATH="$SYS161_HOME/bin:$SYS161_HOME/tools/bin:$PATH"' >> "${HOME}/.bashrc"

# ---- Copy toolchain + OS/161 tree from builder ----
COPY --from=builder --chown=${USER}:${USER} \
    /home/os161user/sys161 \
    ${SYS161_HOME}

# Fix ranlib check in os161 configure script
USER root
RUN ln -sf /home/os161user/sys161/tools/bin/mips-harvard-os161-ranlib /usr/local/bin/ranlib
USER ${USER}

# Also copy the source archives in case students need to rebuild
COPY --from=builder --chown=${USER}:${USER} \
    /home/os161user/src \
    ${HOME}/src

# # ---- VS Code Server (code-server) ----
# # Installed at image build time so the container is ready to use immediately.
# RUN curl -fsSL https://code-server.dev/install.sh | sh

# # code-server config: no password, bind all interfaces
# RUN mkdir -p "${HOME}/.config/code-server" && \
#     printf 'bind-addr: 0.0.0.0:8080\nauth: none\ncert: false\n' \
#     > "${HOME}/.config/code-server/config.yaml"

# EXPOSE 8080

WORKDIR ${HOME}/work/os161
CMD ["/bin/bash"]