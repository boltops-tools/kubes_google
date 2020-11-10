module KubesGoogle
  class Hooks
    def path
      File.expand_path("../hooks", __dir__)
    end
  end
end
