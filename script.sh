set -ex
# Compile the Fortran files
all=$(find /home/harshita/scipy/scipy/optimize/minpack/ -name "*.f" | wc -l)

for src in $(find /home/harshita/scipy/scipy/optimize/minpack/ -name "*.f"); do
    echo "Compiling $src"
    lfortran -c $src -o ${src%.f}.o --fixed-form --implicit-typing --implicit-interface --generate-object-code --use-loop-variable-after-loop
    cp ${src%.f}.o ./
done

lfortran -c /home/harshita/scipy/scipy/optimize/minpack/chkder.f -o chkder.o --fixed-form --implicit-typing --implicit-interface --generate-object-code --use-loop-variable-after-loop --rtlib

# Link the object files into a shared library using clang
clang -shared -fPIC -o scipy/optimize/minpack.so *.o -L/home/harshita/Desktop/lfortran/src/runtime -llfortran_runtime

# nm scipy/optimize/minpack.so
mkdir -p $CONDA_PREFIX/lib/scipy/optimize/
cp scipy/optimize/minpack.so $CONDA_PREFIX/lib/scipy/optimize/

# Copy the runtime library

# For Mac
# cp ~/Desktop/lfortran/src/runtime/liblfortran_runtime.dylib $CONDA_PREFIX/lib/

# For Linux
cp ~/Desktop/lfortran/src/runtime/liblfortran_runtime.so $CONDA_PREFIX/lib/

# Build
python dev.py build

# Setup the package  

# For mac
# mkdir -p ./build-install/lib/python3.10/site-packages/scipy/optimize/
# cp scipy/optimize/minpack.so ./build-install/lib/python3.10/site-packages/scipy/optimize/

# For Linux
mkdir -p ./build-install/lib/python3.10/scipy/optimize/
cp scipy/optimize/minpack.so ./build-install/lib/python3.10/scipy/optimize/

# Test
python dev.py test -t scipy.optimize -v

