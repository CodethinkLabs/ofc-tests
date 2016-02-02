FRONTEND ?= ofc
FRONTEND_DEBUG ?= $(FRONTEND)-debug

TEST_SCRIPT = test.sh
COMPARE_SCRIPT = compare-test.sh
TEST_REPORT = out/test.html
TEST_REPORT_LITE = out/test-lite.html

PROGRAMS_DIR = programs
PROGRAMS_NIST = $(sort $(wildcard $(PROGRAMS_DIR)/nist/*))
PROGRAMS_BASE = $(sort $(wildcard $(PROGRAMS_DIR)/*))
PROGRAMS = $(PROGRAMS_NIST) $(PROGRAMS_BASE)
PROGRAMS_SEMA = $(sort $(wildcard $(PROGRAMS_DIR)/sema/*))
PROGRAMS_NEGATIVE = $(sort $(wildcard $(PROGRAMS_DIR)/negative/*))

PROGRAMS_DUMMY = $(addsuffix .dummy, $(PROGRAMS))
PROGRAMS_SEMA_DUMMY = $(addsuffix .dummy, $(PROGRAMS_SEMA))
PROGRAMS_NEGATIVE_DUMMY = $(addsuffix .dummy, $(PROGRAMS_NEGATIVE))

PROGRAMS_ALL = $(PROGRAMS) $(PROGRAMS_SEMA) $(PROGRAMS_NEGATIVE)

STDERR_PROGRAMS = $(addprefix out/, $(addsuffix .stderr, $(PROGRAMS_ALL)))
VG_PROGRAMS = $(addprefix out/, $(addsuffix .vg, $(PROGRAMS_ALL)))
VGO_PROGRAMS = $(addprefix out/, $(addsuffix .vgo, $(PROGRAMS_ALL)))
VG_FLAGS ?= -v --leak-check=full --error-exitcode=1

# Older versions of valgrind don't support this flag.
VG_FLAGS += $(shell valgrind --help | grep errors-for-leak-kinds > /dev/null 2>&1 && echo "--errors-for-leak-kinds=all")


all : $(TEST_REPORT)


test : $(PROGRAMS_DUMMY) $(PROGRAMS_SEMA_DUMMY) $(PROGRAMS_NEGATIVE_DUMMY)

$(PROGRAMS_DUMMY) : %.dummy : % $(FRONTEND) $(FRONTEND_DEBUG) $(COMPARE_SCRIPT)
	$(realpath $(FRONTEND)) $<
	$(realpath $(COMPARE_SCRIPT)) $(realpath $(FRONTEND)) $<
	valgrind $(VG_FLAGS) --track-origins=yes $(realpath $(FRONTEND_DEBUG)) $<
	valgrind $(VG_FLAGS) $(realpath $(FRONTEND)) $<

$(PROGRAMS_SEMA_DUMMY) : %.dummy : % $(FRONTEND) $(FRONTEND_DEBUG) $(COMPARE_SCRIPT)
	$(realpath $(FRONTEND)) --sema-tree $<
	valgrind $(VG_FLAGS) --track-origins=yes $(realpath $(FRONTEND_DEBUG)) $<
	valgrind $(VG_FLAGS) $(realpath $(FRONTEND)) $<

$(PROGRAMS_NEGATIVE_DUMMY) : %.dummy : % $(FRONTEND) $(FRONTEND_DEBUG) $(COMPARE_SCRIPT)
	! $(realpath $(FRONTEND)) $<


out-dir:
	mkdir -p out out/programs out/programs/nist

test-report : $(TEST_REPORT)

test-report-lite : $(TEST_REPORT_LITE)

$(TEST_REPORT) : out-dir $(TEST_SCRIPT)
	@$(realpath $(TEST_SCRIPT)) $(realpath $(FRONTEND)) 1 1 > $(TEST_REPORT)

$(TEST_REPORT_LITE) : out-dir $(TEST_SCRIPT)
	@$(realpath $(TEST_SCRIPT)) $(realpath $(FRONTEND)) 0 0 > $(TEST_REPORT_LITE)

$(STDERR_PROGRAMS) : out/%.stderr : % out-dir $(FRONTEND)
	@$(realpath $(FRONTEND)) $< 2> $@

valgrind: $(VG_PROGRAMS)

valgrind-optimized: $(VGO_PROGRAMS)

$(VG_PROGRAMS) : out/%.vg : % out-dir $(FRONTEND_DEBUG)
	valgrind $(VG_FLAGS) --track-origins=yes $(realpath $(FRONTEND_DEBUG)) $< > $@ 2>&1

$(VGO_PROGRAMS) : out/%.vgo : % out-dir $(FRONTEND)
	valgrind $(VG_FLAGS) $(realpath $(FRONTEND)) $< > $@ 2>&1


clean:
	rm -rf out


.PHONY : all clean test test-report test-report-lite valgrind valgrind-optimized $(PROGRAMS_DUMMY) out-dir
