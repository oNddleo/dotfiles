# Nushell Config File
#
# version = "0.106.0"

$env.config.color_config = {
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    empty: blue
    bool: light_cyan
    int: white
    filesize: cyan
    duration: white
    datetime: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cell-path: white
    row_index: green_bold
    record: white
    list: white
    closure: green_bold
    glob:cyan_bold
    block: white
    hints: dark_gray
    search_result: { bg: red fg: white }
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_external_resolved: light_yellow_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    shape_glob_interpolation: cyan_bold
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: cyan_bold
    shape_keyword: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_match_pattern: green
    shape_matching_brackets: { attr: u }
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
    shape_vardecl: purple
    shape_raw_string: light_purple
    shape_garbage: {
        fg: white
        bg: red
        attr: b
    }
}
$env.STARSHIP_SHELL = "nu"
$env.config.shell_integration = {
	osc2: false
	osc7: false
	osc8: false
	osc9_9: false
	osc133: false
	osc633: false
	reset_application_mode: false
}
$env.config.use_ansi_coloring = true
def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)' | str replace '\u{1b}\[[0-9;]*R' ''
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ": "
$env.PROMPT_INDICATOR_VI_NORMAL = "〉"
$env.PROMPT_MULTILINE_INDICATOR = "::: "

# Load starship prompt - Fixed version
if (which starship | length) > 0 {
    let starship_cache = ($env.HOME | path join '.cache' 'starship' 'init.nu')
    if not ($starship_cache | path exists) {
        starship init nu | save -f $starship_cache
    }
    # Use overlay to load starship instead of source with variable
    try {
        overlay use ~/.cache/starship/init.nu
    } catch {
        # Fallback: regenerate and use exec
        starship init nu | save -f ~/.cache/starship/init.nu
        exec nu
    }
    if ($env.TMUX? | is-not-empty) {
        $env.STARSHIP_CONFIG = ($env.HOME | path join '.config' 'starship-tmux.toml')
    }
}


# Color theme
let dark_theme = {
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    empty: blue
    bool: white
    int: white
    filesize: cyan
    duration: white
    date: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cellpath: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray
    search_result: red
    shape_and: purple_bold
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    shape_garbage: { fg: white bg: red attr: b}
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_match_pattern: green
    shape_matching_brackets: { attr: u }
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_or: purple_bold
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
    shape_vardecl: purple
}
# General settings
$env.config = {
    show_banner: true
    footer_mode: "auto"
    float_precision: 2
    use_ansi_coloring: true
    edit_mode: emacs # or vi
    buffer_editor: "nvim" # or "vim", "nano"

    table: {
        mode: rounded # basic, compact, light, thin, with_love, rounded, reinforced, heavy, none, other
        index_mode: always # always, never, auto
        show_empty: true
        trim: {
            methodology: wrapping # wrapping or truncating
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
    }

    error_style: "fancy" # plain, fancy

    datetime_format: {
        normal: '%a, %d %b %Y %H:%M:%S %z'
        table: '%m/%d/%y %I:%M:%S%p'
    }

    explore: {
        help_banner: true
        exit_esc: true
        command_bar_text: '#C4C9C6'
        status_bar_background: {fg: '#1D1F21', bg: '#C4C9C6'}
        highlight: {bg: 'yellow', fg: 'black'}
        status: {
            error: {fg: 'white', bg: 'red'}
            warn: {}
            info: {}
        }
        try: {
            border_color: 'red'
            highlighted_color: 'blue'
        }
        table: {
            split_line: '#404040'
            cursor: true
            line_index: true
            line_shift: true
            line_head_top: true
            line_head_bottom: true
            show_head: true
            show_index: true
        }
        config: {
            cursor_color: {bg: 'yellow', fg: 'black'}
        }
    }

    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "plaintext" # "sqlite" or "plaintext"
        isolation: false
    }

    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy" # prefix or fuzzy
        external: {
            enable: true
            max_results: 100
            completer: null
        }
    }

    cursor_shape: {
        emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line
        vi_insert: block
        vi_normal: underscore
    }

    color_config: $dark_theme

    hooks: {
        pre_prompt: [{ ||
            null # replace with source code to run before the prompt is shown
        }]
        pre_execution: [{ ||
            null # replace with source code to run before the repl input is run
        }]
        env_change: {
            PWD: [{|before, after|
                null # replace with source code to run if the PWD environment is different since the last repl input
            }]
        }
        display_output: { ||
            if (term size).columns >= 100 { table -e } else { table }
        }
    }

    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]

    keybindings: [
        {
            name: completion_previous
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menuprevious }
        }
        {
            name: fzf-history
            mode: [emacs,vi_insert,vi_normal]
            modifier: control
            keycode: char_r
            event: { send: executehostcommand, cmd: "hist-fzf" }
        }
        {
            name: undo_or_previous_page
            modifier: control
            keycode: char_z
            mode: emacs
            event: {
                until: [
                    { send: menupageprevious }
                    { edit: undo }
                ]
            }
        }
        {
            name: yank
            modifier: control
            keycode: char_y
            mode: emacs
            event: {
                until: [
                    {edit: pastecutbufferafter}
                ]
            }
        }
        {
            name: unix-line-discard
            modifier: control
            keycode: char_u
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {edit: cutfromlinestart}
                ]
            }
        }
        {
            name: kill-line
            modifier: control
            keycode: char_k
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {edit: cuttolineend}
                ]
            }
        }
        {
            name: forward-word
            modifier: alt
            keycode: char_f
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {edit: movewordright}
                ]
            }
        }
        {
            name: backward-word
            modifier: alt
            keycode: char_b
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {edit: movewordleft}
                ]
            }
        }
        {
            name: delete-word
            modifier: alt
            keycode: char_d
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {edit: cutwordright}
                ]
            }
        }
        {
            name: backward-delete-word
            modifier: alt
            keycode: backspace
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {edit: cutwordleft}
                ]
            }
        }
        {
            name: fzf-file
            mode: ["emacs","vi_insert","vi_normal"]
            modifier: control
            keycode: char_f
            event: { send: executehostcommand, cmd: "fzf-file -m" }
        }
        { 
            name: fzf-open-file, 
            mode: ["emacs","vi_insert","vi_normal"], 
            modifier: control, 
            keycode: char_o,
            event: { send: executehostcommand, cmd: "fzf-open --cd -m" } 
        }
        {   
            name: fzf-cd,   
            mode: ["emacs","vi_insert","vi_normal"], 
            modifier: control,     
            keycode: char_c,
            event: { send: executehostcommand, cmd: "fzf-cd" } 
        }
        {
            name: fzf-git-file
            mode: [emacs, vi_insert, vi_normal]
            modifier: control
            keycode: char_g
            event: {
                until: [
                { edit: InsertString, value: "fzf-git-file -m" }
                { send: Enter }
                ]
            }
        }
    ]
}

# Aliases
alias ll = ls -la
alias la = ls -a
alias l = ls
alias c = clear
alias .. = cd ..
alias ... = cd ../..
alias grep = rg
alias cat = bat
alias find = fd
alias ps = procs
alias du = dust
alias top = btop

# Kubernetes
alias k = kubectl
alias kp = kubectl port-forward
alias kaf = kubectl apply -f
alias kdf = kubectl delete -f
alias hi = helm install
alias hu = helm update
alias h = helm
alias t = tmux

# Load asdf for Nushell
if ('~/.asdf/asdf.nu' | path expand | path exists) {
    source ~/.asdf/asdf.nu
}

def hist-fzf [] {
  let ignored = ["ls" "ll" "la" "history" "cd" "pwd" "clear" "c"]

  let lines = (
    history
    | reverse
    | where {|it|
        let cmd = ($it.command | into string | str trim)
        if $cmd == "" { return false }
        let head = ($cmd | split words | get 0? | default "")
        $head != "" and not ($ignored | any {|x| $x == $head })
      }
    | get command
    | each {|c| $c | into string }
    | str join "\n"
  )

  let sel = (
    $lines
    | ^fzf --layout=reverse --border=none --color=bg:-1,bg+:-1,gutter:-1,border:-1
    | decode utf-8
    | into string
    | str trim
  )

  if ($sel | is-empty) { return }
  try { commandline edit --replace $sel } catch { echo $sel }
}

def fzf-file [--multi(-m)] {
  let preview_cmd = if (which bat | is-empty) {
    "cat {}"
  } else {
    "bat --style=plain --color=always --line-range=:200 {}"
  }

  let out = (
    ^fd --type f --hidden --follow --exclude .git -0
    | ^fzf --read0 --print0 ($multi | if $in { "--multi" } else { "" }) --preview $preview_cmd
    | into binary
    | decode utf-8
    | into string
  )

  if ($out | is-empty) { return }

  let sels = (
    $out
    | split row "\u{0000}"
    | where {|s| $s | is-not-empty }
  )

  if ($sels | is-empty) { return }

  if $multi {
    ^$env.EDITOR ...$sels
  } else {
    ^$env.EDITOR ($sels | first)
  }
}




def fzf-cd [] {
  let preview = if (which eza | is-empty) { "ls -la {}" } else { "eza -la --group-directories-first --icons=auto {}" }

  let out = (
    ^fd --type d --hidden --follow --exclude .git --strip-cwd-prefix -0
    | ^fzf --read0 --no-multi --preview $preview --print0 --select-1 --exit-0
    | into binary
    | decode utf-8
    | into string
  )
  if ($out | is-empty) { return }

  let sel = (
    $out
    | split row "\u{0000}"         # <— dùng chuỗi NUL, không phải (char 0)
    | where {|s| $s | is-not-empty }
    | first
    | str trim
  )
  if ($sel | is-empty) { return }
  if (($sel | path type) != 'dir') { return }
  cd $sel
}



def fzf-git-file [
  --multi(-m)
] {
  let preview_cmd = if (which bat | is-empty) { 
    "cat {}" 
  } else { 
    "bat --style=plain --color=always --line-range=:200 {}" 
  }

  # đang ở trong repo?
  let in_repo = (do { ^git rev-parse --is-inside-work-tree } | complete | get stdout | str trim | default "")
  
  # NUL-delimited input giữ nguyên dạng binary để không mất \0
  let input = if $in_repo == "true" {
    ^git -c core.quotepath=off ls-files -z | into binary
  } else {
    ^fd --type f --hidden --follow --exclude .git -0 | into binary
  }

  # truyền NUL vào fzf và nhận lại NUL
  let out = (
    $input
    | ^fzf --read0 ($multi | if $in { "--multi" } else { "" }) --preview $preview_cmd --print0
    | into binary
    | decode utf-8
    | into string
  )
  if ($out | is-empty) { return }

  let sels = (
    $out
    | split row "\u{0000}"
    | where {|s| $s | is-not-empty }
  )
  if ($sels | is-empty) { return }

  if $multi {
    ^$env.EDITOR ...$sels
  } else {
    ^$env.EDITOR ($sels | first)
  }
}


def fzf-open [
  --cd
  --multi(-m)
] {
  let preview = 'test -d {} && (eza -la --group-directories-first --icons=auto {} || ls -la {}) || (bat --style=plain --color=always --line-range=:200 {} || sed -n "1,200p" {})'

  let out = (
    ^fd --type f --type d --hidden --follow --exclude .git -0
    | ^fzf --read0 ($multi | if $in { "--multi" } else { "" }) --preview $preview --print0
    | into binary
    | decode utf-8
    | into string
  )
  if ($out | is-empty) { return }

  let sels = (
    $out
    | split row "\u{0000}"   # <-- quan trọng: dùng chuỗi NUL
    | where {|s| $s | is-not-empty }
  )
  if ($sels | is-empty) { return }

  if $multi {
    for p in $sels {
      if (($p | path type) == 'dir') {
        if $cd { cd $p } else { ^$env.EDITOR $p }
      } else {
        ^$env.EDITOR $p
      }
    }
  } else {
    let p = ($sels | first)
    if (($p | path type) == 'dir') {
      if $cd { cd $p } else { ^$env.EDITOR $p }
    } else {
      ^$env.EDITOR $p
    }
  }
}


# Custom functions
def git-cleanup [] {
    git branch --merged | lines | where $it !~ "main|master|\\*" | each { |branch| git branch -d $branch }
}

def mkcd [path: string] {
    mkdir $path
    cd $path
}

def weather [city?: string] {
    let location = if ($city | is-empty) { "" } else { $city }
    try {
        http get $"https://wttr.in/($location)?format=3"
    } catch {
        echo "Failed to fetch weather data. Check your internet connection."
    }
}

def system [] {
    let cpu_info = (sys cpu | first | get brand)
    let cpu_cores = (sys cpu | length)
    let mem_info = (sys mem)
    let mem_used = ($mem_info.used | into filesize)
    let mem_total = ($mem_info.total | into filesize)
    let mem_percent = (($mem_info.used / $mem_info.total) * 100 | math round --precision 1)
    
    let disk_info = (sys disks | where mount == "/" | first)
    let disk_free = ($disk_info.free | into filesize)
    let disk_total = ($disk_info.total | into filesize)
    let disk_used_bytes = ($disk_info.total - $disk_info.free)
    let disk_used = ($disk_used_bytes | into filesize)
    let disk_percent = (($disk_used_bytes / $disk_info.total) * 100 | math round --precision 1)
    
    print $"╭─────────────────────────────────────────────────────────────╮"
    print $"│ (ansi green_bold)System Information(ansi reset)                                      │"
    print $"├─────────────────────────────────────────────────────────────┤"
    print $"│ (ansi cyan_bold)CPU:(ansi reset) ($cpu_info)                                │"
    print $"│ (ansi yellow_bold)Cores:(ansi reset) ($cpu_cores)                                             │"
    print $"├─────────────────────────────────────────────────────────────┤"
    print $"│ (ansi blue_bold)Memory:(ansi reset) ($mem_used) / ($mem_total) \(($mem_percent)%\)      │"
    print $"├─────────────────────────────────────────────────────────────┤"
    print $"│ (ansi purple_bold)Disk:(ansi reset) ($disk_used) / ($disk_total) \(($disk_percent)%\)        │"
    print $"╰─────────────────────────────────────────────────────────────╯"
}
