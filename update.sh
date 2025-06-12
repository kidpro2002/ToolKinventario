#!/bin/bash
# Script de actualización rápida para ToolKinventario
# Ejecuta solo la actualización sin verificaciones completas

echo "🔄 Actualizando ToolKinventario..."
curl -sSL https://raw.githubusercontent.com/donnadieapps/toolkinventario/main/install.sh | sudo bash
echo "✅ Actualización completada"
