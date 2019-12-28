#!/bin/bash

#########Configure Version Directory etc...###############
BUILDDIR="OpenSiv3D-installer"
ANGELSCRIPT_VERSION="2.34.0"
MULTICORE="10"
OPENCV_VERSION='4.2.0'
OPENCV_CONTRIB='YES'
##########################################################

##################Installing Dependancies##################
echo -e "\e[5;33;45m Install OpenSiv3D dependancies \e[0m"
sudo apt install -y -qq libxi-dev libxcursor-dev libxrandr-dev \
libglu1-mesa libgl1-mesa-dev libglu1-mesa-dev libglfw3-dev \
libpng-dev libjpeg-turbo8-dev libgif-dev libwebp-dev \
libfreetype6-dev libharfbuzz-dev libharfbuzz-bin libopenal-dev \
libopenal-data libogg-dev libvorbis-dev libboost1.65-dev \
libglib2.0-dev libudev-dev libc6 libavcodec-dev libavformat-dev\
libavutil-dev libswresample-dev libturbojpeg0-dev libglew-dev

##########################################################
cd ~
echo -e "\e[5;33;45m Install JasPer(Jpeg2000 Library) \e[0m"
wget --no-clobber https://github.com/mdadams/jasper/archive/master.zip
unzip -u master.zip
cd jasper-master
mkdir build-jasper
cd build-jasper
cmake -G "Unix Makefiles" .. -DJAS_ENABLE_DOC=NO
make
sudo make install
###########################################################
cd ~
cd $BUILDDIR
echo -e "\e[5;33;45m Install OpenCV4 \e[0m"
echo -e "\e[5;33;45m it will be install OpenCV version : echo ${OPENCV_VERSION}\e[0m"

sudo apt-get -y update -qq
sudo apt-get install -y -qq build-essential cmake \
                        qt5-default libvtk6-dev \
                        zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev \
                        libopenexr-dev libgdal-dev \
                        libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev \
                        libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev yasm \
                        libopencore-amrnb-dev libopencore-amrwb-dev libv4l-dev libxine2-dev \
                        libtbb-dev libeigen3-dev \
                        python-dev  python-tk  pylint  python-numpy  \
                        python3-dev python3-tk pylint3 python3-numpy flake8 \
                        ant default-jdk doxygen unzip wget

wget --no-clobber https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip
unzip -uq ${OPENCV_VERSION}.zip 
mv -u opencv-${OPENCV_VERSION} OpenCV

if [ $OPENCV_CONTRIB = 'YES' ]; then
  wget --no-clobber https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip
  unzip -uq ${OPENCV_VERSION}.zip 
  mv -u opencv_contrib-${OPENCV_VERSION} opencv_contrib
  mv -u opencv_contrib OpenCV
fi

cd OpenCV && mkdir -p build 
cd build

if [ $OPENCV_CONTRIB = 'NO' ]; then
cmake -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON \
      -DWITH_XINE=ON -DENABLE_PRECOMPILED_HEADERS=OFF .. -DOPENCV_GENERATE_PKGCONFIG=ON
fi

if [ $OPENCV_CONTRIB = 'YES' ]; then
cmake -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON \
      -DWITH_XINE=ON -DENABLE_PRECOMPILED_HEADERS=OFF \
      -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules .. -DOPENCV_GENERATE_PKGCONFIG=ON
fi

export PKG_CONFIG_PATH=`pwd`/unix-install:$PKG_CONFIG=PATH
pkg-config --cflags --libs opencv4
make -j $MULTICORE
sudo make install
sudo ldconfig

pwd

###############Install AngelScript##########################
cd ~
mkdir -p $BUILDDIR
cd $BUILDDIR
echo "Downloading AngelScript SDK . . ."
wget --no-clobber https://www.angelcode.com/angelscript/sdk/files/angelscript_${ANGELSCRIPT_VERSION}.zip
echo "Extracting AngelScript SDK . . ."
unzip -u angelscript*.zip
cd sdk/angelscript/projects/cmake
mkdir -p build
cd build 
cmake ..
make -j4
sudo make install 
pwd
################Install Boost C++ Library###########################
wget https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz -o boost_1_72_0.tar.gz
tar xvf boost_1_72_0.tar.gz 
cd boost_1_72_0/
./bootstrap.sh
./b2
sudo ./b2 install
###############Install OpenSiv3D##########################
cd ~
cd $BUILDDIR
git clone git@github.com:Siv3D/OpenSiv3D.git --depth=1
cd OpenSiv3D
git checkout linux
cd Linux
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ..
make -j $MULTICORE
# run test app
cd ../App
mkdir -p build
cd build
cmake ..
cp -r ../resources/ .
cp -r ../../build/libSiv3D.a .
mkdir ../../Debug -p
cp -r ../../build/libSiv3D.a ../../Debug/
make CXXFLAGS=-lopencv_imgproc
