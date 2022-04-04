{ config, lib, ... }:

{
  options.rootDir = lib.mkOption {
    type = lib.types.path;
  };

  config = {
    rootDir = ../..;
  };
}
