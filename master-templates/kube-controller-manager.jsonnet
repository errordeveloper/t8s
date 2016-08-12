local build_params(arr) =
  std.flattenArrays(std.filter(function(a) a != null, arr));

function(cfg)
  {
    apiVersion: "v1",
    kind: "Pod",
    metadata: {
      name: "kube-controller-manager",
      namespace: "kube-system",
      labels: {
        tier: "control-plane",
        component: "kube-controller-manager",
      },
    },
    spec: {
      hostNetwork: true,
      containers: [
        {
          name: "kube-controller-manager",
          image: "%(docker_registry)s/%(image_name)s:%(kubernetes_version)s" % cfg.phase2,
          resources: {
            requests: {
              cpu: "200m",
            },
          },
          command: build_params([
            [
              "/hyperkube",
              "controller-manager",
              "--master=127.0.0.1:8080",
              "--cluster-name=" + cfg.phase1.cluster_name,
              "--root-ca-file=/etc/kubernetes/test-pki/ca.pem",
              "--service-account-private-key-file=/etc/kubernetes/test-pki/apiserver-key.pem",
              "--cluster-signing-cert-file=/etc/kubernetes/test-pki/ca.pem",
              "--cluster-signing-key-file=/etc/kubernetes/test-pki/ca-key.pem",
              "--insecure-approve-all-csrs=true",
              "--v=9",
            ],
            if cfg.phase1.cloud_provider == "azure" then
              ["--cloud-config=/etc/kubernetes/azure.json"],
          ]),
          livenessProbe: {
            httpGet: {
              host: "127.0.0.1",
              port: 10252,
              path: "/healthz",
            },
            initialDelaySeconds: 15,
            timeoutSeconds: 15,
          },
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
