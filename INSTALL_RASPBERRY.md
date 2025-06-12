# Guía de Instalación de ToolKinventario en Raspberry Pi

Esta guía detalla el proceso de instalación de ToolKinventario en una Raspberry Pi, desde la preparación del sistema hasta la configuración final.

## Índice

1. [Requisitos del Sistema](#requisitos-del-sistema)
2. [Preparación de la Raspberry Pi](#preparación-de-la-raspberry-pi)
3. [Instalación Automática](#instalación-automática)
4. [Instalación Manual](#instalación-manual)
5. [Configuración Post-Instalación](#configuración-post-instalación)
6. [Solución de Problemas](#solución-de-problemas)
7. [Actualización](#actualización)
8. [Desinstalación](#desinstalación)

## Requisitos del Sistema

### Hardware Recomendado

- Raspberry Pi 3 Model B+ o superior
- Memoria microSD de 16GB o más
- Fuente de alimentación de 5V/2.5A
- Pantalla (opcional, para modo kiosko)
- Lector de códigos de barras USB (opcional)
- Cámara Raspberry Pi (opcional, para escaneo de códigos)

### Software Requerido

- Raspberry Pi OS (anteriormente Raspbian) Bullseye o superior
- Python 3.7 o superior
- Navegador web (Chromium recomendado)

## Preparación de la Raspberry Pi

### 1. Instalar Raspberry Pi OS

Si aún no tiene Raspberry Pi OS instalado:

1. Descargue Raspberry Pi Imager desde [raspberrypi.org](https://www.raspberrypi.org/software/)
2. Ejecute Raspberry Pi Imager
3. Seleccione "Raspberry Pi OS (32-bit)"
4. Seleccione su tarjeta microSD
5. Haga clic en "WRITE" y espere a que termine el proceso

### 2. Configuración Inicial

1. Inserte la tarjeta microSD en su Raspberry Pi y enciéndala
2. Complete el asistente de configuración inicial
3. Actualice el sistema:
   \`\`\`bash
   sudo apt update
   sudo apt upgrade -y
   \`\`\`

### 3. Habilitar la Cámara (opcional)

Si planea usar la cámara para escanear códigos de barras:

1. Abra la configuración de Raspberry Pi:
   \`\`\`bash
   sudo raspi-config
   \`\`\`
2. Vaya a "Interfacing Options" > "Camera"
3. Seleccione "Yes" para habilitar la cámara
4. Reinicie la Raspberry Pi:
   \`\`\`bash
   sudo reboot
   \`\`\`

## Instalación Automática

La forma más sencilla de instalar ToolKinventario es usando nuestro script de instalación automática:

1. Descargue el script de instalación:
   \`\`\`bash
   wget https://raw.githubusercontent.com/donnadieapps/toolkinventario/main/install_raspberry.sh
   \`\`\`

2. Haga el script ejecutable:
   \`\`\`bash
   chmod +x install_raspberry.sh
   \`\`\`

3. Ejecute el script:
   \`\`\`bash
   sudo ./install_raspberry.sh
   \`\`\`

4. Siga las instrucciones en pantalla para completar la instalación

El script realizará automáticamente todas las tareas necesarias:
- Instalar dependencias del sistema
- Configurar el entorno Python
- Instalar ToolKinventario
- Configurar el servicio para inicio automático
- Configurar respaldos automáticos

## Instalación Manual

Si prefiere realizar una instalación manual o el script automático no funciona, siga estos pasos:

### 1. Instalar Dependencias

\`\`\`bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv libzbar0 libopencv-dev python3-opencv
\`\`\`

### 2. Crear Directorio de Instalación

\`\`\`bash
sudo mkdir -p /opt/toolkinventario
sudo chown pi:pi /opt/toolkinventario
\`\`\`

### 3. Clonar el Repositorio

\`\`\`bash
git clone https://github.com/donnadieapps/toolkinventario.git /opt/toolkinventario
cd /opt/toolkinventario
\`\`\`

### 4. Crear Entorno Virtual

\`\`\`bash
python3 -m venv venv
source venv/bin/activate
\`\`\`

### 5. Instalar Requisitos

\`\`\`bash
pip install --upgrade pip
pip install -r requirements.txt
\`\`\`

### 6. Crear Directorios Necesarios

\`\`\`bash
mkdir -p database backups logs uploads
\`\`\`

### 7. Configurar Servicio Systemd

Cree un archivo de servicio:

\`\`\`bash
sudo nano /etc/systemd/system/toolkinventario.service
\`\`\`

Con el siguiente contenido:

\`\`\`
[Unit]
Description=ToolKinventario - Sistema de Inventario
After=network.target

[Service]
User=pi
WorkingDirectory=/opt/toolkinventario
ExecStart=/opt/toolkinventario/venv/bin/python /opt/toolkinventario/run.py
Restart=always
RestartSec=5
Environment=FLASK_ENV=production
Environment=PORT=5000

[Install]
WantedBy=multi-user.target
\`\`\`

Habilite e inicie el servicio:

\`\`\`bash
sudo systemctl daemon-reload
sudo systemctl enable toolkinventario.service
sudo systemctl start toolkinventario.service
\`\`\`

### 8. Configurar Respaldos Automáticos

Cree un script de respaldo:

\`\`\`bash
nano /opt/toolkinventario/backup.sh
\`\`\`

Con el siguiente contenido:

\`\`\`bash
#!/bin/bash
DATE=$(date +%Y%m%d)
BACKUP_DIR="/opt/toolkinventario/backups"
DB_FILE="/opt/toolkinventario/database/toolkinventario.db"

# Crear respaldo de la base de datos
sqlite3 $DB_FILE ".backup '$BACKUP_DIR/toolkinventario_$DATE.db'"

# Comprimir respaldo
tar -czf "$BACKUP_DIR/toolkinventario_backup_$DATE.tar.gz" -C "$BACKUP_DIR" "toolkinventario_$DATE.db"

# Eliminar archivo temporal
rm "$BACKUP_DIR/toolkinventario_$DATE.db"

# Mantener solo los últimos 7 respaldos
find "$BACKUP_DIR" -name "toolkinventario_backup_*.tar.gz" -type f -mtime +7 -delete
\`\`\`

Haga el script ejecutable:

\`\`\`bash
chmod +x /opt/toolkinventario/backup.sh
\`\`\`

Configure cron para ejecutar respaldos diarios:

\`\`\`bash
(crontab -l 2>/dev/null; echo "0 1 * * * /opt/toolkinventario/backup.sh") | crontab -
\`\`\`

## Configuración Post-Instalación

### 1. Acceder al Sistema

Abra un navegador en su Raspberry Pi y vaya a:

\`\`\`
http://localhost:5000
\`\`\`

### 2. Iniciar Sesión

Use las credenciales por defecto:
- Usuario: `admin`
- Contraseña: `admin123`

### 3. Cambiar Contraseña

Por seguridad, cambie inmediatamente la contraseña por defecto:
1. Haga clic en su nombre de usuario en la esquina superior derecha
2. Seleccione "Mi Perfil"
3. Ingrese una nueva contraseña segura
4. Haga clic en "Actualizar Perfil"

### 4. Configuración para Modo Kiosko (opcional)

Si desea que ToolKinventario se inicie automáticamente en modo kiosko al encender la Raspberry Pi:

1. Cree un archivo de inicio automático:
   \`\`\`bash
   sudo nano /etc/xdg/autostart/toolkinventario.desktop
   \`\`\`

2. Agregue el siguiente contenido:
   \`\`\`
   [Desktop Entry]
   Type=Application
   Name=ToolKinventario
   Comment=Sistema de Inventario
   Exec=chromium-browser --kiosk --app=http://localhost:5000
   Terminal=false
   X-GNOME-Autostart-enabled=true
   \`\`\`

3. Guarde el archivo y reinicie la Raspberry Pi:
   \`\`\`bash
   sudo reboot
   \`\`\`

## Solución de Problemas

### El Servicio No Inicia

Verifique el estado del servicio:

\`\`\`bash
sudo systemctl status toolkinventario
\`\`\`

Revise los logs para más detalles:

\`\`\`bash
tail -n 100 /opt/toolkinventario/logs/toolkinventario.log
\`\`\`

### Problemas de Permisos

Si hay problemas de permisos:

\`\`\`bash
sudo chown -R pi:pi /opt/toolkinventario
chmod -R 755 /opt/toolkinventario
\`\`\`

### La Cámara No Funciona

1. Verifique que la cámara esté habilitada:
   \`\`\`bash
   vcgencmd get_camera
   \`\`\`
   Debería mostrar `supported=1 detected=1`

2. Asegúrese de que el módulo de la cámara esté correctamente conectado

3. Reinicie el servicio:
   \`\`\`bash
   sudo systemctl restart toolkinventario
   \`\`\`

### Problemas con el Lector de Códigos de Barras

1. Verifique que el lector esté conectado:
   \`\`\`bash
   lsusb
   \`\`\`

2. Pruebe el lector en un editor de texto para confirmar que funciona como dispositivo HID

### Errores de Base de Datos

Si hay errores relacionados con la base de datos:

1. Haga un respaldo de la base de datos actual:
   \`\`\`bash
   cp /opt/toolkinventario/database/toolkinventario.db /opt/toolkinventario/database/toolkinventario.db.bak
   \`\`\`

2. Reinicie el servicio:
   \`\`\`bash
   sudo systemctl restart toolkinventario
   \`\`\`

## Actualización

Para actualizar ToolKinventario a la última versión:

1. Detenga el servicio:
   \`\`\`bash
   sudo systemctl stop toolkinventario
   \`\`\`

2. Haga un respaldo de la base de datos:
   \`\`\`bash
   /opt/toolkinventario/backup.sh
   \`\`\`

3. Actualice el código:
   \`\`\`bash
   cd /opt/toolkinventario
   git pull
   \`\`\`

4. Actualice las dependencias:
   \`\`\`bash
   source venv/bin/activate
   pip install -r requirements.txt
   \`\`\`

5. Reinicie el servicio:
   \`\`\`bash
   sudo systemctl start toolkinventario
   \`\`\`

## Desinstalación

Si necesita desinstalar ToolKinventario:

1. Detenga y deshabilite el servicio:
   \`\`\`bash
   sudo systemctl stop toolkinventario
   sudo systemctl disable toolkinventario
   \`\`\`

2. Elimine el archivo de servicio:
   \`\`\`bash
   sudo rm /etc/systemd/system/toolkinventario.service
   \`\`\`

3. Elimine el directorio de instalación:
   \`\`\`bash
   sudo rm -rf /opt/toolkinventario
   \`\`\`

4. Elimine la tarea cron:
   \`\`\`bash
   crontab -l | grep -v "toolkinventario/backup.sh" | crontab -
   \`\`\`

5. Elimine el archivo de inicio automático (si lo configuró):
   \`\`\`bash
   sudo rm /etc/xdg/autostart/toolkinventario.desktop
   \`\`\`

---

Para más información o soporte técnico, contacte a soporte@donnadieapps.com
\`\`\`
