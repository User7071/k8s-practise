aws eks --region eu-central-1 update-kubeconfig --name myekscluster7

printf $(kubectl get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo

$MYTEXT = 'kubectl get secret jenkins -o jsonpath="{.data.jenkins-admin-password}'
$DECODED = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($MYTEXT))
Write-Output $DECODED



