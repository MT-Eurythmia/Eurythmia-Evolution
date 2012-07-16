#!/bin/bash

TEXTURE=$1
COMPOSITE=$2

base_texture="red_base_"$TEXTURE".png"

if [ -z $TEXTURE ] || [ $TEXTURE == "--help" ] || [ $TEXTURE == "-h" ] ; then {

	echo -e "\nUsage:"
	echo -e "\ngentextures.sh basename [overlay filename]"
	echo -e "\nThis script requires one or two parameters which supply the"
	echo -e "base filename of the textures, and an optional overlay.  The"
	echo -e "<basename> is the first part of the filename that your textures"
	echo -e "will use when your mod is done.  For example, if you supply the"
	echo -e "word 'cotton', this script will produce filenames like cotton_red.png"
	echo -e "or 'cotton_dark_blue_s50.png'.  The texture that this script will"
	echo -e "read and recolor is derived from this parameter, and will be of"
	echo -e "the form 'red_base_xxxxx.png', where 'xxxx' is the basename."
	echo -e "\nYou can also supply an optional overlay image filename."
	echo -e "This image will be composited onto the output files after they"
	echo -e "have been colorized, but without being modified.  This is useful"
	echo -e "when you have some part of your base image that will either get"
	echo -e "changed unpredictably or undesirably.  Simply draw two images -"
	echo -e "one containing the whole image to be colored, and one containing"
	echo -e "the parts that should not be changed, with transparency where the"
	echo -e "base image should show through.\n"
	exit 1
} fi


if [[ ! -z $TEXTURE && ! -e $base_texture ]]; then {
	echo -e "\nThe basename 'red_base_"$TEXTURE".png' was not found."
        echo -e "\nAborting.\n"
	exit 1
} fi

if [[ ! -z $COMPOSITE && ! -e $COMPOSITE ]]; then {
	echo -e "\nThe requested composite file '"$COMPOSITE"' was not found."
        echo -e "\nAborting.\n"
	exit 1
} fi


convert $base_texture -modulate 1,2,3 tempfile.png 1>/dev/null 2>/dev/null

if (( $? )) ; then {
	echo -e "\nImagemagick failed while testing the base texture file."
	echo -e "\nEither the base file 'red_base_"$TEXTURE".png isn't an image,"
	echo "or it is broken, or Imagemagick itself just didn't work."
	echo -e "\nPlease check and correct your base image and try again."
	echo -e "\nAborting.\n"
	exit 1
} fi

composite_file=""

if [ ! -z $COMPOSITE ] ; then {
	convert $base_texture -modulate 1,2,3 $COMPOSITE -composite tempfile.png 1>/dev/null 2>/dev/null

	if (( $? )) ; then {
		echo -e "\nImagemagick failed while testing the composite file."
		echo -e "\nEither the composite file '"$COMPOSITE"' isn't an image"
		echo "or it is broken, or Imagemagick itself just didn't work."
		echo -e "\nPlease check and correct your composite image and try again."
		echo -e "\nAborting.\n"
		exit 1
	} fi

	composite_file=$COMPOSITE" -composite"
} fi

rm tempfile.png

base_colors="red orange yellow lime green aqua cyan skyblue blue violet magenta redviolet"

echo -e -n "\nGenerating filenames based on "$base_texture
if [ ! -z $COMPOSITE ] ; then {
	echo ","
	echo -n "using "$COMPOSITE" as an overlay"
} fi
echo -e "...\n"

rm -rf generated-textures
mkdir generated-textures

hue=0
for name in $base_colors ; do
	hue2=`echo "scale=10; ("$hue"*200/360)+100" |bc`
	echo $name "("$hue" degrees)"
	echo "     dark"
	convert $base_texture -modulate  33,100,$hue2 $composite_file "generated-textures/"$TEXTURE"_dark_"$name".png"
	echo "     medium"
	convert $base_texture -modulate  66,100,$hue2 $composite_file "generated-textures/"$TEXTURE"_medium_"$name".png"
	echo "     full"
	convert $base_texture -modulate 100,100,$hue2 $composite_file "generated-textures/"$TEXTURE"_"$name".png"
	echo "     light"
	convert $base_texture -modulate 150,100,$hue2 $composite_file "generated-textures/"$TEXTURE"_light_"$name".png"
	echo "     dark, 50% saturation"
	convert $base_texture -modulate  33,50,$hue2  $composite_file "generated-textures/"$TEXTURE"_dark_"$name"_s50.png"
	echo "     medium, 50% saturation"
	convert $base_texture -modulate  66,50,$hue2  $composite_file "generated-textures/"$TEXTURE"_medium_"$name"_s50.png"
	echo "     full, 50% saturation"
	convert $base_texture -modulate 100,50,$hue2  $composite_file "generated-textures/"$TEXTURE"_"$name"_s50.png"
	hue=$((hue+30))
done

echo "greyscales"
echo "     black"
convert $base_texture -modulate  15,0,0  $composite_file "generated-textures/"$TEXTURE"_black.png"
echo "     dark grey"
convert $base_texture -modulate  50,0,0  $composite_file "generated-textures/"$TEXTURE"_darkgrey.png"
echo "     medium grey"
convert $base_texture -modulate 100,0,0  $composite_file "generated-textures/"$TEXTURE"_mediumgrey.png"
echo "     light grey"
convert $base_texture -modulate 150,0,0  $composite_file "generated-textures/"$TEXTURE"_lightgrey.png"
echo "     white"
convert $base_texture -modulate 190,0,0  $composite_file "generated-textures/"$TEXTURE"_white.png"
