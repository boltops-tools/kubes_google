# Kubes Google

[![Gem Version](https://badge.fury.io/rb/kubes_google.png)](http://badge.fury.io/rb/kubes_google)

[![BoltOps Badge](https://img.boltops.com/boltops/badges/boltops-badge.png)](https://www.boltops.com)

[Kubes](https://kubes.guru) Library with Google helpers.

## Usage

The helpers include:

* Secrets
* Service Accounts

## Secrets

Set up a [Kubes hook](https://kubes.guru/docs/config/hooks/kubes/).

.kubes/config/hooks/kubes.rb

```ruby
before("compile",
  execute: KubesGoogle::Secrets.new(upcase: true, prefix: 'projects/686010496118/secrets/demo-dev-')
)
```

Then set the secrets in the YAML:

.kubes/resources/shared/secret.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: demo
  labels:
    app: demo
data:
<% KubesGoogle::Secrets.data.each do |k,v| -%>
  <%= k %>: <%= Base64.encode64(v).strip %>
<% end -%>
```

This results in Google secrets with the prefix the `demo-dev-` being added to the Kubernetes secret data.  The values are automatically base64 encoded.

For example if you have these secret values:

    $ gcloud secrets versions access latest --secret demo-dev-db_user
    test1
    $ gcloud secrets versions access latest --secret demo-dev-db_pass
    test2
    $

.kubes/output/shared/secret.yaml

```yaml
metadata:
  namespace: demo
  name: demo-2a78a13682
  labels:
    app: demo
apiVersion: v1
kind: Secret
data:
  db_pass: dGVzdDEK
  db_user: dGVzdDIK
```

These environment variables can be set:

Name | Description
---|---
GCP_SECRET_PREFIX | Prefixed used to list and filter Google secrets. IE: `projects/686010496118/secrets/demo-dev-`.
GOOGLE_PROJECT | Google project id.

Secrets#initialize options:

Variable | Description | Default
---|---|---
upcase | Automatically upcase the Kubernetes secret data keys. | false
prefix | Prefixed used to list and filter Google secrets. IE: `projects/686010496118/secrets/demo-dev-`. Can also be set with the `GCP_SECRET_PREFIX` env variable. The env variable takes the highest precedence. | nil

Note, Kubernetes secrets are only base64 encoded. So users who have access to read Kubernetes secrets will be able to decode and get the value trivially. Depending on your security posture requirements, this may or may not suffice.

## Service Accounts

This library can also be used to automatically create Google Service Accounts associated with the [GKE Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity).

Here's a Kubes hook that creates a service account:

.kubes/config/hooks/kubes.rb

```ruby
service_account = KubesGoogle::ServiceAccount.new(
  app: "demo",
  namespace: "demo-#{Kubes.env}", # defaults to APP-ENV when not set. IE: demo-dev
  roles: ["cloudsql.client", "secretmanager.viewer"], # defaults to empty when not set
)
before("apply",
  label: "create service account",
  execute: service_account,
)
```

The role permissions are currently always added to the existing permissions. So removing roles that were previously added does not remove them.

ServiceAccount#initialize options:

Variable | Description | Default
---|---|---
app | The app name. It's used to conventionally set other variables. This is required. | nil
gsa | The Google Service Account name. The conventional name is APP-ENV. IE: demo-dev. | APP-ENV
ksa | The Kubernetes Service Account name. The conventional name is APP. IE: demo | APP
namespace | The Kubernetes namespace. Defaults to the APP-ENV. IE: demo-dev. | APP-ENV
roles | Google IAM roles to add. This adds permissions to the Google service account. | []

Notes:

* By default, `KubeGoogle.logger = Kubes.logger`. This means, you can set `logger.level = "debug"` in `.kubes/config.rb` to see more details.
* The `gcloud` cli is used to create IAM roles. So `gcloud` is required.
* Note: Would like to use the google sdk, but it wasn't obvious how to do so. PRs are welcomed.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/boltops-tools/kubes_google.
