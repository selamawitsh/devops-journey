# Lesson 8 — Matrix Builds, Caching, and Artifacts

## Learning objectives
- Explain matrix strategies.
- Understand dependency caching.
- Explain workflow artifacts.
- Distinguish a cache from an artifact.

## 1. Matrix builds
A matrix lets one job run multiple times with different combinations of values, such as operating systems or language versions.

Example:
```yaml
jobs:
  test:
    strategy:
      matrix:
        go-version: ['1.22', '1.23']
        os: [ubuntu-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go-version }}
      - run: go test ./...
```

This creates a job run for each combination. Use a matrix when compatibility across versions or platforms matters. It can increase runtime and resource use.

## 2. Caching
A cache stores reusable data, commonly downloaded dependencies, so later workflow runs may avoid downloading everything again.

Caching can:
- Reduce repeated dependency downloads.
- Speed up workflows.
- Reduce unnecessary network traffic.

A cache is an optimization, not the authoritative storage for build output. A workflow must still work correctly when a cache miss occurs.

## 3. Cache keys
A cache key identifies the data being cached. Good keys reflect relevant inputs such as operating system, runtime version, and dependency lockfiles.

Example using setup-go's built-in caching behavior:
```yaml
- uses: actions/setup-go@v5
  with:
    go-version: '1.23'
    cache: true
```

Check the action documentation for its default cache paths and key behavior.

## 4. Artifacts
Artifacts preserve files produced by a workflow run. Examples:
- Test reports.
- Coverage reports.
- Compiled binaries.
- Distribution packages.
- Diagnostic logs.

Artifacts can be downloaded from the workflow run or passed to later jobs using upload/download actions.

Example:
```yaml
- name: Upload test report
  uses: actions/upload-artifact@v4
  with:
    name: test-report
    path: reports/
```

The path must exist and contain the files you intend to upload.

## 5. Cache vs artifact

| Cache | Artifact |
|---|---|
| Speeds up future runs | Preserves output from a run |
| Reusable dependency data | Build/test files and reports |
| May be unavailable on a run | Intended to be retrieved |
| Optimization | Workflow output |

## 6. Design considerations
- Avoid caching files that are cheap to recreate.
- Include dependency inputs in cache keys.
- Do not store secrets in caches or artifacts.
- Give artifacts clear names.
- Set retention according to project needs.
- Keep matrix combinations focused on meaningful compatibility targets.

## Review questions
1. What problem does a matrix solve?
2. What is a cache used for?
3. What is an artifact?
4. Why must a workflow tolerate a cache miss?
5. Give one example of something appropriate to upload as an artifact.

## Practical checkpoint
Add a small matrix to an existing test workflow. Then upload a test report or build output as an artifact and download it from the Actions run.

## Completion record
- [ ] I can explain a matrix combination.
- [ ] I can explain why caching is an optimization.
- [ ] I can upload and retrieve an artifact.
- [ ] I can distinguish cache data from artifacts.

## References
Add the matrix, dependency caching, and artifact action documentation used.
