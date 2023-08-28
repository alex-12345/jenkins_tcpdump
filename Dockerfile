FROM aflplusplus/aflplusplus:latest

RUN apt update && apt install libpcap-dev screen iputils-ping -y