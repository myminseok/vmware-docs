#!/bin/bash

helm list -n avi-system
target=$(helm list -n avi-system -o yaml | grep "name:" | cut -d ":" -f 2)
echo $target
helm uninstall -n avi-system $target
