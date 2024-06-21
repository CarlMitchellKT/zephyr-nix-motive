{ python3
, zephyr-src
, pyproject-nix
, clang-tools_17
, gitlint
, lib
, extraLibs ? [ ]
}:

let
  python = python3.override {
    self = python;
    packageOverrides = self: super: {
      # HACK: Zephyr uses pypi to install non-Python deps
      clang-format = clang-tools_17;
      inherit gitlint;

      # HACK: Older Zephyr depends on these missing dependencies
      sphinxcontrib-svg2pdfconverter = super.sphinxcontrib-svg2pdfconverter or null;
    };
  };

  project = pyproject-nix.lib.project.loadRequirementsTxt {
    requirements = zephyr-src + "/scripts/requirements.txt";
  };

  invalidConstraints = project.validators.validateVersionConstraints { inherit python; };

in
lib.warnIf
  (invalidConstraints != { })
  "zephyr-pythonEnv: Found invalid Python constraints for: ${builtins.toJSON (lib.attrNames invalidConstraints)}"
  (python.withPackages (project.renderers.withPackages {
    inherit python;
    extraPackages = ps: [
      ps.west
      ps.python-can
      ps.pyserial
      ps.protobuf
      ps.dqdm
      ps.pyelftools
      ps.PyYAML
      ps.pykwalify
      ps.canopen
      ps.packaging
      ps.progress
      ps.psutil
      ps.pylink-square
      ps.requests
      ps.intelhex
      ps.colorama
      ps.ply
      ps.coverage
      ps.pytest
      ps.mypy
      ps.mock
      ps.python-magic
      ps.lxml
      ps.junitparser
      ps.pylint
      ps.yamllint
      ps.anytree
      ps.gitlint
      ps.junit2html
      ps.clang-format
      ps.lpc_checksum
      ps.Pillow
      ps.imgtool
      ps.grpcio-tools
      ps.PyGithub
      ps.graphviz
      ps.zcbor
      ps.pyocd
      ps.tabulate
      ps.natsort
      ps.cbor
    ] ++ extraLibs;
  }))
