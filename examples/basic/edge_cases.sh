#!/bin/bash

apt-get install package_a package_z package_x
apt-get remove package_b package_y

apt-get install -f -q package_a package_d
apt-get remove --purge package_b package_c