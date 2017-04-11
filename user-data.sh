#!/bin/bash -x

# install chef.
cd /tmp/
curl -O https://opscode-omnibus-packages.s3.amazonaws.com/debian/8/x86_64/chefdk_0.11.2-1_amd64.deb
dpkg -i chefdk_0.11.2-1_amd64.deb
# check the SHA1 of this deb. It should be 670e85e0598626947030cb013e4be723d4de1870
mkdir -p /opt/udr/chef/
cd  /opt/udr/chef/
curl -O upside-down-research.s3-website-us-west-2.amazonaws.com/chef/udr.tgz
tar xzf udr.tgz
# we claim a recipe called cluster exists and is convergable.
chef-client -z -o cluster
