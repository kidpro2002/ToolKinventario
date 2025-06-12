#!/bin/bash

echo "🔧 ToolKinventario - Instalación Completa"
echo "📱 Por Don Nadie Apps"
echo "=" * 50

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script debe ejecutarse como root (sudo)"
    exit 1
fi

# Detener servicio si existe
systemctl stop toolkinventario 2>/dev/null || true

# Crear directorio principal
mkdir -p /opt/toolkinventario
cd /opt/toolkinventario

# Crear entorno virtual si no existe
if [ ! -d "venv" ]; then
    echo "🐍 Creando entorno virtual..."
    python3 -m venv venv
fi

# Activar entorno virtual
source venv/bin/activate

# Instalar dependencias básicas
echo "📦 Instalando dependencias..."
pip install --upgrade pip
pip install Flask

# Crear estructura de directorios
echo "📁 Creando estructura de directorios..."
mkdir -p app templates/auth static/css static/js database backups logs uploads

# Crear archivo principal
echo "📝 Creando archivo principal..."
cat > run.py << 'EOF'
#!/usr/bin/env python3
import os
from flask import Flask

app = Flask(__name__)
app.config['SECRET_KEY'] = 'toolkinventario_secret_key'

@app.route('/')
def home():
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>ToolKinventario</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
            .container { max-width: 600px; margin: 0 auto; }
            .success { color: #28a745; }
            .info { color: #17a2b8; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1 class="success">🔧 ToolKinventario</h1>
            <h2 class="info">📱 Sistema de Inventario</h2>
            <p>Por Don Nadie Apps</p>
            <p>🍓 Funcionando correctamente en Raspberry Pi</p>
            <p>✅ Instalación exitosa!</p>
            <hr>
            <p><strong>Próximos pasos:</strong></p>
            <ul style="text-align: left;">
                <li>Configurar base de datos</li>
                <li>Crear usuarios</li>
                <li>Configurar escáner de códigos</li>
            </ul>
        </div>
    </body>
    </html>
    '''

if __name__ == '__main__':
    print("🔧 ToolKinventario iniciando...")
    print("🌐 Accesible en: http://0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF

# Hacer ejecutable
chmod +x run.py

# Crear archivo de servicio
echo "⚙️ Configurando servicio systemd..."
cat > /etc/systemd/system/toolkinventario.service << EOF
[Unit]
Description=ToolKinventario - Sistema de Inventario
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/toolkinventario
Environment=PATH=/opt/toolkinventario/venv/bin
ExecStart=/opt/toolkinventario/venv/bin/python /opt/toolkinventario/run.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Configurar permisos
chown -R root:root /opt/toolkinventario
chmod -R 755 /opt/toolkinventario

# Recargar systemd y habilitar servicio
systemctl daemon-reload
systemctl enable toolkinventario
systemctl start toolkinventario

echo "✅ Instalación completada!"
echo "🔍 Verificando estado del servicio..."
sleep 3
systemctl status toolkinventario

echo ""
echo "🌐 Accede a la aplicación en:"
echo "   - Local: http://localhost:5000"
echo "   - Red: http://$(hostname -I | awk '{print $1}'):5000"
echo ""
echo "📋 Comandos útiles:"
echo "   - Ver estado: sudo systemctl status toolkinventario"
echo "   - Ver logs: sudo journalctl -u toolkinventario -f"
echo "   - Reiniciar: sudo systemctl restart toolkinventario"
