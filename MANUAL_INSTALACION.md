# 📖 Manual de Instalación - ToolKinventario

## 🚀 Instalación Automática (Recomendada)

### Instalación Nueva
\`\`\`bash
curl -sSL https://raw.githubusercontent.com/donnadieapps/toolkinventario/main/install.sh | sudo bash
\`\`\`

### Actualización de Versión Existente
\`\`\`bash
curl -sSL https://raw.githubusercontent.com/donnadieapps/toolkinventario/main/install.sh | sudo bash
\`\`\`
> ⚠️ **Nota**: El mismo comando funciona para instalación nueva y actualización. El sistema detecta automáticamente qué tipo de operación realizar.

### Actualización Rápida
\`\`\`bash
curl -sSL https://raw.githubusercontent.com/donnadieapps/toolkinventario/main/update.sh | sudo bash
\`\`\`

## 🔧 Instalación con Debug (Para Problemas)

Si tiene problemas con la instalación normal:

\`\`\`bash
curl -sSL https://raw.githubusercontent.com/donnadieapps/toolkinventario/main/debug_install.sh | bash
\`\`\`

Esto creará un archivo `debug_install.log` con información detallada.

## 📋 Requisitos del Sistema

- **Sistema Operativo**: Raspberry Pi OS (Debian/Ubuntu compatible)
- **RAM**: Mínimo 512MB (Recomendado 1GB+)
- **Almacenamiento**: Mínimo 2GB libres
- **Python**: 3.7 o superior (se instala automáticamente)
- **Conexión a Internet**: Requerida para instalación

## 🎯 Características de la Instalación

### ✅ Instalación Nueva
- ✅ Detección automática del usuario actual
- ✅ Instalación de todas las dependencias
- ✅ Creación de base de datos con datos iniciales
- ✅ Configuración de servicio systemd
- ✅ Configuración de respaldos automáticos
- ✅ Configuración básica de firewall
- ✅ Usuario administrador por defecto (admin/admin123)

### 🔄 Actualización Inteligente
- ✅ Preservación completa de datos existentes
- ✅ Respaldo automático antes de actualizar
- ✅ Actualización sin interrupción del servicio
- ✅ Rollback automático en caso de error
- ✅ Migración automática de base de datos
- ✅ Preservación de configuraciones personalizadas

## 📁 Estructura de Instalación

\`\`\`
/opt/toolkinventario/
├── app/                    # Código de la aplicación
├── database/              # Base de datos SQLite
├── backups/               # Respaldos automáticos
├── logs/                  # Archivos de log
├── uploads/               # Archivos subidos
├── static/                # Archivos estáticos (CSS, JS, imágenes)
├── templates/             # Plantillas HTML
├── venv/                  # Entorno virtual Python
├── run.py                 # Archivo principal
├── backup.sh              # Script de respaldo
└── version.txt            # Versión actual
\`\`\`

## 🔧 Gestión del Servicio

### Comandos Básicos
\`\`\`bash
# Iniciar servicio
sudo systemctl start toolkinventario

# Detener servicio
sudo systemctl stop toolkinventario

# Reiniciar servicio
sudo systemctl restart toolkinventario

# Ver estado
sudo systemctl status toolkinventario

# Ver logs en tiempo real
sudo journalctl -u toolkinventario -f

# Habilitar inicio automático
sudo systemctl enable toolkinventario

# Deshabilitar inicio automático
sudo systemctl disable toolkinventario
\`\`\`

### Verificar Funcionamiento
\`\`\`bash
# Verificar que el servicio esté activo
systemctl is-active toolkinventario

# Verificar que el puerto esté abierto
netstat -tlnp | grep :5000

# Probar conexión local
curl http://localhost:5000
\`\`\`

## 🌐 Acceso a la Aplicación

### URLs de Acceso
- **Local**: http://localhost:5000
- **Red local**: http://[IP_DE_SU_RASPBERRY]:5000

### Credenciales por Defecto
- **Usuario**: admin
- **Contraseña**: admin123

> ⚠️ **Importante**: Cambie la contraseña por defecto después del primer acceso.

## 🔄 Respaldos Automáticos

### Configuración Automática
- ✅ Respaldo diario a las 2:00 AM
- ✅ Mantiene los últimos 7 respaldos
- ✅ Compresión automática
- ✅ Ubicación: `/opt/toolkinventario/backups/`

### Respaldo Manual
\`\`\`bash
# Ejecutar respaldo manual
sudo /opt/toolkinventario/backup.sh

# Ver respaldos existentes
ls -la /opt/toolkinventario/backups/
\`\`\`

### Restaurar Respaldo
\`\`\`bash
# Detener servicio
sudo systemctl stop toolkinventario

# Restaurar base de datos desde respaldo
cd /opt/toolkinventario/backups/
tar -xzf toolkinventario_backup_YYYYMMDD_HHMMSS.tar.gz
cp toolkinventario_YYYYMMDD_HHMMSS.db ../database/toolkinventario.db

# Reiniciar servicio
sudo systemctl start toolkinventario
\`\`\`

## 🛠️ Solución de Problemas

### Problema: Servicio no inicia
\`\`\`bash
# Ver logs detallados
sudo journalctl -u toolkinventario -n 50

# Verificar permisos
sudo chown -R pi:pi /opt/toolkinventario
sudo chmod +x /opt/toolkinventario/run.py

# Reiniciar servicio
sudo systemctl restart toolkinventario
\`\`\`

### Problema: No se puede acceder desde la red
\`\`\`bash
# Verificar firewall
sudo ufw status

# Abrir puerto si es necesario
sudo ufw allow 5000/tcp

# Verificar que el servicio escuche en todas las interfaces
netstat -tlnp | grep :5000
\`\`\`

### Problema: Error de base de datos
\`\`\`bash
# Verificar permisos de base de datos
ls -la /opt/toolkinventario/database/

# Corregir permisos
sudo chmod 777 /opt/toolkinventario/database/
sudo chown pi:pi /opt/toolkinventario/database/toolkinventario.db
\`\`\`

### Problema: Dependencias faltantes
\`\`\`bash
# Reinstalar dependencias
cd /opt/toolkinventario
source venv/bin/activate
pip install --upgrade -r requirements.txt
\`\`\`

## 🔄 Proceso de Actualización Detallado

### Lo que hace la actualización:
1. **Detección**: Identifica si es instalación nueva o actualización
2. **Respaldo**: Crea respaldo completo de datos existentes
3. **Preservación**: Guarda base de datos, configuraciones y archivos
4. **Actualización**: Descarga e instala nueva versión
5. **Migración**: Ejecuta migraciones de base de datos si es necesario
6. **Restauración**: Restaura todos los datos preservados
7. **Verificación**: Verifica que todo funcione correctamente
8. **Rollback**: Si hay errores, restaura automáticamente desde respaldo

### Datos que se preservan:
- ✅ Base de datos completa (productos, movimientos, usuarios)
- ✅ Configuraciones personalizadas
- ✅ Archivos subidos
- ✅ Respaldos existentes
- ✅ Logs del sistema

## 📞 Soporte

### Información del Sistema
\`\`\`bash
# Ver versión instalada
cat /opt/toolkinventario/version.txt

# Ver información del sistema
uname -a
cat /etc/os-release

# Ver uso de recursos
htop
df -h
\`\`\`

### Logs Importantes
- **Aplicación**: `sudo journalctl -u toolkinventario`
- **Sistema**: `/var/log/syslog`
- **Instalación**: `debug_install.log` (si usó modo debug)

### Contacto
- **Desarrollador**: Don Nadie Apps
- **Proyecto**: ToolKinventario
- **Versión**: 1.0.0

---

## 🎉 ¡Listo para usar!

Después de la instalación exitosa, su sistema de inventario estará completamente funcional y listo para gestionar su inventario de manera profesional.

**¡Disfrute usando ToolKinventario!** 🚀
