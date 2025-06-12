#!/bin/bash
# ToolKinventario - Instalador/Actualizador Universal
# Instala nueva versión o actualiza preservando datos
# Por Don Nadie Apps

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

print_update() {
    echo -e "${CYAN}[UPDATE]${NC} $1"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detectar usuario actual (funciona con cualquier usuario)
CURRENT_USER=$(whoami)
if [ "$CURRENT_USER" = "root" ]; then
    # Si es root, usar el usuario que invocó sudo
    ACTUAL_USER=${SUDO_USER:-pi}
else
    ACTUAL_USER=$CURRENT_USER
fi

# Detectar directorio home del usuario
if [ "$ACTUAL_USER" = "root" ]; then
    USER_HOME="/root"
else
    USER_HOME="/home/$ACTUAL_USER"
fi

# Configuración
INSTALL_DIR="/opt/toolkinventario"
VENV_DIR="$INSTALL_DIR/venv"
SERVICE_NAME="toolkinventario"
BACKUP_DIR="$INSTALL_DIR/backups"
UPDATE_DIR="$INSTALL_DIR/update_temp"
VERSION_FILE="$INSTALL_DIR/version.txt"
CURRENT_VERSION="1.0.0"
REPO_URL="https://raw.githubusercontent.com/kidpro2002/ToolKinventario/main"

# Función para detectar si es instalación nueva o actualización
detect_installation_type() {
    if [ -d "$INSTALL_DIR" ] && [ -f "$INSTALL_DIR/run.py" ]; then
        return 0  # Es actualización
    else
        return 1  # Es instalación nueva
    fi
}

# Función para obtener versión actual
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

# Función para crear respaldo antes de actualizar
create_update_backup() {
    local backup_name="pre_update_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    print_step "Creando respaldo de seguridad antes de actualizar..."
    
    mkdir -p "$backup_path"
    
    # Respaldar base de datos
    if [ -f "$INSTALL_DIR/database/toolkinventario.db" ]; then
        cp "$INSTALL_DIR/database/toolkinventario.db" "$backup_path/"
        print_success "Base de datos respaldada"
    fi
    
    # Respaldar configuraciones personalizadas si existen
    if [ -f "$INSTALL_DIR/config.py" ]; then
        cp "$INSTALL_DIR/config.py" "$backup_path/"
        print_success "Configuración personalizada respaldada"
    fi
    
    # Respaldar uploads si existen
    if [ -d "$INSTALL_DIR/uploads" ] && [ "$(ls -A $INSTALL_DIR/uploads)" ]; then
        cp -r "$INSTALL_DIR/uploads" "$backup_path/"
        print_success "Archivos subidos respaldados"
    fi
    
    # Crear archivo de información del respaldo
    cat > "$backup_path/backup_info.txt" << EOF
Respaldo creado: $(date)
Versión anterior: $(get_current_version)
Versión nueva: $CURRENT_VERSION
Tipo: Actualización automática
EOF
    
    print_success "Respaldo completo creado en: $backup_path"
    echo "$backup_path" > "$INSTALL_DIR/last_backup.txt"
}

# Función para actualización sin interrupción
update_application() {
    local old_version=$(get_current_version)
    
    print_update "🔄 Iniciando actualización desde v$old_version a v$CURRENT_VERSION"
    
    # Crear respaldo de seguridad
    create_update_backup
    
    # Crear directorio temporal para la actualización
    print_step "Preparando actualización..."
    rm -rf "$UPDATE_DIR"
    mkdir -p "$UPDATE_DIR"
    
    # Detener servicio temporalmente
    print_step "Deteniendo servicio temporalmente..."
    systemctl stop "$SERVICE_NAME" 2>/dev/null || true
    
    # Preservar datos críticos
    print_step "Preservando datos existentes..."
    
    # Copiar base de datos
    if [ -d "$INSTALL_DIR/database" ]; then
        cp -r "$INSTALL_DIR/database" "$UPDATE_DIR/"
        print_success "Base de datos preservada"
    fi
    
    # Copiar respaldos existentes
    if [ -d "$INSTALL_DIR/backups" ]; then
        cp -r "$INSTALL_DIR/backups" "$UPDATE_DIR/"
        print_success "Respaldos preservados"
    fi
    
    # Copiar logs existentes
    if [ -d "$INSTALL_DIR/logs" ]; then
        cp -r "$INSTALL_DIR/logs" "$UPDATE_DIR/"
        print_success "Logs preservados"
    fi
    
    # Copiar uploads si existen
    if [ -d "$INSTALL_DIR/uploads" ]; then
        cp -r "$INSTALL_DIR/uploads" "$UPDATE_DIR/"
        print_success "Archivos subidos preservados"
    fi
    
    # Copiar configuraciones personalizadas
    if [ -f "$INSTALL_DIR/config.py" ]; then
        cp "$INSTALL_DIR/config.py" "$UPDATE_DIR/"
        print_success "Configuración personalizada preservada"
    fi
    
    # Actualizar código de la aplicación
    print_step "Actualizando código de la aplicación..."
    
    # Descargar run.py desde el repositorio
    curl -sSL "$REPO_URL/run.py" -o "$INSTALL_DIR/run.py"
    print_success "Archivo principal actualizado"
    
    # Restaurar datos preservados
    print_step "Restaurando datos preservados..."
    
    if [ -d "$UPDATE_DIR/database" ]; then
        cp -r "$UPDATE_DIR/database" "$INSTALL_DIR/"
        print_success "Base de datos restaurada"
    fi
    
    if [ -d "$UPDATE_DIR/backups" ]; then
        cp -r "$UPDATE_DIR/backups" "$INSTALL_DIR/"
        print_success "Respaldos restaurados"
    fi
    
    if [ -d "$UPDATE_DIR/logs" ]; then
        cp -r "$UPDATE_DIR/logs" "$INSTALL_DIR/"
        print_success "Logs restaurados"
    fi
    
    if [ -d "$UPDATE_DIR/uploads" ]; then
        cp -r "$UPDATE_DIR/uploads" "$INSTALL_DIR/"
        print_success "Archivos subidos restaurados"
    fi
    
    if [ -f "$UPDATE_DIR/config.py" ]; then
        cp "$UPDATE_DIR/config.py" "$INSTALL_DIR/"
        print_success "Configuración personalizada restaurada"
    fi
    
    # Actualizar dependencias si es necesario
    print_step "Verificando dependencias..."
    source "$VENV_DIR/bin/activate"
    
    # Descargar requirements.txt desde el repositorio
    curl -sSL "$REPO_URL/requirements.txt" -o "$INSTALL_DIR/requirements.txt"
    pip install --upgrade --quiet -r "$INSTALL_DIR/requirements.txt"
    
    print_success "Dependencias actualizadas"
    
    # Ejecutar migraciones de base de datos si es necesario
    print_step "Verificando base de datos..."
    run_database_migrations
    
    # Actualizar versión
    echo "$CURRENT_VERSION" > "$VERSION_FILE"
    
    # Establecer permisos correctos
    print_step "Estableciendo permisos..."
    chown -R "$ACTUAL_USER:$ACTUAL_USER" "$INSTALL_DIR"
    chmod -R 755 "$INSTALL_DIR"
    chmod 777 "$INSTALL_DIR/database"
    chmod +x "$INSTALL_DIR/run.py"
    
    # Limpiar directorio temporal
    rm -rf "$UPDATE_DIR"
    
    # Reiniciar servicio
    print_step "Reiniciando servicio..."
    systemctl daemon-reload
    systemctl start "$SERVICE_NAME"
    
    # Verificar que el servicio esté funcionando
    sleep 3
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        print_success "✅ Actualización completada exitosamente"
        print_success "🚀 Servicio reiniciado y funcionando"
        print_update "📈 Actualizado de v$old_version a v$CURRENT_VERSION"
    else
        print_error "❌ Error al reiniciar el servicio"
        print_warning "🔄 Intentando restaurar desde respaldo..."
        restore_from_backup
    fi
}

# Función para restaurar desde respaldo en caso de error
restore_from_backup() {
    if [ -f "$INSTALL_DIR/last_backup.txt" ]; then
        local backup_path=$(cat "$INSTALL_DIR/last_backup.txt")
        if [ -d "$backup_path" ]; then
            print_warning "Restaurando desde respaldo: $backup_path"
            
            # Detener servicio
            systemctl stop "$SERVICE_NAME" 2>/dev/null || true
            
            # Restaurar base de datos
            if [ -f "$backup_path/toolkinventario.db" ]; then
                cp "$backup_path/toolkinventario.db" "$INSTALL_DIR/database/"
                print_success "Base de datos restaurada desde respaldo"
            fi
            
            # Restaurar configuración
            if [ -f "$backup_path/config.py" ]; then
                cp "$backup_path/config.py" "$INSTALL_DIR/"
                print_success "Configuración restaurada desde respaldo"
            fi
            
            # Reiniciar servicio
            systemctl start "$SERVICE_NAME"
            
            if systemctl is-active --quiet "$SERVICE_NAME"; then
                print_success "✅ Sistema restaurado desde respaldo"
            else
                print_error "❌ Error crítico. Contacte soporte técnico"
            fi
        fi
    fi
}

# Función para ejecutar migraciones de base de datos
run_database_migrations() {
    # Aquí se ejecutarían las migraciones necesarias
    # Por ejemplo, agregar nuevas columnas, tablas, etc.
    
    print_step "Ejecutando migraciones de base de datos..."
    
    # Ejemplo de migración: agregar tabla de configuración si no existe
    if [ -f "$INSTALL_DIR/database/toolkinventario.db" ]; then
        sqlite3 "$INSTALL_DIR/database/toolkinventario.db" << 'EOF'
CREATE TABLE IF NOT EXISTS configuracion (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    clave VARCHAR(100) UNIQUE NOT NULL,
    valor TEXT,
    descripcion TEXT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Insertar configuraciones por defecto si no existen
INSERT OR IGNORE INTO configuracion (clave, valor, descripcion) VALUES 
('version', '1.0.0', 'Versión de la aplicación'),
('backup_auto', 'true', 'Respaldos automáticos habilitados'),
('backup_dias', '7', 'Días de respaldos a mantener');
EOF
        print_success "Migraciones de base de datos completadas"
    fi
}

# Mostrar banner
echo -e "${CYAN}"
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
║                 INSTALADOR/ACTUALIZADOR INTELIGENTE                           ║
║                    Sistema de Inventario para Raspberry Pi                    ║
║                              Por Don Nadie Apps                               ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
    print_error "Este script debe ejecutarse como root (sudo)."
    print_message "Ejecute: curl -sSL $REPO_URL/install.sh | sudo bash"
    exit 1
fi

# Detectar tipo de instalación
if detect_installation_type; then
    IS_UPDATE=true
    OLD_VERSION=$(get_current_version)
    print_update "🔄 Actualización detectada"
    print_message "Versión actual: v$OLD_VERSION"
    print_message "Versión nueva: v$CURRENT_VERSION"
    print_message "Usuario detectado: $ACTUAL_USER"
    print_message "Directorio de instalación: $INSTALL_DIR"
    
    if [ "$OLD_VERSION" = "$CURRENT_VERSION" ]; then
        print_warning "Ya tiene la versión más reciente instalada (v$CURRENT_VERSION)"
        read -p "¿Desea reinstalar/reparar la instalación? (s/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            print_message "Operación cancelada."
            exit 0
        fi
    fi
    
    # Proceder con actualización
    update_application
else
    IS_UPDATE=false
    print_message "🆕 Nueva instalación detectada"
    print_message "Usuario detectado: $ACTUAL_USER"
    print_message "Directorio de instalación: $INSTALL_DIR"
    
    # Verificar conexión a internet
    print_step "Verificando conexión a internet..."
    if ! ping -c 1 google.com &> /dev/null; then
        print_error "No hay conexión a internet. Verifique su conexión y vuelva a intentar."
        exit 1
    fi
    print_success "Conexión a internet verificada"
    
    # Actualizar sistema
    print_step "Actualizando sistema..."
    apt update -qq
    print_success "Sistema actualizado"
    
    # Instalar dependencias del sistema
    print_step "Instalando dependencias del sistema..."
    apt install -y -qq \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        build-essential \
        git \
        curl \
        wget \
        sqlite3 \
        libsqlite3-dev \
        nginx \
        supervisor \
        ufw \
        htop \
        tree \
        nano \
        vim \
        unzip \
        zip \
        cron
    
    print_success "Dependencias del sistema instaladas"
    
    # Crear directorio de instalación
    print_step "Creando estructura de directorios..."
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Crear estructura completa
    mkdir -p {database,backups,logs,uploads,static/{css,js,img},templates/{auth,productos,movimientos,categorias,proveedores,importar_exportar,admin},app}
    
    print_success "Estructura de directorios creada"
    
    # Crear entorno virtual
    print_step "Creando entorno virtual Python..."
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip wheel setuptools
    print_success "Entorno virtual creado"
    
    # Instalar dependencias de Python
    print_step "Instalando dependencias de Python..."
    
    # Descargar requirements.txt desde el repositorio
    curl -sSL "$REPO_URL/requirements.txt" -o "$INSTALL_DIR/requirements.txt"
    pip install --quiet -r "$INSTALL_DIR/requirements.txt"
    
    print_success "Dependencias de Python instaladas"
    
    # Descargar aplicación principal
    print_step "Descargando aplicación principal..."
    curl -sSL "$REPO_URL/run.py" -o "$INSTALL_DIR/run.py"
    print_success "Aplicación principal descargada"
    
    # Establecer permisos correctos
    print_step "Estableciendo permisos..."
    chown -R "$ACTUAL_USER:$ACTUAL_USER" "$INSTALL_DIR"
    chmod -R 755 "$INSTALL_DIR"
    chmod 777 "$INSTALL_DIR/database"
    chmod +x "$INSTALL_DIR/run.py"
    
    print_success "Permisos establecidos"
    
    # Crear servicio systemd
    print_step "Creando servicio systemd..."
    cat > "/etc/systemd/system/$SERVICE_NAME.service" << EOF
[Unit]
Description=ToolKinventario - Sistema de Inventario
After=network.target

[Service]
Type=simple
User=$ACTUAL_USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$VENV_DIR/bin/python $INSTALL_DIR/run.py
Restart=always
RestartSec=5
Environment=FLASK_ENV=production
Environment=PORT=5000

[Install]
WantedBy=multi-user.target
EOF
    
    # Recargar systemd y habilitar servicio
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME.service"
    systemctl start "$SERVICE_NAME.service"
    
    print_success "Servicio systemd configurado"
    
    # Crear script de respaldo
    print_step "Configurando respaldos automáticos..."
    cat > "$INSTALL_DIR/backup.sh" << 'EOF'
#!/bin/bash
# Script de respaldo automático para ToolKinventario
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/toolkinventario/backups"
DB_FILE="/opt/toolkinventario/database/toolkinventario.db"

# Crear directorio de respaldos si no existe
mkdir -p "$BACKUP_DIR"

# Crear respaldo de la base de datos
if [ -f "$DB_FILE" ]; then
    sqlite3 "$DB_FILE" ".backup '$BACKUP_DIR/toolkinventario_$DATE.db'"
    
    # Comprimir respaldo
    tar -czf "$BACKUP_DIR/toolkinventario_backup_$DATE.tar.gz" -C "$BACKUP_DIR" "toolkinventario_$DATE.db"
    
    # Eliminar archivo temporal
    rm "$BACKUP_DIR/toolkinventario_$DATE.db"
    
    # Mantener solo los últimos 7 respaldos
    find "$BACKUP_DIR" -name "toolkinventario_backup_*.tar.gz" -type f -mtime +7 -delete
    
    echo "✅ Respaldo creado: toolkinventario_backup_$DATE.tar.gz"
else
    echo "❌ No se encontró la base de datos"
fi
EOF
    
    chmod +x "$INSTALL_DIR/backup.sh"
    
    # Configurar cron para respaldos diarios
    (crontab -u "$ACTUAL_USER" -l 2>/dev/null; echo "0 2 * * * $INSTALL_DIR/backup.sh") | crontab -u "$ACTUAL_USER" -
    
    print_success "Respaldos automáticos configurados"
    
    # Configurar firewall básico
    print_step "Configurando firewall..."
    ufw --force enable
    ufw allow 5000/tcp
    ufw allow ssh
    print_success "Firewall configurado"
    
    # Crear archivo de versión
    echo "$CURRENT_VERSION" > "$VERSION_FILE"
fi

# Esperar a que el servicio inicie
print_step "Verificando instalación..."
sleep 5

# Verificar estado del servicio
if systemctl is-active --quiet "$SERVICE_NAME"; then
    print_success "Servicio funcionando correctamente"
else
    print_warning "El servicio no está funcionando. Verificando..."
    systemctl status "$SERVICE_NAME" --no-pager
fi

# Obtener IP del sistema
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Finalizar instalación/actualización
if [ "$IS_UPDATE" = true ]; then
    echo -e "${GREEN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════════╗
║                                                                                ║
║                          ✅ ACTUALIZACIÓN COMPLETADA                          ║
║                                                                                ║
║                    🎉 ToolKinventario actualizado exitosamente                ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    print_success "¡ToolKinventario actualizado de v$OLD_VERSION a v$CURRENT_VERSION!"
    print_success "✅ Todos los datos han sido preservados"
    print_success "🔄 Servicio reiniciado automáticamente"
else
    echo -e "${GREEN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════════╗
║                                                                                ║
║                          ✅ INSTALACIÓN COMPLETADA                            ║
║                                                                                ║
║                    🎉 ToolKinventario está listo para usar                    ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    print_success "¡ToolKinventario instalado exitosamente!"
fi

echo ""
print_message "📍 INFORMACIÓN DE ACCESO:"
echo "   🌐 URL Local: http://localhost:5000"
echo "   🌐 URL Red: http://$IP_ADDRESS:5000"
echo "   👤 Usuario: admin"
echo "   🔑 Contraseña: admin123"
echo ""
print_message "🔄 ACTUALIZACIONES FUTURAS:"
echo "   Para actualizar: curl -sSL $REPO_URL/install.sh | sudo bash"
echo "   ✅ Las actualizaciones preservan todos los datos"
echo "   🔄 El servicio se reinicia automáticamente"
echo ""
print_message "📁 UBICACIONES IMPORTANTES:"
echo "   📂 Instalación: $INSTALL_DIR"
echo "   💾 Base de datos: $INSTALL_DIR/database/"
echo "   📋 Respaldos: $INSTALL_DIR/backups/"
echo "   📄 Logs: $INSTALL_DIR/logs/"
echo ""
print_message "🔧 COMANDOS ÚTILES:"
echo "   ▶️  Iniciar: sudo systemctl start $SERVICE_NAME"
echo "   ⏹️  Detener: sudo systemctl stop $SERVICE_NAME"
echo "   🔄 Reiniciar: sudo systemctl restart $SERVICE_NAME"
echo "   📊 Estado: sudo systemctl status $SERVICE_NAME"
echo "   📋 Logs: sudo journalctl -u $SERVICE_NAME -f"
echo ""
print_success "🎯 Acceda ahora a: http://$IP_ADDRESS:5000"
print_success "📖 Manual disponible en: http://$IP_ADDRESS:5000/manual"
echo ""
print_message "🙏 ¡Gracias por usar ToolKinventario!"
print_message "💌 Desarrollado con ❤️ por Don Nadie Apps"
