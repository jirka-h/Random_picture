#!/bin/bash

size_x=1920
size_y=1080

#Convert random data to images using the ImageMagick
#On Fedora, you can install ImageMagick with dnf install ImageMagick

#haveged -n "$(bc <<< "$size_x * $size_y")" --file - | convert -size "${size_x}"x"${size_y}" -depth 8 -format GRAY GRAY:-  gray_output.png
haveged -n "$(bc <<< "$size_x * $size_y")" --file - | display -size "${size_x}"x"${size_y}" -depth 8 -format GRAY GRAY:-
#head -c "$(bc <<< "$size_x * $size_y * 3")" /dev/random | convert -size "${size_x}"x"${size_y}" -depth 8 -format RGB RGB:- rgb_output.png
head -c "$(bc <<< "$size_x * $size_y * 3")" /dev/random | display -size "${size_x}"x"${size_y}" -depth 8 -format RGB RGB:-

#Create huge image and resize it. This will average blocks of size 8x8 to one pixel.
size_big_x=$((size_x * 8))
size_big_y=$((size_y * 8))

head -c "$(bc <<< "$size_big_x * $size_big_y")" /dev/random | display -size "${size_big_x}"x"${size_big_y}" -depth 8 -resize "${size_x}"x"${size_y}" -format GRAY GRAY:-
head -c "$(bc <<< "$size_big_x * $size_big_y * 3")" /dev/random | display -size "${size_big_x}"x"${size_big_y}" -depth 8 -resize "${size_x}"x"${size_y}" -format RGB RGB:-


#Work with any binary file
#{{{ ceiling_divide
function ceiling_divide()
{
  local num=$1
  local div=$2
  echo $(( (num + div -1) / div ))
}
#}}} ceiling_divide

file="/usr/bin/$(ls -S /usr/bin | head -1)"
file_size=$(stat --printf="%s" "$file")
file_x=$(bc <<<"scale=0;sqrt($file_size)")
file_y="$(ceiling_divide "$file_size" "$file_x")"
file_pad=$((file_x*file_y-file_size))

{
  dd if="$file"
  (( file_pad > 0 )) && dd if=/dev/zero bs="$file_pad" count=1
} | display -size "${file_x}"x"${file_y}" -depth 8 -format GRAY GRAY:-



