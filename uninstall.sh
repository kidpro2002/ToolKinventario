#!/bin/bash
# ToolKinventario - Script de Desinstalación
# Elimina completamente ToolKinventario del sistema
# Por Don Nadie Apps

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
print_message() {
    echo -e "${BLUE}[ToolKinventario]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[PASO]${NC} $1"
}

# Configuración
INSTALL_DIR="/opt/toolkinventario"
SERVICE_NAME="toolkinventario"

# Mostrar banner
echo -e "${RED}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════════╗
║                                                                                ║
║   ████████╗ ██████╗  ██████╗ ██╗     ██╗  ██╗██╗███╗   ██╗██╗   ██╗███████╗   ║
║   ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██║ ██╔╝██║████╗  ██║██║   ██║██╔════╝   ║
║      ██║   ██║   ██║██║   ██║██║     █████╔╝ ██║██╔██╗ ██║██║   ██║█████╗     ║
║      ██║   ██║   ██║██║   ██║██║     ██╔═██╗ ██║██║╚██╗██║╚██╗ ██╔╝██╔══╝     ║
║      ██║   ╚██████╔╝╚██████╔╝███████╗██║  ██╗██║██║ ╚████║ ╚████╔╝ ███████╗   ║
║      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝  ╚═══╝  ╚══════╝   ║
║                                                                                ║
║                      DESINSTALADOR COMPLETO                                   ║
║                    Sistema de Inventario para Raspberry Pi                    ║
║                              Por Don Nadie Apps                               ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
    print_error "Este script debe ejecutarse como root (sudo)."
    print_message "Ejecute: sudo bash uninstall.sh"
    exit 1
fi

# Verificar si ToolKinventario está instalado
if [ ! -d "$INSTALL_DIR" ]; then
    print_error "ToolKinventario no parece estar instalado en $INSTALL_DIR."
    print_message "No hay nada que desinstalar."
    exit 1
fi

# Confirmar desinstalación
print_warning "⚠️ ADVERTENCIA: Esta acción eliminará completamente ToolKinventario y todos sus datos."
print_warning "⚠️ Se eliminarán todos los productos, movimientos, configuraciones y respaldos."
print_warning "⚠️ Esta acción NO SE PUEDE DESHACER."
echo ""
read -p "¿Está seguro que desea desinstalar ToolKinventario? (escriba 'SI' para confirmar): " -r
echo ""

if [[ ! $REPLY == "SI" ]]; then
    print_message "Desinstalación cancelada."
    exit 0
fi

# Preguntar si desea hacer un respaldo final
read -p "¿Desea crear un respaldo final de la base de datos antes de desinstalar? (s/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Ss]$ ]]; then
    BACKUP_DIR="$HOME/toolkinventario_backup_final_$(date +%Y%m%d_%H%M%S)"
    print_step "Creando respaldo final en $BACKUP_DIR..."
    
    mkdir -p "$BACKUP_DIR"
    
    if [ -f "$INSTALL_DIR/database/toolkinventario.db" ]; then
        cp "$INSTALL_DIR/database/toolkinventario.db" "$BACKUP_DIR/"
        print_success "Base de datos respaldada"
    fi
    
    if [ -d "$INSTALL_DIR/uploads" ] && [ "$(ls -A $INSTALL_DIR/uploads)" ]; then
        cp -r "$INSTALL_DIR/uploads" "$BACKUP_DIR/"
        print_success "Archivos subidos respaldados"
    fi
    
    print_success "Respaldo final creado en: $BACKUP_DIR"
fi

# Iniciar proceso de desinstalación
print_step "Iniciando desinstalación de ToolKinventario..."

# Detener y deshabilitar el servicio
print_step "Deteniendo y deshabilitando el servicio..."
systemctl stop "$SERVICE_NAME" 2>/dev/null || true
systemctl disable "$SERVICE_NAME" 2>/dev/null || true
print_success "Servicio detenido y deshabilitado"

# Eliminar el archivo de servicio
if [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
    rm "/etc/systemd/system/$SERVICE_NAME.service"
    systemctl daemon-reload
    print_success "Archivo de servicio eliminado"
fi

# Eliminar tareas de cron
print_step "Eliminando tareas programadas..."
ACTUAL_USER=${SUDO_USER:-$(whoami)}
if [ "$ACTUAL_USER" != "root" ]; then
    crontab -u "$ACTUAL_USER" -l 2>/dev/null | grep -v "toolkinventario" | crontab -u "$ACTUAL_USER" -
fi
print_success "Tareas programadas eliminadas"

# Eliminar reglas de firewall
print_step "Eliminando reglas de firewall..."
if command -v ufw >/dev/null 2>&1; then
    ufw delete allow 5000/tcp >/dev/null 2>&1 || true
    print_success "Reglas de firewall eliminadas"
fi

# Eliminar directorio de instalación
print_step "Eliminando archivos de la aplicación..."
rm -rf "$INSTALL_DIR"
print_success "Archivos de la aplicación eliminados"

# Limpiar archivos temporales
print_step "Limpiando archivos temporales..."
rm -rf /tmp/toolkinventario* 2>/dev/null || true
print_success "Archivos temporales eliminados"

# Finalizar desinstalación
echo -e "${GREEN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════════╗
║                                                                                ║
║                      ✅ DESINSTALACIÓN COMPLETADA                             ║
║                                                                                ║
║                ToolKinventario ha sido eliminado completamente                ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_success "ToolKinventario ha sido desinstalado exitosamente."
print_success "Todos los archivos y configuraciones han sido eliminados."

if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_message "Se ha creado un respaldo final en: $BACKUP_DIR"
fi

echo ""
print_message "Gracias por haber usado ToolKinventario."
print_message "¡Hasta pronto!"
