# Doom Emacs Configuration

Personal Doom Emacs configuration with enhanced features, Spacemacs-inspired keybindings, and extensive performance optimizations.

##  Quick Start

### Installation

#### Required tools

Doom needs a few CLI tools at runtime, `doom sync` needs build tools to compile
native package components (`zmq`, `workspace-hud`), and the enabled language
modules need their toolchains and LSP servers.

**Core — required by Doom itself:**

```bash
brew install git ripgrep fd coreutils
```

| Tool | Needed by |
|------|-----------|
| `git` | straight.el package management (clones every package) |
| `ripgrep` 11+ | Doom search, consult, projectile |
| `fd` | faster file lookup (recommended) |
| GNU `coreutils` | Doom doctor / GNU `ls` (recommended on macOS) |

**Build-time — required for `doom sync` to complete:**

```bash
xcode-select --install                      # clang, make, git
brew install emacs pkgconf zeromq           # Emacs (with modules) + libzmq
brew install autoconf automake libtool      # zmq package runs `autoreconf -i`
brew install rustup                         # workspace-hud builds a wasm bundle
cargo install wasm-pack
rustup target add wasm32-unknown-unknown
```

| Tool | Needed by |
|------|-----------|
| `autoconf` `automake` `libtool` | `zmq` pre-build (`make` runs `autoreconf -i` to generate `configure`) |
| `pkgconf` `zeromq` | `zmq` pre-build (pkg-config lookup of `libzmq`) |
| `rustup` `wasm-pack` wasm32 target | `workspace-hud` pre-build (`wasm-pack build`) |
| Emacs with module support | loading the built `emacs-zmq.dylib` (Homebrew formula has it) |

**Languages & features — install what you use:**

| Tool | Install | Needed by |
|------|---------|-----------|
| Node.js + npm | `brew install node` | `copilot.el`, LSP server installers, `scripts/format-elisp.js` |
| Python 3 + Jupyter | `brew install python` then `pip install jupyter ipykernel` | `jupyter` REPL, `:lang python` |
| rust-analyzer | `rustup component add rust-analyzer` | `:lang (rust +lsp)` |
| LaTeX (`latexmk`, `dvisvgm`) | BasicTeX or MacTeX | `:lang latex`, org/markdown math previews |
| `plantuml` + `graphviz` + `temurin` | `brew install plantuml graphviz temurin` | `:lang plantuml` (PlantUML needs Java) |
| `shellcheck` | `brew install shellcheck` | flycheck (`:checkers syntax`) for `:lang sh` |
| `poppler` | `brew install poppler` | `:tools pdf` (build epdfinfo with `M-x pdf-tools-install`) |
| Docker CLI | `brew install docker` | `:tools docker` (optional) |
| `emacs-lsp-booster` | [GitHub releases](https://github.com/blahgeek/emacs-lsp-booster) | faster LSP responses (optional) |
| `codex` / `pi-acp` | npm / GitHub releases | `agent-shell` backends (optional) |

LSP servers for the enabled languages (js/ts, web, json/yaml, python, rust,
sh): let lsp-mode install them with `M-x lsp-install-server`, or preinstall
them globally:

```bash
npm i -g typescript @vtsls/language-server pyright \
  vscode-langservers-extracted bash-language-server yaml-language-server
```

Environment rules:

- Run `doom sync` from a terminal whose `PATH` includes `/opt/homebrew/bin` and `~/.cargo/bin`.
- Never append `$path`/`$PATH` to `CFLAGS`, `CPPFLAGS`, `LDFLAGS`, or `PKG_CONFIG_PATH` in shell profiles — a full PATH string inside compiler flags breaks every C build with `C compiler cannot create executables`.
- If you launch Emacs.app from the Dock, run `doom env` once so GUI Emacs sees the same `PATH`.

1. Install Doom Emacs:
   ```bash
   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
   ~/.config/emacs/bin/doom install
   ```

2. Clone this config (either `~/.config/doom` or `~/.doom.d` works):
   ```bash
   git clone https://github.com/luyangliuable/doom-emacs-config.git ~/.config/doom
   cd ~/.config/doom
   git submodule update --init --recursive    # elisp-functions submodule
   ```

3. Sync and compile:
   ```bash
   doom sync                  # installs packages and runs all :pre-build steps
   ./scripts/compile-doom-config.sh
   ```
   If a package's `:pre-build` step fails (e.g. the `zmq` recipe's `make`),
   install the missing tool from the Required tools list above, then re-run:
   ```bash
   doom sync --rebuild        # force :pre-build commands to run again
   ```

4. Restart Emacs!

### Credentials and integrations

Keep credentials outside this repository. Optional integrations read these
environment variables when present:

- `ANTHROPIC_API_KEY` and optional `ANTHROPIC_MODEL`
- `OPENAI_API_KEY`
- `JIRA_URL`

Do not place tokens, private endpoints, or organization-specific settings in
`config.el` or `config/local.el`.

##  Performance Features

### What's Optimized

-  **Fast startup**: ~3-7 seconds (down from 10-20)
-  **LSP auto-update**: Fixed! No more manual `:lsp` reloading
-  **All LSP features enabled**: Docs, sideline, code lens, modeline actions
-  **Smart garbage collection**: 100MB threshold, runs on idle/focus-out
-  **Byte-compilation support**: Run `./scripts/compile-doom-config.sh` for 2-3x faster loading
-  **Early init optimizations**: `early-init.el` disables GC and file handlers during startup

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

##  Configuration Structure

```
.doom.d/
├── config.el                    # Main configuration loader
├── init.el                      # Doom modules configuration
├── packages.el                  # Package declarations
├── early-init.el                #  Early startup optimizations
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
│       ├── performance.el       #  Performance optimizations
│       └── ...
├── elisp-functions/
│   └── functions.el             # Custom Elisp functions
└── scripts/
    ├── compile-config.el        #  Byte-compilation script
    └── compile-doom-config.sh   #  Compilation wrapper
```

 = New optimization files

##  Maintenance

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

##  Key Customizations

- **Localleader**: `,` (instead of `SPC m`)
- **Leader key**: `SPC` (standard Doom)
- **Font**: Fira Code (configured in `config/core.el`)
- **Theme**: Configured in `themes.el`
- **Custom functions**: Defined in `elisp-functions/functions.el`

##  Notes

- Optimized for macOS but works on Linux
- LSP servers need separate installation per language
- Some packages require system dependencies
- Byte-compilation is optional but recommended
- Native compilation (Emacs 28+) provides best performance

##  Troubleshooting

### If LSP doesn't auto-update:
- Check LSP is running: `M-x lsp-describe-session`
- Check mode hooks: `M-x describe-variable RET typescript-mode-hook`
- Restart LSP: `M-x lsp-workspace-restart`

### If `doom sync` fails with `:pre-build command error in "zmq" recipe`:

The `zmq` package runs `make`, which needs autotools and a working C toolchain:

```bash
autoreconf --version             # brew install autoconf automake libtool
make --version
pkg-config --modversion libzmq   # brew install pkgconf zeromq
env | grep -E "^(CFLAGS|CPPFLAGS|LDFLAGS)="
```

The flags must contain only compiler flags — never `PATH` entries. Then re-run:

```bash
doom sync --rebuild
```

### If startup is slow:
- Run `doom doctor` to check for issues
- Run `M-x doom/info` for startup time breakdown
- Lazy-load more packages using `:defer` in `use-package!`

### If compiled config causes issues:
```bash
cd ~/.config/doom
./scripts/compile-doom-config.sh clean
```

##  References

Configuration inspired by:
- [Doom Emacs](https://github.com/doomemacs/doomemacs)
- [Spacemacs](https://github.com/syl20bnr/spacemacs)
- [Timothy Ye's Doom](https://github.com/TimothyYe/doom-emacs)

##  License

MIT License - See individual package licenses for third-party components

---

**Last Updated**: 2026-10-04
