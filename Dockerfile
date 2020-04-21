FROM registry.opensuse.org/yast/sle-15/sp2/containers/yast-ruby
COPY . /usr/src/app
# a workaround to allow package building on a non-s390 machine
RUN sed -i "/^ExclusiveArch:/d" package/*.spec
RUN git update-index --assume-unchanged package/*.spec

