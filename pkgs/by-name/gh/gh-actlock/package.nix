{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
  nix-update-script,
}:
let
  mainProgram = "gh-actlock";
in
buildGoModule (finalAttrs: {
  pname = "gh-actlock";
  version = "0.13.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "esacteksab";
    repo = "gh-actlock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N5kWBxEe7aGYN+WRLBnteBDrtNC0AuhotCfFjRgBeKI=";
  };

  vendorHash = "sha256-JCnxy0i71PGqha60pJ4/0bTAZ4YhWCdLgcvn2iZQMwY=";

  env.CGO_ENABLED = 0;

  doCheck = true;

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd '${mainProgram}'         \
      --bash <("$out/bin/${mainProgram}" completion bash) \
      --zsh  <("$out/bin/${mainProgram}" completion zsh)  \
      --fish <("$out/bin/${mainProgram}" completion fish)
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  doInstallCheck = true;

  checkFlags = [
    # This test requires a network connection
    "-skip=TestNewClient_WithoutToken"
  ];

  preCheck = ''
    export XDG_CACHE_HOME="$TMPDIR/.cache"
    mkdir -p "$XDG_CACHE_HOME"
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex=^v([\\d\\.]+)$"
      ];
    };
  };

  ldflags = [
    "-s"
    "-w"
    "-X github.com/esacteksab/gh-actlock/cmd.Version=${finalAttrs.version}"
    "-X github.com/esacteksab/gh-actlock/cmd.BuiltBy=Nix"
  ];

  meta = {
    inherit mainProgram;
    homepage = "https://github.com/esacteksab/gh-actlock";
    description = "gh extension to lock GitHub Actions to a SHA";
    longDescription = ''
      Improves the security of your GitHub Actions workflows by automatically
      pinning action references to specific commit SHAs.
    '';
    changelog = "https://github.com/esacteksab/gh-actlock/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://github.com/esacteksab/gh-actlock/releases";
    maintainers = [ lib.maintainers.panchoh ];
    license = lib.licenses.mit;
  };
})
