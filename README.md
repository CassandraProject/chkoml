# chkoml #

### chkoml is a script used to find and close orphaned Foxboro I/A OM list ###

The Motif-style Alarm Display screens tend to leave OM lists opened
when they are closed as well as DM screens that crash or are not closed
down properly. Using som, one can see multiple OM lists with
2 objects in them, like this:

000 ALMSTATE04WP01                   Y    -01 000 00000001  0F24:FD10
    Scanning    0026                 L  Y -01 -1 0000000003 0000 0000
001 ALMCNT04WP01                     Y    -01 001 00000001  0F24:FD30
    Scanning    0026                 L  Y -01 -1 0000003043 0000 0000

Eventually, the accumulation of these orphaned lists results in non-
connected data (displayed as cyan) on graphics and overlays. The
only fix is rebooting the WP, with the resulting loss of display
capability for an entire operating seat for several minutes.

The subject of orphaned OM lists came up on the foxboro discussion
list, and [Jeremy Milum]](http://github.com/jmilum) contributed a C program,
[close_list](http://github.com/CassandraProject/close_list), that can be used
to close OM lists, as well as his shell script, check_lists.sh, that detects
the orphaned OM lists. This script is a derivation of his work with 
more ease-of-use features added.

This script file can be used to selectively delete the orphaned OM
lists left behind by long-gone Alarm Display screens, thereby
enhancing the performance of the Sun workstation without having to
resort to rebooting it.

## Dependencies ##

[close_list](http://github.com/CassandraProject/close_list) is required

You can get that by cloning the repo from GitHub:

    git clone git://github.com/CassandraProject/close_list.git

## Installation ##

Cloning the repo from GitHub:

    git clone git://github.com/CassandraProject/chkoml.git

## Command line operation ##

The invocation of the program is:

    ./chkoml   -aodxvh

* -a: display all OM lists
* -o: display orphaned lists
* -d: delete CAD-related orphaned lists
* -x: delete all orphaned lists
* -v: verbose mode, used with -d and -x
* -h: show this help prompt
    
## Contributing ##

Contributions to chkoml are welcome.

## Thanks ##

The following people have contributed patches to close_list - thanks!

* [Duc Do](duc@thedos.org)
* [Jeremy Milum](http://github.com/jmilum)
