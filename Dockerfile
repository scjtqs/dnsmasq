FROM alpine:3.11
LABEL maintainer="scjtqs@qq.com"
ENV TIMEZONE            Asia/Shanghai
# webproc release settings
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
#RUN echo -e "http://mirrors.aliyun.com/alpine/v3.11/main" > /etc/apk/repositories
#RUN echo -e "\n" >> /etc/apk/repositories
#RUN echo -e "http://mirrors.aliyun.com/alpine/v3.11/community" >> /etc/apk/repositories
# fetch dnsmasq and webproc binary
WORKDIR /usr/local/bin
RUN apk update \
	&& apk --no-cache add dnsmasq \
	&& apk add --no-cache --virtual .build-deps curl bash \
	&& curl https://i.jpillora.com/webproc | bash \
#	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
#    && apk add --no-cache go \
	&& apk del .build-deps
#configure dnsmasq
ENV GOPROXY https://go.likeli.top
ENV GO111MODULE on
#RUN go get -v github.com/jpillora/webproc
#RUN curl https://i.jpillora.com/webproc | bash
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
#run!
ENTRYPOINT ["webproc","--configuration-file","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]
