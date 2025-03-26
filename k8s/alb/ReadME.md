aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iampolicy.json

eksctl create iamserviceaccount --cluster=eks-workshop --namespace=kube-system --name=aws-load-balancer-controller  --attach-policy-arn=arn:aws:iam::180606272272:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --approve


eksctl  get iamserviceaccount --cluster eksdemo1

choco install kubernetes-helm

## Replace Cluster Name, Region Code, VPC ID, Image Repo Account ID and Region Code  
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eksdemo1 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-0165a396e41e292a3 \
  --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller


# Verify that the controller is installed.
kubectl -n kube-system get deployment 
kubectl -n kube-system get deployment aws-load-balancer-controller
kubectl -n kube-system describe deployment aws-load-balancer-controller


$CLUSTER_NAME = "eks-workshop"
$AWS_REGION = "us-east-1"
