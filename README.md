# Wesnoth Image Optimizer

A GitHub Action for [Wesnoth](https://www.wesnoth.org/) add-ons.
Verifies PNG images using the `woptipng` tool from a partially cloned
[Wesnoth repository](https://github.com/wesnoth/wesnoth).

## Usage

Create a `.github/workflows` folder in your GitHub repository.
Add a workflow that triggers this action. For more info, see
the following examples of GitHub workflows.

The optimization threshold for the `woptipng` tool can be configured
with the `threshold` parameter. By default, a threshold of `10` is used,
which means that the uploaded PNG files can be within 10% of the size
of the compressed images. If any of the images are larger than that,
the action will fail, and the files will be listed by the `woptipng` tool.

### Examples

A workflow that verifies PNG images on every push to the repository,
as well as every pull request:

```yaml
name: lint

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Repository checkout
      uses: actions/checkout@v2
    - name: Verify images
      uses: czyzby/wesnoth-png-optimizer@v1
```

A workflow that verifies PNG images with a custom threshold on every push
or pull request to a specific branch:

```yaml
name: lint

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Repository checkout
      uses: actions/checkout@v2
    - name: Verify images
      uses: czyzby/wesnoth-png-optimizer@v1
      with:
        threshold: 5
```

## Notes

Use `@v1` for the latest stable release. Use `@latest` for the latest
version directly from the default development branch.
