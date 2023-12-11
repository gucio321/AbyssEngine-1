FROM fedora:latest

# remove gcc to ensure it uses clang (clang is currently in fedora at the appropiae version)
RUN dnf remove -y gcc
# install dependencies
RUN dnf install -y git clang pkg-config python3 bison nasm autoconf autoconf-archive luarocks gettext-devel gperf python3-jinja2 automake libtool perl-open perl-FindBin python3-distutils-extra python3-distlib python3-pip ninja-build clang-tools-extra libcxx libcxx-devel openssl openssl-devel wget curl zip unzip tar libXext-devel libXft-devel libxkbcommon-devel ibus-devel SDL2-devel

# install vcpkg
RUN mkdir -p /opt
RUN git clone https://github.com/microsoft/vcpkg /opt/vcpkg
RUN /opt/vcpkg/bootstrap-vcpkg.sh
RUN ln -s /opt/vcpkg/vcpkg /usr/local/bin/vcpkg

# install cmake
WORKDIR /tmp/cmake
RUN wget https://cmake.org/files/v3.28/cmake-3.28.0.tar.gz
RUN tar xvf cmake-*
WORKDIR /tmp/cmake/cmake-3.28.0
RUN ./bootstrap
RUN make -j 12
RUN make -j 12 install

COPY . /abyssengine
WORKDIR /abyssengine
RUN CXXFLAGS='-stdlib=libc++' CC=clang CXX=clang++ cmake -DCMAKE_TOOLCHAIN_FILE=/opt/vcpkg/scripts/buildsystems/vcpkg.cmake -Bbuild -G "Ninja" .
WORKDIR /abyssengine/build/
RUN ninja
