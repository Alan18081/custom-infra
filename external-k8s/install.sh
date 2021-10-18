# Istio install
#kubectl apply -f ./istio/istio-namespace.yml
#kubectl apply -f ./istio/istio-installation.yml
# Install EFS driver
helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.us-east-2.amazonaws.com/eks/aws-efs-csi-driver \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=efs-csi-controller-sa
# Install Kiali dashboard
#helm install kiali ./charts/kiali-server --namespace istio-system --set auth.strategy="anonymous"
# Install Prometheus + Grafana setup
#helm install prometheus ./charts/kube-prometheus-stack --namespace istio-system
# Install Jaeger
#kubectl apply -f ./istio/jaeger.yml

