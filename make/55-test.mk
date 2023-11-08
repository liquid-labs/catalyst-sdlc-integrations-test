# This file was generated by @liquid-labs/catalyst-projects-workflow-local-make-
# node. Refer to https://npmjs.com/package/@liquid-labs/catalyst-projects-workflow
# -local-make-node for further details

#####
# test rules
#####

CATALYST_TEST_REPORT:=$(QA)/unit-test.txt
CATALYST_TEST_PASS_MARKER:=$(QA)/.unit-test.passed
CATALYST_COVERAGE_REPORTS:=$(QA)/coverage
TEST_TARGETS+=$(CATALYST_TEST_REPORT) $(CATALYST_TEST_PASS_MARKER) $(CATALYST_COVERAGE_REPORTS)
PRECIOUS_TARGETS+=$(CATALYST_TEST_REPORT)

CATALYST_TEST_FILES_BUILT:=$(patsubst %.cjs, %.js, $(patsubst %.mjs, %.js, $(patsubst $(SRC)/%, $(TEST_STAGING)/%, $(CATALYST_ALL_JS_FILES_SRC))))

$(CATALYST_TEST_DATA_BUILT): $(TEST_STAGING)/%: $(SRC)/%
	@echo "Copying test data..."
	@mkdir -p $(dir $@)
	@cp $< $@

# Jest is not picking up the external maps, so we inline them for the test. (As of?)
$(CATALYST_TEST_FILES_BUILT) &: $(CATALYST_ALL_JS_FILES_SRC)
	rm -rf $(TEST_STAGING)
	mkdir -p $(TEST_STAGING)
	NODE_ENV=test $(CATALYST_BABEL) \
		--config-file=$(CATALYST_BABEL_CONFIG) \
		--out-dir=./$(TEST_STAGING) \
		--source-maps=inline \
		$(SRC)

$(CATALYST_TEST_PASS_MARKER) $(CATALYST_TEST_REPORT) $(TEST_STAGING)/coverage &: package.json $(CATALYST_TEST_FILES_BUILT) $(CATALYST_TEST_DATA_BUILT)
	rm -rf $@
	mkdir -p $(dir $@)
	echo -n 'Test git rev: ' > $(CATALYST_TEST_REPORT)
	git rev-parse HEAD >> $(CATALYST_TEST_REPORT)
	( set -e; set -o pipefail; \
	  ( cd $(TEST_STAGING) && $(CATALYST_JEST) \
	    --config=$(CATALYST_JEST_CONFIG) \
	    --runInBand \
	    $(TEST) 2>&1 ) \
	  | tee -a $(CATALYST_TEST_REPORT); \
	  touch $(CATALYST_TEST_PASS_MARKER) )

$(CATALYST_COVERAGE_REPORTS): $(CATALYST_TEST_PASS_MARKER) $(TEST_STAGING)/coverage
	rm -rf $(CATALYST_COVERAGE_REPORTS)
	mkdir -p $(CATALYST_COVERAGE_REPORTS)
	cp -r $(TEST_STAGING)/coverage/* $(CATALYST_COVERAGE_REPORTS)

#####
# end test
#####