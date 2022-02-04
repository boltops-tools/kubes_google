require "active_support/core_ext/string"
require "json"

module KubesGoogle
  class ServiceAccount
    include Logging
    include Util::Sh

    def initialize(app:, namespace:nil, roles: [], gsa: nil, ksa: nil)
      @app, @roles = app, roles
      @google_project = ENV['GOOGLE_PROJECT'] || raise("GOOGLE_PROJECT env variable is not set. It's required.")

      # conventional names
      @namespace = namespace || "#{@app}-#{Kubes.env}" # convention: app-env
      @gsa = gsa || "#{@app}-#{Kubes.env}"             # convention: app-env
      @ksa = ksa || @app                               # convention: app
      @service_account = "#{@gsa}@#{@google_project}.iam.gserviceaccount.com" # full service account name
    end

    def call
      create_google_service_account
      create_gke_iam_binding
      add_roles
    end

    def create_google_service_account
      logger.debug "Creating google service account"
      found = sh %Q{gcloud iam service-accounts list | grep " #{@service_account}" > /dev/null}
      return if found
      sh "gcloud iam service-accounts create #{@gsa}"
    end

    def create_gke_iam_binding
      logger.debug "Creating GKE IAM Binding"
      member = "serviceAccount:#{@google_project}.svc.id.goog[#{@namespace}/#{@ksa}]"

      found = sh "gcloud iam service-accounts get-iam-policy #{@service_account} | grep -F #{member} > /dev/null"
      return if found

      sh "gcloud iam service-accounts add-iam-policy-binding \
                --role roles/iam.workloadIdentityUser \
                --member #{member} \
                --condition=None \
                #{@service_account}".squish
    end

    def add_roles
      logger.debug "Adding Google Roles/Permissions"
      roles.each do |role|
        add_role(role)
      end
    end

    def roles
      @roles.map do |role|
        role.include?("roles/") ? role : "roles/#{role}"
      end
    end

    def has_role?(role)
      out = capture "gcloud projects get-iam-policy #{@google_project} --format json"
      data = JSON.load(out)
      bindings = data['bindings']
      binding = bindings.find { |b| b['role'] == role }
      return false unless binding
      binding['members'].include?(@service_account)
    end

    def add_role(role)
      return if has_role?(role)

      sh "gcloud projects add-iam-policy-binding #{@google_project} \
          --member=serviceAccount:#{@service_account} \
          --role=#{role} > /dev/null".squish
    end
  end
end
