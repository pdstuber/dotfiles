# Home Macs

- **Containers:** no `docker` binary, but Apple's `container` CLI builds and runs Dockerfiles
  (`container build -t NAME DIR`, `container run`). Never report "no Docker" without trying it;
  if `container system status` says not running, `container system start`.
- **Rust and Emscripten:** `rustup` holds several toolchains side by side; pick one per command
  (`cargo +TOOLCHAIN`, list with `rustup toolchain list`) and never change the default. Emscripten is
  in `~/emsdk` and not on `PATH`: source `~/emsdk/emsdk_env.sh` (fish: `emsdk_env.fish`) in the command
  that needs `emcc`, so a bare `command -v emcc` says missing when it is installed. Version pins belong
  in the project's notes.
