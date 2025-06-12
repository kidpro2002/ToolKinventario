#!/bin/bash
# ToolKinventario - Script de Desinstalación AUTOMÁTICA
# Elimina completamente ToolKinventario del sistema SIN CONFIRMACIÓN
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
║                      DESINSTALADOR AUTOMÁTICO                                 ║
║                    Sistema de Inventario para Raspberry Pi                    ║
║                              Por Don Nadie Apps                               ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
    print_error "Este script debe ejecutarse como root (sudo)."
    print_message "Ejecute: sudo bash uninstall_auto.sh"
    exit 1
fi

# Verificar si ToolKinventario está instalado
if [ ! -d "$INSTALL_DIR" ]; then
    print_error "ToolKinventario no parece estar instalado en $INSTALL_DIR."
    print_message "No hay nada que desinstalar."
    exit 1
fi

print_warning "🚀 DESINSTALACIÓN AUTOMÁTICA INICIADA"
print_warning "⚡ Eliminando ToolKinventario completamente..."
print_warning "⚡ NO SE HARÁN PREGUNTAS - PROCESO AUTOMÁTICO"

# Crear respaldo automático de emergencia
BACKUP_DIR="/tmp/toolkinventario_backup_emergency_$(date +%Y%m%d_%H%M%S)"
print_step "Creando respaldo de emergencia en $BACKUP_DIR..."

mkdir -p "$BACKUP_DIR"

if [ -f "$INSTALL_DIR/database/toolkinventario.db" ]; then
    cp "$INSTALL_DIR/database/toolkinventario.db" "$BACKUP_DIR/" 2>/dev/null || true
    print_success "Base de datos respaldada automáticamente"
fi

if [ -d "$INSTALL_DIR/uploads" ] && [ "$(ls -A $INSTALL_DIR/uploads 2>/dev/null)" ]; then
    cp -r "$INSTALL_DIR/uploads" "$BACKUP_DIR/" 2>/dev/null || true
    print_success "Archivos subidos respaldados automáticamente"
fi

print_success "Respaldo de emergencia creado en: $BACKUP_DIR"

# Iniciar proceso de desinstalación
print_step "🔥 Iniciando eliminación completa de ToolKinventario..."

# Detener y deshabilitar el servicio
print_step "⏹️ Deteniendo y deshabilitando el servicio..."
systemctl stop "$SERVICE_NAME" 2>/dev/null || true
systemctl disable "$SERVICE_NAME" 2>/dev/null || true
print_success "Servicio detenido y deshabilitado"

# Eliminar el archivo de servicio
if [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
    rm "/etc/systemd/system/$SERVICE_NAME.service" 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true
    print_success "Archivo de servicio eliminado"
fi

# Eliminar tareas de cron para todos los usuarios
print_step "🗑️ Eliminando tareas programadas..."
for user in $(cut -f1 -d: /etc/passwd); do
    if [ -d "/home/$user" ] || [ "$user" = "root" ]; then
        crontab -u "$user" -l 2>/dev/null | grep -v "toolkinventario" | crontab -u "$user" - 2>/dev/null || true
    fi
done
print_success "Tareas programadas eliminadas"

# Eliminar reglas de firewall
print_step "🔥 Eliminando reglas de firewall..."
if command -v ufw >/dev/null 2>&1; then
    ufw delete allow 5000/tcp >/dev/null 2>&1 || true
    print_success "Reglas de firewall eliminadas"
fi

# Matar cualquier proceso relacionado
print_step "💀 Terminando procesos relacionados..."
pkill -f "toolkinventario" 2>/dev/null || true
pkill -f "/opt/toolkinventario" 2>/dev/null || true
print_success "Procesos terminados"

# Eliminar directorio de instalación
print_step "🗂️ Eliminando archivos de la aplicación..."
rm -rf "$INSTALL_DIR" 2>/dev/null || true
print_success "Archivos de la aplicación eliminados"

# Limpiar archivos temporales
print_step "🧹 Limpiando archivos temporales..."
rm -rf /tmp/toolkinventario* 2>/dev/null || true
rm -rf /var/tmp/toolkinventario* 2>/dev/null || true
print_success "Archivos temporales eliminados"

# Limpiar logs del sistema
print_step "📋 Limpiando logs del sistema..."
journalctl --vacuum-time=1d >/dev/null 2>&1 || true
print_success "Logs del sistema limpiados"

# Eliminar usuario si existe (solo si fue creado por la aplicación)
if id "toolkinventario" &>/dev/null; then
    print_step "👤 Eliminando usuario del sistema..."
    userdel -r toolkinventario 2>/dev/null || true
    print_success "Usuario del sistema eliminado"
fi

# Limpiar cache de pip
print_step "🧽 Limpiando cache..."
if command -v pip3 >/dev/null 2>&1; then
    pip3 cache purge >/dev/null 2>&1 || true
fi
print_success "Cache limpiado"

# Finalizar desinstalación
echo -e "${GREEN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════════╗
║                                                                                ║
║                      ✅ DESINSTALACIÓN AUTOMÁTICA COMPLETADA                  ║
║                                                                                ║
║                ToolKinventario ha sido eliminado completamente                ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_success "🎯 ToolKinventario ha sido desinstalado exitosamente."
print_success "🗑️ Todos los archivos y configuraciones han sido eliminados."
print_success "💾 Respaldo de emergencia creado en: $BACKUP_DIR"

echo ""
print_message "📊 RESUMEN DE LA DESINSTALACIÓN:"
print_message "   ✅ Servicio systemd eliminado"
print_message "   ✅ Archivos de aplicación eliminados"
print_message "   ✅ Tareas programadas eliminadas"
print_message "   ✅ Reglas de firewall eliminadas"
print_message "   ✅ Procesos terminados"
print_message "   ✅ Cache limpiado"
print_message "   💾 Respaldo de emergencia: $BACKUP_DIR"

echo ""
print_message "🔄 PARA REINSTALAR:"
print_message "   curl -sSL https://raw.githubusercontent.com/kidpro2002/ToolKinventario/main/install.sh | sudo bash"

echo ""
print_message "🙏 ¡Gracias por haber usado ToolKinventario!"
print_message "💌 Desarrollado con ❤️ por Don Nadie Apps"

# Mostrar información del respaldo
echo ""
print_warning "📁 RESPALDO DE EMERGENCIA DISPONIBLE:"
print_warning "   Ubicación: $BACKUP_DIR"
if [ -f "$BACKUP_DIR/toolkinventario.db" ]; then
    print_warning "   📊 Base de datos: $(ls -lh $BACKUP_DIR/toolkinventario.db | awk '{print $5}')"
fi
if [ -d "$BACKUP_DIR/uploads" ]; then
    print_warning "   📁 Archivos subidos: $(du -sh $BACKUP_DIR/uploads | awk '{print $1}')"
fi
print_warning "   🗑️ Para eliminar el respaldo: sudo rm -rf $BACKUP_DIR"

echo ""
print_success "✅ Desinstalación automática completada exitosamente"
