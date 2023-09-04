FROM swift:5.8.1-jammy AS package

WORKDIR /root

COPY Package.* .
RUN swift package resolve

FROM package AS source

COPY Sources Sources
COPY Tests Tests

FROM source AS source-debug
RUN swift build

FROM source AS source-release
RUN swift build -c release

FROM source AS docs

COPY docs.sh .

RUN sh docs.sh

FROM swift:5.8.1-jammy
COPY --from=source-debug /root/.build/debug /root/.build/debug
COPY --from=source-release /root/.build/release /root/.build/release
COPY --from=docs /root/docs /root/docs
