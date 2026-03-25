# SandraManuals Framework

Framework para la creación de manuales técnicos con LaTeX, desarrollado por Code Epic Technologies.

## Estructura del Framework

```
$HOME/dev/man/
├── .sandra/              # Núcleo del framework
│   ├── config.yml        # Configuración global
│   ├── habilidades/      # Capítulos reutilizables
│   ├── templates/        # Plantillas LaTeX
│   ├── estilos/          # Estilos compartidos
│   └── modelos/          # Esquemas YAML
├── assets/               # Recursos compartidos
│   ├── fonts/            # Fuentes (Inter, FiraCode)
│   ├── iconos/           # 56 iconos SVG
│   └── logos/            # Logos corporativos
├── agentes/              # Scripts de automatización
│   ├── sandra-init.sh    # Wizard de inicialización
│   ├── sandra-add.sh     # Agregar habilidades
│   └── sandra-build.sh   # Compilar manuales
└── manuales/             # Manuales generados
    ├── SandraEcosystem/  # Proyecto importado
    ├── SandraDesktop/    # Proyecto importado
    └── [Nuevos manuales] # Creados con el framework
```

## Uso Rápido

### Crear un nuevo manual

```bash
cd $HOME/dev/man
./agentes/sandra-init.sh
```

Sigue el wizard interactivo para configurar tu manual.

### Estructura de un manual

```yaml
# manual-config.yml
manual:
  nombre: "Mi Manual"
  version: "1.0.0"
  autor: "Carlos Peña"
  entorno: "hibrido"

estructura:
  portada: true
  preliminares:
    - presentacion
    - resumen
  capitulos:
    - introduccion
    - instalacion
    - dashboard
  anexos: true
```

## Habilidades Disponibles

- **introduccion** - Propósito, alcance y estructura
- **instalacion** - Guía de instalación y requisitos
- **dashboard** - Panel de control y navegación
- **configuracion** - Opciones de personalización
- **seguridad** - Estándares y prácticas de seguridad
- **api** - Documentación de API
- **glosario** - Glosario de iconos
- **referencias** - Bibliografía

## Paletas de Colores

- **teal-soft** - Verde pastel (Sandra Desktop)
- **dark-professional** - Oscuro profesional (Sandra Ecosystem)
- **universal** - Combinación de ambos

## Compilación

```bash
cd manuales/[nombre-manual]
xelatex -interaction=nonstopmode -shell-escape main.tex
```

## Autor

**Carlos Peña**  
Code Epic Technologies  
Caracas, Venezuela

## Licencia

Propietario - Code Epic Technologies
