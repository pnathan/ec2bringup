EC2 Bringup
===

EC2 bringup for autobootstrapping. Uses chef as the mechanism. Presumes, grotesquely, that all nodes are identical, 
and thus lays the ground for being a cluster Down The Mythical Road.

While the Chef code is grotesque, it is also brutalist, in the sense of architecture: everything's out there 
and dumb and simple and ugly.

The system assumes there's an S3 HTTPS URL that can be downloaded from. A more sophisticated AWS system would install the AWS client and use IAM permissions to lock down the URL. An even more sophisticated one might inject secrets into the environment.  

The chef system is self-updating: a cron job runs every 5 minutes, curls the tarball from s3, and applys chef to the node from that tarball. Updates (Jenkins or otherwise) will do an S3 put of a new tarball edition.

downsides
===
this is largely vacuumed out of my own management code, so the observer will see that `chef/cookbooks/cluster/recipes/default.rb` has the code that drives pnathan.com, along some commented out code to do a nginx reverse proxy (something very useful if you have docker containers running on your system)! You can use this as an example for your own work!
