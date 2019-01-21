#!/bin/sh

# NOTE:  this script uses ImageMagick, tools installed with '-im6' suffixes
#        as it is on the Devuan install I'm currently using.

# This shell script accepts the name of an Android project 'root' directory
# as the first parameter, and then does the following:
#
# 1.  make a copy of the 'ic_launcher.png' file with max resolution
#     as ic_launcher_orig.png (optional to overwrite existing file);
# 2.  edit that file using 'gimp';
# 3.  using the edited image, produce a nwe 'ic_launcher.png' file
#     that has a 3D-looking red border;
# 4.  produce a 'round icon' version 'ic_launcher_round.png' with
#     a 3D-looking ROUND border;
# 5.  produce copy/converted versions for all of the other resolutions
#
# This script is really just an example.  Use it as-is at your own risk.
# You are free to use it or abuse it as you see fit.  No warranty is
# either implied nor provided for its use or abuse.
#
# Yes, it CAN mess up your project.  Make backups.  You have been warned.
#
#
# adaptive icons, for some odd reason, are based on 72x72 within 108x108
# and so the outer part needs to be transparent (basically) with an inner
# part that's actually the correct size.

# adjust these definitions to use the correct tools
MOGRIFY=mogrify-im6
CONVERT=convert-im6
COMPOSITE=composite-im6

# check for parameter, print usage if missing
if test -z "$1" ; then
  echo ""
  echo "usage:  make_icons.sh directoryname"
  echo " where  directoryname is the name of the project directory for the Android project"
  echo ""
  echo "The various files and directories must follow the standard for 'ic_launcher' etc."
  echo ""
  exit
fi

# if 'ic_launcher_orig.png' exists, ask to overwrite.  Otherwise, create it
if test -e "$1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_orig.png" ; then

  yn=""

  while test -z "$yn" ; do
    read -p "Overwrite 'ic_launcher_orig.png' with 'ic_launcher.png'? (N/y) " yn

    if test -z "$yn" ; then
	  yn="N"
    fi
    if test "$yn" = "n" -o "$yn" = "N" ; then
	  break
    fi

    if test "$yn" != "Y" -a "$yn" != "y" ; then
	  echo please enter Y or N
	  yn=""
    else

	  cp -p $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_orig.png

    fi
  done

else

  cp -p $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_orig.png

fi

# run gimp on 'ic_launcher_orig.png'
if test -z "$2" ; then
  gimp $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_orig.png
fi

yn=""

while test -z "$yn" ; do
  read -p "Do you want to continue? (N/y) " yn

  if test -z "$yn" ; then
    yn="N"
  fi
  if test "$yn" = "n" -o "$yn" = "N" ; then
    echo goodbye
    exit
  fi

  if test "$yn" != "Y" -a "$yn" != "y" ; then
    echo please enter Y or N
    yn=""
  fi
done

# step 1: make sure that the edited ic_launcher.png is 192x192 [TODO:  maybe don't need, so comment out]

# ${MOGRIFY} -resize 192x192 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_orig.png

# put a frame on this as 'ic_launcher.png' 192x192 pixels

${CONVERT} -resize 192x192 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_orig.png \
           -mattecolor Red -frame 16x16+16+0 \
           $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# make a 'round frame' version as 'ic_launcher_round.png'
# see https://www.imagemagick.org/discourse-server/viewtopic.php?t=30488

cp -p $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_orig.png /var/tmp/roundie.png

${CONVERT} /var/tmp/roundie.png -alpha on -background none \
           \( +clone -channel A -evaluate multiply 0 +channel -fill white -draw "ellipse 96,96 96,96 0,360" \) \
           \( -clone 0,1 -compose DstOut -composite \) \
           \( -clone 0,1 -compose DstIn -composite \) \
           -delete 0,1 /var/tmp/roundie_round.png

# this last thing creates /var/tmp/roundie_round-0.png and /var/tmp/roundie_round-1.png

# make the thing 176x176 and combine with a 'highlight' and 'shadow' 
${MOGRIFY} -resize 176x176 /var/tmp/roundie_round-1.png

# the shadows are built as 'roundie_round2.png
${CONVERT} /var/tmp/roundie.png -alpha on -background none \
           \( +clone -channel A -evaluate multiply 0 \
           +channel -fill red -draw "translate 90,90 rotate 45 ellipse 0,0 90,96 0,360" \
           +channel -fill brown -draw "translate 102,102 rotate 45 ellipse 0,0 90,96 0,360" \) \
          /var/tmp/roundie_round2.png

# output ends up in roundie_round2-1
# now combine it with roundie_round-1.png to get my round icon

${COMPOSITE} -gravity center /var/tmp/roundie_round-1.png \
             /var/tmp/roundie_round2-1.png \
             $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png

# get rid of the temporary files
rm /var/tmp/roundie.png
rm /var/tmp/roundie_round*.png

# and now I create the other resolutions based on this first one

# NOTE:  web verswion has size of 512x512 'dp', foreground 108x108 'dp',
#        and legacy 48x48 'dp', consistently - how do I set this?

# web version - based on 'orig' version
${CONVERT} -resize 512x512 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_orig.png -alpha on -background none \
           \( +clone -channel A -evaluate multiply 0 +channel \) \
           /var/tmp/transparent_background.png


${CONVERT} -resize 342x342 \
           $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_orig.png \
           /var/tmp/mipmap_foreground.png

${COMPOSITE} -gravity center /var/tmp/mipmap_foreground.png \
             /var/tmp/transparent_background-1.png \
             $1/app/src/main/res/ic_launcher-web.png

for xxx in "xxxhdpi 432 288" "xxhdpi 324 216" "xhdpi 216 144" "hdpi 162 108" "mdpi 108 72" ; do

  dd=`echo $xxx | awk '{print $1;}'`
  xx=`echo $xxx | awk '{print $2;}'`
  yy=`echo $xxx | awk '{print $3;}'`

  # make compatible mask
  ${CONVERT} -resize ${xx}x${xx} $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png -alpha on -background none \
             \( +clone -channel A -evaluate multiply 0 +channel \) \
             /var/tmp/transparent_background.png

  # resize to '72 of 96' because of 'outer slop' requirement
  ${CONVERT} -resize ${yy}x${yy} \
             $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png \
             /var/tmp/mipmap_foreground.png

  ${COMPOSITE} -gravity center /var/tmp/mipmap_foreground.png \
               /var/tmp/transparent_background-1.png \
               $1/app/src/main/res/mipmap-${dd}/ic_launcher_foreground.png

  # same for roundie
  ${CONVERT} -resize ${yy}x${yy} \
             $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png \
             /var/tmp/mipmap_roundround.png

  ${COMPOSITE} -gravity center /var/tmp/mipmap_roundround.png \
               /var/tmp/transparent_background-1.png \
               $1/app/src/main/res/mipmap-${dd}/ic_launcher_roundround.png

  rm /var/tmp/transparent_background*.png
  rm /var/tmp/mipmap_foreground*.png
  rm /var/tmp/mipmap_roundround*.png

done


# the 'legacy' versions
# 144x144 - xxhdpi
${CONVERT} -resize 144x144 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png \
           $1/app/src/main/res/mipmap-xxhdpi/ic_launcher.png

${CONVERT} -resize 144x144 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png \
           $1/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png

# 96x96 - xhdpi
${CONVERT} -resize 96x96 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png \
           $1/app/src/main/res/mipmap-xhdpi/ic_launcher.png

${CONVERT} -resize 96x96 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png \
           $1/app/src/main/res/mipmap-xhdpi/ic_launcher_round.png

# 72x72 - hdpi
${CONVERT} -resize 72x72 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png \
           $1/app/src/main/res/mipmap-hdpi/ic_launcher.png

${CONVERT} -resize 72x72 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png \
           $1/app/src/main/res/mipmap-hdpi/ic_launcher_round.png

# 48x48 - mdpi
${CONVERT} -resize 48x48 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png \
           $1/app/src/main/res/mipmap-mdpi/ic_launcher.png

${CONVERT} -resize 48x48 $1/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png \
           $1/app/src/main/res/mipmap-mdpi/ic_launcher_round.png

# now create the XML files as needed by the project

cat >$1/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml << THINGY1
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
THINGY1

cat >$1/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml << THINGY2
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_roundround"/>
</adaptive-icon>
THINGY2

# TODO:  use a solid background instead of the default one?
cat >$1/app/src/main/res/drawable/ic_launcher_background.xml << THINGY3
<?xml version="1.0" encoding="utf-8"?>
<vector
    android:height="108dp"
    android:width="108dp"
    android:viewportHeight="108"
    android:viewportWidth="108"
    xmlns:android="http://schemas.android.com/apk/res/android">
    <path android:fillColor="#008577"
          android:pathData="M0,0h108v108h-108z"/>
    <path android:fillColor="#00000000" android:pathData="M9,0L9,108"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M19,0L19,108"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M29,0L29,108"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M39,0L39,108"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M49,0L49,108"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M59,0L59,108"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M69,0L69,108"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M79,0L79,108"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M89,0L89,108"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M99,0L99,108"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M0,9L108,9"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M0,19L108,19"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M0,29L108,29"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M0,39L108,39"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M0,49L108,49"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M0,59L108,59"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M0,69L108,69"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M0,79L108,79"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M0,89L108,89"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M0,99L108,99"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M19,29L89,29"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M19,39L89,39"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M19,49L89,49"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M19,59L89,59"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M19,69L89,69"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M19,79L89,79"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M29,19L29,89"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M39,19L39,89"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M49,19L49,89"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M59,19L59,89"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M69,19L69,89"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
    <path android:fillColor="#00000000" android:pathData="M79,19L79,89"
          android:strokeColor="#33FFFFFF" android:strokeWidth="0.8"/>
</vector>
THINGY3

echo "Complete!!"

