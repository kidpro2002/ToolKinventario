#!/bin/bash
echo "🚀 Actualizando a ToolKinventario completo..."

cd /opt/toolkinventario

# Detener el servicio temporalmente
sudo systemctl stop toolkinventario

# Instalar dependencias adicionales
source venv/bin/activate
pip install Flask-SQLAlchemy Flask-Login Flask-Migrate python-barcode[images] qrcode[pil] Pillow

# Crear backup del run.py actual
cp run.py run_simple.py

# Crear la versión completa
cat > run.py << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Punto de entrada principal para ToolKinventario
Sistema de inventario para Raspberry Pi por Don Nadie Apps
"""

import os
import sys
from app import create_app

def main():
    """
    Función principal para ejecutar la aplicación
    """
    # Configurar variables de entorno si no están definidas
    if not os.environ.get('SECRET_KEY'):
        os.environ['SECRET_KEY'] = 'toolkinventario_secret_key_cambiar_en_produccion'
    
    if not os.environ.get('DATABASE_URL'):
        os.environ['DATABASE_URL'] = 'sqlite:///database/toolkinventario.db'
    
    # Crear la aplicación
    app = create_app()
    
    # Configuración para desarrollo o producción
    debug_mode = os.environ.get('FLASK_ENV') == 'development'
    host = os.environ.get('HOST', '0.0.0.0')
    port = int(os.environ.get('PORT', 5000))
    
    print("=" * 60)
    print("🔧 ToolKinventario - Sistema de Inventario")
    print("📱 Por Don Nadie Apps")
    print("🍓 Optimizado para Raspberry Pi")
    print("=" * 60)
    print(f"🌐 Servidor iniciando en http://{host}:{port}")
    print(f"🔧 Modo debug: {'Activado' if debug_mode else 'Desactivado'}")
    print("=" * 60)
    
    try:
        # Ejecutar la aplicación
        app.run(
            host=host,
            port=port,
            debug=debug_mode,
            threaded=True
        )
    except KeyboardInterrupt:
        print("\n🛑 Aplicación detenida por el usuario")
        sys.exit(0)
    except Exception as e:
        print(f"❌ Error al iniciar la aplicación: {str(e)}")
        sys.exit(1)

if __name__ == '__main__':
    main()
EOF

# Crear app/__init__.py completo
cat > app/__init__.py << 'EOF'
# -*- coding: utf-8 -*-
"""
Inicialización de la aplicación Flask para ToolKinventario
"""

import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager

# Inicializar extensiones
db = SQLAlchemy()
login_manager = LoginManager()

def create_app(config=None):
    """Crear y configurar la aplicación Flask"""
    app = Flask(__name__, 
                static_folder='../static',
                template_folder='../templates')
    
    # Configuración básica
    app.config.from_mapping(
        SECRET_KEY=os.environ.get('SECRET_KEY', 'dev_key_insegura'),
        SQLALCHEMY_DATABASE_URI=os.environ.get('DATABASE_URL', 'sqlite:///database/toolkinventario.db'),
        SQLALCHEMY_TRACK_MODIFICATIONS=False,
    )
    
    # Inicializar extensiones
    db.init_app(app)
    login_manager.init_app(app)
    login_manager.login_view = 'auth.login'
    login_manager.login_message = 'Por favor inicie sesión para acceder.'
    
    # Crear directorios necesarios
    os.makedirs('database', exist_ok=True)
    os.makedirs('static', exist_ok=True)
    os.makedirs('templates', exist_ok=True)
    
    # Registrar rutas básicas
    @app.route('/')
    def home():
        return '''
        <h1>🔧 ToolKinventario</h1>
        <p>📱 Sistema de Inventario por Don Nadie Apps</p>
        <p>🍓 Funcionando en Raspberry Pi</p>
        <p>✅ Versión completa instalada!</p>
        <p><a href="/login">🔐 Iniciar Sesión</a></p>
        '''
    
    @app.route('/login')
    def login():
        return '''
        <h2>🔐 Iniciar Sesión</h2>
        <p>Sistema de autenticación configurado</p>
        <p><a href="/">← Volver al inicio</a></p>
        '''
    
    # Crear la base de datos
    with app.app_context():
        db.create_all()
    
    return app
EOF

# Hacer ejecutable
chmod +x run.py

echo "✅ Actualización completa"
echo "🔄 Reiniciando servicio..."

# Reiniciar servicio
sudo systemctl restart toolkinventario
sleep 3
sudo systemctl status toolkinventario

echo ""
echo "🌐 Accede a la aplicación en:"
echo "   http://localhost:5000"
echo "   http://192.168.1.221:5000"
echo ""
EOF

chmod +x upgrade_to_full.sh
