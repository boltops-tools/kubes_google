gke = KubesGoogle::Gke.new(
  cluster_name: KubesGoogle.config.gke.cluster_name,
  google_region: KubesGoogle.config.gke.google_region,
  google_project: KubesGoogle.config.gke.google_project,
  enable_get_credentials: KubesGoogle.config.gke.enable_get_credentials,
  whitelist_ip: KubesGoogle.config.gke.whitelist_ip,
)

before("apply",
  label: "gke get-credentials hook",
  execute: gke.method(:get_credentials).to_proc,
) if gke.get_credentials_enabled?

before("apply",
  label: "gke whitelist hook",
  execute: gke.method(:allow).to_proc,
) if gke.enabled?

after("apply",
  label: "gke whitelist hook",
  execute: gke.method(:deny).to_proc,
) if gke.enabled?
