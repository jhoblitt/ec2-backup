ec2-snapshot
============

A simple script to create and manage snapshots of the EC2 instance upon which
it is executed.

Dependencies
------------

* `bash`
* [`wget`](https://www.gnu.org/software/wget/)
* [`awscli`](https://github.com/aws/aws-cli)
* [`jq`](https://stedolan.github.io/jq/)
* [`ec2-automate-backup-awscli.sh`](https://github.com/colinbjohnson/aws-missing-tools/)

Usage
-----

    export AWS_ACCESS_KEY_ID=<...>
    export AWS_SECRET_ACCESS_KEY=<...>
    export AWS_DEFAULT_REGION=us-east-1

    ./ec2-snapshot.sh
