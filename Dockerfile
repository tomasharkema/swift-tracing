FROM swift:5.8.1-jammy

WORKDIR /root

COPY Package.* .
RUN RESOLVE_COMMAND_PLUGINS=1 swift package resolve

COPY Sources Sources
COPY Tests Tests
COPY docs.sh .

# RUN RESOLVE_COMMAND_PLUGINS=1 swift build

RUN RESOLVE_COMMAND_PLUGINS=1 sh docs.sh