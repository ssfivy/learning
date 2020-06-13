# References
- Predefined variables: https://docs.gitlab.com/ce/ci/variables/predefined_variables.html
- Deprecated variables: https://docs.gitlab.com/ee/ci/variables/deprecated_variables.html
- At time of writing: this is the tracking issue for the feature of being able to easily make commit to the same repository using CI (other than setting up ssh-keys): https://gitlab.com/groups/gitlab-org/-/epics/3559

# Run CI / CD process only if something changes in a specific directory

Seems possible but controversial:
- https://stackoverflow.com/questions/51661076/gitlab-ci-cd-run-jobs-only-when-files-in-a-specific-directory-have-changed?rq=1
- https://gitlab.com/gitlab-org/gitlab-foss/-/issues/19232
- https://gitlab.com/gitlab-org/gitlab-foss/-/issues/19813

Seems NOT possible in travis:
- https://travis-ci.community/t/how-to-skip-jobs-based-on-the-files-changed-in-a-subdirectory/2979/12

Snippet says azure devops can do this
