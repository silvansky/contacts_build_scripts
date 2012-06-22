#!/bin/sh

ILBC_DIR="iLBC"
RFC_URL="http://www.ietf.org/rfc"
RFC_FILENAME="rfc3951.txt"
ES_URL="http://www.ilbcfreeware.org/documentation"
ES_FILENAME="extract-cfile.txt"
ES_MV_FILENAME="extract-cfile.awk"
PRO_FILE="iLBC.pro"

echo "Fetching sources..."

rm -rf $ILBC_DIR
mkdir $ILBC_DIR && cd $ILBC_DIR
wget ${RFC_URL}/${RFC_FILENAME}
wget ${ES_URL}/${ES_FILENAME}
mv $ES_FILENAME $ES_MV_FILENAME
awk -f $ES_MV_FILENAME $RFC_FILENAME

echo "Creating Makefile..."

echo "CC=gcc
OPTS=-Wall -pedantic
SOURCES=\$(wildcard *.c)
OBJECTS=\$(SOURCES:.c=.o)

LIBFILE=libilbc.a

all: \$(LIBFILE)

\$(LIBFILE): \$(OBJECTS)
	libtool -o \$@ -static \$^

.c.o:
	\$(CC) -c \$(OPTS) \$<

clean:
	rm \$(LIBFILE) \$(OBJECTS)

install:
	cp \$(LIBFILE) /usr/local/lib/

uninstall:
	rm /usr/local/lib/\$(LIBFILE)
" > Makefile

#cat Makefile
echo "Running make..."

make

echo "

Run \"cd $ILBC_DIR && sudo make install\" now!
"
