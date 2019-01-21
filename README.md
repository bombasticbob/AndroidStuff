# AndroidStuff

Android-related files and projects

* MessageBox.java - this is a sample 'Message Box' API that will do what it says on the tin;
that is, it will display a simple message box to which the user must respond before the
function returns.  The return value of the function (for Yes/No anyway) indicates which
button was pressed.

* SkButton.java - this implements a button class that can be placed in the layout, which is
re-drawn a bit using 3D Skeuomorphic 'press' indications, similar to what you would normally
expect in a desktop application that pre-dates Windows &quot;Ape&quot; (8).

* make_icons.sh - A sample shell script that might be useful for creating a set of
icon files needed for a typical Android project.  What this does differently, however,
is to add 3D-looking borders to the icons.  It appears to work properly for Android 8 and
the round icons as well, though I have not tested it on 9.<br>
Warning:  use this at your own risk.  back things up beforehand, it overwrites project
files that use standard names.  Try it out on a bare-bones project first, if you want
to see how well it will work for you.<br>
Requires 'ImageMagick' utilities.


Others to be added at a later date.

