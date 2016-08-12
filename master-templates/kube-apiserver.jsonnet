local build_params(arr) =
  std.flattenArrays(std.filter(function(a) a != null, arr));

function(cfg)
  {
    apiVersion: "v1",
    kind: "Pod",
    metadata: {
      name: "kube-apiserver",
      namespace: "kube-system",
      labels: {
        tier: "control-plane",
        component: "kube-apiserver",
      },
    },
    spec: {
      hostNetwork: true,
      containers: [
        {
          name: "kube-apiserver",
          image: "%(docker_registry)s/%(image_name)s:%(kubernetes_version)s" % cfg.phase2,
          resources: {
            requests: {
              cpu: "250m",
            },
          },
          command: build_params([
            [
              "/hyperkube",
              "apiserver",
              "--address=127.0.0.1",
              "--etcd-servers=http://127.0.0.1:2379",
              "--cloud-provider=%s" % cfg.phase1.cloud_provider,
              "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,ResourceQuota",
              "--service-cluster-ip-range=%s" % cfg.phase2.service_cluster_ip_range,
              "--service-account-key-file=/etc/kubernetes/test-pki/apiserver-key.pem",
              "--client-ca-file=/etc/kubernetes/test-pki/ca.pem",
              "--tls-cert-file=/etc/kubernetes/test-pki/apiserver.pem",
              "--tls-private-key-file=/etc/kubernetes/test-pki/apiserver-key.pem",
              "--token-auth-file=/etc/kubernetes/tokens",
              "--secure-port=443",
              "--allow-privileged",
              "--v=4",
            ],
            if cfg.phase1.cloud_provider == "azure" then
              ["--cloud-config=/etc/kubernetes/azure.json"],
          ]),
          livenessProbe: {
            httpGet: {
              host: "127.0.0.1",
              port: 8080,
              path: "/healthz",
            },
            initialDelaySeconds: 15,
            timeoutSeconds: 15,
          },
          ports: [
            {
              name: "https",
              containerPort: 443,
              hostPort: 443,
            },
            {
              name: "local",
              containerPort: 8080,
              hostPort: 8080,
            },
          ],
          volumeMounts: [
            /*
            {
              name: "srvkube",
              mountPath: "/srv/kubernetes",
              readOnly: true,
            },
            {
              name: "etckube",
              mountPath: "/etc/kubernetes",
              readOnly: true,
            },
            */
            {
              name: "etcssl",
              mountPath: "/etc/ssl",
              readOnly: true,
            },
          ],
        },
      ],
      volumes: [
        /*
        {
          name: "srvkube",
          hostPath: {
            path: "/srv/kubernetes",
          },
        },
        {
          name: "etckube",
          hostPath: {
            path: "/etc/kubernetes",
          },
        },
        */
        {
          name: "etcssl",
          hostPath: {
            path: "/etc/ssl",
          },
        },
      ],
    },
  }
