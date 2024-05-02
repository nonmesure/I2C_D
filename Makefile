LDFLAGS =
DC      = gdc
PROGS   = setfreq8564
RPROGS  = r8564
WPROGS  = w8564
SRCS    = i2c_test.d
RSRCS   = r8564.d
WSRCS   = w8564.d
LIBSRCS = i2cdev_lib.d rtc8564nb_lib.d
LIBOBJS = i2c_lib.o
LIBS    = libi2c.a

all: $(LIBOBJS) $(LIBS) $(PROGS) $(RPROGS) $(WPROGS)

$(PROGS): $(SRCS) $(LIBSRCS)
	$(DC) $(LDFLAGS) $(SRCS) $(LIBS) -o $@

$(RPROGS): $(RSRCS) $(LIBSRCS)
	$(DC) $(LDFLAGS) $(RSRCS) $(LIBS) -o $@

$(WPROGS): $(WSRCS) $(LIBSRCS)
	$(DC) $(LDFLAGS) $(WSRCS) $(LIBS) -o $@

$(LIBOBJS): $(LIBSRCS)
	$(DC) -c $(LDFLAGS) $(LIBSRCS) -o $@

$(LIBS): $(LIBOBJS)
	$(AR) rv $@ $?

clean:
	rm -f $(PROGS) $(RPROGS) $(WPROGS) $(LIBS) *.o
