#!/bin/bash

awslocal s3api \
create-bucket --bucket data-store-failed-files-dev \
--create-bucket-configuration LocationConstraint=eu-central-1 \
--region eu-central-1

awslocal s3api \
create-bucket --bucket data-store-file-assets-dev \
--create-bucket-configuration LocationConstraint=eu-central-1 \
--region eu-central-1

 aws s3 cp /tmp/example-template.xlsx s3://data-store-file-assets-dev \
--endpoint-url http://localhost:4566

 aws s3 cp /tmp/example-total-grant-awarded.xlsx s3://data-store-file-assets-dev \
--endpoint-url http://localhost:4566
 aws s3 cp /tmp/TD-grant-awarded.csv s3://data-store-file-assets-dev \
--endpoint-url http://localhost:4566
 aws s3 cp /tmp/HS-grant-awarded.csv s3://data-store-file-assets-dev \
--endpoint-url http://localhost:4566