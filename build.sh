#!/usr/bin/env bash
# Build CurePlease (Release|x86) from a Unix shell - WSL, Git Bash, MSYS.
# Visual Studio users can open CurePlease.sln instead and skip all of this.
#
# Two gotchas this handles:
#   1. The framework's own csc is C# 5 and this code uses C# 6/7, so MSBuild is pointed at
#      the Roslyn compiler from the Microsoft.Net.Compilers package.
#   2. Building over a WSL share trips MSB3821 "mark of the web" on the .resx files, so
#      under WSL point BUILD_DIR at a real Windows drive and the source is mirrored there.
#
# Overridable: MSBUILD, NUGET, BUILD_DIR.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${BUILD_DIR:-$SRC}"
MSBUILD="${MSBUILD:-/mnt/c/Windows/Microsoft.NET/Framework64/v4.0.30319/MSBuild.exe}"
NUGET="${NUGET:-nuget.exe}"
ROSLYN_PKG="Microsoft.Net.Compilers.3.6.0"

if [ ! -d "$SRC/packages/$ROSLYN_PKG" ]; then
  echo ">> restoring $ROSLYN_PKG"
  "$NUGET" install Microsoft.Net.Compilers -Version 3.6.0 -OutputDirectory "$SRC/packages"
fi
[ -d "$SRC/packages/GlobalHotKey.1.1.0" ] || "$NUGET" restore "$SRC/CurePlease.sln"

if [ "$BUILD_DIR" != "$SRC" ]; then
  echo ">> mirroring source to $BUILD_DIR"
  rsync -a --delete --exclude='.git' --exclude='bin/' --exclude='obj/' "$SRC"/ "$BUILD_DIR"/
fi

ROSLYN="$BUILD_DIR/packages/$ROSLYN_PKG/tools"
command -v wslpath >/dev/null && ROSLYN="$(wslpath -w "$ROSLYN")"

echo ">> building Release|x86"
cd "$BUILD_DIR"
"$MSBUILD" CurePlease.csproj /t:Build /p:Configuration=Release /p:Platform=x86 \
  /p:CscToolPath="$ROSLYN" /p:CscToolExe=csc.exe \
  /nologo /v:minimal /clp:ErrorsOnly

echo ">> OK: $BUILD_DIR/bin/Release/Cure Please.exe"
