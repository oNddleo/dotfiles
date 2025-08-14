# Nushell Environment Configuration

# Force add Homebrew to PATH immediately
if ('/opt/homebrew/bin/brew' | path exists) {
    $env.PATH = (['/opt/homebrew/bin', '/opt/homebrew/sbin'] | append ($env.PATH | split row (char esep)) | uniq)
    $env.HOMEBREW_PREFIX = "/opt/homebrew"
} else if ('/usr/local/bin/brew' | path exists) {
    $env.PATH = (['/usr/local/bin', '/usr/local/sbin'] | append ($env.PATH | split row (char esep)) | uniq)
    $env.HOMEBREW_PREFIX = "/usr/local"
}

# Test if brew is now accessible
if (which brew | length) == 0 {
     print "(ansi red)ERROR: Homebrew still not accessible!(ansi reset)"
} else {
     print "(ansi green)✓ Homebrew accessible(ansi reset)"
 }

# Directories for scripts and plugins
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
    ($nu.default-config-dir | path join 'completions')
]

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# PATH setup - add paths that exist
let additional_paths = [
    '/opt/homebrew/bin'
    '/opt/homebrew/sbin'
    '/usr/local/bin'
    '/usr/bin'
    '/usr/sbin'
    '/bin'
    '/sbin'
    '/opt/nvim-linux64/bin'
    '/usr/local/sbin'
    ($env.HOME | path join '.local' 'bin')
    ($env.HOME | path join '.asdf' 'shims')
    ($env.HOME | path join '.asdf' 'bin')
    /Applications/Xcode.app/Contents/Developer/usr/bin
]

$env.PATH = ($env.PATH | split row (char esep) | prepend ($additional_paths | where { |p| $p | path exists }) | uniq)

# Homebrew setup - simple version
if ('/opt/homebrew/bin/brew' | path exists) {
    $env.HOMEBREW_PREFIX = "/opt/homebrew"
    $env.HOMEBREW_CELLAR = "/opt/homebrew/Cellar" 
    $env.HOMEBREW_REPOSITORY = "/opt/homebrew"
} else if ('/usr/local/bin/brew' | path exists) {
    $env.HOMEBREW_PREFIX = "/usr/local"
    $env.HOMEBREW_CELLAR = "/usr/local/Cellar"
    $env.HOMEBREW_REPOSITORY = "/usr/local"
}

# Basic environment variables
$env.EDITOR = (
  if (which nvim | is-empty) {
    if (which vim | is-empty) { "nano" } else { "vim" }
  } else { "nvim" }
)
$env.VISUAL = $env.EDITOR
$env.LANG   = "en_US.UTF-8"
$env.LC_ALL = "en_US.UTF-8"

# Development tools
$env.PYTHONDONTWRITEBYTECODE = "1"

# asdf setup - will be loaded at runtime
$env.ASDF_DIR = ($env.HOME | path join '.asdf')
$env.ASDF_DATA_DIR = $env.ASDF_DIR

# Terminal settings
$env.LESS = "-R -F -X"
$env.PAGER = "less"

# fzf settings
$env.FZF_DEFAULT_OPTS = "--layout=reverse --border=none --color=bg:-1,bg+:-1,gutter:-1,border:-1"
if (which fd | length) > 0 {
    $env.FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"
}

# Load .env file if it exists in home directory
let home_env = ($env.HOME | path join '.env')
if ($home_env | path exists) {
    open $home_env | lines | where { |line|
        ($line | str contains '=') and not ($line | str starts-with '#')
    } | each { |line|
        let parts = ($line | split column '=')
        if ($parts | columns | length) >= 2 {
            let key = ($parts | get 0 | str trim)
            let value = ($parts | get 1 | str trim -c '"' | str trim -c "'")
            load-env { $key: $value }
        }
    } | ignore
}

# Starship setup - simple version
if (which starship | length) > 0 {
    mkdir ($env.HOME | path join '.cache' 'starship')
    $env.STARSHIP_SHELL = "nu"
}

# Create important directories
[
    ($env.HOME | path join '.local' 'bin')
    ($env.HOME | path join '.cache')
    ($env.HOME | path join '.config')
    ($nu.default-config-dir | path join 'scripts')
    ($nu.default-config-dir | path join 'completions')
] | each { |dir| if not ($dir | path exists) { mkdir $dir } } | ignore

# SSL/TLS certificate configuration
# $env.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
# $env.SSL_CERT_DIR = "/etc/ssl/certs"
# $env.REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt"
# $env.CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt"

# Tool-specific certificate configuration
# $env.BUN_CA_BUNDLE_PATH = "/etc/ssl/certs/ca-certificates.crt"
# $env.DENO_CERT = "/etc/ssl/certs/ca-certificates.crt"
# $env.NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt"
# $env.NODE_OPTIONS = "--use-openssl-ca"