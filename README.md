# aws-rds-postgres-replica

This is a Nullstone module to create a read-only replica of an existing RDS Postgres cluster.

This read-only replica will be created in the same VPC and subnet group as the source cluster.
AWS does not allow the creation of a read-only replica in a different subnet group.
The only exception is if the replica is created in a different region, which is not supported by this module.

The result of this is:
If the source cluster is in a private subnet, the replica will also be in a private subnet and can not be made public.
And vice versa, if the source cluster is in a public subnet, the replica will also be in a public subnet.

## Security & Compliance

Security scanning is graciously provided by Bridgecrew. Bridgecrew is the leading fully hosted, cloud-native solution providing continuous Terraform security and compliance.

[![Infrastructure Security](https://www.bridgecrew.cloud/badges/github/nullstone-modules/aws-rds-postgres/general)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=nullstone-modules%2Faws-rds-postgres&benchmark=INFRASTRUCTURE+SECURITY)
[![CIS AWS V1.3](https://www.bridgecrew.cloud/badges/github/nullstone-modules/aws-rds-postgres/cis_aws_13)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=nullstone-modules%2Faws-rds-postgres&benchmark=CIS+AWS+V1.3)
[![PCI-DSS V3.2](https://www.bridgecrew.cloud/badges/github/nullstone-modules/aws-rds-postgres/pci)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=nullstone-modules%2Faws-rds-postgres&benchmark=PCI-DSS+V3.2)
[![NIST-800-53](https://www.bridgecrew.cloud/badges/github/nullstone-modules/aws-rds-postgres/nist)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=nullstone-modules%2Faws-rds-postgres&benchmark=NIST-800-53)
[![ISO27001](https://www.bridgecrew.cloud/badges/github/nullstone-modules/aws-rds-postgres/iso)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=nullstone-modules%2Faws-rds-postgres&benchmark=ISO27001)
[![SOC2](https://www.bridgecrew.cloud/badges/github/nullstone-modules/aws-rds-postgres/soc2)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=nullstone-modules%2Faws-rds-postgres&benchmark=SOC2)
[![HIPAA](https://www.bridgecrew.cloud/badges/github/nullstone-modules/aws-rds-postgres/hipaa)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=nullstone-modules%2Faws-rds-postgres&benchmark=HIPAA)
