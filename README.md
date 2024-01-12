# Wesnoth Image Optimizer

A GitHub Action for [Wesnoth](https://www.wesnoth.org/) add-ons.
Verifies PNG images using the `woptipng` tool from a partially
cloned [Wesnoth repository](https://github.com/wesnoth/wesnoth).

## Usage

Create a `.github/workflows` folder in your GitHub repository.
Add a workflow that triggers this action. For more info, see
the following examples of GitHub workflows.

The optimization threshold for the `woptipng` tool can be configured
with the `threshold` parameter. By default, a threshold of `10` is used,
which means that the uploaded PNG files can be within 10% of the size
of the compressed images. If any of the images are larger than that,
the action will fail, and the files will be listed by the `woptipng` tool.

The Wesnoth version that the PNG images are checked against can
be specified with the `wesnoth-version` parameter. It can match
any Wesnoth [branch](https://github.com/wesnoth/wesnoth/branches)
or [tag](https://github.com/wesnoth/wesnoth/tags).

The folder or file that should be validated can be specified with
the `path` parameter. By default, all images in the project will
be verified.

### Examples

A workflow that verifies PNG images on every push to the repository,
as well as every pull request:

```yaml
name: check

on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest

    steps:
    - name: Repository checkout
      uses: actions/checkout@v4
    - name: Verify images
      uses: czyzby/wesnoth-png-optimizer@v1
```


A workflow that verifies WML files in the `images/units/` folder against
Wesnoth 1.16 `woptipng` with a custom threshold on every push or pull
request to a specific branch:

```yaml
name: check

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  check:
    runs-on: ubuntu-latest

    steps:
    - name: Repository checkout
      uses: actions/checkout@v4
    - name: Verify images
      uses: czyzby/wesnoth-png-optimizer@v1
      with:
        path: images/units/
        threshold: 5
        wesnoth-version: 1.16
```

By leveraging the `continue-on-error` flag and write permissions,
GitHub Action can also be set up to optimize and commit the images
rather than verify them. This is an example of an action that runs
on every push to the `main` branch and optimizes all images from
the repository:

```yaml
name: optimize

on:
  push:
    branches: [ main ]

permissions:
  contents: write

jobs:
  optimize:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    - name: Optimize images
      uses: czyzby/wesnoth-png-optimizer@v1
      continue-on-error: true
      with:
        threshold: 0
    - name: Commit images
      run: |
        git config --global user.name "github-actions"
        git config --global user.email "actions@users.noreply.github.com"
        git commit -am "🤖 Optimize $GITHUB_REPOSITORY@$GITHUB_SHA"
        git push
```

The following example similarly optimizes the images instead of just
verifying them, but instead of pushing commits directly to the branch,
it sets up a PR after each successful optimization. This might be
preferable to the previous approach if you'd like to accept the changes
manually, or if the main branch is protected. Note that it requires
setting up a [private access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token)
and adding it in the repository _Settings_ tab under
_Secrets and variables > Actions_ as `PRIVATE_ACCESS_TOKEN`.

```yaml
name: optimize

on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  optimize:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    - name: Optimize images
      uses: czyzby/wesnoth-png-optimizer@v1
      continue-on-error: true
      with:
        threshold: 0
    - name: Commit changes
      continue-on-error: true
      run: |
        git config user.name "GitHub Action"
        git config user.email "actions@users.noreply.github.com"
        git config --add --bool push.autoSetupRemote true
        git checkout -b "optimize/$GITHUB_SHA"
        git commit -am "🤖 Optimize $GITHUB_REPOSITORY@$GITHUB_SHA" && git push

    - name: Create pull request
      run: gh pr create -B main -H "optimize/$GITHUB_SHA" --title "Optimize images from @${GITHUB_SHA::7}" --body "Images from $GITHUB_REPOSITORY@$GITHUB_SHA optimized with `woptipng`."
      continue-on-error: true
      env:
        GITHUB_TOKEN: ${{ secrets.PRIVATE_ACCESS_TOKEN }}
```

## Notes

Use `@v1` for the latest stable release. Use `@latest` for the latest
version directly from the default development branch.

### See also

* [`czyzby/wesnoth-wml-linter`](https://github.com/czyzby/wesnoth-wml-linter):
a GitHub Action that verifies WML files with `wmllint` and `wmlindent`.
* [`czyzby/wesnoth-wml-scope`](https://github.com/czyzby/wesnoth-wml-scope):
a GitHub Action that verifies project resources with `wmlscope`.
