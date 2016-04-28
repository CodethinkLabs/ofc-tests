FRONTEND ?= ofc
FRONTEND_DEBUG ?= $(FRONTEND)-debug

TEST_SOURCE = test.c
TEST_EXEC = out/test

COMPARE_SCRIPT = compare-test.sh
TEST_REPORT = out/test.html
TEST_REPORT_LITE = out/test-lite.html
TEST_REPORT_THREADS = 5

export TESTS_GIT_COMMIT = $(shell git rev-parse HEAD)

PROGRAMS_DIR = programs
PROGRAMS_NIST = $(sort $(shell find $(PROGRAMS_DIR)/nist -maxdepth 1 -type f))
PROGRAMS_BASE = $(sort $(shell find $(PROGRAMS_DIR) -maxdepth 1 -type f))
PROGRAMS = $(PROGRAMS_NIST) $(PROGRAMS_BASE)
PROGRAMS_SEMA = $(sort $(shell find $(PROGRAMS_DIR)/sema -maxdepth 1 -type f))
PROGRAMS_NEGATIVE = $(sort $(shell find $(PROGRAMS_DIR)/negative -maxdepth 1 -type f))
PROGRAMS_TODO = $(sort $(shell find $(PROGRAMS_DIR)/todo -maxdepth 1 -type f))

PROGRAMS_DUMMY = $(addsuffix .dummy, $(PROGRAMS))
PROGRAMS_SEMA_DUMMY = $(addsuffix .dummy, $(PROGRAMS_SEMA))
PROGRAMS_NEGATIVE_DUMMY = $(addsuffix .dummy, $(PROGRAMS_NEGATIVE))

PROGRAMS_ALL = $(PROGRAMS) $(PROGRAMS_SEMA) $(PROGRAMS_NEGATIVE) $(PROGRAMS_TODO)

STDERR_PROGRAMS = $(addprefix out/, $(addsuffix .stderr, $(PROGRAMS_ALL)))
RESTDERR_PROGRAMS = $(subst .stderr,.restderr,$(STDERR_PROGRAMS))
SEMA_PROGRAMS = $(addprefix out/, $(addsuffix .sema, $(PROGRAMS_ALL)))
RESEMA_PROGRAMS = $(subst .sema,.resema,$(SEMA_PROGRAMS))
VG_PROGRAMS = $(addprefix out/, $(addsuffix .vg, $(PROGRAMS_ALL)))
VGO_PROGRAMS = $(addprefix out/, $(addsuffix .vgo, $(PROGRAMS_ALL)))
VG_FLAGS ?= --leak-check=full --error-exitcode=1

# Older versions of valgrind don't support this flag.
VG_FLAGS += $(shell valgrind --help | grep errors-for-leak-kinds > /dev/null 2>&1 && echo "--errors-for-leak-kinds=all")


all : $(TEST_REPORT)


test : $(PROGRAMS_DUMMY) $(PROGRAMS_SEMA_DUMMY) $(PROGRAMS_NEGATIVE_DUMMY)

$(PROGRAMS_DUMMY) : %.dummy : % $(FRONTEND) $(FRONTEND_DEBUG) $(COMPARE_SCRIPT)
	$(realpath $(FRONTEND)) --no-warn --include $(dir $<)include/ $<
	$(realpath $(COMPARE_SCRIPT)) $(realpath $(FRONTEND)) $<
	valgrind -q $(VG_FLAGS) $(realpath $(FRONTEND)) --no-warn --include $(dir $<)include/ $<

$(PROGRAMS_SEMA_DUMMY) : %.dummy : % $(FRONTEND) $(FRONTEND_DEBUG) $(COMPARE_SCRIPT)
	$(realpath $(FRONTEND)) --no-warn --sema-tree --sema-unused-decl --include $(dir $<)include/ $<
	valgrind -q $(VG_FLAGS) $(realpath $(FRONTEND)) --no-warn --include $(dir $<)include/ $<

$(PROGRAMS_NEGATIVE_DUMMY) : %.dummy : % $(FRONTEND) $(FRONTEND_DEBUG) $(COMPARE_SCRIPT)
	! $(realpath $(FRONTEND)) --no-warn --include $(dir $<)include/ $< 2> /dev/null


out-dir:
	@mkdir -p out out/programs out/programs/nist out/programs/sema out/programs/negative out/programs/todo

$(TEST_EXEC) : $(TEST_SOURCE) out-dir
	$(CC) -pthread -Wall -Wextra $< -o $@

test-report : $(TEST_REPORT)

test-report-lite : $(TEST_REPORT_LITE)

$(TEST_REPORT) : out-dir $(TEST_EXEC) $(COMPARE_SCRIPT) $(FRONTEND) $(FRONTEND_DEBUG)
	@$(realpath $(TEST_EXEC)) $(realpath $(FRONTEND)) 1 $(TEST_REPORT_THREADS) > $(TEST_REPORT)

$(TEST_REPORT_LITE) : out-dir $(TEST_EXEC) $(COMPARE_SCRIPT) $(FRONTEND)
	@$(realpath $(TEST_EXEC)) $(realpath $(FRONTEND)) 0 $(TEST_REPORT_THREADS) > $(TEST_REPORT_LITE)

$(STDERR_PROGRAMS) : %.stderr : %.sema

$(SEMA_PROGRAMS) : out/%.sema : % out-dir $(FRONTEND)
	@$(realpath $(FRONTEND)) --sema-tree --sema-unused-decl --include $(dir $<)include/ $< 2> $(subst .sema,.stderr,$@) > $@

$(RESTDERR_PROGRAMS) : %.restderr : %.resema

$(RESEMA_PROGRAMS) : %.resema : %.sema out-dir $(FRONTEND)
	@$(realpath $(FRONTEND)) --sema-tree --sema-unused-decl --include $(dir $<)include/ $< 2> $(subst .resema,.restderr,$@) > $@

valgrind: $(VG_PROGRAMS)

valgrind-optimized: $(VGO_PROGRAMS)

$(VG_PROGRAMS) : out/%.vg : % out-dir $(FRONTEND_DEBUG)
	valgrind -v $(VG_FLAGS) --track-origins=yes $(realpath $(FRONTEND_DEBUG)) --include $(dir $<)include/ $< > $@ 2>&1

$(VGO_PROGRAMS) : out/%.vgo : % out-dir $(FRONTEND)
	valgrind -v $(VG_FLAGS) $(realpath $(FRONTEND)) --include $(dir $<)include/ $< > $@ 2>&1


clean:
	rm -rf out


.PHONY : all clean test test-report test-report-lite valgrind valgrind-optimized $(PROGRAMS_DUMMY) out-dir
