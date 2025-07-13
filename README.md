To stow the `nvim` folder (typically your Neovim configuration), you can use **GNU Stow**, a symlink manager that helps organize your dotfiles. Here's how to do it:

## Install

### 1.Lazydocker

```bash
brew install lazydocker
```

### 2. Zsh

### 3. Fzf

### 4. Tmux

### 5. Nvim

### 6. Aerospace

### 7. Ghostty/Wezterm

### 8. Atuin

### 9. JLess

View file input

### 10. Xh

### 11. Stow

### 12. K9s

### 13. TPM (Tmux Plugin Manager)

---

### 1. **Ensure Your Directory Structure is Correct**

   Your `nvim` folder should be inside a dotfiles directory (e.g., `~/.dotfiles`). Example:

   ```
   ~/.dotfiles/
   └── nvim/
       ├── init.lua
       ├── lua/
       └── ...
   ```

   If your `nvim` folder is at `~/.config/nvim`, you can either:

- Move it to `~/.dotfiles/nvim` and then stow it back.
- Or stow directly from `~/.dotfiles/.config/nvim` (less common).

### 2. **Stow the `nvim` Folder**

   Run this command inside your dotfiles directory:

   ```sh
   stow -v -t ~ nvim
   ```

- `-v` = verbose (shows what’s happening).
- `-t ~` = target directory (your home folder).
- `nvim` = the package to stow.

   This will create a symlink:  
   `~/.config/nvim` → `~/.dotfiles/nvim`

### 3. **If Your `nvim` is in `~/.config/nvim`**

   If you want to keep the `nvim` folder in `~/.dotfiles/.config/nvim`, run:

   ```sh
   stow -v -t ~ -d ~/.dotfiles .config
   ```

   This will symlink the entire `.config` folder correctly.

### 4. **Verify the Symlink**

   Check if it worked:

   ```sh
   ls -la ~/.config/nvim
   ```

   It should point to your dotfiles directory.

### Alternative: Manual Symlink

   If you prefer not to use Stow:

   ```sh
   ln -s ~/.dotfiles/nvim ~/.config/nvim
   ```

Let me know if you need help adjusting the paths!
