return {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   ssh_domains = {},

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = {
      -- {
      --    name = 'WSL:kali-linux',
      --    distribution = 'kali-linux'
      -- },
   },
   -- default_domain = 'WSL:kali-linux'
}
