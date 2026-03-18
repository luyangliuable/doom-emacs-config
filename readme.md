# Doom Emacs Configuration

Custom Doom Emacs configuration with enhanced features and Spacemacs-inspired keybindings.

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
- **Projectile**: Enhanced project management
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
  - gptel
  - minimap
  - org-jira
  - lsp-vtsls (TypeScript)

### Language Support
- **TypeScript/JavaScript**: LSP with vtsls
- **Rust**: LSP support
- **Web**: HTML/CSS/JavaScript with LSP
- **Python**: Full language support
- **Emacs Lisp**: Enhanced with flycheck
- **Markdown**: With live preview
- **Org mode**: Enhanced org support with org-jira
- **Common Lisp**: With SLY
- **Shell scripting**: Bash/Zsh support

### Additional Tools
- **Docker**: Docker integration
- **EditorConfig**: Consistent coding styles
- **Tree-sitter**: Enhanced syntax parsing
- **LSP**: Multiple language servers configured
- **PDF tools**: PDF viewing and annotation
- **Task runner**: Project task management

## Configuration Structure

```
.doom.d/
├── config.el                    # Main configuration loader
├── init.el                      # Doom modules configuration
├── packages.el                  # Package declarations
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
│       └── ...
└── elisp-functions/
    └── functions.el             # Custom Elisp functions
```

## Installation

1. Install Doom Emacs:
```bash
git clone https://github.com/doomemacs/doomemacs ~/.config/doom-emacs
~/.config/doom-emacs/bin/doom install
```

2. Clone this configuration:
```bash
git clone https://github.com/luyangliuable/doom-emacs-config.git ~/.doom.d
cd ~/.doom.d
git submodule update --init --recursive
```

3. Sync Doom:
```bash
doom sync
```

4. Restart Emacs

## Key Customizations

- **Localleader**: `,` (instead of `SPC m`)
- **Leader key**: `SPC` (standard Doom)
- **Font**: Set in `config/core.el`
- **Theme**: Configured in `themes.el`
- **Custom functions**: Defined in `elisp-functions/functions.el`

## Notes

- This configuration is optimized for macOS but should work on Linux
- LSP servers need to be installed separately for each language
- Some packages require additional system dependencies

## License

MIT License - See individual package licenses for third-party components
