# Deploys a Wowza Linux VM configured with mounted Azure Blob Storage


This Terraform module deploys a Wowza Linux VM, initializes it using Cloud-int for [cloud-init-enabled virtual machine images](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init), and returns the id of the VM deployed.  

This module requires .

Visit [this website](http://cloudinit.readthedocs.io/en/latest/index.html) for more information about cloud-init. Some quick tips:
- Troubleshoot logging via `/var/log/cloud-init.log`
- Relevant applied cloud configuration information can be found in the `/var/lib/cloud/instance` directory
- By default this module will create a new txt file `/tmp/terraformtest` to validate if cloud-init worked

To override the cloud-init configuration, place a file called `cloudconfig.tpl` in the root of the module directory with the cloud-init contents or update the `cloudconfig_file` variable with the location of the file containing the desired configuration.

## Usage

```hcl
provider "azurerm" {
  version = "~> 1.0"
}

variable "resource_group_name" {
  default = "terraform-vmss-cloudinit"
}

variable "location" {
  default = "eastus"
}

module "network" {
  source              = "Azure/network/azurerm"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

module "loadbalancer" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  prefix              = "terraform-test"

  "remote_port" {
    ssh = ["Tcp", "22"]
  }

  "lb_port" {
    http = ["80", "Tcp", "80"]
  }
}

module "wowza" {
  source                                 = "github.com/hmcts/tf-azure-wowza"
  service_name
  admin_ssh_key_path
  service_certificate_kv_url
  service_certificate_thumbprint
  key_vault_id
  cloud_init_file
}

output "vmss_id" {
  value = "${module.vmss-cloudinit.vmss_id}"
}
```

## Test

### Configurations

- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)
- [Generate and add SSH Key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) Save the key in ~/.ssh/id_rsa.  This is not required for Windows deployments.

We provide 2 ways to build, run, and test the module on a local development machine.  [Native (Mac/Linux)](#native-maclinux) or [Docker](#docker).

### Native (Mac/Linux)

#### Prerequisites

- [Ruby **(~> 2.3)**](https://www.ruby-lang.org/en/downloads/)
- [Bundler **(~> 1.15)**](https://bundler.io/)
- [Terraform **(~> 0.12.20)**](https://www.terraform.io/downloads.html)
- [Golang **(~> 1.10.3)**](https://golang.org/dl/)

#### Quick Run

We provide simple script to quickly set up module development environment:

```sh
$ curl -sSL https://raw.githubusercontent.com/Azure/terramodtest/master/tool/env_setup.sh | sudo bash
```

Then simply run it in local shell:

```sh
$ cd $GOPATH/src/{directory_name}/
$ bundle install
$ rake build
$ rake e2e
```

### Docker

We provide a Dockerfile to build a new image based `FROM` the `microsoft/terraform-test` Docker hub image which adds additional tools / packages specific for this module (see Custom Image section).  Alternatively use only the `microsoft/terraform-test` Docker hub image [by using these instructions](https://github.com/Azure/terraform-test).

#### Prerequisites

- [Docker](https://www.docker.com/community-edition#/download)

#### Custom Image

This builds the custom image:

```sh
$ docker build --build-arg BUILD_ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID --build-arg BUILD_ARM_CLIENT_ID=$ARM_CLIENT_ID --build-arg BUILD_ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET --build-arg BUILD_ARM_TENANT_ID=$ARM_TENANT_ID -t vh-wowza .
```

This runs the build and unit tests:

```sh
$ docker run --rm vh-wowza /bin/bash -c "bundle install && rake build"
```

This runs the end to end tests:

```sh
$ docker run --rm vh-wowza /bin/bash -c "bundle install && rake e2e"
```

This runs the full tests:

```sh
$ docker run --rm vh-wowza /bin/bash -c "bundle install && rake full"
```

## Authors

Originally created by [Ryan Bartram](http://github.com/rdbartram)

## License

[MIT](LICENSE)
