# (C) 2021 GoodData Corporation
TOX_FLAGS =
ifeq (1,$(RECREATE_ENVS))
  TOX_FLAGS += -r
endif

LOCAL_TEST_ENVS =
ifdef TEST_ENVS
	LOCAL_TEST_ENVS := -e $(TEST_ENVS)
endif

LOCAL_ADD_ARGS =
ifdef ADD_ARGS
	LOCAL_ADD_ARGS := -- $(ADD_ARGS)
endif


# linting and formatting tools have configuration in parent dir to support pre-commit - use it
# flake8 use parent directory to have the same per-file-ignores config parameter for parent and child dirs
CURR_DIR_BASE_NAME = $(notdir $(CURDIR))

.PHONY: all
all:
	echo "Nothing here yet."

.PHONY: lint
lint:
	(cd ..; flake8 $(CURR_DIR_BASE_NAME))

.PHONY: format
format:
	(cd ..; black --check $(CURR_DIR_BASE_NAME))
	(cd ..; isort --check $(CURR_DIR_BASE_NAME))

.PHONY: format-diff
format-diff:
	(cd ..; black --diff $(CURR_DIR_BASE_NAME))
	(cd ..; isort --diff $(CURR_DIR_BASE_NAME))

.PHONY: format-fix
format-fix:
	(cd ..; black $(CURR_DIR_BASE_NAME))
	(cd ..; isort $(CURR_DIR_BASE_NAME))

.PHONY: mypy
mypy:
	tox $(TOX_FLAGS) -e mypy

.PHONY: test
test:
	tox $(TOX_FLAGS) $(LOCAL_TEST_ENVS) $(LOCAL_ADD_ARGS)

.PHONY: test-ci
test-ci:
	TEST_CI_PROJECT=$(CURR_DIR_BASE_NAME) $(MAKE) -C .. -f ci_tests.mk test-ci

.PHONY: docs
docs:
	tox $(TOX_FLAGS) -e docs

# this is effective for gooddata-sdk only now - it should be part of test fixtures
# remove this target once implemented in pytest global fixture
.PHONY: remove-store-data
remove-store-data:
	echo "Removing directory $(CURDIR)/tests/catalog/store"
	rm -rf $(CURDIR)/tests/catalog/store

.PHONY: remove-cassettes
remove-cassettes: remove-store-data
	find $(CURDIR)/tests -type f -name "*.json" -path "*/fixtures/*" -print -delete
