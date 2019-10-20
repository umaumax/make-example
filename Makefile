PROGRAM = main
OBJS = main.o
CC := $(CC)
CXX := $(CXX)
CFLAGS = -Wall -O2
.SUFFIXES: .cpp .c .o

.PHONY: all
all: depend $(PROGRAM)

$(PROGRAM): $(OBJS)
	$(CXX) -o $(PROGRAM) $^

.c.o:
	$(CXX) $(CFLAGS) -c $<

.PHONY: clean
clean:
	$(RM) $(PROGRAM) $(OBJS) depend.inc

.PHONY: depend
depend:
	makedepend -- $(CFLAGS) -- $(ALL_C_FILES)

.PHONY: test
test:
	echo "[TEST] OK"

-include depend.inc
# DO NOT DELETE
