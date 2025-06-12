# 🔄 Guía de Actualización - ToolKinventario

## Actualización Automática (Recomendado)

### Una sola línea de comando:
\`\`\`bash
curl -sSL https://raw.githubusercontent.com/donnadieapps/toolkinventario/main/install.sh | sudo bash
\`\`\`

## ✨ Características del Sistema de Actualización

### 🔒 Seguridad de Datos
- ✅ **Respaldo automático** antes de cada actualización
- ✅ **Preservación de base de datos** completa
- ✅ **Restauración automática** en caso de error
- ✅ **Configuraciones personalizadas** mantenidas

### 🚀 Proceso de Actualización
1. **Detección automática** de instalación existente
2. **Respaldo de seguridad** de todos los datos
3. **Actualización del código** sin interrupciones
4. **Migración de base de datos** si es necesaria
5. **Restauración de datos** preservados
6. **Reinicio automático** del servicio

### 📊 Qué se Preserva
- 🗄️ **Base de datos completa** (productos, movimientos, usuarios)
- 📋 **Respaldos existentes**
- 📄 **Logs del sistema**
- 📁 **Archivos subidos**
- ⚙️ **Configuraciones personalizadas**

### 🔄 Qué se Actualiza
- 💻 **Código de la aplicación**
- 🎨 **Interfaz de usuario**
- 🔧 **Funcionalidades nuevas**
- 🐛 **Corrección de errores**
-  **Dependencias de Python**

## 🛠️ Comandos Útiles Post-Actualización

### Verificar estado:
\`\`\`bash
sudo systemctl status toolkinventario
\`\`\`

### Ver logs en tiempo real:
\`\`\`bash
sudo journalctl -u toolkinventario -f
\`\`\`

### Reiniciar servicio manualmente:
\`\`\`bash
sudo systemctl restart toolkinventario
\`\`\`

## 🆘 Solución de Problemas

### Si la actualización falla:
1. El sistema **restaura automáticamente** desde el respaldo
2. Verifique los logs: \`sudo journalctl -u toolkinventario\`
3. Contacte soporte si persiste el problema

### Restaurar manualmente desde respaldo:
\`\`\`bash
# Los respaldos están en:
ls /opt/toolkinventario/backups/

# Para restaurar manualmente (si es necesario):
sudo systemctl stop toolkinventario
sudo cp /opt/toolkinventario/backups/[RESPALDO]/toolkinventario.db /opt/toolkinventario/database/
sudo systemctl start toolkinventario
\`\`\`

## 📈 Historial de Versiones

### v1.0.0 (Actual)
- ✅ Sistema de actualización inteligente
- ✅ Manual integrado en la aplicación
- ✅ Dashboard mejorado con estadísticas
- ✅ Respaldos automáticos
- ✅ Interfaz responsive optimizada

## 🔮 Próximas Actualizaciones

Las futuras versiones incluirán:
- 📱 **App móvil nativa**
- 🔍 **Búsqueda avanzada**
- 📊 **Reportes detallados**
- 🏷️ **Sistema de etiquetas**
- 📈 **Analytics de inventario**
- 🔔 **Notificaciones push**

## 💡 Consejos

1. **Actualice regularmente** para obtener las últimas mejoras
2. **Los respaldos se crean automáticamente** cada día a las 2:00 AM
3. **Mantenga al menos 7 días** de respaldos (configuración por defecto)
4. **La aplicación funciona sin interrupciones** durante las actualizaciones

---

**¿Necesita ayuda?** Consulte el manual integrado en: http://[IP-RASPBERRY]:5000/manual
