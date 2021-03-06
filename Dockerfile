FROM crystallang/crystal:0.35.1-alpine
COPY . /src
WORKDIR /src

# Install the latest version of LibSSH2 and the GDB debugger
RUN apk update
RUN apk add libssh2 libssh2-dev gdb

# Build App
RUN rm -rf lib bin
RUN mkdir -p /src/bin/drivers
RUN shards build --error-trace --production

# Run the app binding on port 8080
EXPOSE 8080
ENTRYPOINT ["/src/bin/test-harness"]
CMD ["/src/bin/test-harness", "-b", "0.0.0.0", "-p", "8080"]
