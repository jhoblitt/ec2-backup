#!/usr/bin/env bash

die() {
  >&2 echo $@
  exit 1
}

vars=(
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  AWS_DEFAULT_REGION
  INSTANCE_ID
)

# lookup ec2 instance-id
INSTANCE_ID=${INSTANCE_ID:-$(wget -q -O- http://169.254.169.254/latest/meta-data/instance-id)}

# check that all required env vars are declared
for v in ${vars[*]}
do
  # it doesn't seem to be possible to check for undefined variables via
  # indirection in bash, the best we can do is check for empty string (which
  # shouldn't be a problem in this case as an empty string can't be used with
  # the aws cli)
  eval check=\$$v
  if [ -z "${check}" ]; then
    die "env var $v is required"
  fi
done

# install the awscli util
virtualenv venv
. venv/bin/activate

pip install -q awscli

# install ec2-automate-backup-awscli.sh
wget --no-clobber --no-verbose "https://raw.githubusercontent.com/colinbjohnson/aws-missing-tools/master/ec2-automate-backup/ec2-automate-backup.sh"
chmod a+x ec2-automate-backup-awscli.sh

# jq
wget --no-clobber --no-verbose https://stedolan.github.io/jq/download/linux64/jq
chmod a+x jq

# lookup volume-ids for our instance-id; assuming only one volume is mounted
VOLUME_ID=$(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=${INSTANCE_ID} | ./jq --raw-output '.Volumes[0].VolumeId')

# snapshot our volume-id
./ec2-automate-backup-awscli.sh -v $VOLUME_ID -k 31 -n
