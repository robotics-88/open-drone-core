
# Clone and build GDAL
cd $HOME/src/
git clone https://github.com/OSGeo/gdal.git
cd gdal
git checkout release/3.5

mkdir build && cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install

# Refresh dynamic linker
sudo ldconfig

# Confirm install
gdalinfo --version