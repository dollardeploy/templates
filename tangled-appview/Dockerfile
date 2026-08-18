# ponytail: nix stays in the runtime image. The upstream flake is the only
# supported way to build the appview (its static assets — tailwind, icons,
# fonts, generated logos — come from `appview-static-files`), and the
# `pkgsStatic-*` outputs miss the binary cache and rebuild half of nixpkgs.
FROM nixos/nix:2.31.2

ARG TAG=v1.16.1-alpha
ARG FLAKE=git+https://tangled.org/@tangled.org/core

RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# goat generates the OAuth client key; appview is the server itself.
# ref= resolves against refs/heads/, so tags need the full ref path.
RUN nix profile add \
      "${FLAKE}?ref=refs/tags/${TAG}#appview" \
      "${FLAKE}?ref=refs/tags/${TAG}#goat" \
    && nix store gc

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
