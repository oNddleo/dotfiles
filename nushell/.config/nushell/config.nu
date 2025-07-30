# Nushell Config File
#
# version = "0.106.0"
def "load bash env" [] {
    # Load bash PATH and environment variables
    let bash_env = (bash -c 'echo $PATH' | str trim)
    $env.PATH = ($bash_env | split row ":")
    
    # Load bash aliases as Nushell aliases
    bash -c 'alias' | lines | each { |line|
        if ($line | str contains "=") {
            let parts = ($line | split column "=" --max-split 2)
            alias ($parts.0) = ($parts.1 | str trim -c "'\"")
        }
    }
}

# Call the function
load bash env

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
    show_banner: false
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
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                ]
            }
        }
        {
            name: completion_previous
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menuprevious }
        }
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: emacs
            event: { send: menu name: history_menu }
        }
        {
            name: next_page
            modifier: control
            keycode: char_x
            mode: emacs
            event: { send: menupagenext }
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
    http get $"https://wttr.in/($location)?format=3"
}
