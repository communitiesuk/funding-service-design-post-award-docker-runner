#!/bin/bash

awslocal s3api \
create-bucket --bucket data-store-failed-files-test \
--create-bucket-configuration LocationConstraint=eu-central-1 \
--region eu-central-1

awslocal s3api \
create-bucket --bucket data-store-file-assets-test \
--create-bucket-configuration LocationConstraint=eu-central-1 \
--region eu-central-1

 aws s3 cp /tmp/example-template.xlsx s3://data-store-file-assets-test \
--endpoint-url http://localhost:4566

 aws s3 cp /tmp/example-total-grant-awarded s3://data-store-file-assets-test \
--endpoint-url http://localhost:4566