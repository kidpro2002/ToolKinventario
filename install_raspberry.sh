#!/bin/bash
# Script de instalación de ToolKinventario para Raspberry Pi
# Por Don Nadie Apps

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
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

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Mostrar banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║   ████████╗ ██████╗  ██████╗ ██╗     ██╗  ██╗██╗███╗   ██╗ ║"
echo "║   ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██║ ██╔╝██║████╗  ██║ ║"
echo "║      ██║   ██║   ██║██║   ██║██║     █████╔╝ ██║██╔██╗ ██║ ║"
echo "║      ██║   ██║   ██║██║   ██║██║     ██╔═██╗ ██║██║╚██╗██║ ║"
echo "║      ██║   ╚██████╔╝╚██████╔╝███████╗██║  ██╗██║██║ ╚████║ ║"
echo "║      ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ║"
echo "║                                                            ║"
echo "║   Sistema de Inventario para Raspberry Pi                  ║"
echo "║   Por Don Nadie Apps                                       ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
    print_error "Este script debe ejecutarse como root (sudo)."
    exit 1
fi

# Verificar si es una Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo && ! grep -q "BCM" /proc/cpuinfo; then
    print_warning "No se detectó una Raspberry Pi. El script está optimizado para Raspberry Pi."
    read -p "¿Desea continuar de todos modos? (s/n): " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Ss]$ ]]; then
        print_message "Instalación cancelada."
        exit 0
    fi
fi

# Directorio de instalación
INSTALL_DIR="/opt/toolkinventario"
VENV_DIR="$INSTALL_DIR/venv"
USER_NAME="pi"

# Verificar si ya está instalado
if [ -d "$INSTALL_DIR" ]; then
    print_warning "ToolKinventario ya parece estar instalado en $INSTALL_DIR"
    read -p "¿Desea reinstalar? Esto eliminará la instalación existente (s/n): " reinstall
    if [[ "$reinstall" =~ ^[Ss]$ ]]; then
        print_message "Eliminando instalación anterior..."
        rm -rf "$INSTALL_DIR"
    else
        print_message "Instalación cancelada."
        exit 0
    fi
fi

# Crear directorio de instalación
print_message "Creando directorio de instalación..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit 1

# Actualizar sistema
print_message "Actualizando sistema..."
apt update
apt upgrade -y

# Instalar dependencias del sistema
print_message "Instalando dependencias del sistema..."
apt install -y python3 python3-pip python3-venv libzbar0 libopencv-dev python3-opencv

# Crear entorno virtual
print_message "Creando entorno virtual Python..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# Instalar dependencias de Python
print_message "Instalando dependencias de Python..."
pip install --upgrade pip
pip install wheel

# Copiar archivos del proyecto
print_message "Copiando archivos del proyecto..."
# Asumiendo que los archivos están en el directorio actual
cp -r . "$INSTALL_DIR"

# Instalar requisitos
print_message "Instalando requisitos de Python..."
pip install -r "$INSTALL_DIR/requirements.txt"

# Crear directorios necesarios
print_message "Creando directorios necesarios..."
mkdir -p "$INSTALL_DIR/database"
mkdir -p "$INSTALL_DIR/backups"
mkdir -p "$INSTALL_DIR/logs"
mkdir -p "$INSTALL_DIR/uploads"

# Establecer permisos
print_message "Estableciendo permisos..."
chown -R "$USER_NAME:$USER_NAME" "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"

# Crear servicio systemd
print_message "Creando servicio systemd..."
cat > /etc/systemd/system/toolkinventario.service << EOF
[Unit]
Description=ToolKinventario - Sistema de Inventario
After=network.target

[Service]
User=$USER_NAME
WorkingDirectory=$INSTALL_DIR
ExecStart=$VENV_DIR/bin/python $INSTALL_DIR/run.py
Restart=always
RestartSec=5
Environment=FLASK_ENV=production
Environment=PORT=5000

[Install]
WantedBy=multi-user.target
EOF

# Recargar systemd
systemctl daemon-reload
systemctl enable toolkinventario.service
systemctl start toolkinventario.service

# Crear script de inicio automático
print_message "Configurando inicio automático..."
cat > /etc/xdg/autostart/toolkinventario.desktop << EOF
[Desktop Entry]
Type=Application
Name=ToolKinventario
Comment=Sistema de Inventario
Exec=chromium-browser --kiosk --app=http://localhost:5000
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

# Crear script de respaldo
print_message "Configurando respaldo automático..."
cat > "$INSTALL_DIR/backup.sh" << EOF
#!/bin/bash
# Script de respaldo automático para ToolKinventario
DATE=\$(date +%Y%m%d)
BACKUP_DIR="$INSTALL_DIR/backups"
DB_FILE="$INSTALL_DIR/database/toolkinventario.db"

# Crear respaldo de la base de datos
sqlite3 \$DB_FILE ".backup '\$BACKUP_DIR/toolkinventario_\$DATE.db'"

# Comprimir respaldo
tar -czf "\$BACKUP_DIR/toolkinventario_backup_\$DATE.tar.gz" -C "\$BACKUP_DIR" "toolkinventario_\$DATE.db"

# Eliminar archivo temporal
rm "\$BACKUP_DIR/toolkinventario_\$DATE.db"

# Mantener solo los últimos 7 respaldos
find "\$BACKUP_DIR" -name "toolkinventario_backup_*.tar.gz" -type f -mtime +7 -delete
EOF

chmod +x "$INSTALL_DIR/backup.sh"

# Configurar cron para respaldos diarios
(crontab -l 2>/dev/null; echo "0 1 * * * $INSTALL_DIR/backup.sh") | crontab -

# Crear acceso directo en el escritorio
print_message "Creando acceso directo en el escritorio..."
cat > "/home/$USER_NAME/Desktop/ToolKinventario.desktop" << EOF
[Desktop Entry]
Type=Application
Name=ToolKinventario
Comment=Sistema de Inventario
Exec=chromium-browser --app=http://localhost:5000
Icon=$INSTALL_DIR/static/img/icon.png
Terminal=false
Categories=Utility;
EOF

chmod +x "/home/$USER_NAME/Desktop/ToolKinventario.desktop"
chown "$USER_NAME:$USER_NAME" "/home/$USER_NAME/Desktop/ToolKinventario.desktop"

# Finalizar instalación
print_success "¡Instalación completada con éxito!"
print_message "ToolKinventario está instalado en: $INSTALL_DIR"
print_message "El servicio se ha iniciado automáticamente."
print_message "Puede acceder a la aplicación en: http://localhost:5000"
print_message "Usuario por defecto: admin"
print_message "Contraseña por defecto: admin123"
print_warning "¡IMPORTANTE! Cambie la contraseña por defecto después de iniciar sesión."

# Mostrar información del sistema
echo ""
print_message "Información del sistema:"
echo "- Sistema operativo: $(cat /etc/os-release | grep PRETTY_NAME | cut -d '=' -f 2 | tr -d '"')"
echo "- Kernel: $(uname -r)"
echo "- Arquitectura: $(uname -m)"
echo "- Memoria total: $(free -h | grep Mem | awk '{print $2}')"
echo "- Espacio en disco: $(df -h / | awk 'NR==2 {print $4}') disponible"

echo ""
print_message "Para iniciar/detener el servicio manualmente:"
echo "- Iniciar: sudo systemctl start toolkinventario"
echo "- Detener: sudo systemctl stop toolkinventario"
echo "- Reiniciar: sudo systemctl restart toolkinventario"
echo "- Estado: sudo systemctl status toolkinventario"

echo ""
print_success "¡Gracias por instalar ToolKinventario!"
