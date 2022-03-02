# Multiple VMs

Example Terraform configs

## Basic

Simple, hardcoded config that creates two VMSS.

Very tidy, and stopped / deleted instances will not get replaced automatically.

Uses a smaller number of linux VMs and a public SSH key resource.

## Intermediate

Uses locals, variables, modules etc. for a more complex configuration.

Notable difference is that the first set is created using a for_each loop on the module to create _x_ number of standalone VMs.
