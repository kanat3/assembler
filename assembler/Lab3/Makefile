CROSS_COMPILE ?= aarch64-linux-gnu-

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static

SRCS = lab.s
OBJS = $(SRCS:.s=.o)

EXE = lab

clean:
		rm -rf $(EXE) $(OBJS)

all: $(SRCS) $(EXE)

$(EXE): $(OBJS)
		$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
		$(AS) $(ASFLAGS) $< -o $@
