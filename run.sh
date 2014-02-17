#!/bin/sh
export PERL5LIB=extlib/lib/perl5
for i in `seq 1 50`
do
  perl script/worker.pl
  echo "died $i `date`"
done
