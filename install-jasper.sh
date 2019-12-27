echo -e "\e[5;33;45m Install JasPer(Jpeg2000 Library) \e[0m"
wget --no-clobber https://github.com/mdadams/jasper/archive/master.zip
unzip -u master.zip
cd jasper-master
mkdir build-jasper
cd build-jasper
cmake -G "Unix Makefiles" .. -DJAS_ENABLE_DOC=NO
make
sudo make install