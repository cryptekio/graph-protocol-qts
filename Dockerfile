FROM ruby:3.0.0

WORKDIR /myapp

COPY . /myapp

RUN apt-get update && apt-get install -y libjemalloc2
RUN bundle install
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
RUN mkdir -p /tmp/imports

ENTRYPOINT ["entrypoint.sh"]
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
EXPOSE 3000


CMD ["rails", "server", "-b", "0.0.0.0"]
