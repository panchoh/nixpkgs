{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
}:

stdenv.mkDerivation rec {
  pname = "a52dec";
  version = "0.8.0";

  src = fetchFromGitLab {
    domain = "git.adelielinux.org";
    owner = "community";
    repo = "a52dec";
    tag = "v${version}";
    hash = "sha256-Z4riiwetJkhQYa+AD8qOiwB1+cuLbOyN/g7D8HM8Pkw=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  configureFlags = [
    "--enable-shared"
    # Define inline as __attribute__ ((__always_inline__))
    "ac_cv_c_inline=yes"
  ];

  makeFlags = [ "AR=${stdenv.cc.targetPrefix}ar" ];

  # fails 1 out of 1 tests with "BAD GLOBAL SYMBOLS" on i686
  # which can also be fixed with
  # hardeningDisable = lib.optional stdenv.hostPlatform.isi686 "pic";
  # but it's better to disable tests than loose ASLR on i686
  doCheck = !stdenv.hostPlatform.isi686;

  meta = {
    description = "ATSC A/52 stream decoder";
    homepage = "https://liba52.sourceforge.io/";
    changelog = "https://git.adelielinux.org/community/a52dec/-/blob/v${version}/ChangeLog?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ wegank ];
    mainProgram = "a52dec";
    platforms = lib.platforms.unix;
  };
}
