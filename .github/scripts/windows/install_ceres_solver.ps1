$ErrorActionPreference = "Stop"

$INSTALL_PREFIX = "C:\ceres-solver220"

# Install dependencies via vcpkg (pre-installed on windows-2022 runners)
cd C:\vcpkg
git pull
.\bootstrap-vcpkg.bat
.\vcpkg install eigen3 glog gflags suitesparse --triplet x64-windows

# Build Ceres
cd $env:GITHUB_WORKSPACE
Invoke-WebRequest -Uri "https://github.com/ceres-solver/ceres-solver/archive/2.2.0.zip" -OutFile "2.2.0.zip"
Expand-Archive -Path "2.2.0.zip" -DestinationPath "."
cd ceres-solver-2.2.0
mkdir build | Out-Null
cd build

cmake .. `
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" `
    -DCMAKE_TOOLCHAIN_FILE="C:\vcpkg\scripts\buildsystems\vcpkg.cmake" `
    -DVCPKG_TARGET_TRIPLET="x64-windows" `
    -DUSE_CUDA=OFF

cmake --build . --config Release --parallel
cmake --install . --config Release
