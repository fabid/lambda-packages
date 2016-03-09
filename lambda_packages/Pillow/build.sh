#!/bin/bash

set -ex
set -o pipefail

echo "do update"
yum update -y

echo "do dependcy install"
yum install -y \
	gcc \
	libtiff-devel \
	libzip-devel \
	libjpeg-devel \
	freetype-devel \
	lcms2-devel \
	libwebp-devel \
	tcl-devel \
	tk-devel

echo "copy webp deps"
cd /usr/lib64/ 
find . -name "*webp*" | cpio -pdm ~/env/lib64/python2.7/site-packages/
cd ~/
chmod 755 -R env/lib64/python2.7/site-packages/

echo "make env"
/usr/bin/virtualenv \
	--python /usr/bin/python env \
	--always-copy



echo "activate env in `pwd`"
source env/bin/activate

echo "install pips"
pip install --verbose --use-wheel pillow
deactivate

echo "tar lib and lib64"
mkdir Pillow-3.1.1
cp -a env/lib/python2.7/site-packages/. Pillow-3.1.1/
cp -a env/lib64/python2.7/site-packages/. Pillow-3.1.1/
cd Pillow-3.1.1/ && tar -zcvf ../Pillow-3.1.1.tar.gz * && cd ..

#make lambda test
cd Pillow-3.1.1/
wget https://raw.githubusercontent.com/jDmacD/lambda-packages/master/lambda_packages/Pillow/test/test.jpg
wget https://raw.githubusercontent.com/jDmacD/lambda-packages/master/lambda_packages/Pillow/test/test.py
zip -r9 ../test.zip * && cd ..

#aws s3 cp test.zip s3://<YOUR BUCKET>/test.zip --region <YOUR REGION>
#aws s3 cp Pillow-3.1.1.tar.gz s3://<YOUR BUCKET>/Pillow-3.1.1.tar.gz --region <YOUR REGION>
