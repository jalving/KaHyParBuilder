# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "KaHyParBuilder"
version = v"0.1.0"

# Collection of sources required to build CMakeBuilder
sources = [
    "https://cmake.org/files/v3.15/cmake-3.15.0.tar.gz" =>
    "0678d74a45832cacaea053d85a5685f3ed8352475e6ddf9fcb742ffca00199b5",
    "https://github.com/SebastianSchlag/kahypar.git" =>
    "2aaaae31cb8b44329e4fca7d3a58625ff3eedfe2"
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd cmake-3.15.0/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DCMAKE_USE_SYSTEM_LIBRARIES=Off -DBUILD_CursesDialog=Off ..
make
make install

cd $WORKSPACE/srcdir/kahypar
$WORKSPACE/srcdir/cmake-3.15.0/build/bin/cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DCMAKE_BUILD_TYPE=RELEASE ..
make
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    BinaryProvider.Linux(:x86_64, libc = :glibc, compiler_abi = CompilerABI(:gcc7)),
    BinaryProvider.MacOS(compiler_abi = CompilerABI(:gcc7)),
    BinaryProvider.Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libkahypar", :libkahypar)
]

# Dependencies that must be installed before this package can be built
dependencies = [https://github.com/twadleigh/BoostBuilder/releases/download/v1.68.0-4/build_Boost.v1.68.0.jl]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
