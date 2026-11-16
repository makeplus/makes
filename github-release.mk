# Public GitHub release binaries, without repository-specific recipes.
# Parameters are environment variables, never interpolated as shell code:
# GITHUB_RELEASE_REPO, GITHUB_RELEASE_TAG (optional),
# GITHUB_RELEASE_ASSET (optional exact name), GITHUB_RELEASE_MANIFEST,
# GITHUB_RELEASE_DEST (installation directory).
ifndef GITHUB-RELEASE-LOADED
GITHUB-RELEASE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/python.mk

# Keep uv-managed launchers inside this private runtime as well.
export UV_PYTHON_BIN_DIR := $(LOCAL-BIN)

export GITHUB_RELEASE_REPO GITHUB_RELEASE_TAG GITHUB_RELEASE_ASSET
export GITHUB_RELEASE_MANIFEST GITHUB_RELEASE_DEST

github-release-resolve: $(PYTHON)
	$Q $(PYTHON) $(MAKES)/util/github-release.py resolve

github-release-install: $(PYTHON)
	$Q $(PYTHON) $(MAKES)/util/github-release.py install

endif
