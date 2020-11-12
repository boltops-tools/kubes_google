class KubesGoogle::Secrets::Fetcher
  class Gcloud < Base
    include KubesGoogle::Util::Sh

    def fetch(short_name, version="latest")
      value = gcloud("secrets versions access #{version} --secret #{short_name}")
      if value.include?("ERROR") && value.include?("NOT_FOUND")
        logger.info "WARN: secret #{short_name} not found".color(:yellow)
        logger.info e.message
        "NOT FOUND #{short_name}" # simple string so Kubernetes YAML is valid
      else
        value = Base64.strict_encode64(value).strip if base64?
        value
      end
    end

    def gcloud(args)
      capture("gcloud --project #{@project_id} #{args}")
    end
  end
end
