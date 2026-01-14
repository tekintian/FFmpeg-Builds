ARG GH_REPO=ghcr.io/btbn/ffmpeg-builds
FROM $GH_REPO/base:latest

RUN --mount=type=cache,id=osxcross,target=/var/cache/osxcross,sharing=locked \
    git clone --filter=blob:none --depth=1 https://github.com/tpoechtrager/osxcross.git /opt/osxcross && \
    cd /opt/osxcross && \
    git clone --filter=blob:none --depth=1 --branch=master https://github.com/phracker/MacOSX-SDKs.git /opt/osxcross/tarballs && \
    ./tools/gen_sdk_package.sh /opt/osxcross/tarballs/MacOSX12.3.sdk.tar.xz && \
    UNATTENDED=1 OSX_VERSION_MIN=10.13 ./build.sh && \
    ln -sf /opt/osxcross/target/bin/* /usr/local/bin/ && \
    rm -rf /opt/osxcross/.git /opt/osxcross/tarballs/.git

RUN mkdir /opt/ffbuild

ENV FFBUILD_TOOLCHAIN=x86_64-apple-darwin \
    FFBUILD_RUST_TARGET="x86_64-apple-darwin"

RUN \
    rustup default nightly && \
    rustup target add x86_64-apple-darwin && \
    echo "[target.$FFBUILD_RUST_TARGET]\nlinker = \"${FFBUILD_TOOLCHAIN}-clang\"\nar = \"${FFBUILD_TOOLCHAIN}-ar\"\n" >> "$CARGO_HOME"/config.toml

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson

ENV PATH="/opt/osxcross/target/bin:${PATH}" \
    FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- --arch=x86_64 --target-os=darwin" \
    FFBUILD_CROSS_PREFIX="${FFBUILD_TOOLCHAIN}-" \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_DESTDIR=/opt/ffdest \
    FFBUILD_DESTPREFIX=/opt/ffdest/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    CC="${FFBUILD_TOOLCHAIN}-clang" \
    CXX="${FFBUILD_TOOLCHAIN}-clang++" \
    LD="${FFBUILD_TOOLCHAIN}-ld" \
    AR="${FFBUILD_TOOLCHAIN}-ar" \
    RANLIB="${FFBUILD_TOOLCHAIN}-ranlib" \
    NM="${FFBUILD_TOOLCHAIN}-nm" \
    STRIP="${FFBUILD_TOOLCHAIN}-strip" \
    CFLAGS="-I/opt/ffbuild/include -O2 -pipe -fPIC -DPIC -D_FORTIFY_SOURCE=2 -fstack-protector-strong -fstack-clash-protection -mmacosx-version-min=10.13" \
    CXXFLAGS="-I/opt/ffbuild/include -O2 -pipe -fPIC -DPIC -D_FORTIFY_SOURCE=2 -fstack-protector-strong -fstack-clash-protection -mmacosx-version-min=10.13" \
    LDFLAGS="-L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong -fstack-clash-protection -mmacosx-version-min=10.13 -lm" \
    STAGE_CFLAGS="-fvisibility=hidden -fno-semantic-interposition" \
    STAGE_CXXFLAGS="-fvisibility=hidden -fno-semantic-interposition"
