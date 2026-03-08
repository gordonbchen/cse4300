# ./configure --ostree=$HOME/work/root --toolprefix=cse4300-

cd kern/conf
./config ASST0
cd ../compile/ASST0

make depend
make
make install

cd $HOME/work/os161
make

cd ../root
sys161 kernel-ASST0