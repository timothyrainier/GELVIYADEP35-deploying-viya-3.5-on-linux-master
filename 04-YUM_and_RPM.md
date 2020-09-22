# YUM and RPM

* [Are there any packages that can be updated?](#are-there-any-packages-that-can-be-updated)
* [Install a new package with YUM](#install-a-new-package-with-yum)
* [RPM](#rpm)

These exercises are there to familiarize you with some simple yum-related commands. You only need to run these on the SASVIYA01 machine. If you wanted to do the same thing on all machines, you could use MobaXterm's Multi-Exec feature to do it faster.

## Are there any packages that can be updated?

1. Check to see if any packages need updated.

    ```bash
    sudo yum check-update
    ```

2. If you want to update all updatable packages:

    ```bash
    sudo yum update -y
    ```

3. This can take a while to complete.

## Install a new package with YUM

1. Run the following commands, and answer "y" when prompted:

    ```bash
    sudo yum install tmux
    ```

1. Now that tmux is installed, let's see which files make up this package:

    ```bash
    sudo rpm -ql tmux
    ```

    ```log
    #Output
    /usr/bin/tmux
    /usr/share/doc/tmux-1.8
    /usr/share/doc/tmux-1.8/CHANGES
    /usr/share/doc/tmux-1.8/FAQ
    /usr/share/doc/tmux-1.8/TODO
    /usr/share/doc/tmux-1.8/examples
    /usr/share/doc/tmux-1.8/examples/bash_completion_tmux.sh
    /usr/share/doc/tmux-1.8/examples/h-boetes.conf
    /usr/share/doc/tmux-1.8/examples/n-marriott.conf
    /usr/share/doc/tmux-1.8/examples/screen-keys.conf
    /usr/share/doc/tmux-1.8/examples/t-williams.conf
    /usr/share/doc/tmux-1.8/examples/tmux.vim
    /usr/share/doc/tmux-1.8/examples/tmux_backup.sh
    /usr/share/doc/tmux-1.8/examples/vim-keys.conf
    /usr/share/man/man1/tmux.1.gz
    ```

1. If we had to uninstall it, we could run:

    ``` bash
    sudo yum remove -y tmux
    ```

1. Ok, great, now you removed it. Can you guess how to add it back?

______________

## RPM

1. Confirm that tmux was installed and which version.

    ```bash
    sudo rpm -qa | grep tmux
    ```

    ```log
    #Output
    tmux-1.8-4.el7.x86_64
    ```

2. Get detailed info on this package

    ```bash
    rpm -qi tmux
    ```

    ```log
    #output

    Name          : tmux
    Version       : 1.8
    Release       : 4.el7
    Architecture  : x86_64
    Install Date: : Thu 15 Feb 2018 03:08:03 PM EST
    Group         : Applications/System
    Size          : 571839
    License       : ISC and BSD
    Signature     : RSA/SHA256, Wed 02 Apr 2014 05:25:30 PM EDT, Key ID 199e2f91fd431d51
    Source RPM    : tmux-1.8-4.el7.src.rpm
    Build Date    : Mon 27 Jan 2014 11:31:03 AM EST
    Build Host    : x86-020.build.eng.bos.redhat.com
    Relocations   : (not relocatable)
    Packager      : Red Hat, Inc. <http://bugzilla.redhat.com/bugzilla>
    Vendor        : Red Hat, Inc.
    URL           : http://sourceforge.net/projects/tmux
    Summary       : A terminal multiplexer
    Description   : tmux is a "terminal multiplexer."  It enables a number of terminals (or windows) to be accessed and controlled from a single terminal.  tmux is intended to be a simple, modern, BSD-licensed alternative to programs such as GNU Screen.
    ```
