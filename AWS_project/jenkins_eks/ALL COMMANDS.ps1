eksctl create cluster --name myekscluster7 --region eu-central-1 --managed --nodegroup-name eks-node-1 --nodes 3 --instance-types=t3.medium

#Check if EKS was built successfully 
kubectl get svc

#GET VPC ID
aws ec2 describe-vpcs
#vpc-0083c44297c653a77

#Create a security group to mount EFS
aws ec2 create-security-group --region eu-central-1 --group-name 7-mount-efs `
--description "Amazon EFS for EKS, SG for mount target" `
--vpc-id vpc-0083c44297c653a77    
#sg-052c4a94e48308af7

#Open Inbound rule for EFS
aws ec2 authorize-security-group-ingress `
--group-id sg-052c4a94e48308af7 `
--region eu-central-1 `
--protocol tcp `
--port 2049 `
--cidr 192.168.0.0/16
#SECURITYGROUPRULES      192.168.0.0/16  2049    sg-052c4a94e48308af7    315727832121    tcp     False   sgr-0ae8777f96777eb6f   2049

#Create EFS
aws efs create-file-system `
--creation-token creation-token `
--performance-mode generalPurpose `
--throughput-mode bursting `
--region eu-central-1 `
--tags Key=Name,Value=MyEFSFileSystem Key=Owner,Value=dkolegaev Key=Discipline,Value=AM Key=Purpose,Value=Practicing_in_EKS `
--encrypted
#2022-01-10T15:06:49+02:00       creation-token  True    arn:aws:elasticfilesystem:eu-central-1:315727832121:file-system/fs-03dec83515397e0d6    
#fs-03dec83515397e0d6    arn:aws:kms:eu-central-1:315727832121:key/1ee769bb-efbb-488e-8394-4b2966c62e3f  creating       
#MyEFSFileSystem 0       315727832121    generalPurpose  bursti

#Find subnet ID of my VPC
aws ec2 describe-instances --filters Name=vpc-id,Values=vpc-0083c44297c653a77 --query 'Reservations[*].Instances[].SubnetId'
#subnet-01964fc39fe824e3b        subnet-0718765131f3e7b69        subnet-02fe3bf17fa2d6e82

#Create mount target for EFS. CWe can create a target for one subnet for all EC2 instances we have. The instances should be run in the same VPC
aws efs create-mount-target `
--file-system-id fs-03dec83515397e0d6 `
--subnet-id subnet-01964fc39fe824e3b `
--security-group sg-052c4a94e48308af7 `
--region eu-central-1
#euc1-az2        eu-central-1a   fs-03dec83515397e0d6    192.168.75.68   creating        
#fsmt-0d86f866e48726d44  eni-0f7abc2d1c73a092b   315727832121    subnet-01964fc39fe824e3b        vpc-0083c44297c653a77

#Create an Amazon EFS access point
aws efs create-access-point --file-system-id fs-03dec83515397e0d6 `
--posix-user Uid=1000,Gid=1000 `
--root-directory "Path=/jenkins,CreationInfo={OwnerUid=1000,OwnerGid=1000,Permissions=777}"
#arn:aws:elasticfilesystem:eu-central-1:315727832121:access-point/fsap-0dc4a1b15b9019c83 fsap-0dc4a1b15b9019c83  e78ef547-3c27-4685-9a62-94d1133b668c    
#fs-03dec83515397e0d6    creating        315727832121
#POSIXUSER       1000    1000
#ROOTDIRECTORY   /jenkins
#CREATIONINFO    1000    1000    777
___________________________________________________________________

#Deploy the Amazon EFS CSI driver to your Amazon EKS cluster
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"


helm repo add stable https://charts.helm.sh/stable

helm install jenkins jenkinsci/jenkins --set rbac.create=true,controller.servicePort=80,controller.serviceType=LoadBalancer,persistence.existingClaim=efs-claim

printf $(kubectl get service jenkins -o jsonpath="{.status.loadBalancer.ingress[].hostname}");echo

printf $(kubectl get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
#Password=YNLuIDTnRhpszEYLuGWBaa