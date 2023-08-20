FROM swift:5.8.1-jammy AS package

WORKDIR /root

COPY Package.* .
RUN RESOLVE_COMMAND_PLUGINS=1 swift package resolve

FROM package AS source

COPY Sources Sources
COPY Tests Tests

FROM source AS source-debug
RUN swift build

FROM source AS docs

COPY docs.sh .

# RUN RESOLVE_COMMAND_PLUGINS=1 swift build

RUN RESOLVE_COMMAND_PLUGINS=1 sh docs.sh

FROM swift:5.8.1-jammy
COPY --from=source-debug /root/.build/debug /root/.build/debug
COPY --from=docs /root/docs /root/docs