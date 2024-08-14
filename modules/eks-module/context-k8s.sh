#!/bin/bash
aws eks update-kubeconfig --region us-east-1 --name "${var.eks_name}" 
#aws eks update-kubeconfig --name eks-eks-cluster --region us-east-1 --profile eks-admin