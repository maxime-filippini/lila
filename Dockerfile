ARG GLEAM_VERSION=v1.7.0


FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-erlang-alpine AS builder

COPY . /build/server

RUN cd /build/server \
    && gleam export erlang-shipment

FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-erlang-alpine

COPY --from=builder /build/server/build/erlang-shipment /app

EXPOSE 42069
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]