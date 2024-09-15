{
  lib,
  python3Packages,
  fetchzip,
  writeScript,
}:

python3Packages.buildPythonApplication rec {
  pname = "pdf-parser";
  version = "0.7.4";

  src = fetchzip {
    url = "https://didierstevens.com/files/software/pdf-parser_V${
      lib.replaceStrings [ "." ] [ "_" ] version
    }.zip";
    hash = "sha256-sIprS2vp7z+rmtZn69yea0EmC3WftNfRVoxQLzj3acg=";
  };

  format = "other";

  installPhase = ''
    install -Dm555 pdf-parser.py $out/bin/pdf-parser.py
  '';

  preFixup = ''
    substituteInPlace $out/bin/pdf-parser.py \
      --replace '/usr/bin/python' '${python3Packages.python}/bin/python'
  '';

  passthru.updateScript = writeScript "update-pdf-parser" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p common-updater-scripts curl pcre2

    set -eu -o pipefail

    version="$(curl -s https://blog.didierstevens.com/programs/pdf-tools/ |
      pcre2grep -O '$1.$2.$3' '\bpdf-parser_V(\d+)_(\d+)_(\d+)\.zip\b.*')"

    update-source-version "$UPDATE_NIX_ATTR_PATH" "$version"
  '';

  meta = {
    description = "Parse a PDF document";
    longDescription = ''
      This tool will parse a PDF document to identify the fundamental elements used in the analyzed file.
      It will not render a PDF document.
    '';
    homepage = "https://blog.didierstevens.com/programs/pdf-tools/";
    license = lib.licenses.publicDomain;
    maintainers = [ lib.maintainers.lightdiscord ];
    platforms = lib.platforms.all;
    mainProgram = "pdf-parser.py";
  };
}
