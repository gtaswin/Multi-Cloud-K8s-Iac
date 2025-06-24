# EKS

resource "aws_eks_cluster" "k8" {
  name    = join("-", [var.resource_group_name, "k8"])
  version = var.kubernetes_version
  vpc_config {
    subnet_ids              = aws_subnet.subnet[*].id
    endpoint_private_access = true
    endpoint_public_access  = false
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = [aws_security_group.bot_sg.id]
  }

  role_arn = aws_iam_role.eks-cluster-role.arn

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]

  tags = {
    Name          = join("-", [var.resource_group_name, "k8"])
    ResourceGroup = var.resource_group_name
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks-cluster-role" {
  name               = join("-", [var.resource_group_name, "eks-cluster-role"])
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role" "node-role" {
  name = join("-", [var.resource_group_name, "eks-node-group-role"])

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role.name
}

# AUTOSCALING
resource "aws_iam_policy" "cluster-autoscaler-policy" {
  name   = join("-", [var.resource_group_name, "cluster-autoscaler-policy"])
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeImages",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster-autoscaler-attachment" {
  policy_arn = aws_iam_policy.cluster-autoscaler-policy.arn
  role       = aws_iam_role.node-role.name
}

# NODEGROUPS
resource "aws_eks_node_group" "default_pool" {
  cluster_name    = aws_eks_cluster.k8.name
  node_group_name = "poolstandard"
  node_role_arn   = aws_iam_role.node-role.arn
  #subnet_ids      = aws_subnet.example[*].id
  subnet_ids = [aws_subnet.subnet[0].id,aws_subnet.nat_gateway.id]

  capacity_type  = "ON_DEMAND"
  instance_types = [var.aks_node_size]
  disk_size      = 50
  labels = {
    "pool" = "agentpool-standard"
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.aws_ssh_key.key_name
    source_security_group_ids = [aws_security_group.bot_sg.id]
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  update_config {
    max_unavailable = 1
  }

  // Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  // Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name          = join("-", [var.resource_group_name, "k8-pool-standard"])
    ResourceGroup = var.resource_group_name
  }
}

resource "aws_eks_node_group" "spot_pool" {
  cluster_name    = aws_eks_cluster.k8.name
  node_group_name = "poolspot"
  node_role_arn   = aws_iam_role.node-role.arn
  #subnet_ids      = aws_subnet.example[*].id
  subnet_ids = aws_subnet.subnet[*].id

  capacity_type  = "SPOT"
  instance_types = [var.aks_node_size_spot]
  disk_size      = var.agent_pool_os_disk_size_gb
  labels = {
    "pool" = "agentpool-spot"
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.aws_ssh_key.key_name
    source_security_group_ids = [aws_security_group.bot_sg.id]
  }

  scaling_config {
    desired_size = var.aks_min_node_count
    max_size     = var.aks_max_node_count
    min_size     = var.aks_min_node_count
  }

  # lifecycle {
  #   ignore_changes = [scaling_config[0].desired_size]
  # }

  update_config {
    max_unavailable = 1
  }

  # taint {
  # key = "spot-no-schedule"
  # value  = "true"
  # effect = "NO_SCHEDULE"
  # }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name          = join("-", [var.resource_group_name, "k8-pool-spot"])
    ResourceGroup = var.resource_group_name
  }
}

data "aws_eks_cluster_auth" "k8s" {
  name = aws_eks_cluster.k8.name
}

resource "local_file" "kubeconfig" {
  depends_on = [aws_eks_cluster.k8]
  filename   = "./kubeconfig"
  content    = <<-EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${aws_eks_cluster.k8.certificate_authority.0.data}
    server: ${aws_eks_cluster.k8.endpoint}
  name: ${aws_eks_cluster.k8.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.k8.name}
    user: ${aws_eks_cluster.k8.name}
  name: ${aws_eks_cluster.k8.name}
current-context: ${aws_eks_cluster.k8.name}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.k8.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - --region
      - ${var.location}
      - eks
      - get-token
      - --cluster-name
      - ${aws_eks_cluster.k8.name}
      - --output
      - json
      command: {{FC_HOME}}/aws/dist/aws
EOF
}

resource "local_file" "aws_credential" {
  depends_on = [aws_eks_cluster.k8]
  filename   = "./aws_credential"
  content    = <<-EOF
[default]
aws_access_key_id = ${var.client_id}
aws_secret_access_key = ${var.client_secret}
EOF
}


resource "local_file" "cluster-autoscaler-deployment" {
  depends_on = [aws_eks_cluster.k8]
  filename   = "./cluster-autoscaler.yaml"
  content    = <<-EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
  name: cluster-autoscaler
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-autoscaler
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
rules:
  - apiGroups: [""]
    resources: ["events", "endpoints"]
    verbs: ["create", "patch"]
  - apiGroups: [""]
    resources: ["pods/eviction"]
    verbs: ["create"]
  - apiGroups: [""]
    resources: ["pods/status"]
    verbs: ["update"]
  - apiGroups: [""]
    resources: ["endpoints"]
    resourceNames: ["cluster-autoscaler"]
    verbs: ["get", "update"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["watch", "list", "get", "update"]
  - apiGroups: [""]
    resources:
      - "namespaces"
      - "pods"
      - "services"
      - "replicationcontrollers"
      - "persistentvolumeclaims"
      - "persistentvolumes"
    verbs: ["watch", "list", "get"]
  - apiGroups: ["extensions"]
    resources: ["replicasets", "daemonsets"]
    verbs: ["watch", "list", "get"]
  - apiGroups: ["policy"]
    resources: ["poddisruptionbudgets"]
    verbs: ["watch", "list"]
  - apiGroups: ["apps"]
    resources: ["statefulsets", "replicasets", "daemonsets"]
    verbs: ["watch", "list", "get"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses", "csinodes", "csidrivers", "csistoragecapacities"]
    verbs: ["watch", "list", "get"]
  - apiGroups: ["batch", "extensions"]
    resources: ["jobs"]
    verbs: ["get", "list", "watch", "patch"]
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["create"]
  - apiGroups: ["coordination.k8s.io"]
    resourceNames: ["cluster-autoscaler"]
    resources: ["leases"]
    verbs: ["get", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create","list","watch"]
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
    verbs: ["delete", "get", "update", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-autoscaler
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-autoscaler
subjects:
  - kind: ServiceAccount
    name: cluster-autoscaler
    namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: cluster-autoscaler
subjects:
  - kind: ServiceAccount
    name: cluster-autoscaler
    namespace: kube-system

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    app: cluster-autoscaler
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '8085'
    spec:
      priorityClassName: system-cluster-critical
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        fsGroup: 65534
        seccompProfile:
          type: RuntimeDefault
      serviceAccountName: cluster-autoscaler
      containers:
        - image: registry.k8s.io/autoscaling/cluster-autoscaler:v1.22.2
          name: cluster-autoscaler
          resources:
            limits:
              cpu: 100m
              memory: 600Mi
            requests:
              cpu: 100m
              memory: 600Mi
          command:
            - ./cluster-autoscaler
            - --v=4
            - --stderrthreshold=info
            - --cloud-provider=aws
            - --skip-nodes-with-local-storage=false
            - --expander=least-waste
            - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${aws_eks_cluster.k8.name}
          volumeMounts:
            - name: ssl-certs
              mountPath: /etc/ssl/certs/ca-certificates.crt #/etc/ssl/certs/ca-bundle.crt for Amazon Linux Worker Nodes
              readOnly: true
          imagePullPolicy: "Always"
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
            readOnlyRootFilesystem: true
      volumes:
        - name: ssl-certs
          hostPath:
            path: "/etc/ssl/certs/ca-bundle.crt"
EOF
}

#resource "null_resource" "kubectl" {
#  depends_on = [aws_eks_cluster.k8]
#  provisioner "local-exec" {
#    command = "aws eks --region ${var.location} update-kubeconfig --name ${aws_eks_cluster.k8.name} --kubeconfig ./kubeconfig"
#  }
#}

# module "eks-kubeconfig" {
#   source  = "hyperbadger/eks-kubeconfig/aws"
#   version = "2.0.0"

#   depends_on = [aws_eks_cluster.k8]
#   cluster_name = aws_eks_cluster.k8.name
# }

# resource "local_file" "kubeconfig" {
#   content  = module.eks-kubeconfig.kubeconfig
#   filename = "kubeconfig"
# }

# data "template_file" "aws" {
#   template = file("aws_credential.tpl")
#   vars = {
#     client_id  = var.client_id
#     client_secret = var.client_secret
#   }
# }

# resource "local_file" "example" {
#   filename = "aws_credential"
#   content  = data.template_file.aws.rendered
# }
