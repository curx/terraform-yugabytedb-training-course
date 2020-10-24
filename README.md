# a terraform for using the YugabyteDB Fundamentals Training

This is only a simple lab for spawn up some virtual machines for my training with [YugabyteDB](https://www.yugabyte.com/)

Make sure you have a working terraform environment, for further reference or a guide take a look at the [install instructions](https://learn.hashicorp.com/tutorials/terraform/install-cli). This project requires terraform >= v0.13.

Currently cloud provider [Hetzner](https://www.hetzner.com/cloud) is used for this Lab - maybe the instuctions can be used for others.

## Setup

This lab follow the [yugabyteDB training guide](https://github.com/yugabyte/yugabyte-db/wiki/YugabyteDB-Fundamentals-Training-Preparation-and-FAQ).
As OS Ubuntu 18.04 LTS is used here.

Tools used for this Lab:
- [terraform](https://terraform.io) `mandatory`
- [direnv](https://direnv.net/) `optional`
 
```bash
# set HetznerCloud API token,
# or use the direnv .envrc file to setup some vars
export HCLOUD_TOKEN=<value>

# init, get all terrafrom provider
terrafrom init hetzner

# check and get the plan
terraform plan <opts>

# start the deploy process, takes some minutes 
terraform apply <opts>

# log in for playing around, e.g. for the first node
ssh -l root $(terraform output -json | jq -r '.nodes_ip.value[0]' )
```

## Contributing

Fork -> Patch -> Push -> Pull Request

## Authors

* [Thorsten Schifferdecker](https://github.com/curx)

## License

Apache-2.0

## Copyright

```console
Copyright (c) 2020 Thorsten Schifferdecker <ts@systs.org>
```
