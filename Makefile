FRONTEND ?= ofc
FRONTEND_DEBUG ?= $(FRONTEND)-debug

TEST_DIR = .
TEST_SCRIPT = $(TEST_DIR)/test.sh
TEST_REPORT = $(TEST_DIR)/test.html
TEST_REPORT_LITE = $(TEST_DIR)/test-lite.html
TARGETS = $(sort $(wildcard $(TEST_DIR)/*.FOR))
VG_TARGETS = $(addsuffix .vg, $(TARGETS))
VGO_TARGETS = $(addsuffix .vgo, $(TARGETS))

all : $(TEST_REPORT)

test : $(TEST_REPORT)

test-lite : $(TEST_REPORT_LITE)

clean:
	rm -f $(VG_TARGETS) $(VGO_TARGETS) $(TEST_REPORT) $(TEST_REPORT_LITE)

$(TEST_REPORT): $(TEST_SCRIPT)
	@$(realpath $(TEST_SCRIPT)) $(realpath $(FRONTEND)) 1 1 > $(TEST_REPORT)

$(TEST_REPORT_LITE): $(TEST_SCRIPT)
	@$(realpath $(TEST_SCRIPT)) $(realpath $(FRONTEND)) 0 0 > $(TEST_REPORT_LITE)

$(TARGETS): $(FRONTEND)
	@$(realpath $(FRONTEND)) $@ > /dev/null

$(VG_TARGETS) : %.vg : % $(FRONTEND_DEBUG)
	valgrind -v --leak-check=full --errors-for-leak-kinds=all --track-origins=yes --error-exitcode=1 $(realpath $(FRONTEND_DEBUG)) $(patsubst %.vg, %, $@) > $@ 2>&1

$(VGO_TARGETS) : %.vgo : % $(FRONTEND)
	valgrind -v --leak-check=full --errors-for-leak-kinds=all --error-exitcode=1 $(realpath $(FRONTEND)) $(patsubst %.vgo, %, $@) > $@ 2>&1

valgrind: $(VG_TARGETS)

valgrind-optimized: $(VGO_TARGETS)

.PHONY : all clean test test-lite $(TARGETS) valgrind valgrind-optimized
