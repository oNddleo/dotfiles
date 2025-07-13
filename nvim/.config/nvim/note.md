# Install neovim

- Use this as a sub module using sub tree
  [refer atlassian](https://www.atlassian.com/git/tutorials/git-subtree)
  [refer git](https://docs.github.com/en/get-started/using-git/about-git-subtree-merges)

1. Add remote in the parent repo

```shell
git remote add nvim https://github.com/oNddleo/dotfiles.git
```

```shell
git fetch nvim
```

2. Add prefix

Please remove the old nvim in the parent repo

```shell
git subtree add --prefix=nvim/.config/nvim nvim main --squash
```

- This command adds child repo (remote name, main branch) into the `nvim/.config/nvim` directory in the parent repo

_in the nix repo_

```shell
git subtree add --prefix=dotfiles/nvim nvim main --squash
```

3. Push changes from parent repo

Be careful with the prefix (this should be correct)

```shell
git subtree push --prefix=nvim/.config/nvim nvim main
```

or (nix repo)

```shell
git subtree push --prefix=dotfiles/nvim nvim main
```

- If you want to sync anyway, remove --squash from 2nd step

4. Pull changes from child repo

- fetch remote
- pull with right prefix

```shell
git fetch nvim
git subtree pull --prefix=nvim/.config/nvim nvim main --squash
```

or (nix repo)

```shell
git fetch nvim
git subtree pull --prefix=dotfiles/nvim nvim main --squash

```

# Neovim

1. [Move](https://www-barbarianmeetscoding-com.translate.goog/boost-your-coding-fu-with-vscode-and-vim/moving-blazingly-fast-with-the-core-vim-motions/?_x_tr_sl=en&_x_tr_tl=vi&_x_tr_hl=vi&_x_tr_pto=tc)

- `w/b` `W/B` (Word/Back)
- `f/F` (find)
- `e/E` (end)
- `h/j/k/l` (Left/Down/Up/Right)
- `0/$/^/g_` (First not empty start, End not empty end)
- `{/}/Ctr-D/Ctr-U`
- `gg/G` (Start/End of File)
- `%` (pair of `()[]{}`)

2. [Operator](https://www-barbarianmeetscoding-com.translate.goog/boost-your-coding-fu-with-vscode-and-vim/editing-like-magic-with-vim-operators/?_x_tr_sl=en&_x_tr_tl=vi&_x_tr_hl=vi&_x_tr_pto=tc&_x_tr_hist=true)

- `c/d/y/p` (Change/delete/yank/paste)
- `g~` `gu` `gU` (Change letters)
- `>/</=`
- `ggyG` (Copy all file)
- `gUw` (Change all word to uppercase)
- `i|a` (Inner/Around)
  Example: {operator}{a|i}{text-object}
  text-object: w/s/p/b/B (Word/Sentences/Paragraph/Block)

- `x/X/s/~`
- `i/a/I/A` (I: Insert at start of line/A: Append to end of line)
- `o/O/gi` (open new line below, open new line above, insert at the last place you left insert mode)

3. Visual

- `v/V/<C-V>`
  - v (visual mode - character)
  - V (visual mode - linewise)
  - <C-V> (visual block)

# Action Tmux

1. `Ctr A + \`, `Ctr A + -` (split panel), `Ctr A + x` (Kill panel)
2. `Ctr A + S + number` (Move session)
3. Create session (using `Ctr A + :` ) (`new-session -s <name>`)
