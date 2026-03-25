#!/bin/bash
#======================================================================
# SANDRA-BUILD - Script de compilación para SSSIFANB
#======================================================================
# Autor: Carlos Peña
# Versión: 1.0.0
#======================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MOTOR="${1:-xelatex}"
LIMPIAR="${2:-false}"

case "$MOTOR" in
    xelatex|pdflatex|lualatex) ;;
    *) echo "Motor no soportado: $MOTOR"; exit 1 ;;
esac

echo "=============================================="
echo " Compilando Manual SSSIFANB"
echo " Motor: $MOTOR"
echo "=============================================="

$MOTOR -interaction=nonstopmode -shell-escape main.tex

if [ "$LIMPIAR" = "-c" ] || [ "$LIMPIAR" = "--clean" ]; then
    echo "Limpiando archivos auxiliares..."
    rm -f main.aux main.log main.out main.toc main.lof main.lot main.bbl main.blg
fi

echo "=============================================="
echo " Compilación completada"
echo " PDF generado: main.pdf"
echo "=============================================="
