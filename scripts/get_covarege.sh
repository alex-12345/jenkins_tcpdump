for F in $PWD/tcpdumpfuzz/M/queue/*; do ./tcpdump -vvv -ee -nnr $F || true; done
for F in $PWD/tcpdumpfuzz/S-1/queue/*; do ./tcpdump -vvv -ee -nnr $F || true; done
for F in $PWD/tcpdumpfuzz/S-2/queue/*; do ./tcpdump -vvv -ee -nnr $F || true; done