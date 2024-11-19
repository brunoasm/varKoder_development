convert xc:white xc:red xc:orange xc:yellow xc:green1 xc:cyan xc:blue xc:blueviolet xc:black +append -filter Cubic -resize 600x30! -flop rainbow_lut.png

find . -name '*.png' -exec convert {} -colorspace gray rainbow_lut.png -clut -filter Point -resize 363x363! $(dirname {})/$(basename {} .png).color.png \;
