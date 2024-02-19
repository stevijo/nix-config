{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
in
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 1000;
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$golang"
        "$fill"
        "$status"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      username = {
        style_user = "yellow";
        style_root = "red";
        format = "[$user]($style)";
        show_always = false;
      };

      hostname = {
        ssh_only = true;
        format = "[@$hostname]($style) in ";
        style = "green";
      };

      directory = {
        truncation_length = -1;
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "blue";
        read_only = " ";
        truncate_to_repo = false;
        truncation_symbol = "../";
      };

      git_branch = {
        format = "on [$symbol$branch]($style) ";
        style = "purple";
        symbol = " ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "purple";
        conflicted = " ";
        ahead = " ";
        behind = " ";
        diverged = "󰆗 ";
        up_to_date = " ";
        untracked = " ";
        stashed = " ";
        modified = " ";
        staged = " ";
        renamed = " ";
        deleted = " ";
      };

      fill = {
        symbol = " ";
      };

      golang = {
        symbol = "󰟓 ";
      };

      status = {
        disabled = false;
        format = "[$symbol]($style) ";
        symbol = " ";
        success_symbol = " ";
        style = "red";
      };

      cmd_duration = {
        min_time = 2000;
        format = "took [$duration]($style) ";
        style = "yellow";
      };

      character = {
        success_symbol = "[](green)";
        error_symbol = "[](green)";
        vicmd_symbol = "[](purple)";
      };
    };
  };
}
