#!/bin/bash 
set -x

if [ -z "${EMSCRIPTEN_ROOT+xxx}" ]; then
  echo "EMSCRIPTEN_ROOT is not set. Please set it and try again."
  exit 1
fi

echo "Using EMSCRIPTEN_ROOT: $EMSCRIPTEN_ROOT"
export EMCC_DEBUG=1

mkdir -p build-wasm
cd build-wasm

cmake -DUSE_COMPILER_OPTIMIZATIONS=0 -DWASM=1 -DINIT_STATIC_MODULES=1 -DUSE_DOUBLE=NO -DBUILD_MULTI_CORE=0 -DBUILD_JACK_OPCODES=0 -DEMSCRIPTEN=1 -DCMAKE_TOOLCHAIN_FILE=$EMSCRIPTEN_ROOT/cmake/Modules/Platform/Emscripten.cmake -DCMAKE_MODULE_PATH=$EMSCRIPTEN_ROOT/cmake -DCMAKE_BUILD_TYPE=Release -G"Unix Makefiles" -DHAVE_BIG_ENDIAN=0 -DCMAKE_16BIT_TYPE="unsigned short"  -DHAVE_STRTOD_L=0 -DBUILD_STATIC_LIBRARY=YES -DHAVE_ATOMIC_BUILTIN=0 -DHAVE_SPRINTF_L=NO -DUSE_GETTEXT=NO -DLIBSNDFILE_LIBRARY=../deps/libsndfile-1.0.25/libsndfile-wasm.a -DSNDFILE_H_PATH=../deps/libsndfile-1.0.25/src ../..

emmake make csound-static -j6 

emcc -O2 -g4 ../src/FileList.c -s LINKABLE=1  -s ASSERTIONS=1 -Iinclude -o FileList.bc
emcc -O2 -g4 ../src/CsoundObj.c -s LINKABLE=1 -s ASSERTIONS=1 -I../../include -Iinclude -o CsoundObj.bc

# Total memory for a WebAssembly module must be a multiple of 64 KB so...
# 1024 * 64 = 65536 is 64 KB
# 65536 * 1024 * 4 is 268435456

# Keep exports in alphabetical order please, to correlate with CsoundObj.js.

emcc -v -O2 -g4 -DINIT_STATIC_MODULES=1 -s WASM=1 -s ASSERTIONS=1 -s "BINARYEN_METHOD='native-wasm'" -s LINKABLE=1 -s RESERVED_FUNCTION_POINTERS=1 -s TOTAL_MEMORY=268435456 -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_FUNCTIONS="['_strlen', '_CsoundObj_closeAudioOut', '_CsoundObj_compileCSD', '_CsoundObj_compileOrc', '_CsoundObj_destroy', '_CsoundObj_evaluateCode', '_CsoundObj_getControlChannel', '_CsoundObj_getInputBuffer', '_CsoundObj_getInputChannelCount', '_CsoundObj_getKsmps', '_CsoundObj_getOutputBuffer', '_CsoundObj_getOutputChannelCount', '_CsoundObj_getTable', '_CsoundObj_getTableLength', '_CsoundObj_getZerodBFS', '_CsoundObj_new', '_CsoundObj_openAudioOut', '_CsoundObj_pause', '_CsoundObj_performKsmps', '_CsoundObj_play', '_CsoundObj_prepareRT', '_CsoundObj_pushMidiMessage', '_CsoundObj_readScore' , '_CsoundObj_render' , '_CsoundObj_reset', '_CsoundObj_setControlChannel', '_CsoundObj_setMidiCallbacks', '_CsoundObj_setOption', '_CsoundObj_setOutputChannelCallback', '_CsoundObj_getScoreTime', '_CsoundObj_setStringChannel', '_CsoundObj_setTable']" CsoundObj.bc FileList.bc libcsound.a ../deps/libsndfile-1.0.25/libsndfile-wasm.a -o libcsound.js

cd ..
rm -rf dist-wasm
mkdir dist-wasm
cp build-wasm/libcsound.js dist-wasm/
cp src/*.js dist-wasm/
cp build-wasm/libcsound.wasm dist-wasm/
cp build-wasm/libcsound.js.map dist-wasm/
