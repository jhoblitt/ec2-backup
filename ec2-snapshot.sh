#!/usr/bin/env bash

die() {
  >&2 echo "$@"
  exit 1
}

vars=(
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  INSTANCE_ID
  REGION
)

# install jq
if [[ ! -e jq ]]; then
    wget --no-clobber --no-verbose 'https://stedolan.github.io/jq/download/linux64/jq'
    chmod a+x jq
fi

# lookup ec2 instance-id
INSTANCE_ID=${INSTANCE_ID:-$(wget -q -O- 'http://169.254.169.254/latest/meta-data/instance-id')}

# lookup ec2 region
REGION=${REGION:-$(wget -q -O- 'http://169.254.169.254/latest/dynamic/instance-identity/document' | ./jq --raw-output '.region')}

# check that all required env vars are declared
for v in ${vars[*]}
do
  # it doesn't seem to be possible to check for undefined variables via
  # indirection in bash, the best we can do is check for empty string (which
  # shouldn't be a problem in this case as an empty string can't be used with
  # the aws cli)
  if [[ -z ${!v} ]]; then
    die "env var $v is required"
  fi
done

# install the awscli util
if [[ ! -e venv/bin/activate ]]; then
    virtualenv venv
fi

. venv/bin/activate

pip install -q awscli

# install ec2-automate-backup-awscli.sh
# per https://github.com/colinbjohnson/aws-missing-tools/issues/106
# this script was renamed to ec2-automate-backup.sh
# XXX pinning to the commit sha
BACKUP_SCRIPT="ec2-automate-backup.sh"
wget --no-clobber --no-verbose "https://raw.githubusercontent.com/colinbjohnson/aws-missing-tools/1b6cd230dde529f3bf4c19ea80fccdf42e479dae/ec2-automate-backup/${BACKUP_SCRIPT}"
chmod a+x "$BACKUP_SCRIPT"

# lookup volume-ids for our instance-id; assuming only one volume is mounted
VOLUME_ID="$(aws ec2 describe-volumes --region "$REGION" --filters Name=attachment.instance-id,Values="${INSTANCE_ID}" | ./jq --raw-output '.Volumes[0].VolumeId')"

# option snapshot our volume-id

# XXX for unknown reasons, ec2-automate-backup.sh defaults to EC2_REGION
# instead of AWS_DEFAULT_REGION -- so we are setting it an exclitly as a cli
# option
"./${BACKUP_SCRIPT}" -v "$VOLUME_ID" -r "$REGION" -k 91d -n -p
