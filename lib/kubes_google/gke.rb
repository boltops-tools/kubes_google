require 'open-uri'

module KubesGoogle
  class Gke
    extend Memoist
    include Logging
    include Services

    def initialize(name:, whitelist_ip: nil)
      @name, @whitelist_ip = name, whitelist_ip
    end

    def allow
      return unless enabled?
      logger.debug "Updating cluster. Adding IP: #{ip}"
      update_cluster(cidr_blocks(:with_whitelist))
    end

    def deny
      return unless enabled?
      logger.debug "Updating cluster. Removing IP: #{ip}"
      update_cluster(cidr_blocks(:without_whitelist))
    end

    # Setting the cluster name is enough to enable the hooks
    def enabled?
      enable = KubesGoogle.config.gke.enable_hooks
      enable = enable.nil? ? true : enable
      # gke = KubesGoogle::Gke.new(name: KubesGoogle.config.gke.cluster_name)
      # so @name = KubesGoogle.config.gke.cluster_name
      !!(enable && @name)
    end

    def update_cluster(cidr_blocks)
      resp = cluster_manager.update_cluster(
        name: @name,
        update: {
          desired_master_authorized_networks_config: {
            cidr_blocks: cidr_blocks,
            enabled: true,
          }
        }
      )
      operation_name = resp.self_link.sub(/.*projects/,'projects')
      wait_for(operation_name)
    end

    def wait_for(operation_name)
      resp = cluster_manager.get_operation(name: operation_name)
      until resp.status != :RUNNING do
        sleep 5
        resp = cluster_manager.get_operation(name: operation_name)
      end
    end

    def cidr_blocks(type)
      # so we dont keep adding duplicates
      old = old_cidrs.reject do |x|
        x[:display_name] == new_cidr[:display_name] &&
        x[:cidr_block] == new_cidr[:cidr_block]
      end
      if type == :with_whitelist
        old + [new_cidr]
      else
        old
      end
    end

    def old_cidrs
      resp = cluster_manager.get_cluster(name: @name)
      config = resp.master_authorized_networks_config.to_h
      config[:cidr_blocks]
    end
    memoize :old_cidrs

    def new_cidr
      {
        display_name: "added-by-kubes-google",
        cidr_block: ip,
      }
    end
    memoize :new_cidr

    def ip
      @whitelist_ip || current_ip
    end

    def current_ip
      resp = URI.open("http://ifconfig.me")
      ip = resp.read
      "#{ip}/32"
    rescue SocketError => e
      logger.info "WARN: #{e.message}"
      logger.info "Unable to detect current ip. Will use 0.0.0.0/0"
      "0.0.0.0/0"
    end
    memoize :current_ip
  end
end
