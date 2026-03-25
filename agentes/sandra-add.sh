#!/bin/bash
#======================================================================
# SANDRA-ADD - Script para agregar habilidades a un manual existente
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

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SANDRA_DIR="$(dirname "$SCRIPT_DIR")/.sandra"

# Verificar que estamos en un directorio de manual
if [ ! -f "manual-config.yml" ]; then
    echo -e "${RED}Error: No se encontró manual-config.yml${NC}"
    echo "Este script debe ejecutarse desde un directorio de manual existente"
    exit 1
fi

# Listar habilidades disponibles
echo -e "${BLUE}Habilidades disponibles:${NC}"
echo "=========================="

for archivo in "$SANDRA_DIR/habilidades"/*.tex; do
    if [ -f "$archivo" ]; then
        nombre=$(basename "$archivo" .tex)
        id=$(echo "$nombre" | cut -d- -f2)
        echo "  - $id"
    fi
done

echo ""
echo -n "Ingrese el ID de la habilidad a agregar: "
read HABILIDAD

# Buscar archivo de habilidad
ARCHIVO_HABILIDAD=$(ls "$SANDRA_DIR/habilidades"/*"-$HABILIDAD.tex" 2>/dev/null | head -1)

if [ -z "$ARCHIVO_HABILIDAD" ]; then
    echo -e "${RED}Error: Habilidad '$HABILIDAD' no encontrada${NC}"
    exit 1
fi

# Copiar habilidad
if [ -f "capitulos/$(basename "$ARCHIVO_HABILIDAD")" ]; then
    echo -e "${YELLOW}La habilidad ya existe. ¿Desea sobrescribir? (s/n)${NC}"
    read respuesta
    if [ "$respuesta" != "s" ] && [ "$respuesta" != "S" ]; then
        echo "Operación cancelada"
        exit 0
    fi
fi

cp "$ARCHIVO_HABILIDAD" "capitulos/"
echo -e "${GREEN}✓ Habilidad '$HABILIDAD' agregada${NC}"

# Actualizar manual-config.yml
if ! grep -q "capitulos:" manual-config.yml; then
    echo -e "${YELLOW}Advertencia: No se encontró la sección 'capitulos' en manual-config.yml${NC}"
    exit 0
fi

# Verificar si la habilidad ya está en la configuración
if grep -A 20 "capitulos:" manual-config.yml | grep -q "\- $HABILIDAD"; then
    echo -e "${BLUE}La habilidad ya está en la configuración${NC}"
else
    # Agregar a la configuración
    sed -i.bak "/capitulos:/a\\    - $HABILIDAD" manual-config.yml
    rm -f manual-config.yml.bak
    echo -e "${GREEN}✓ manual-config.yml actualizado${NC}"
fi

echo ""
echo -e "${GREEN}Habilidad agregada exitosamente${NC}"
echo "Recuerde compilar el manual para ver los cambios"
