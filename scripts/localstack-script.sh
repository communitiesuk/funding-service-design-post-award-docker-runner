awslocal s3api \
create-bucket --bucket fmd-data-extract \
--create-bucket-configuration LocationConstraint=eu-central-1 \
--region eu-central-1