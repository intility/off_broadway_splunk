# Changelog

## [3.0.0](https://github.com/intility/off_broadway_splunk/compare/v2.1.4...v3.0.0) (2026-04-14)


### ⚠ BREAKING CHANGES

* add telemetry error events and stop producer on auth failures (v3.0.0) ([#14](https://github.com/intility/off_broadway_splunk/issues/14))

### Features

* add telemetry error events and stop producer on auth failures (v3.0.0) ([#14](https://github.com/intility/off_broadway_splunk/issues/14)) ([46fba50](https://github.com/intility/off_broadway_splunk/commit/46fba506f32d92057582d7ef933b366c55cc1f92))

## [2.1.4](https://github.com/intility/off_broadway_splunk/compare/v2.1.3...v2.1.4) (2026-04-14)

### Bug Fixes

* correct typespec annotations in Producer module ([5bafbd9](https://github.com/intility/off_broadway_splunk/commit/5bafbd97c16d33293e3e4cef0ae8aec961d9cace))
* **producer:** handle refetch when job already in progress ([53b3019](https://github.com/intility/off_broadway_splunk/commit/53b301959025856b06da5d8a7f56d6c9539baeb7))

### Documentation

* Update README badges and links ([069f548](https://github.com/intility/off_broadway_splunk/commit/069f5482769936465a39fd45af6c7d989540a4c4))

### CI

* Configure automated releases with release-please ([b18df30](https://github.com/intility/off_broadway_splunk/commit/b18df30437498cbb65a352a0d7ab74d9c344a899))

### Styles

* Reformat code to use 120 character line length ([3029b41](https://github.com/intility/off_broadway_splunk/commit/3029b41cc81e5d41ae56a9c97e94e4d876b761f4))

### Tests

* **logger:** Disable colored console output in test environment ([a3133e3](https://github.com/intility/off_broadway_splunk/commit/a3133e328cc3476bb040f8bbba153f8bcb291384))

## [2.1.3](https://github.com/intility/off_broadway_splunk/compare/v2.1.1...v2.1.3) (2024-08-20)

- Replace `:only_new` and `:only_latest` options with a `:jobs` option. Set `:jobs` to `:new` to only process new jobs, and `:latest`
  to only process the latest available job.
- Add deprecation warnings to `:only_new` and `:only_latest` option. The options are still accepted but will be removed in the
  next major release.
- If the client receives an `{:error, reason}` tuple, reschedule another fetch instead of blowing up.

## [2.1.1](https://github.com/intility/off_broadway_splunk/compare/v2.1.0...v2.1.1) (2023-12-28)

- Generate unique message IDs using the `_bkt` and `_cd` metadata fields.

## 2.1.1 (2023-12-07)

- Make the producer accept `{:error, reason}` tuples as response from API client. Whenever this occurs,
  simply reschedule a fetch after `receive_interval` milliseconds.

## [2.1.0](https://github.com/intility/off_broadway_splunk/compare/v2.0.0...v2.1.0) (2023-12-06)

### Options

- Add new option `only_new` to skip consuming any existing jobs. The pipeline will ignore currently known
  jobs, and only consume new jobs that arrives after the pipeline has started.
- Add new option `only_latest` to only consume the most recent job for given report or alert.

### Other

- Remove `OffBroadway.Splunk.Queue` GenServer process and keep the queue in the producer.
  This makes the producer process fully self-contained and we no longer need to communicate with
  another process to know what job we should produce messages for.
- New telemetry events `[:off_broadway_splunk, :process_job, :start]` and `[:off_broadway_splunk, :process_job, :stop]`
  are generated whenever a new job is started.
- Log error and return empty list of messages when receiving an `{:error, reason}` tuple while trying to fetch
  messages from Splunk.

## [2.0.0](https://github.com/intility/off_broadway_splunk/compare/v1.2.4...v2.0.0) (2023-05-23)

This almost a complete rewrite and is **incompatible** with the `v1.x` branch.
Instead of targeting a specific `SID` to produce messages for, this release is focused around producing messages
from Splunk Reports or (triggered) Alerts.

### Options

- Replace `sid` option with `name`. Pipelines should now be given the name of a report or alert.
- Remove `endpoint` option. All messages will be downloaded using the `results` endpoint.
- Remove `offset` option, as it is only available for the `events` endpoint.
- Add `refetch_interval` option. This is the amount in milliseconds the `OffBroadway.Splunk.Queue` process will
  wait before refetching the list of available jobs.

### Other

- Add `OffBroadway.Splunk.Queue` GenServer process that will start as part of the pipeline supervision tree.
- Remove `OffBroadway.Splunk.Leader` GenServer process as it is not usable anymore.
- Refactored `OffBroadway.Splunk.Producer` and `OffBroadway.Splunk.SplunkClient` to new workflow.
- Updated `telemetry` events to new workflow.

## [1.2.4](https://github.com/intility/off_broadway_splunk/compare/v1.2.3...v1.2.4) (2023-04-20)

### Bug Fixes

- Using `state.is_done` proved unreliable when consuming certain jobs. Replaced calculation of retry timings
  to be based on `receive_interval`.
- Fixed typings for `OffBroadway.Splunk.Leader` struct.

## [1.2.3](https://github.com/intility/off_broadway_splunk/compare/v1.2.2...v1.2.3) (2023-04-05)

- Remove `Tesla.Middleware.Logger` from default `OffBroadway.Splunk.SplunkClient` tesla client because
  of too much noise.

## [1.2.2](https://github.com/intility/off_broadway_splunk/compare/v1.2.1...v1.2.2) (2023-04-03)

- Filter `authorization` headers for `Tesla.Middleware.Logger`
- Replace some enumerations with streams

## [1.2.1](https://github.com/intility/off_broadway_splunk/compare/v1.2.0...v1.2.1) (2023-03-28)

- Accept `nimble_options` version `v1.0`

## [1.2.0](https://github.com/intility/off_broadway_splunk/compare/v1.1.1...v1.2.0) (2023-01-23)

### New options

- `api_version` - Configures if messages should be produced from the `v1` or `v2` versioned API endpoints.

### Dependencies

- Accept `telemetry` version `1.1` or `1.2`
- Accept `tesla` version `1.4` or `1.5`

## [1.1.1](https://github.com/intility/off_broadway_splunk/compare/v1.1.0...v1.1.1) (2023-01-16)

### New options

- `shutdown_timeout` - Configurable number of milliseconds Broadway should wait before timing out when trying to stop
  the pipeline.
- `endpoint` - Choose to consume messages using the `events` or `results` endpoint of the Splunk Web API.
- `offset` - Allow passing a custom initial offset to start consuming messages from. Passing a negative value will
  cause the pipeline to consume messages from the "end" of the results.
- `max_events` - If set to a positive integer, shut down the pipeline after producing this many messages.

## 1.1.0 (2022-10-28)

The first release targeted consuming a single SID (Search ID) produced by saving a triggered alert.
