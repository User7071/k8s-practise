# k8s-practise
Let's try some interesting stuff

1. Create an EKS Cluster with 3 nodes based on ubuntu t3.medium.
2. Spin up pods with:
    a. GitLab
    b. SonarQube
    c. Jenkins
    d. Grafana
    e. influxdb
3. Config persistent storage for pods created in previous step.
4. Upload these two projects to your new created GitLab:
    java: https://github.com/spring-projects/spring-petclinic
    dotnet: https://github.com/blogifierdotnet/Blogifier.git
5. Spin up an ec2 slave for Jenkins and install docker on it
6. Create multistage pipelines for java and dotnet project which would build, test and deploy them to ECS
7. Create deploy manifests for docker images to be deployed to EKS
8. Create deploy pipelines which would aply deploy manifests. BONUS POINTS if you use HELM
9. To ask Dumitru to prepare the rest of the tasks.