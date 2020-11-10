gke = KubesGoogle::Gke.new(
  name: KubesGoogle.config.gke.cluster_name,
  whitelist_ip: KubesGoogle.config.gke.whitelist_ip,
)

before("apply",
  execute: gke.method(:allow).to_proc,
)

after("apply",
  execute: gke.method(:deny).to_proc,
)
