FROM sdurrheimer/alpine-glibc

MAINTAINER David Igou <igou@redhat.com> 

WORKDIR /

ADD ovirt-vm-prometheus-bridge .

ENTRYPOINT ["/ovirt-vm-prometheus-bridge"]
