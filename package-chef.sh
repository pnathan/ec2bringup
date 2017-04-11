#!/bin/bash -e

cd chef
tar cvzf ../udr.tgz .
cd ..
aws s3 cp udr.tgz s3://upside-down-research/chef/udr.tgz --grants 'read=uri=http://acs.amazonaws.com/groups/global/AllUsers'
