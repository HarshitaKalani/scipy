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
cp scipy/optimize/minpack.so $CONDA_PREFIX/lib/scipy/optimize/

cp ~/Desktop/lfortran/src/runtime/liblfortran_runtime.so $CONDA_PREFIX/lib/

cp scipy/optimize/minpack.so ./build-install/lib/python3.10/scipy/optimize/
# Test

python dev.py test -t scipy.optimize.tests.test_constraints -v
