FROM debian:latest
##################
# Instructions:
# * mkdir -p out
# * docker build . -t nh-tools
# * docker run --env-file ./env.list -v "`pwd`/out:/root/nethunter-installer-tools/out/" -t nh-tools
# Output files will be in output/[arch] outside of docker container *
##################

ENV NH_WORKSPACE /root/nethunter-installer-tools

RUN apt-get update && apt-get install -y autopoint libtool libreadline-dev
RUN mkdir -p ${NH_WORKSPACE}
COPY .  ${NH_WORKSPACE}
WORKDIR ${NH_WORKSPACE}
RUN chmod +x bootstrap.sh && ./bootstrap.sh

CMD ["./build_all.sh"]
