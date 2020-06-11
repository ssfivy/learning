# Google Repo - Automatic tagging experiment

This is an experient with repo based workflows, where:
- You have multiuple git repositories checked out using repo
- some of these git repositories are set to follow a branch (e.g. master) instead of checking out a specific revision.
- You perform a time-based (daily, weekly, etc) build on these repositories (not a per-commit build).
- You want to keep an archive of the versions used in each build.

This experiment uses a separate git repository to store the manifests. That will then check out this repository.

To start experimenting, install repo on your system and call:

```
# via https
repo init -u https://gitlab.com/ssfivy/learning-repo.git -b master
# via ssh
repo init -u git@gitlab.com:ssfivy/learning-repo.git -b master
repo sync
```

To create a default.xml file with fixed revisions:

`repo manifest -r -o default.xml`

The manifest repo has two branches:
- `master` is the normal working branch
- `buildtags` contains a modified default.xml with fixed revisions.
