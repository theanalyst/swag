# README

Terraform swag to bring up a tiny ceph cluster 

## First steps

From your openstack cloud provider, download your openrc file and source in your env. Then create a file called myvars.tfvars for eg 

```
image_name=myimage
deploy_key="ssh-rsa <my-public-key>""

```


 and then launching terraform with 
 
```sh

$ terraform plan -var-file=myvars.tfvars # Plan to see how things look like
$ terraform apply -var-file=myvars.tfvars
```


For multiple ssh-keys, we use cloud-init, create a file with ssh-keys.yml with
content similar to 

```yml
ssh_authorized_keys:
  - ssh-rsa asdghsgh foo@bar
  - ssh-rsa asdgxasdh bar@baz
```
