gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-a

gcloud compute disks create --size=200GB --zone=us-west1-a nfs-disk
gcloud container clusters create torchserve --machine-type n1-standard-8 --num-nodes 1
gcloud container clusters get-credentials torchserve
cd GKE
helm install mynfs ./nfs-provisioner/

kubectl get svc -n default mynfs-nfs-provisioner -o jsonpath='{.spec.clusterIP}'
# Copy it the ip address over, and then...

kubectl apply -f templates/pv_pvc.yaml -n default
kubectl apply -f templates/pod.yaml

kubectl exec --tty pod/model-store-pod -- mkdir /pv/model-store/
kubectl cp ./trocr-handwritten.mar model-store-pod:/pv/model-store/trocr-handwritten.mar

kubectl exec --tty pod/model-store-pod -- mkdir /pv/config/
kubectl cp ./config.properties model-store-pod:/pv/config/config.properties

kubectl exec --tty pod/model-store-pod -- ls -lR /pv/
kubectl delete po model-store-pod

cd ../Helm
helm install ts .