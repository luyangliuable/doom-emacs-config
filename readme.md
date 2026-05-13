# Doom Emacs Configuration

Personal Doom Emacs configuration with enhanced features, Spacemacs-inspired keybindings, and extensive performance optimizations.

## 🚀 Quick Start

### Installation

1. Install Doom Emacs:
   ```bash
   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
   ~/.config/emacs/bin/doom install
   ```

2. Clone this config:
   ```bash
   git clone <your-repo> ~/.doom.d
   cd ~/.doom.d
   ```

3. Sync and compile:
   ```bash
   doom sync
   ./scripts/compile-doom-config.sh
   ```

4. Restart Emacs!

## ⚡ Performance Features

### What's Optimized

- ✅ **Fast startup**: ~3-7 seconds (down from 10-20)
- ✅ **LSP auto-update**: Fixed! No more manual `:lsp` reloading
- ✅ **All LSP features enabled**: Docs, sideline, code lens, modeline actions
- ✅ **Smart garbage collection**: 100MB threshold, runs on idle/focus-out
- ✅ **Byte-compilation support**: Run `./scripts/compile-doom-config.sh` for 2-3x faster loading
- ✅ **Early init optimizations**: `early-init.el` disables GC and file handlers during startup

### Testing LSP Auto-Update

1. Open a TypeScript/Python file
2. Wait 0.5s for LSP to start (watch modeline)
3. Edit code → syntax errors/completions appear automatically
4. No need to run `:lsp` manually anymore!

### Compilation (Optional but Recommended)

```bash
# Byte-compile all config files for faster loading
cd ~/.doom.d
./scripts/compile-doom-config.sh

# Clean and recompile
./scripts/compile-doom-config.sh clean
```

**Note**: Recompile after editing any `.el` file or running `doom sync`.

## Features Beyond Vanilla Doom Emacs

### LSP Enhancements
- **Comprehensive localleader bindings**: All LSP code actions available under `,` (localleader)
  - `,rr` - LSP rename
  - `,aa` - Execute code action
  - `,=b` / `,=r` / `,=o` - Format buffer/region/organize imports
  - `,gg` / `,gi` / `,gr` / `,gt` - Jump to definition/implementation/references/type
  - `,hh` - Describe thing at point
  - `,bd` / `,br` / `,bs` / `,bv` - LSP backend management
  - `,Fa` / `,Fr` / `,Fs` - Workspace folder management
- **Electric indent**: Auto-indentation on new lines in LSP buffers
- **Auto-update**: LSP updates syntax analysis automatically on edit

### UI & Visual Enhancements
- **Beacon mode**: Highlights cursor position on big movements
- **Minimap**: Code overview sidebar (`SPC tmM`)
- **Good scroll**: Smooth scrolling with customizable speed
- **Auto-highlight-symbol**: Toggle symbol highlighting with `SPC sh`
- **Ligatures**: Programming ligatures support
- **Doom modeline**: Enhanced modeline with breadcrumbs
- **Global breadcrumb navigation**: File path breadcrumbs for all files
- **Zen mode**: Distraction-free writing/coding

### Window & Layout Management
- **Custom window resizing**: Resize by percentage
  - `SPC wrw` - Resize window width by %
  - `SPC wrh` - Resize window height by %
- **Window maximize**: Toggle buffer maximization (`SPC wm`)
- **Ace window**: Quick window switching (`SPC wW`)
- **Workspaces**: Tab emulation with persistence
- **Hydra window management**: Transient state for window operations (`SPC w.`)

### Evil/Vim Enhancements
- **Evil everywhere**: Vim bindings in all modes
- **Evil operator state**: Full operator pending support
- **Custom text objects**: Additional text object support
- **Visual wrapping**: Quick wrap selections with quotes, brackets, etc.
  - `s"` / `s'` / `` s` `` - Wrap with quotes
  - `s(` / `s[` / `s{` - Wrap with brackets
  - `s*` - Wrap with asterisks
- **Enhanced undo**: Persistent undo with undo-tree/vundo
- **Code folding**: Universal code folding support
- **Snippets**: YASnippet integration

### File Operations
- **Enhanced yank/copy**:
  - `SPC fyd` - Copy directory path
  - `SPC fyn` - Copy file name
  - `SPC fyy` - Copy file path
  - `SPC fyl` - Copy file path with line number
- **Treemacs integration**: Project drawer with icon support
- **Browse at remote**: Open current file/line in browser (`SPC xb`)

### Project Management
- **Projectile**: Enhanced project management with aggressive caching
- **Project shell commands**:
  - `SPC p$.` - Run shell in project
  - `SPC p$v` / `SPC p$s` - Split and run shell
  - `SPC p!.` - New shell for project
- **Magit integration**: Git porcelain
  - `SPC gs.` - Open magit
  - `SPC gsv` / `SPC gss` - Split and open magit

### Text Operations
- **Drag stuff**: Move lines/regions up/down
  - `SPC xJ` - Drag down (repeatable)
  - `SPC xK` - Drag up (repeatable)
- **Delete trailing whitespace**: `SPC xdw`
- **Sort lines**: `SPC xls`
- **Link hint**: Open links at point (`SPC xo`)
- **Evil nerd commenter**: Comment operator (`SPC ;`)

### Toggle Commands
- **Line numbers**:
  - `SPC tna` - Toggle absolute line numbers
  - `SPC tnr` - Toggle relative line numbers
- **UI elements**:
  - `SPC tmT` - Toggle mode line
  - `SPC tmM` - Toggle minimap
  - `SPC sh` - Toggle symbol highlighting
  - `SPC tG` - Toggle golden ratio
  - `SPC tc` - Centered buffer mode

### Navigation
- **Avy**: Jump to char (`SPC jw`)
- **Goto last change**: `SPC jc`
- **Buffer switching**: `SPC TAB` - Switch to last buffer
- **Scratch buffer**: `SPC bs` - Go to scratch buffer

### Custom Functions
- **Buffer operations**:
  - `SPC bY` - Copy entire buffer to clipboard
  - `SPC wm` - Toggle buffer maximization
- **Window splitting with shell**:
  - `SPC p$V` / `SPC p$S` - Split and run shell (stay in current)
  - `SPC p!V` / `SPC p!S` - New shell split (stay in current)
- **Mode line toggle**: Custom function to show/hide mode line

### Package Management
- **Straight.el**: Declarative package management
- **Custom packages**:
  - agent-shell
  - anki-editor
  - auto-highlight-symbol
  - beacon
  - drag-stuff
  - golden-ratio
  - good-scroll
  - gptel
  - minimap
  - org-jira
  - persistent-scratch
  - lsp-vtsls (TypeScript)

### Language Support
- **TypeScript/JavaScript**: LSP with vtsls
- **Rust**: LSP support with rust-analyzer
- **Web**: HTML/CSS/JavaScript with LSP
- **Python**: Full LSP support with pyright/pylsp
- **Emacs Lisp**: Enhanced with flycheck
- **Markdown**: With live preview
- **Org mode**: Enhanced org support with org-jira
- **Common Lisp**: With SLIME/SLY
- **Shell scripting**: Bash/Zsh support with LSP

### Additional Tools
- **Docker**: Docker integration
- **EditorConfig**: Consistent coding styles
- **Tree-sitter**: Enhanced syntax parsing
- **LSP**: Multiple language servers configured
- **PDF tools**: PDF viewing and annotation
- **Task runner**: Project task management
- **Git timemachine**: Browse git history

## 📁 Configuration Structure

```
.doom.d/
├── config.el                    # Main configuration loader
├── init.el                      # Doom modules configuration
├── packages.el                  # Package declarations
├── early-init.el                # ⭐ Early startup optimizations
├── themes.el                    # Theme configuration
├── config/
│   ├── core.el                  # Core settings
│   ├── modes.el                 # Mode hooks
│   ├── ui.el                    # UI configuration
│   ├── keybindings.el           # Main keybindings
│   ├── keybindings/             # Keybinding modules
│   │   ├── emacs-lisp.el
│   │   ├── evil.el
│   │   ├── gptel.el
│   │   ├── lsp.el
│   │   ├── magit.el
│   │   ├── shell.el
│   │   ├── treemacs.el
│   │   └── ...
│   └── packages/                # Package configurations
│       ├── agent-shell.el
│       ├── auto-highlight-symbol.el
│       ├── drag-stuff.el
│       ├── evil.el
│       ├── lsp.el
│       ├── lsp-vtsls.el
│       ├── performance.el       # ⭐ Performance optimizations
│       └── ...
├── elisp-functions/
│   └── functions.el             # Custom Elisp functions
└── scripts/
    ├── compile-config.el        # ⭐ Byte-compilation script
    └── compile-doom-config.sh   # ⭐ Compilation wrapper
```

⭐ = New optimization files

## 🔧 Maintenance

### After editing config files:

```bash
# Recompile for faster loading
cd ~/.doom.d
./scripts/compile-doom-config.sh

# Or clean and recompile
./scripts/compile-doom-config.sh clean
```

### After Doom updates:

```bash
doom sync
doom upgrade
cd ~/.doom.d && ./scripts/compile-doom-config.sh
```

## 🔑 Key Customizations

- **Localleader**: `,` (instead of `SPC m`)
- **Leader key**: `SPC` (standard Doom)
- **Font**: Fira Code (configured in `config/core.el`)
- **Theme**: Configured in `themes.el`
- **Custom functions**: Defined in `elisp-functions/functions.el`

## 📝 Notes

- Optimized for macOS but works on Linux
- LSP servers need separate installation per language
- Some packages require system dependencies
- Byte-compilation is optional but recommended
- Native compilation (Emacs 28+) provides best performance

## 🆘 Troubleshooting

### If LSP doesn't auto-update:
- Check LSP is running: `M-x lsp-describe-session`
- Check mode hooks: `M-x describe-variable RET typescript-mode-hook`
- Restart LSP: `M-x lsp-workspace-restart`

### If startup is slow:
- Run `doom doctor` to check for issues
- Run `M-x doom/info` for startup time breakdown
- Lazy-load more packages using `:defer` in `use-package!`

### If compiled config causes issues:
```bash
cd ~/.doom.d
./scripts/compile-doom-config.sh clean
```

## 📚 References

Configuration inspired by:
- [Doom Emacs](https://github.com/doomemacs/doomemacs)
- [Spacemacs](https://github.com/syl20bnr/spacemacs)
- [Timothy Ye's Doom](https://github.com/TimothyYe/doom-emacs)

## 📄 License

MIT License - See individual package licenses for third-party components

---

**Last Updated**: 2026-05-13
