rm -rf neon
cp -rf /storage/emulated/0/pacotes/neon/ $HOME
cd neon
rm -rf .git
make limpar
make compilar_fpb
make
make disco.img
make qemu
cd ../
cp b.sh /storage/emulated/0/pacotes/neon/
cp neon/qemu.log /storage/emulated/0/pacotes/neon/
cp neon/debug.log /storage/emulated/0/pacotes/neon/
