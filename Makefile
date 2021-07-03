CC := gcc
CXX := g++
CFLAGS := -Wall -O3
CXXFLAGS := -Wall -O3

PROGRAM := main
SRCS := main.cpp
OBJS := $(SRCS:%.cpp=%.o)
DEPS := $(SRCS:%.cpp=%.d)

.SUFFIXES: .cpp .c .o

.PHONY: all
all: $(PROGRAM)

-include $(DEPS)

$(PROGRAM): $(OBJS)
	$(CXX) -o $(PROGRAM) $^

.cpp.o:
	$(CXX) $(CXXFLAGS) -MMD -MP -c $<

.PHONY: clean
clean:
	$(RM) $(PROGRAM) $(OBJS) depend.inc

.PHONY: test
test: $(PROGRAM)
	# NOTE: shell command which has '-' prefix ignore exit code
	-false
	echo "[TEST]"
	./$(PROGRAM)

hoge:
	ls hoge

fuga:
	ls fuga

# DO NOT DELETE
