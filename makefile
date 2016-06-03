FOR = lf95
FFLAGS = -O --dbl --quiet --staticlink
.f.o:
	$(FOR) $(FFLAGS) -c $<

OBJ = 	mf2k.o \
	de45.o \
	fhb1.o \
	glo1bas6.o \
	gage5.o \
	gwf1bas6.o \
	gwf1bcf6.o \
	gwf1chd6.o \
	gwf1drn6.o \
	gwf1drt1.o \
	gwf1ets1.o \
	gwf1evt6.o \
	gwf1ghb6.o \
	gwf1hfb6.o \
	gwf1huf1.o \
	gwf1ibs6.o \
	gwf1lpf1.o \
	gwf1rch6.o \
	gwf1riv6.o \
	gwf1str6.o \
	gwf1wel6.o \
	hydmod.o \
	lak3.o \
	memchk.o \
	obs1adv2.o \
	obs1bas6.o \
	obs1drn6.o \
	obs1drt1.o \
	obs1ghb6.o \
	obs1riv6.o \
	obs1str6.o \
	parutl1.o \
	pcg2.o \
	pes1bas6.o \
	pes1gau1.o \
	res1.o \
	sen1bas6.o \
	sen1chd6.o \
	sen1drn6.o \
	sen1drt1.o \
	sen1ets1.o \
	sen1evt6.o \
	sen1ghb6.o \
	sen1hfb6.o \
	sen1huf1.o \
	sen1lpf1.o \
	sen1rch6.o \
	sen1riv6.o \
	sen1str6.o \
	sen1wel6.o \
	sip5.o \
	sor5.o \
	lmt6.o \
	lmg1.o \
	para-non.o \
	amg1r5.o \
	utl6.o \
	ctime.o

mf2k: $(OBJ)
	$(FOR) $(FFLAGS) -o mf2k $(OBJ)

clean:
	rm -f mf2k *.o
