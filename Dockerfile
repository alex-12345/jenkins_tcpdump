FROM aflplusplus/aflplusplus:latest

RUN apt update && apt install libpcap-dev libssl-dev -y