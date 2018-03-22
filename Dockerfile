FROM alpine:3.7

ARG BACKUP_SCRIPT_URL='https://raw.githubusercontent.com/lsst-sqre/aws-missing-tools/master/ec2-automate-backup/ec2-automate-backup.sh'
ARG BACKUP_SCRIPT='/usr/local/bin/ec2-automate-backup.sh'
ARG RUN_SCRIPT='/usr/local/bin/ec2-snapshot.sh'

ARG AWS_DEFAULT_REGION=us-east-1
ARG AWSCLI_VER=1.14.61

# need gnu date from coreutils
RUN apk add --no-cache --update \
    python3 \
    bash \
    wget \
    ca-certificates \
    jq \
    coreutils && \
    rm -rf /root/.cache

RUN pip3 install awscli=="${AWSCLI_VER}" --upgrade --no-cache-dir && \
    rm -rf /root/.cache

RUN wget --no-verbose "$BACKUP_SCRIPT_URL" -O "$BACKUP_SCRIPT" && \
    chmod a+x "$BACKUP_SCRIPT"

COPY ec2-snapshot.sh "$RUN_SCRIPT"
RUN chmod a+x "$RUN_SCRIPT"
