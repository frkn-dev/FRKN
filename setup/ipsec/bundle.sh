#!/bin/bash
#
# Script for automatic setup of an IPsec VPN server on Ubuntu and Debian
#
# DO NOT RUN THIS SCRIPT ON YOUR PC OR MAC!
#
# Copyright (C) 2022 Kira 2pizza Sotnikoff <the2pizza@proton.me> 
# Based on the work of Lin Song <linsongui@gmail.com> (Copyright 2014-2022)
# Based on the work of Thomas Sarlandie (Copyright 2012)
#
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
# Unported License: http://creativecommons.org/licenses/by-sa/3.0/
#

VERSION=$(cat ../../VERSION.txt)
NAME=fuckrkn1-ipsec

TMP="./build"

mkdir -p $TMP

cp extras/*.sh $TMP
cp install-ubuntu.sh $TMP

mv $TMP/ikev2setup.sh $TMP/ikev2.sh

tar -czf ${NAME}-${VERSION}.tar.gz ${TMP}

