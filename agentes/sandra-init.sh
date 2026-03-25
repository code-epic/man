#!/bin/bash
#======================================================================
# SANDRA-INIT - Wizard interactivo para crear nuevos manuales
# Autor: Carlos Peña
# Versión: 1.0.0
#======================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
SANDRA_DIR="$BASE_DIR/.sandra"
ASSETS_DIR="$BASE_DIR/assets"
MANUALES_DIR="$BASE_DIR/manuales"

# Variables del manual
NOMBRE_MANUAL=""
VERSION="1.0.0"
AUTOR="Carlos Peña"
DESCRIPCION=""
ENTORNO="hibrido"
PALETA="universal"
RUTA_DESTINO=""
README_PATH=""
HABILIDADES_SELECCIONADAS=()
PRELIMINARES_SELECCIONADOS=()

# Funciones de utilidad
print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${BOLD}SandraManuals Framework - Wizard de Inicialización${NC}      ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

validate_input() {
    local input="$1"
    local pattern="^[a-zA-Z0-9_ -]+$"
    if [[ ! "$input" =~ $pattern ]]; then
        return 1
    fi
    return 0
}

# Paso 1: Información básica
paso_1_info_basica() {
    echo -e "${BOLD}Paso 1: Información Básica del Manual${NC}"
    echo "─────────────────────────────────────────────────────────────"
    
    # Nombre del manual
    while true; do
        echo -n "Nombre del manual: "
        read NOMBRE_MANUAL
        
        if [ -z "$NOMBRE_MANUAL" ]; then
            print_error "El nombre no puede estar vacío"
            continue
        fi
        
        if validate_input "$NOMBRE_MANUAL"; then
            break
        else
            print_error "El nombre solo puede contener letras, números, espacios y guiones"
        fi
    done
    
    # Versión
    echo -n "Versión inicial [1.0.0]: "
    read input_version
    VERSION=${input_version:-"1.0.0"}
    
    # Autor
    echo -n "Autor [Carlos Peña]: "
    read input_autor
    AUTOR=${input_autor:-"Carlos Peña"}
    
    # Descripción
    echo -n "Descripción breve: "
    read DESCRIPCION
    
    print_success "Información básica capturada"
    echo ""
}

# Paso 2: Selección de entorno
paso_2_entorno() {
    echo -e "${BOLD}Paso 2: Selección de Entorno Base${NC}"
    echo "─────────────────────────────────────────────────────────────"
    echo ""
    
    PS3="Seleccione el entorno (1-4): "
    options=(
        "Sandra Ecosystem - Estilo académico/profesional"
        "Sandra Desktop - Estilo técnico/orientado a usuarios"
        "Híbrido - Combinación de ambos estilos (Recomendado)"
        "Minimalista - Solo esqueleto básico"
    )
    
    select opt in "${options[@]}"; do
        case $REPLY in
            1) ENTORNO="sandra_ecosystem"; break ;;
            2) ENTORNO="sandra_desktop"; break ;;
            3) ENTORNO="hibrido"; break ;;
            4) ENTORNO="minimalista"; break ;;
            *) print_error "Opción inválida. Intente de nuevo." ;;
        esac
    done
    
    print_success "Entorno seleccionado: $ENTORNO"
    echo ""
}

# Paso 3: Selección de habilidades
paso_3_habilidades() {
    echo -e "${BOLD}Paso 3: Selección de Capítulos/Habilidades${NC}"
    echo "─────────────────────────────────────────────────────────────"
    echo "Seleccione las habilidades a incluir (números separados por espacios):"
    echo ""
    
    local habilidades=(
        "00:introduccion:Introducción General"
        "01:instalacion:Instalación y Onboarding"
        "03:dashboard:Panel de Control"
        "02:configuracion:Configuración"
        "04:seguridad:Seguridad"
        "05:api:API y Desarrollo"
        "98:glosario:Glosario de Iconos"
        "99:referencias:Referencias Bibliográficas"
    )
    
    for i in "${!habilidades[@]}"; do
        local parts=(${habilidades[$i]//:/ })
        printf "  [%d] %-25s - %s\n" $((i+1)) "${parts[2]}" "${parts[1]}"
    done
    
    echo ""
    echo -n "Seleccione (ej: 1 2 3) o 'a' para todas: "
    read seleccion
    
    if [ "$seleccion" = "a" ] || [ "$seleccion" = "A" ]; then
        for hab in "${habilidades[@]}"; do
            local id=$(echo "$hab" | cut -d: -f2)
            HABILIDADES_SELECCIONADAS+=("$id")
        done
    else
        for num in $seleccion; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#habilidades[@]} ]; then
                local id=$(echo "${habilidades[$((num-1))]}" | cut -d: -f2)
                HABILIDADES_SELECCIONADAS+=("$id")
            fi
        done
    fi
    
    print_success "${#HABILIDADES_SELECCIONADAS[@]} habilidades seleccionadas"
    echo ""
}

# Paso 4: Selección de preliminares
paso_4_preliminares() {
    echo -e "${BOLD}Paso 4: Secciones Preliminares${NC}"
    echo "─────────────────────────────────────────────────────────────"
    echo "Seleccione las secciones preliminares a incluir:"
    echo ""
    
    local preliminares=(
        "presentacion:Presentación del documento"
        "resumen:Resumen ejecutivo"
        "indice:Índice general"
        "dedicatoria:Dedicatoria"
        "prologo:Prólogo"
        "agradecimientos:Agradecimientos"
    )
    
    for i in "${!preliminares[@]}"; do
        local parts=(${preliminares[$i]//:/ })
        printf "  [%d] %-20s\n" $((i+1)) "${parts[1]}"
    done
    
    echo ""
    echo -n "Seleccione (ej: 1 2 3) o Enter para omitir: "
    read seleccion
    
    if [ -n "$seleccion" ]; then
        for num in $seleccion; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#preliminares[@]} ]; then
                local id=$(echo "${preliminares[$((num-1))]}" | cut -d: -f1)
                PRELIMINARES_SELECCIONADOS+=("$id")
            fi
        done
    fi
    
    print_success "${#PRELIMINARES_SELECCIONADOS[@]} preliminares seleccionados"
    echo ""
}

# Paso 5: Ruta de destino
paso_5_ruta() {
    echo -e "${BOLD}Paso 5: Ubicación del Proyecto${NC}"
    echo "─────────────────────────────────────────────────────────────"
    
    local nombre_dir=$(echo "$NOMBRE_MANUAL" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
    local ruta_default="$MANUALES_DIR/$nombre_dir"
    
    echo -n "Ruta de destino [$ruta_default]: "
    read input_ruta
    RUTA_DESTINO=${input_ruta:-"$ruta_default"}
    
    # Expandir ~ si se usa
    RUTA_DESTINO="${RUTA_DESTINO/#\~/$HOME}"
    
    if [ -d "$RUTA_DESTINO" ]; then
        print_warning "El directorio ya existe. ¿Desea sobrescribir? (s/n)"
        read respuesta
        if [ "$respuesta" != "s" ] && [ "$respuesta" != "S" ]; then
            print_error "Operación cancelada"
            exit 1
        fi
        rm -rf "$RUTA_DESTINO"
    fi
    
    print_success "Ruta seleccionada: $RUTA_DESTINO"
    echo ""
}

# Paso 6: README
paso_6_readme() {
    echo -e "${BOLD}Paso 6: Archivo README${NC}"
    echo "─────────────────────────────────────────────────────────────"
    echo ""
    
    PS3="Seleccione una opción (1-2): "
    options=(
        "Crear README.md básico automáticamente"
        "Importar README existente"
    )
    
    select opt in "${options[@]}"; do
        case $REPLY in
            1) 
                README_PATH=""
                break 
                ;;
            2) 
                echo -n "Ruta al README existente: "
                read README_PATH
                if [ ! -f "$README_PATH" ]; then
                    print_error "Archivo no encontrado. Se creará uno básico."
                    README_PATH=""
                fi
                break 
                ;;
            *) print_error "Opción inválida" ;;
        esac
    done
    
    print_success "Configuración de README completada"
    echo ""
}

# Crear estructura del proyecto
crear_proyecto() {
    echo ""
    echo -e "${BOLD}Creando estructura del proyecto...${NC}"
    echo "─────────────────────────────────────────────────────────────"
    
    # Crear directorios
    mkdir -p "$RUTA_DESTINO"/{capitulos,anexos,imagenes,estilos}
    
    # Copiar estilos
    cp "$SANDRA_DIR/templates/estilos/sandra-estilos.sty" "$RUTA_DESTINO/estilos/"
    print_success "Estilos copiados"
    
    # Crear manual-config.yml
    crear_config_yml
    print_success "Archivo de configuración creado"
    
    # Crear main.tex
    crear_main_tex
    print_success "Archivo principal creado"
    
    # Crear portada.tex
    crear_portada_tex
    print_success "Portada creada"
    
    # Copiar habilidades seleccionadas
    for habilidad in "${HABILIDADES_SELECCIONADAS[@]}"; do
        local archivo_habilidad="$SANDRA_DIR/habilidades/"*"-$habilidad.tex"
        if ls $archivo_habilidad 1> /dev/null 2>&1; then
            cp $archivo_habilidad "$RUTA_DESTINO/capitulos/"
            print_success "Habilidad agregada: $habilidad"
        fi
    done
    
    # Crear README
    if [ -n "$README_PATH" ]; then
        cp "$README_PATH" "$RUTA_DESTINO/README.md"
    else
        crear_readme
    fi
    print_success "README.md creado"
    
    echo ""
    print_success "Proyecto creado exitosamente en:"
    echo -e "  ${CYAN}$RUTA_DESTINO${NC}"
}

crear_config_yml() {
    cat > "$RUTA_DESTINO/manual-config.yml" << EOF
# Configuración del Manual
# Generado por SandraManuals Framework

manual:
  nombre: "$NOMBRE_MANUAL"
  version: "$VERSION"
  autor: "$AUTOR"
  fecha: "$(date +%Y-%m-%d)"
  descripcion: "$DESCRIPCION"
  entorno: "$ENTORNO"

estructura:
  portada: true
  preliminares:
$(for p in "${PRELIMINARES_SELECCIONADOS[@]}"; do echo "    - $p"; done)
  capitulos:
$(for h in "${HABILIDADES_SELECCIONADAS[@]}"; do echo "    - $h"; done)
  anexos: true
  glosario: $(if [[ " ${HABILIDADES_SELECCIONADAS[*]} " =~ "glosario" ]]; then echo "true"; else echo "false"; fi)
  referencias: $(if [[ " ${HABILIDADES_SELECCIONADAS[*]} " =~ "referencias" ]]; then echo "true"; else echo "false"; fi)

metadatos:
  paleta: "$PALETA"
  fuentes:
    principal: "Inter"
    codigo: "FiraCode"
  iconos: true
  logo: "../../assets/logos/sandra.png"

build:
  motor: "xelatex"
  opciones:
    - "-interaction=nonstopmode"
    - "-shell-escape"
  salida: "$(echo "$NOMBRE_MANUAL" | tr ' ' '_' | tr '[:upper:]' '[:lower:]').pdf"
EOF
}

crear_main_tex() {
    # Crear archivo main.tex directamente
    cat > "$RUTA_DESTINO/main.tex" << EOF
%======================================================================
% MANUAL: $NOMBRE_MANUAL
% Version: $VERSION
% Autor: $AUTOR
% Generado con SandraManuals Framework
%======================================================================

\\documentclass[11pt,oneside,openright,spanish,letterpaper]{book}

% Estilos Sandra
\\usepackage{estilos/sandra-estilos}

% Metadatos
\\hypersetup{
    pdftitle={$NOMBRE_MANUAL},
    pdfauthor={$AUTOR},
    pdfsubject={$DESCRIPCION},
    pdfkeywords={Sandra, Manual}
}

\\begin{document}

% Portada
\\newgeometry{margin=0cm}
\\input{portada}
\\restoregeometry

% Preliminares
\\frontmatter
\\pagenumbering{roman}

% Indices
\\tableofcontents
\\listoffigures
\\listoftables

% Contenido principal
\\mainmatter
\\pagenumbering{arabic}

% Capitulos
$(for hab in "${HABILIDADES_SELECCIONADAS[@]}"; do
    echo "\\input{capitulos/*-$hab.tex}"
done)

% Anexos
\\appendix
\\input{anexos/anexos}

\\backmatter
\\printindex

\\end{document}
EOF
}

crear_portada_tex() {
    cat > "$RUTA_DESTINO/portada.tex" << 'EOF'
% Portada generada por SandraManuals

\begin{tikzpicture}[
    remember picture,
    overlay,
    shift={(current page.center)}
]

\fill[sandraSoft] 
    (current page.south west) rectangle (current page.north east);

\fill[sandraLight, opacity=0.3]
    (current page.north west) .. controls ++(8cm,-3cm) and ++(-8cm,1cm) .. ++(21cm,0) --
    (current page.north east) -- cycle;

\fill[sandraGreen, opacity=0.2]
    (current page.north west) .. controls ++(6cm,-2cm) and ++(-10cm,2cm) .. ++(21cm,-1cm) --
    (current page.north east) -- cycle;

\draw[sandraDark, line width=3pt]
    ([shift={(1.5cm,-1.5cm)}]current page.north west) rectangle
    ([shift={(-1.5cm,1.5cm)}]current page.south east);

\fill[sandraGreen]
    ([shift={(2cm,3cm)}]current page.south west) rectangle
    ([shift={(-2cm,3.3cm)}]current page.south east);

\node[
    fill=white,
    draw=sandraDark,
    line width=2pt,
    rounded corners=10pt,
    inner sep=20pt,
    minimum width=14cm,
    minimum height=5cm,
    align=center
] at (0, 3cm) {
    \fontsize{32}{36}\selectfont
    \textcolor{sandraDark}{\textbf{EOF
    cat >> "$RUTA_DESTINO/portada.tex" << EOF
$NOMBRE_MANUAL}}\\\\[0.8cm]
    \fontsize{14}{16}\selectfont
    \textcolor{sandraGreen}{$DESCRIPCION}
};

\node[
    fill=sandraGreen,
    text=white,
    rounded corners=5pt,
    inner sep=8pt,
    font=\large\bfseries
] at (0, 0cm) {Versión $VERSION};

\node[
    align=center,
    font=\large
] at (0, -4cm) {
    \textcolor{sandraDark}{\textbf{Autor:}}\\\\[0.3cm]
    \textcolor{textDark}{$AUTOR}\\\\[0.5cm]
    \textcolor{sandraGray}{$(date +%B %Y)}
};

\node[
    align=center,
    font=\normalsize
] at (0, -8cm) {
    \textcolor{sandraDark}{\textbf{Code Epic Technologies}}\\\\[0.2cm]
    \textcolor{textLight}{Caracas, Venezuela}
};

\fill[sandraDark, opacity=0.1]
    (current page.south west) .. controls ++(10cm,2cm) and ++(-5cm,-1cm) .. (current page.south east) -- cycle;

\end{tikzpicture}

\clearpage
EOF
}

crear_readme() {
    local nombre_dir=$(basename "$RUTA_DESTINO")
    
    cat > "$RUTA_DESTINO/README.md" << EOF
# $NOMBRE_MANUAL

**Versión:** $VERSION  
**Autor:** $AUTOR  
**Fecha:** $(date +%Y-%m-%d)

## Descripción

$DESCRIPCION

## Estructura del Proyecto

\`\`\`
$nombre_dir/
├── main.tex              # Documento principal
├── portada.tex           # Portada del manual
├── manual-config.yml     # Configuración del manual
├── capitulos/            # Capítulos/habilidades
├── anexos/              # Anexos técnicos
├── imagenes/            # Capturas de pantalla y diagramas
└── estilos/             # Archivos de estilo LaTeX
\`\`\`

## Compilación

Para compilar el manual:

\`\`\`bash
xelatex -interaction=nonstopmode -shell-escape main.tex
\`\`\`

## Capítulos Incluidos

EOF

    for hab in "${HABILIDADES_SELECCIONADAS[@]}"; do
        echo "- $hab" >> "$RUTA_DESTINO/README.md"
    done
    
    cat >> "$RUTA_DESTINO/README.md" << EOF

## Notas

Este manual fue generado utilizando el [SandraManuals Framework](https://github.com/codeepic/sandra-manuals).

---

**Code Epic Technologies** - Caracas, Venezuela
EOF
}

# Mensaje final
mostrar_resumen() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}            ${BOLD}Proyecto Creado Exitosamente${NC}                   ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Resumen:${NC}"
    echo "  Nombre: $NOMBRE_MANUAL"
    echo "  Versión: $VERSION"
    echo "  Entorno: $ENTORNO"
    echo "  Ubicación: $RUTA_DESTINO"
    echo "  Habilidades: ${#HABILIDADES_SELECCIONADAS[@]}"
    echo ""
    echo -e "${BOLD}Próximos pasos:${NC}"
    echo "  1. cd $RUTA_DESTINO"
    echo "  2. Revisa manual-config.yml para personalizar"
    echo "  3. Edita los capítulos en la carpeta capitulos/"
    echo "  4. Compila con: xelatex -interaction=nonstopmode -shell-escape main.tex"
    echo ""
    echo -e "${CYAN}¡Feliz documentación!${NC} 📚"
    echo ""
}

# Función principal
main() {
    print_header
    
    paso_1_info_basica
    paso_2_entorno
    paso_3_habilidades
    paso_4_preliminares
    paso_5_ruta
    paso_6_readme
    
    crear_proyecto
    mostrar_resumen
}

# Ejecutar
main "$@"
