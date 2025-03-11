{ config, pkgs, ... }:
let

  kmsConfDir = pkgs.writeTextFile {
    name = "kmscon-config";
    destination = "/kmscon.conf";
    text = "";
  };

in
{
  config = {
    systemd.services."getty@tty1" = {
      enable = true;
      after = [
        "systemd-logind.service"
        "systemd-vconsole-setup.service"
      ];
      requires = [ "systemd-logind.service" ];

      serviceConfig.ExecStart = [
        ""
        ''
          ${pkgs.kmscon}/bin/kmscon "--vt=%I" --seats=seat0 --no-switchvt --configdir ${kmsConfDir} --login -- ${pkgs.shadow}/bin/login -p codman
        ''
      ];

      restartIfChanged = false;
    };
    systemd.services."getty@tty2" = {
      enable = true;
      after = [
        "systemd-logind.service"
        "systemd-vconsole-setup.service"
      ];
      requires = [ "systemd-logind.service" ];

      serviceConfig.ExecStart = [
        ""
        ''
          ${pkgs.kmscon}/bin/kmscon "--vt=%I" --seats=seat0 --no-switchvt --configdir ${kmsConfDir} --login -- ${pkgs.shadow}/bin/login -p codman
        ''
      ];

      restartIfChanged = false;
    };

    systemd.suppressedSystemUnits = [
      "kmscon@tty1.service"
      "kmscon@tty2.service"
    ];

    
    systemd.services.systemd-vconsole-setup.enable = false;
    systemd.services.reload-systemd-vconsole-setup.enable = false;
  };
}
