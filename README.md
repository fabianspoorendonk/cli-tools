# Containerized CLI tools

Run developer and operations command-line tools as if they were installed natively, using hardened Podman containers. This approach minimizes the risk of upstream supply-chain attacks in components sourced from public repositories. With limited network access and narrowly scoped, read-only host mounts by default, each container limits the reach and potential impact of a compromised upstream component.

The 2025 [`tj-actions/changed-files` compromise](https://www.stepsecurity.io/blog/harden-runner-detection-tj-actions-changed-files-action-is-compromised) demonstrated how widely used public tooling can become a supply-chain attack vector. Attackers redirected existing release tags to malicious code that exposed CI/CD secrets in affected workflow logs.

Beyond reducing this risk, the container-based approach simplifies installing and updating a collection of tools by keeping their runtimes and dependencies inside the container images. The container-based approach also makes it easy to quickly set up a broad range of static analysis and deployment tools for use in local development environments, Git pre-commit hooks, and AI agents. Be aware that container startup adds overhead, so frequently invoked or performance-critical commands may be better installed as native binaries.

## Available tools

| Command | Tool | Description |
| --- | --- | --- |
| `actionlint` | [actionlint](https://github.com/rhysd/actionlint) | GitHub Actions linting |
| `jq` | [jq](https://github.com/jqlang/jq) | JSON processing and transformation |
| `markdownlint` | [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) | Markdown linting |
| `shellcheck` | [ShellCheck](https://github.com/koalaman/shellcheck) | Shell script static analysis |
| `yq` | [yq](https://github.com/mikefarah/yq) | YAML, JSON, and XML processing |

## Requirements

- [Podman](https://podman.io/) on `PATH`
- Bash to run the Bash launcher scripts
- On Windows, the `.cmd` wrappers invoke Podman directly and do not require Bash

## Installation

Clone the repository and add `bin` to your `PATH`. On Windows, the `.cmd` wrappers expose each tool under its command name; on other platforms, use the Bash scripts with the same names.

## Usage

Each launcher script mounts the current working directory into the container at `/workspace` and runs its tool with that mounted directory as its working directory. Run the launcher script from the directory you want to use as the container workspace.

```shell
actionlint                       # lint all workflows
actionlint --shellcheck=         # skip the shellcheck integration

markdownlint                     # lint **/*.md
markdownlint "docs/**/*.md"      # lint a specific glob
markdownlint --fix               # apply fixable rules
cat README.md | markdownlint -   # lint standard input

shellcheck bin/* lib/*.sh        # lint shell scripts

cat data.json | jq '.items[0]'   # filter standard input
jq '.name' package.json          # read a file from the repository
cat config.yml | yq '.service.name'   # filter YAML standard input
yq '.service.name' config.yml        # read a YAML file from the repository
```

The exit code is `0` when clean and non-zero when findings remain, so the wrappers can be used in scripts and Git hooks.

## Security posture

The tools are third-party binaries with large dependency trees, so they are confined rather than trusted.

The workspace mount exposes only the selected host directory, not its parent or sibling directories. The tools can access other paths inside the container image, but they cannot use those paths to access host files that were not explicitly mounted.

The following controls further limit the tools' access and impact:

| Control | Effect |
| --- | --- |
| `@sha256:` pinned images | A compromised tag cannot change the code that runs. |
| `--network none` | No exfiltration and no downloads at run time. |
| `--read-only`, `--cap-drop all` | No writes to the container, no capabilities. |
| `--security-opt no-new-privileges` | No privilege escalation. |
| `--pids-limit 128` | Bounded fork behaviour. |
| Repository mounted `:ro` | The working tree cannot be modified by the tool. |

`markdownlint --fix` is the single exception: it mounts the repository read-write, because writing fixes requires it. Review the result with `git diff` before staging.

## Tool configuration

[markdownlint-cli2.yaml](config/markdownlint-cli2.yaml) mirrors the shared CI configuration and is passed explicitly, so a repository's own markdownlint configuration is not used. Change the file here to change the rules everywhere.

## Layout

| Path | Purpose |
| --- | --- |
| `bin/*.cmd` | Windows entry points; invoke the tool through Git Bash or Podman. |
| `bin/actionlint`, `bin/jq`, `bin/markdownlint`, `bin/shellcheck`, `bin/yq` | Per-tool configuration: image, mounts, arguments. |
| `lib/container.cmd` | Shared Windows Podman execution, recovery, and cleanup. |
| `lib/container.sh` | Shared container invocation and Podman checks. |
| `config/` | Tool configuration files. |

## Licence

[MIT](LICENSE)
