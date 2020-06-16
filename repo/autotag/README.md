# Google Repo - Automatic tagging experiment

This is an experient with repo based workflows, where:
- You have multiuple git repositories checked out using repo
- some of these git repositories are set to follow a branch (e.g. master) instead of checking out a specific revision.
- You perform a time-based (daily, weekly, etc) build on these repositories (might also feasible for a per-commit build).
- You want to keep an archive of the versions used in each build.

This experiment uses two separate git repositories:
- one that stores this documentation, scripts, and CI settings, and performs the CI (this one)
- one to store the manifest files and has the branches with the locked manifests.

Everytime we run the accompanying script, we will create a locked manifest file and commit it to a branch in the manifest repository. This allows us to record the revisions.
We don't commit if the revisions are identical.

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

You also must specify the manifest repo to be checked out over SSH/Git,
since we cannot use SSH keys if we use HTTPS checkout

## Gitlab-specific implementation

To perform Git operations from gitlab runner, we need to use SSH keys / deploy keys.
Deploy tokens do not have repository commit information at time of writing so we cannot use it.

You need to create a keypair first.
The public key need to be added into the project as one of the deploy keys.
For the private keys, you have two options:

1. Keep it in your specific build machine (useful for private runners)
2. Keep it as a project-specific environment variable (useful for gitlab.com shared runners).

For the second option, you have the option to base64-encode the private key so the variable masking feature works.
Note this is not 100% foolproof for protecting your private key since someone can extract it
by triggering a CI with their own code that grabs the value and say, print it hex-encoded or the like. You want the protect feature for that.
Note that as long as you dont echo that variable, you technically dont need to mask it.

### Details for this specific experiment

- SSH keypair generated using `ssh-keygen -t ed25519 -C "some description"`
- Public key is stored as a deploy key in the manifest repository
- Variable `$SSH_PRIVATE_KEY_B64` set in is just the output of `base64 .ssh/id_ed25519 -w 0`. This is set in the repository that contains the gitlab ci yaml file.
