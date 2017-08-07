FROM debian:latest

ENV NH_WORKSPACE /root/nethunter-installer-tools

RUN mkdir -p ${NH_WORKSPACE}
COPY .  ${NH_WORKSPACE}
WORKDIR ${NH_WORKSPACE}
RUN chmod +x bootstrap.sh && ./bootstrap.sh

CMD ["./build_all.sh"]
