# Setup of Debian 9 Virtual Machine

This document describes how to prepare a development system for the course of Manufacturing Automation, academic year 2017--18.

## Prerequisites

1. **Enable virtualization extension**: If your PC is a Mac computer, then you are set and can go straight to the next point. **Otherwise**, you have to turn on the Virtualization Extension (typically called VT-x) on your computer. The way to do that depends on your computer (if it has a BIOS or a UEFI). Google for [enable vt-x in windows 10](https://www.google.it/search?client=safari&rls=en&q=enable+vt-x+in+windows+10&ie=UTF-8&oe=UTF-8&gfe_rd=cr&dcr=0&ei=u3_kWdbOA8es8wfN74S4Bg).
2. **VirtualBox**. Go to [VirtualBox download area](https://www.virtualbox.org/wiki/Downloads) and download the latest version of VirtualBox (platform-specific) and the _VB Extensions pack_ (which is platform independent: click on the link _All supported platforms_). Install VirtualBox and THEN add the extension pack.
3. **Download** Linux Debian 9: <https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.2.1-amd64-netinst.iso>.

## Installation

When creating the virtual machine select the following settings:

- Operating System: Debian 64 bit
- Disk space: >= 10 Gb
- RAM: >= 1024 Mb
- CPU: if your PC has at least 4 cores, select 2 CPUs
- video RAM: 64 Mb, 3D acceleration
- Network: select NAT
- CD: select the virtual disk image you downloaded
- Boot order: ensure that CD comes before HD
- anything else: accept defaults

Just do a plain graphical install. **It is advised to install Debian in English language**. Be aware that for the following instructions to work, you have to be connected to the internet via a network that does not require a proxy. Your private home network and the campus WiFi networks `eduroam` and `unitn-x` should work fine (better than the `unitn` one).

**It is preferable that you perform the following installation connected to the network (either the `unitn-x` WiFi network or your home WiFi).**

1. on boot, select "graphical Install"
2. select English as language
3. select Other->Europe->Italy as location
4. select United States (en_US.UTF8) as locale
5. select your actual keyboard layout
6. freeley choose a host name, and use `dii.unitn.it` as domain
7. **skip the root password field (leave it empty)**
8. freely choose the new user full name (spaces allowed)
9. choose `rnc` as username (short name, case sensitive, single word). You can actually choose different short names, but in the following instructions it will assumed that the user name is `rnc`.
10. choose a reasonably safe password for the user `rnc`
11. select _Guided - use entired disk_ as partitioning method, and accept defaults in the following disk set-up panes
12. wait for the installer copying data to disk
13. when asked whether to use a network mirror or not, choose _yes_
14. select _Italy_, then accept the default mirror
15. leave blank the proxy
16. in _Software selection_ screen, deselect _print server_
17. accept to install GRUB on the master boot record, and select `\dev\sda` as the bootable device
18. wait for the installation to finish and reboot the VM.

Note that VirtualBox allows you to take _snapshots_ of the virtualization system: these are images of an OS at a given time, and can be used to revert to a clean state whenever something goes wrong. It is suggested that you take a snapshot immediately after the first boot, so that you can skip the installation process whenever would you need to start again from scratch.

## Configuration

We will use the Terminal for configuring our system by installing additional components and software. In the following, note that the `$` (Dollar-space) marks the Terminal prompt and it must not be typed, i.e. the commands are represented only by what follows the dollar-space prompt. The hash character (`#`) marks a comment.

From VirtualBox, select the menu _Devices>Install Guest Additions CD Image..._.

In the virtual machine, select _Cancel_ on the prompt window.

Open a Terminal and type the followings (type your password when prompted, accept with `Y` when asked):

```bash
$ sudo apt-get update
$ sudo apt-get install build-essential module-assistant
$ sudo m-a prepare
$ sudo sh /media/cdrom/VBoxLinuxAdditions.run
$ sudo shutdown -h now
```

This is a good moment to take a snapshot.

Next, install full ruby environment and necessary libraries and utilities. You can copy and paste these commands:

```bash
$ sudo apt-get install ruby ruby-dev git clang make gnuplot curl libreadline6-dev libssl-dev zlib1g-dev libglew-dev libglu1-mesa-dev freeglut3-dev ntp
$ sudo gem install pry colorize ffi gnuplotr rake --no-rdoc --no-ri
```
