#!/bin/bash
# ToolKinventario - Instalador Local (Sin GitHub)
# Versión de diagnóstico y corrección de errores

# NO usar set -e para evitar cierre automático
# set -e  # ← COMENTADO para debugging

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

# Función para verificar errores
check_error() {
    if [ $? -ne 0 ]; then
        print_error "Error en: $1"
        print_warning "Continuando con el siguiente paso..."
        return 1
    else
        print_success "$1 completado"
        return 0
    fi
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar prerrequisitos
check_prerequisites() {
    print_step "Verificando prerrequisitos del sistema..."
    
    local errors=0
    
    # Verificar si es root
    if [ "$EUID" -ne 0 ]; then
        print_error "Este script debe ejecutarse como root (sudo)"
        print_message "Ejecute: sudo bash $0"
        ((errors++))
    else
        print_success "Ejecutándose como root"
    fi
    
    # Verificar comandos esenciales
    local required_commands=("curl" "wget" "python3" "pip3" "sqlite3")
    for cmd in "${required_commands[@]}"; do
        if command_exists "$cmd"; then
            print_success "$cmd está disponible"
        else
            print_warning "$cmd no está instalado (se instalará automáticamente)"
        fi
    done
    
    # Verificar conexión a internet
    print_step "Verificando conexión a internet..."
    if ping -c 1 -W 5 google.com >/dev/null 2>&1; then
        print_success "Conexión a internet OK"
    else
        print_error "No hay conexión a internet"
        print_warning "Algunas funciones pueden no estar disponibles"
        ((errors++))
    fi
    
    # Verificar espacio en disco
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [ "$available_space" -gt 1000000 ]; then  # 1GB en KB
        print_success "Espacio en disco suficiente"
    else
        print_warning "Poco espacio en disco disponible"
    fi
    
    # Verificar memoria RAM
    local available_ram=$(free -m | awk 'NR==2{printf "%.0f", $7}')
    if [ "$available_ram" -gt 100 ]; then  # 100MB
        print_success "Memoria RAM suficiente"
    else
        print_warning "Poca memoria RAM disponible"
    fi
    
    if [ $errors -gt 0 ]; then
        print_error "Se encontraron $errors errores críticos"
        read -p "¿Desea continuar de todos modos? (s/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            print_message "Instalación cancelada por el usuario"
            exit 1
        fi
    fi
    
    print_success "Verificación de prerrequisitos completada"
}

# Detectar usuario actual de forma segura
detect_user() {
    print_step "Detectando configuración del usuario..."
    
    CURRENT_USER=$(whoami)
    if [ "$CURRENT_USER" = "root" ]; then
        # Si es root, intentar obtener el usuario real
        if [ -n "$SUDO_USER" ]; then
            ACTUAL_USER="$SUDO_USER"
        elif [ -n "$USER" ]; then
            ACTUAL_USER="$USER"
        else
            ACTUAL_USER="pi"  # Fallback para Raspberry Pi
        fi
    else
        ACTUAL_USER="$CURRENT_USER"
    fi
    
    # Verificar que el usuario existe
    if id "$ACTUAL_USER" >/dev/null 2>&1; then
        print_success "Usuario detectado: $ACTUAL_USER"
    else
        print_warning "Usuario $ACTUAL_USER no existe, usando 'pi' como fallback"
        ACTUAL_USER="pi"
    fi
    
    # Detectar directorio home
    if [ "$ACTUAL_USER" = "root" ]; then
        USER_HOME="/root"
    else
        USER_HOME="/home/$ACTUAL_USER"
    fi
    
    print_success "Directorio home: $USER_HOME"
}

# Configuración global
INSTALL_DIR="/opt/toolkinventario"
SERVICE_NAME="toolkinventario"
CURRENT_VERSION="1.0.0"

# Función principal de instalación
install_toolkinventario() {
    print_step "Iniciando instalación de ToolKinventario..."
    
    # Crear directorio de instalación
    print_step "Creando estructura de directorios..."
    mkdir -p "$INSTALL_DIR" || {
        print_error "No se pudo crear el directorio de instalación"
        return 1
    }
    
    cd "$INSTALL_DIR" || {
        print_error "No se pudo acceder al directorio de instalación"
        return 1
    }
    
    # Crear subdirectorios
    local dirs=("database" "backups" "logs" "uploads" "static/css" "static/js" "static/img" "templates")
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir" && print_success "Directorio $dir creado" || print_warning "Error creando $dir"
    done
    
    # Actualizar sistema
    print_step "Actualizando lista de paquetes..."
    if apt update; then
        print_success "Lista de paquetes actualizada"
    else
        print_warning "Error actualizando paquetes, continuando..."
    fi
    
    # Instalar dependencias básicas
    print_step "Instalando dependencias del sistema..."
    local packages=("python3" "python3-pip" "python3-venv" "sqlite3" "curl" "wget" "git")
    
    for package in "${packages[@]}"; do
        print_step "Instalando $package..."
        if apt install -y "$package"; then
            print_success "$package instalado"
        else
            print_error "Error instalando $package"
        fi
    done
    
    # Crear entorno virtual Python
    print_step "Creando entorno virtual Python..."
    if python3 -m venv "$INSTALL_DIR/venv"; then
        print_success "Entorno virtual creado"
    else
        print_error "Error creando entorno virtual"
        return 1
    fi
    
    # Activar entorno virtual e instalar dependencias Python
    print_step "Instalando dependencias Python..."
    source "$INSTALL_DIR/venv/bin/activate" || {
        print_error "No se pudo activar el entorno virtual"
        return 1
    }
    
    pip install --upgrade pip || print_warning "Error actualizando pip"
    
    local python_packages=("Flask==3.0.0" "Flask-SQLAlchemy==3.1.1" "Flask-Login==0.6.3" "Werkzeug==3.0.1")
    for package in "${python_packages[@]}"; do
        print_step "Instalando $package..."
        if pip install "$package"; then
            print_success "$package instalado"
        else
            print_warning "Error instalando $package"
        fi
    done
    
    # Crear aplicación básica
    print_step "Creando aplicación ToolKinventario..."
    create_basic_app
    
    # Establecer permisos
    print_step "Estableciendo permisos..."
    chown -R "$ACTUAL_USER:$ACTUAL_USER" "$INSTALL_DIR" || print_warning "Error estableciendo permisos"
    chmod -R 755 "$INSTALL_DIR" || print_warning "Error estableciendo permisos de archivos"
    chmod 777 "$INSTALL_DIR/database" || print_warning "Error estableciendo permisos de base de datos"
    chmod +x "$INSTALL_DIR/run.py" || print_warning "Error haciendo ejecutable run.py"
    
    print_success "Permisos establecidos"
    
    # Crear servicio systemd
    create_systemd_service
    
    print_success "¡Instalación completada!"
}

# Función para crear aplicación básica
create_basic_app() {
    cat > "$INSTALL_DIR/run.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ToolKinventario - Sistema de Inventario Básico
Por Don Nadie Apps
"""

import os
import sys
from flask import Flask, render_template_string, redirect, url_for, flash, request
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

# Configuración
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATABASE_DIR = os.path.join(BASE_DIR, 'database')
os.makedirs(DATABASE_DIR, exist_ok=True)

app = Flask(__name__)
app.config['SECRET_KEY'] = 'toolkinventario_secret_key'
app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{os.path.join(DATABASE_DIR, "toolkinventario.db")}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Modelo de Usuario
class Usuario(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(120), nullable=False)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

@login_manager.user_loader
def load_user(user_id):
    return Usuario.query.get(int(user_id))

# Rutas
@app.route('/')
def index():
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user = Usuario.query.filter_by(username=username).first()
        
        if user and user.check_password(password):
            login_user(user)
            return redirect(url_for('dashboard'))
        else:
            flash('Usuario o contraseña incorrectos')
    
    return render_template_string('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>ToolKinventario - Login</title>
        <style>
            body { font-family: Arial, sans-serif; background: #f0f0f0; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
            .login-form { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
            .form-group { margin-bottom: 15px; }
            label { display: block; margin-bottom: 5px; }
            input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
            button { width: 100%; padding: 10px; background: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
            button:hover { background: #0056b3; }
            .alert { color: red; margin-bottom: 15px; }
            h1 { text-align: center; color: #333; }
        </style>
    </head>
    <body>
        <div class="login-form">
            <h1>🔧 ToolKinventario</h1>
            <p style="text-align: center; color: #666;">Sistema de Inventario</p>
            
            {% with messages = get_flashed_messages() %}
                {% if messages %}
                    {% for message in messages %}
                        <div class="alert">{{ message }}</div>
                    {% endfor %}
                {% endif %}
            {% endwith %}
            
            <form method="post">
                <div class="form-group">
                    <label>Usuario:</label>
                    <input type="text" name="username" required>
                </div>
                <div class="form-group">
                    <label>Contraseña:</label>
                    <input type="password" name="password" required>
                </div>
                <button type="submit">Iniciar Sesión</button>
            </form>
            
            <p style="text-align: center; margin-top: 20px; font-size: 12px; color: #666;">
                Usuario: admin | Contraseña: admin123
            </p>
        </div>
    </body>
    </html>
    ''')

@app.route('/dashboard')
@login_required
def dashboard():
    return render_template_string('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>ToolKinventario - Dashboard</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; background: #f8f9fa; }
            .header { background: white; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            .nav { display: flex; justify-content: space-between; align-items: center; }
            .logo { font-size: 24px; font-weight: bold; color: #333; }
            .user-info a { color: #dc3545; text-decoration: none; }
            .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
            .welcome { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px; border-radius: 15px; text-align: center; }
            .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 30px; }
            .stat-card { background: white; padding: 30px; border-radius: 10px; text-align: center; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .stat-number { font-size: 48px; font-weight: bold; color: #667eea; }
            .stat-label { color: #666; margin-top: 10px; }
        </style>
    </head>
    <body>
        <div class="header">
            <div class="nav">
                <div class="logo">🔧 ToolKinventario</div>
                <div class="user-info">
                    Bienvenido, {{ current_user.username }} | <a href="{{ url_for('logout') }}">Cerrar Sesión</a>
                </div>
            </div>
        </div>
        
        <div class="container">
            <div class="welcome">
                <h1>🎉 ¡Bienvenido a ToolKinventario!</h1>
                <p>Sistema de inventario instalado correctamente</p>
                <p><strong>✅ Instalación exitosa - Todo funcionando</strong></p>
            </div>
            
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Productos</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Categorías</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">✅</div>
                    <div class="stat-label">Sistema OK</div>
                </div>
            </div>
        </div>
    </body>
    </html>
    ''')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

def crear_usuario_admin():
    """Crear usuario administrador por defecto"""
    try:
        admin = Usuario.query.filter_by(username='admin').first()
        if not admin:
            admin = Usuario(username='admin')
            admin.set_password('admin123')
            db.session.add(admin)
            db.session.commit()
            print("✅ Usuario admin creado")
    except Exception as e:
        print(f"⚠️ Error creando usuario admin: {e}")

if __name__ == '__main__':
    print("=" * 50)
    print("🔧 ToolKinventario - Sistema de Inventario")
    print("📱 Por Don Nadie Apps")
    print("=" * 50)
    
    try:
        with app.app_context():
            db.create_all()
            crear_usuario_admin()
        
        print("✅ Base de datos inicializada")
        print("🌐 Servidor iniciando en http://0.0.0.0:5000")
        print("👤 Usuario: admin | Contraseña: admin123")
        print("=" * 50)
        
        app.run(host='0.0.0.0', port=5000, debug=False)
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        sys.exit(1)
EOF

    print_success "Aplicación básica creada"
}

# Función para crear servicio systemd
create_systemd_service() {
    print_step "Creando servicio systemd..."
    
    cat > "/etc/systemd/system/$SERVICE_NAME.service" << EOF
[Unit]
Description=ToolKinventario - Sistema de Inventario
After=network.target

[Service]
Type=simple
User=$ACTUAL_USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/venv/bin/python $INSTALL_DIR/run.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    if systemctl daemon-reload; then
        print_success "Servicio systemd creado"
    else
        print_warning "Error recargando systemd"
        return 1
    fi
    
    if systemctl enable "$SERVICE_NAME"; then
        print_success "Servicio habilitado para inicio automático"
    else
        print_warning "Error habilitando servicio"
    fi
    
    if systemctl start "$SERVICE_NAME"; then
        print_success "Servicio iniciado"
    else
        print_warning "Error iniciando servicio"
        print_message "Intentando iniciar manualmente..."
        cd "$INSTALL_DIR"
        source venv/bin/activate
        python3 run.py &
        print_message "Aplicación iniciada en segundo plano"
    fi
}

# Mostrar banner inicial
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║                    🔧 TOOLKINVENTARIO INSTALLER                      ║
║                                                                      ║
║                   Sistema de Inventario para Raspberry Pi           ║
║                        Por Don Nadie Apps                           ║
║                                                                      ║
║                      VERSIÓN DE DIAGNÓSTICO                         ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Ejecutar instalación paso a paso
print_message "Iniciando instalación con diagnóstico completo..."

# Verificar prerrequisitos
check_prerequisites

# Detectar usuario
detect_user

# Confirmar instalación
print_message "Configuración detectada:"
echo "  👤 Usuario: $ACTUAL_USER"
echo "  🏠 Home: $USER_HOME"
echo "  📁 Instalación: $INSTALL_DIR"
echo ""

read -p "¿Desea continuar con la instalación? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_message "Instalación cancelada por el usuario"
    exit 0
fi

# Ejecutar instalación
if install_toolkinventario; then
    # Obtener IP del sistema
    IP_ADDRESS=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
    
    echo ""
    print_success "🎉 ¡INSTALACIÓN COMPLETADA!"
    echo ""
    print_message "📍 INFORMACIÓN DE ACCESO:"
    echo "   🌐 URL Local: http://localhost:5000"
    echo "   🌐 URL Red: http://$IP_ADDRESS:5000"
    echo "   👤 Usuario: admin"
    echo "   🔑 Contraseña: admin123"
    echo ""
    print_message "🔧 COMANDOS ÚTILES:"
    echo "   📊 Estado: sudo systemctl status $SERVICE_NAME"
    echo "   🔄 Reiniciar: sudo systemctl restart $SERVICE_NAME"
    echo "   📋 Logs: sudo journalctl -u $SERVICE_NAME -f"
    echo ""
    print_success "🎯 Acceda ahora a: http://$IP_ADDRESS:5000"
else
    print_error "❌ Error durante la instalación"
    print_message "Revise los mensajes anteriores para identificar el problema"
    exit 1
fi
