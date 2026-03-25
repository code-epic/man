# AGENTS.md - SandraManuals Framework

Guidelines for AI agents working on this LaTeX-based technical documentation framework.

## Build Commands

### Compiling LaTeX Documents
```bash
# Build a manual (from within manual directory)
cd manuales/[manual-name]
xelatex -interaction=nonstopmode -shell-escape main.tex

# Using the build script
./agentes/sandra-build.sh                    # Build main.tex
./agentes/sandra-build.sh -c                 # Build and clean aux files
./agentes/sandra-build.sh -m pdflatex        # Use pdflatex engine
./agentes/sandra-build.sh -d                 # Draft mode (fast)
```

### Available Engines
- `xelatex` (default) - Required for custom fonts (Inter, FiraCode)
- `pdflatex` - Standard LaTeX, limited font support
- `lualatex` - Alternative with Lua scripting

### Framework Commands
```bash
# Create new manual
./agentes/sandra-init.sh

# Add skill/chapter to existing manual
cd manuales/[manual] && ../../agentes/sandra-add.sh

# Compile manual
cd manuales/[manual] && ../../agentes/sandra-build.sh
```

## Code Style Guidelines

### Bash Scripts (agentes/*.sh)

**Header Format:**
```bash
#!/bin/bash
#======================================================================
# SCRIPT-NAME - Brief description
# Autor: Carlos Peña
# Versión: X.Y.Z
#======================================================================

set -e  # Always use strict mode
```

**Naming Conventions:**
- Constants/Globals: `UPPER_CASE` (e.g., `SCRIPT_DIR`, `BASE_DIR`)
- Variables: `snake_case` (e.g., `nombre_manual`, `ruta_destino`)
- Functions: `descriptive_names()` (e.g., `crear_proyecto()`, `print_success()`)
- Arrays: `DESCRIPTIVE_ARRAY=()` with Spanish names

**Color Output Variables:**
```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'      # No Color
BOLD='\033[1m'
```

**Path Resolution:**
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
```

**Error Handling:**
- Always use `set -e` at the start
- Check file existence: `[ -f "$file" ]` before operations
- Provide meaningful error messages with colors

### LaTeX Files (.tex, .sty)

**Header Format:**
```latex
%======================================================================
% FILE-NAME - Brief description
% Autor: Carlos Peña
% Versión: X.Y.Z
%======================================================================
```

**Section Headers:**
```latex
%--------------------------------------------------------------------
% SECTION NAME
%--------------------------------------------------------------------
```

**Color Definitions (Paleta Sandra):**
```latex
\definecolor{sandraDark}{HTML}{2D5A4A}
\definecolor{sandraGreen}{HTML}{4CAF93}
\definecolor{sandraLight}{HTML}{B2E0D0}
\definecolor{sandraAccent}{HTML}{66BB6A}
\definecolor{sandraSoft}{HTML}{F5FAF8}
\definecolor{textDark}{HTML}{263238}
```

**Font Configuration:**
- Main font: Inter (sans-serif, professional)
- Code font: FiraCode (monospace, ligatures)
- Use `\setmainfont{Inter}` with proper path

**Package Loading Order:**
1. fontspec/inputenc (font encoding)
2. geometry (page layout)
3. graphicx, xcolor (graphics)
4. hyperref (must be near end)
5. babel (language last)

### YAML Configuration

**Structure (2-space indentation):**
```yaml
manual:
  nombre: "Manual Name"
  version: "1.0.0"
  autor: "Carlos Peña"
  entorno: "hibrido"  # sandra_ecosystem|sandra_desktop|hibrido|minimalista

estructura:
  portada: true
  preliminares:
    - presentacion
    - resumen
  capitulos:
    - introduccion
    - instalacion
```

## File Organization

**New Manual Structure:**
```
manual-name/
├── main.tex              # Document entry point
├── portada.tex           # Cover page
├── manual-config.yml     # Configuration
├── capitulos/            # Chapters (skills)
├── anexos/              # Appendices
├── imagenes/            # Screenshots/diagrams
└── estilos/             # Local style files
```

**Skill/Habilidad Files:**
- Naming: `XX-nombre.tex` (e.g., `00-introduccion.tex`)
- Use `\capitulo{}` not `\chapter{}`
- Self-contained, includeable content

## Import Guidelines

**Shell Scripts:**
- Prefer `source` for loading configs
- Check command availability: `command -v tool &> /dev/null`
- Use absolute paths with `$HOME/dev/man`

**LaTeX:**
- Use `\input{path}` for modular content
- Path relative to main.tex: `capitulos/XX-name.tex`
- Shared styles: `estilos/sandra-estilos.sty`

## Testing

LaTeX has no unit tests. Verify by:
1. Compiling without errors
2. Checking PDF output visually
3. Validating YAML with: `yamllint manual-config.yml` (if available)

## Spanish Language Conventions

- Comments and documentation: Spanish
- File names: Spanish (e.g., `introduccion`, `instalacion`)
- Variable names: Spanish (e.g., `habilidades`, `capitulos`)
- User-facing text: Spanish
- Code/logic: Spanish terms preferred

## Asset References

**Always use relative paths from manual directory:**
```latex
% Good:
\usepackage{estilos/sandra-estilos}
\includegraphics{imagenes/screenshot.png}

% Shared assets:
../../assets/fonts/     % Fonts
../../assets/iconos/    % SVG icons
../../assets/logos/     % Logos
```

## Error Messages

Use consistent format:
```bash
echo -e "${RED}Error: Descriptive message${NC}"
echo -e "${YELLOW}Warning: Something to note${NC}"
echo -e "${GREEN}Success: Operation completed${NC}"
```
