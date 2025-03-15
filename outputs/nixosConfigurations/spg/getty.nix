{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.ff.services.kmscon;

  baseArgs =
    [
      "--login-program"
      "${pkgs.shadow}/bin/login"
    ]
    ++ lib.optionals (cfg.autologinUser != null) [
      "--autologin"
      cfg.autologinUser
    ];

  gettyCmd = args: "${lib.getExe' pkgs.util-linux "agetty"} ${lib.escapeShellArgs baseArgs} ${args}";

in
{
  options.ff.services.kmscon = {

    enable = lib.mkEnableOption "Enable kms console";

    autologinUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Username of the account that will be automatically logged in at the console.
        If unspecified, a login prompt is shown as usual.
      '';
    };

    disableAt = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = "Numeric identifier of ttys that should not use the kms console";
      example = [
        "tty2"
      ];
    };

  };
  config = lib.mkIf cfg.enable {

    services.kmscon.enable = true;

    systemd = lib.mkIf (cfg.disableAt != null) {

      services = lib.mkMerge (
        builtins.map (ttyId: {

          "kmsconvt@${ttyId}".enable = false;

          "getty@${ttyId}" = {
            enable = true;
            wantedBy = [ "default.target" ];
            serviceConfig.ExecStart = [
              "" # override upstream default with an empty ExecStart
              (gettyCmd "--noclear --keep-baud pts/${ttyId} 115200,38400,9600 $TERM")
            ];
            environment.TTY = "${ttyId}";
            restartIfChanged = false;
          };
        }) cfg.disableAt
      );
    };
  };
}
