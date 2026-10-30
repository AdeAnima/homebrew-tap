# AdeAnima Homebrew tap

## Install eidolon

After the first release and this tap are published:

```sh
brew install adeanima/tap/eidolon
eidolon fetch-models
eidolon ~/Pictures
```

The supported tap platform is macOS on Apple Silicon (arm64). Homebrew uses a bottle when one is published, or builds from source otherwise. Force source installation with `brew install --build-from-source adeanima/tap/eidolon`. Models are downloaded only by the explicit `fetch-models` command, not during installation or local scanning.

eidolon loads Homebrew's `onnxruntime` at runtime and is built against a specific ONNX Runtime API (`ort` feature `api-24`). If it reports an ORT version error after an `onnxruntime` upgrade, update eidolon with `brew upgrade eidolon` or [open an issue](https://github.com/AdeAnima/eidolon/issues).

Source: <https://github.com/AdeAnima/eidolon>. eidolon reports duplicates; it never deletes or rewrites scanned files. Install the minimal agent skill from that repository's `skills/eidolon/` directory when using eidolon through an agent.

## Publish a source release and bottle

1. In the eidolon repository, commit the release tree, tag it `v<version>` and push the commit and tag. Run `scripts/release.sh <version>` to produce a deterministic source tarball and SHA-256.
2. Create its GitHub Release and upload `dist/eidolon-<version>.tar.gz` unchanged. The formula uses this release asset, not GitHub's automatically generated source archive.
3. Update `Formula/eidolon.rb` with the release-asset URL and printed SHA-256. The preparation-snapshot checksum must be replaced with the real tag's checksum before publication.
4. Add or update `Formula/eidolon.rb` through a pull request, not the initial push to `main`. `brew test-bot` builds, tests and uploads an Apple Silicon bottle on macOS 15 **only for `pull_request` events**.
5. After all checks pass, a maintainer reviews the complete diff (including `.github/`) and verifies the current PR head SHA immediately before publishing. **Default publish path:** manually dispatch `publish.yml` on `main` (`workflow_dispatch`), supplying `pull_request` and the reviewed `head_sha`. `brew pr-pull` evaluates PR formula Ruby with publishing permissions, imports bottle metadata, publishes the bottle and pushes the result. A push after review requires another review.

Before the first publication, create the public repositories `AdeAnima/eidolon` and `AdeAnima/homebrew-tap`, bootstrap tap `main` with the README/workflows but **without `Formula/`**, and enable GitHub Actions. Set **Settings → Actions → General → Workflow permissions → Read and write permissions**. Then add the formula through the pull request above. The tap starts without a `bottle` block: the first successful bottle PR supplies the real hashes and release location. Nothing here requires crates.io publishing.

Optional label path: apply `pr-pull` only when an applicable **Workflow execution protections / Actions event policy explicitly allows `pull_request_target`** in Settings → Actions → Policies. GitHub's [default policy for public repositories blocks that event from December 2, 2026](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target#default-policy-for-pull_request_target). The label grants the same publishing trust and requires the same full-diff/current-head review; manual dispatch does not require opting out of this default policy.

For outside contributions, set Actions to require approval for all external contributors. A green workflow is not a substitute for reviewing workflow changes and the bottle-producing source.
