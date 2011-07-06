# VEGAS

Vegas is a virtual file system implemented via FUSE.  It is a project intended
to test the application of REST system archetecture to a virtual file system for
a POSIX environment.

## Team Members

* [Lou Scoras](http://github.com/ljsc)
* [Catalino Cuadrado](http://github.com/ccuadrado)

## Dependancies

Vegas requires both Ruby and Fuse to run. It has been tested on Mac OS X with MacFUSE.

You can install ruby by downloading the source code for [ruby 1.8.7](http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p352.tar.gz).

MacFUSE can be downloaded [here](http://code.google.com/p/macfuse/downloads/detail?name=MacFUSE-2.0.3%2C2.dmg&can=2&q=).

## Installation

There is no install procedure for Vegas at this time, but you can run it directly out of the source directory.

First, ensure that you have bundler installed:

    $ gem install bundler

All other ruby depenencies can then be installed with the bundle command.

    $ bundle install

## Running

In depth instructions are available in the project document, but in short, you first create the directory you want to mount vegas to

    $ mkdir t

then mount it with the vegas script:

    $ ruby -Ilib bin/vegas mount t

You can then access the system through the normal command line tools:

    $ cat t/user/agentjose1.txt

