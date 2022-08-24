# Changelog

All notable changes to this project will be documented in this file.
This project *loosely tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [0.3.11] - 2022-08-24
- [#12](https://github.com/boltops-tools/kubes_google/pull/12) KUBES_MOCK_SECRET_QUIET env var support

## [0.3.10] - 2022-08-19
- [#11](https://github.com/boltops-tools/kubes_google/pull/11) Google service account fixes
- KUBES_MOCK_SECRET ability
- dont add project iam binding if already exists
- fix iam service has_role? check

## [0.3.9] - 2022-02-16
- [#10](https://github.com/boltops-tools/kubes_google/pull/10) google_secret_data helper

## [0.3.8] - 2022-02-07
- fix service account creation: add condition none

## [0.3.7] - 2022-02-07
- [#9](https://github.com/boltops-tools/kubes_google/pull/9) performance improvement: cache secrets

## [0.3.6] - 2022-02-04
- [#7](https://github.com/boltops-tools/kubes_google/pull/7) Secret auto retry with gcloud strategy
- [#8](https://github.com/boltops-tools/kubes_google/pull/8) add condition none
- get google project number via api

## [0.3.5] - 2020-11-12
- add KubesGoogle.cloudbuild? check
- fetcher sdk friendly suggestion to use gcloud when vpn errors

## [0.3.4] - 2020-11-12
- fix KubesGoogle.config.secrets.fetcher check

## [0.3.3] - 2020-11-12
- [#6](https://github.com/boltops-tools/kubes_google/pull/6) sdk and gcloud secrets fetcher strategy: secrets.fetcher option

## [0.3.2] - 2020-11-11
- [#5](https://github.com/boltops-tools/kubes_google/pull/5) config.base64 option

## [0.3.1] - 2020-11-11
- [#4](https://github.com/boltops-tools/kubes_google/pull/4) get_credentials hook

## [0.3.0]
- #3 gke hook to whitelist ip

## [0.2.0]
- #2 add google_secret helper and register plugin
- fix GOOGLE_PROJECT check

## [0.1.2]
- #1 base64 option

## [0.1.1]
- dont base64 secret values in data by default

## [0.1.0]
- Initial release.
