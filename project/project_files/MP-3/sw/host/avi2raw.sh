#!/bin/sh

# Remove existing images
rm -rf ../data/image-*

# Converts the test.avi file into multiple frames
# -r is FPS, -dframes is number of frames, -t is duration
ffmpeg -i ../data/test.avi -r 10 -ss 00:00:14.2 -t 00:00:5.0 -s vga ../data/image-%3d.png 

# Grab the filenames for the frames
FILES=`ls ../data/image-*.png`
NFRAMES=`ls ../data/image-*.png | wc -l`

ADDR=1074790400
HEXADDR=`echo "obase=16; $ADDR" | bc`
echo "#define STARTADDR 0x$HEXADDR" > ../data/nframes.h
echo "#define NFRAMES $NFRAMES" >> ../data/nframes.h

rm -rf ../data/loadvideo.bat

for f in $FILES
do
  echo "Converting $f to .raw format and updating script"
  ./png2raw ../data/$f

  HEXADDR=`echo "obase=16; $ADDR" | bc`
  echo "bload ../data/$f.raw 0x$HEXADDR" >> ../data/loadvideo.bat
  ADDR=`expr $ADDR + 614400`

done



