EC2 Bringup
===

EC2 bringup for autobootstrapping. Uses chef as the mechanism. Presumes, grotesquely, that all nodes are identical, 
and thus lays the ground for being a cluster Down The Mythical Road.

While the Chef code is grotesque, it is also brutalist, in the sense of architecture: everything's out there 
and dumb and simple and ugly.

The system assumes there's an S3 HTTPS URL that can be downloaded from. A more sophisticated AWS system would install the AWS client and use IAM permissions to lock down the URL. An even more sophisticated one might inject secrets into the environment.  

The chef system is self-updating: a cron job runs every 5 minutes, curls the tarball from s3, and applys chef to the node from that tarball. Updates (Jenkins or otherwise) will do an S3 put of a new tarball edition.
