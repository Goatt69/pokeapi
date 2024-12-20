{pkgs}: {
  channel = "stable-24.05";
  packages = [
    pkgs.jdk17
    pkgs.unzip
  ];
  idx.extensions = [
    
  
 "Dart-Code.dart-code"
 "Dart-Code.flutter"];
  idx.previews = {
    previews = {
      web = {
        command = [
          "flutter"
          "run"
          "--machine"
          "-d"
          "web-server"
          "--web-hostname"
          "0.0.0.0"
          "--web-port"
          "$PORT"
          "--disable-host-check"
        ];
        manager = "flutter";
      };
      android = {
        command = [
          "flutter"
          "run"
          "--machine"
          "-d"
          "-d"
          "localhost:5555"
        ];
        manager = "flutter";
      };
    };
  };
}