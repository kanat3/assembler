CROSS_COMPILE ?= aarch64-linux-gnu-

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static

ifeq ($(MAKECMDGOALS), sort)
	ASFLAGS := $(ASFLAGS) --defsym sort=1
endif

ifeq ($(MAKECMDGOALS), rsort)
	ASFLAGS := $(ASFLAGS) --defsym rsort=1
endif

SRCS = lab.s
OBJS = $(SRCS:.s=.o)

EXE = lab

clean:
		rm -rf $(EXE) $(OBJS)

sort: $(SRCS) $(EXE)

rsort: $(SRCS) $(EXE)

$(EXE): $(OBJS)
		$(LD) $(LDFLAGS) $(OBJS) -o $@
		
.s.o:
		$(AS) $(ASFLAGS) $< -o $@
