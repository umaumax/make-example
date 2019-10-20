CC := gcc
CXX := g++
CFLAGS := -Wall -O3
CXXFLAGS := -Wall -O3

PROGRAM := main
OBJS := main.o

.SUFFIXES: .cpp .c .o

.PHONY: all
all: depend $(PROGRAM)

$(PROGRAM): $(OBJS)
	$(CXX) -o $(PROGRAM) $^

.c.o:
	$(CXX) $(CXXFLAGS) -c $<

.PHONY: clean
clean:
	$(RM) $(PROGRAM) $(OBJS) depend.inc

.PHONY: depend
depend:
	makedepend -- $(CXXFLAGS) -- $(ALL_C_FILES)

.PHONY: test
test: $(PROGRAM)
	# NOTE: shell command which has '-' prefix ignore exit code
	-false
	echo "[TEST]"
	./$(PROGRAM)

-include depend.inc
# DO NOT DELETE
