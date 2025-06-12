#!/bin/bash
# ToolKinventario - Instalador con Modo Debug
# Muestra todos los comandos y errores para diagnóstico
# Por Don Nadie Apps

# Activar modo debug para ver todos los comandos ejecutados
set -x

# Guardar todos los mensajes en un archivo de log
exec > >(tee -a debug_install.log) 2>&1

echo "🔍 Iniciando instalación en modo debug..."
echo "📝 Todos los comandos y errores se guardarán en debug_install.log"

# Descargar y ejecutar el instalador principal
curl -sSL https://raw.githubusercontent.com/donnadieapps/toolkinventario/main/install.sh > install_temp.sh
chmod +x install_temp.sh
sudo bash install_temp.sh

echo "✅ Instalación completada en modo debug"
echo "📋 Revise debug_install.log para ver detalles completos"
