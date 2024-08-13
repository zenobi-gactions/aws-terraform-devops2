#!/bin/bash

aws eks update-kubeconfig --name "${var.eks_name}" --region us-east-1
#aws eks update-kubeconfig --name eks-eks-cluster --region us-east-1 --profile eks-admin