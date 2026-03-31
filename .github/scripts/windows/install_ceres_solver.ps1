$ErrorActionPreference = "Stop"
$INSTALL_PREFIX = "C:\ceres-solver220"

# Install dependencies via vcpkg
cd C:\vcpkg
git pull
if ($LASTEXITCODE -ne 0) { throw "git pull failed" }

.\bootstrap-vcpkg.bat
if ($LASTEXITCODE -ne 0) { throw "bootstrap-vcpkg failed" }

.\vcpkg install glog gflags suitesparse --triplet x64-windows
if ($LASTEXITCODE -ne 0) { throw "vcpkg install failed" }

# Build Ceres
cd $env:GITHUB_WORKSPACE
Invoke-WebRequest -Uri "https://github.com/ceres-solver/ceres-solver/archive/2.2.0.zip" -OutFile "2.2.0.zip"
Expand-Archive -Path "2.2.0.zip" -DestinationPath "."
cd ceres-solver-2.2.0

cmake -S . -B _build `
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" `
    -DCMAKE_TOOLCHAIN_FILE="C:\vcpkg\scripts\buildsystems\vcpkg.cmake" `
    -DVCPKG_TARGET_TRIPLET="x64-windows" `
    -DEigen3_DIR="C:\eigen-3.4.0\share\eigen3\cmake" `
    -DUSE_CUDA=OFF
if ($LASTEXITCODE -ne 0) { throw "cmake configure failed" }

cmake --build build --config Release --parallel
if ($LASTEXITCODE -ne 0) { throw "cmake build failed" }

cmake --install build --config Release
if ($LASTEXITCODE -ne 0) { throw "cmake install failed" }
