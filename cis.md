
# how to run cis benchmark or STIG os benchmark against TKGs or TKGm

https://github.com/dev-sec/cis-kubernetes-benchmark
https://github.com/inspec/inspec

## prerequistes: environment layout

Jumpbox VM  --(ssh) --> one of SV controlplane VM

### if Jumpbox cannot access to SV VM, then use BASTION VM
Jumpbox VM  --(ssh) --> BASTION VM --(ssh) --> one of SV controlplane VM


### install inspec on Jumpbox
```
curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec

```
### ssh into SV CPVM and BASTION VM and copy the id_rsa.pub key from the Jumpbox 
  ~/.ssh/authorised_keys


## cis k8s inspec execution on Jumpbox
### with inspec runnable
```
git clone <cis-k8s-inspec>

inspec exec cis-k8s-inspec \
      --sudo \
      --bastion-host=BASTION-IP \
      --bastion-user=ubuntu \
      -t ssh://root@10.213.70.48 \
      -i "/Path/To/ssh_private_key" \
      --reporter=cli "json:/Path/To/svcontrol-cis-results-48.json" \
      --show-progress --log-level=debug

```

### with docker
```
# ls -al
# cis-k8s-inspec
# SC2__haas-488__private_environment.txt

docker pull chef/inspec

docker run -it --rm -v $(pwd):/share chef/inspec \
exec cis-k8s-inspec --sudo --bastion-host=ubuntu-488.haas-488.pez.vmware.com --bastion-user=ubuntu -t ssh://root@10.213.70.48 -i "/share/SC2__haas-488__private_environment.txt" --reporter=cli "json:/share/svcontrol-cis-results-48-docker.json" --show-progress --log-level=debug

```

## STIG OS inspec execution on Jumpbox

### with inspec executable.

```
git clone <photon-3-stig-inspec-baseline>


inspec exec photon-3-stig-inspec-baseline \
      -t ssh://root@10.213.70.48 \
      --bastion-host=ubuntu-488.haas-488.pez.vmware.com \
      --bastion-user=ubuntu \
      -i "/Users/minseok/_dev/tanzu-main/cis-benchmark-on-pez/SC2__haas-488__private_environment.txt" \
      --reporter=cli "json:/Users/minseok/_dev/tanzu-main/cis-benchmark-on-pez/svcontrol-cis-results-photon-48.json" --log-level=debug

