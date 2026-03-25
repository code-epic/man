#!/bin/bash
#======================================================================
# SANDRA-BUILD - Script para compilar manuales LaTeX
# Autor: Carlos Peña
# Versión: 1.0.0
#======================================================================

set -e

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Variables
MOTOR="xelatex"
OPCIONES="-interaction=nonstopmode -shell-escape"
ARCHIVO="main.tex"
LIMPIO=false

# Función de ayuda
usage() {
    echo "Uso: $0 [opciones] [archivo]"
    echo ""
    echo "Opciones:"
    echo "  -m, --motor      Motor de compilación (xelatex|pdflatex|lualatex) [default: xelatex]"
    echo "  -c, --clean      Limpiar archivos auxiliares después de compilar"
    echo "  -d, --draft      Modo borrador (compilación rápida)"
    echo "  -h, --help       Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0                          Compilar main.tex con XeLaTeX"
    echo "  $0 -c                       Compilar y limpiar archivos auxiliares"
    echo "  $0 -m pdflatex              Usar pdfLaTeX en lugar de XeLaTeX"
    echo "  $0 -d manual.tex            Compilar en modo borrador"
}

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--motor)
            MOTOR="$2"
            shift 2
            ;;
        -c|--clean)
            LIMPIO=true
            shift
            ;;
        -d|--draft)
            OPCIONES="-interaction=nonstopmode -draftmode"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Opción desconocida: $1"
            usage
            exit 1
            ;;
        *)
            ARCHIVO="$1"
            shift
            ;;
    esac
done

# Verificar que el archivo existe
if [ ! -f "$ARCHIVO" ]; then
    echo -e "${RED}Error: No se encontró el archivo $ARCHIVO${NC}"
    exit 1
fi

# Verificar motor disponible
if ! command -v "$MOTOR" &> /dev/null; then
    echo -e "${RED}Error: $MOTOR no está instalado${NC}"
    exit 1
fi

echo -e "${BLUE}Compilando $ARCHIVO con $MOTOR...${NC}"
echo "=================================================="

# Compilar (2 pasos para referencias cruzadas)
$MOTOR $OPCIONES "$ARCHIVO" || { echo -e "${RED}Error en la compilación${NC}"; exit 1; }
$MOTOR $OPCIONES "$ARCHIVO" || { echo -e "${RED}Error en la segunda pasada${NC}"; exit 1; }

# Compilar índice si existe
if [ -f "${ARCHIVO%.tex}.idx" ]; then
    echo -e "${BLUE}Generando índice...${NC}"
    makeindex "${ARCHIVO%.tex}.idx" 2>/dev/null || true
    echo -e "${BLUE}Integrando índice en el documento...${NC}"
    $MOTOR $OPCIONES "$ARCHIVO" >/dev/null 2>&1 || true
fi

# Compilar glosario si existe
if [ -f "${ARCHIVO%.tex}.glo" ]; then
    echo -e "${BLUE}Generando glosario...${NC}"
    makeglossaries "${ARCHIVO%.tex}" 2>/dev/null || true
fi

# Compilar bibliografía si existe
if [ -f "referencias.bib" ]; then
    echo -e "${BLUE}Compilando bibliografía...${NC}"
    bibtex "${ARCHIVO%.tex}" 2>/dev/null || true
    $MOTOR $OPCIONES "$ARCHIVO" 2>/dev/null || true
    $MOTOR $OPCIONES "$ARCHIVO" 2>/dev/null || true
fi

# Limpiar si se solicitó
if [ "$LIMPIO" = true ]; then
    echo -e "${BLUE}Limpiando archivos auxiliares...${NC}"
    rm -f *.aux *.log *.out *.toc *.lof *.lot *.idx *.ind *.ilg *.glo *.gls *.bbl *.blg *.bak
    echo -e "${GREEN}✓ Limpieza completada${NC}"
fi

# Mostrar resultado
PDF_FILE="${ARCHIVO%.tex}.pdf"
if [ -f "$PDF_FILE" ]; then
    SIZE=$(du -h "$PDF_FILE" | cut -f1)
    echo -e "${GREEN}✓ Compilación exitosa${NC}"
    echo -e "${GREEN}  Archivo: $PDF_FILE${NC}"
    echo -e "${GREEN}  Tamaño: $SIZE${NC}"
else
    echo -e "${RED}✗ No se generó el archivo PDF${NC}"
    exit 1
fi
