#!/bin/bash

# This line defines the base of the filename, e.g. cotton_xxx_xxx.png
TEXTURE="cotton"

# This defines the name of the bright red source texture that will
# be used to generate all of the others.
base_texture="red_base_"$TEXTURE".png"

base_colors="red orange yellow lime green aqua cyan skyblue blue violet magenta redviolet"

echo -e "\nCurrently configured to generate filenames based on "$TEXTURE"."

if [ ! -e "$base_texture" ] ; then {
	echo -e "\nPlease supply a proper base texture from which to generate all"
	echo "of the colors.  It must be named "$base_texture" and must"
	echo -e "be placed in the directory you ran this script from.\n"
	exit 1
} fi

pushd . >/dev/null
mkdir generated-textures
cd generated-textures

hue=0
for name in $base_colors ; do
	hue2=`echo "scale=10; ("$hue"*200/360)+100" |bc`
	echo $name "("$hue" degrees)"
	echo "     dark"
	convert ../$base_texture -modulate  33,100,$hue2 $TEXTURE"_dark_"$name".png"
	echo "     medium"
	convert ../$base_texture -modulate  66,100,$hue2 $TEXTURE"_medium_"$name".png"
	echo "     bright"
	convert ../$base_texture -modulate 100,100,$hue2 $TEXTURE"_"$name".png"
	echo "     dark, 50% saturation"
	convert ../$base_texture -modulate  33,50,$hue2  $TEXTURE"_dark_"$name"_s50.png"
	echo "     medium, 50% saturation"
	convert ../$base_texture -modulate  66,50,$hue2  $TEXTURE"_medium_"$name"_s50.png"
	echo "     bright, 50% saturation"
	convert ../$base_texture -modulate 100,50,$hue2  $TEXTURE"_"$name"_s50.png"
	hue=$((hue+30))
done

echo "greyscales"
echo "     black"
convert ../$base_texture -modulate  15,0,0  $TEXTURE"_black.png"
echo "     dark grey"
convert ../$base_texture -modulate  50,0,0  $TEXTURE"_darkgrey.png"
echo "     medium grey"
convert ../$base_texture -modulate 100,0,0  $TEXTURE"_mediumgrey.png"
echo "     light grey"
convert ../$base_texture -modulate 150,0,0  $TEXTURE"_lightgrey.png"
echo "     white"
convert ../$base_texture -modulate 190,0,0  $TEXTURE"_white.png"

popd >/dev/null
