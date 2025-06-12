# Manual de Usuario - ToolKinventario

## Índice

1. [Introducción](#introducción)
2. [Acceso al Sistema](#acceso-al-sistema)
3. [Interfaz Principal](#interfaz-principal)
4. [Gestión de Productos](#gestión-de-productos)
5. [Movimientos de Inventario](#movimientos-de-inventario)
6. [Códigos de Barras](#códigos-de-barras)
7. [Reportes y Exportación](#reportes-y-exportación)
8. [Administración de Usuarios](#administración-de-usuarios)
9. [Respaldos](#respaldos)
10. [Preguntas Frecuentes](#preguntas-frecuentes)

## Introducción

ToolKinventario es un sistema completo de gestión de inventario diseñado específicamente para Raspberry Pi. Este manual le guiará a través de todas las funcionalidades del sistema para que pueda aprovechar al máximo sus capacidades.

### Características Principales

- Gestión completa de productos, categorías y proveedores
- Registro de movimientos de entrada, salida y ajustes
- Soporte para códigos de barras (USB y cámara)
- Reportes y exportación de datos
- Sistema de usuarios con diferentes niveles de acceso
- Respaldos automáticos

## Acceso al Sistema

### Iniciar Sesión

1. Abra su navegador web y acceda a la dirección del sistema (por defecto: `http://localhost:5000`)
2. Ingrese sus credenciales:
   - Usuario
   - Contraseña
3. Haga clic en "Iniciar Sesión"

### Roles de Usuario

El sistema cuenta con tres roles diferentes:

- **Administrador**: Acceso completo a todas las funcionalidades
- **Usuario**: Puede ver productos, registrar movimientos y generar reportes
- **Maestro de Carga**: Puede realizar cargas masivas pero no puede eliminar registros (anti-fraude)

## Interfaz Principal

### Dashboard

El dashboard muestra un resumen del estado actual del inventario:

- Total de productos
- Productos con stock bajo
- Últimos movimientos
- Productos más activos

### Menú Principal

- **Dashboard**: Página de inicio con resumen
- **Productos**: Gestión de productos, categorías y proveedores
- **Movimientos**: Registro y consulta de movimientos de inventario
- **Reportes**: Generación de reportes y exportación de datos
- **Administración**: Gestión de usuarios y configuración del sistema (solo administradores)

## Gestión de Productos

### Lista de Productos

Para ver todos los productos:

1. Haga clic en "Productos" en el menú principal
2. Utilice los filtros para buscar productos específicos:
   - Por texto (código, nombre o descripción)
   - Por categoría
   - Por estado de stock

### Agregar Nuevo Producto

1. Haga clic en "Productos" > "Nuevo Producto"
2. Complete el formulario con la información del producto:
   - Código (puede ser escaneado con un lector de códigos de barras)
   - Nombre
   - Descripción
   - Categoría
   - Cantidad inicial
   - Precio
   - Stock mínimo
   - Ubicación
   - Fecha de vencimiento (opcional)
   - Proveedor (opcional)
3. Haga clic en "Guardar Producto"

### Editar Producto

1. En la lista de productos, haga clic en el botón de editar (ícono de lápiz)
2. Modifique los campos necesarios
3. Haga clic en "Guardar Cambios"

### Eliminar Producto

**Nota**: Solo los administradores pueden eliminar productos.

1. En la lista de productos, haga clic en el botón de eliminar (ícono de papelera)
2. Confirme la eliminación en el cuadro de diálogo

### Gestión de Categorías

1. Haga clic en "Productos" > "Categorías"
2. Para agregar una nueva categoría, haga clic en "Nueva Categoría"
3. Para editar o eliminar, use los botones correspondientes en la lista

### Gestión de Proveedores

1. Haga clic en "Productos" > "Proveedores"
2. Para agregar un nuevo proveedor, haga clic en "Nuevo Proveedor"
3. Para editar o eliminar, use los botones correspondientes en la lista

## Movimientos de Inventario

### Tipos de Movimientos

- **Entrada**: Incrementa el stock (compras, devoluciones)
- **Salida**: Reduce el stock (ventas, consumo)
- **Ajuste**: Establece un valor específico de stock (inventario físico)

### Registrar Movimiento

1. Haga clic en "Movimientos" > "Nuevo Movimiento"
2. Seleccione el producto (puede escanear el código de barras)
3. Elija el tipo de movimiento
4. Ingrese la cantidad
5. Agregue referencia y comentarios si es necesario
6. Haga clic en "Registrar Movimiento"

### Consultar Historial de Movimientos

1. Haga clic en "Movimientos" > "Historial"
2. Utilice los filtros para buscar movimientos específicos:
   - Por tipo de movimiento
   - Por producto
   - Por rango de fechas

## Códigos de Barras

### Escanear con Lector USB

1. Conecte su lector de códigos de barras USB a la Raspberry Pi
2. El lector funcionará automáticamente como un teclado
3. Enfoque cualquier campo de código y escanee el código de barras

### Escanear con Cámara

1. Haga clic en "Movimientos" > "Escanear Código" o en el botón "Escanear" en cualquier formulario
2. Haga clic en "Iniciar Cámara"
3. Coloque el código de barras frente a la cámara
4. Haga clic en "Capturar" cuando el código esté visible
5. Haga clic en "Procesar Código"

## Reportes y Exportación

### Exportar Productos

1. Haga clic en "Reportes" > "Exportar Productos"
2. Seleccione el formato de exportación (CSV)
3. Haga clic en "Exportar"
4. Guarde el archivo generado

### Importar Productos

1. Haga clic en "Reportes" > "Importar Productos"
2. Prepare un archivo CSV con el formato correcto
3. Haga clic en "Seleccionar Archivo" y elija su archivo CSV
4. Haga clic en "Importar"

## Administración de Usuarios

**Nota**: Esta sección solo está disponible para administradores.

### Lista de Usuarios

1. Haga clic en "Administración" > "Usuarios"
2. Verá la lista de todos los usuarios del sistema

### Crear Nuevo Usuario

1. Haga clic en "Administración" > "Usuarios" > "Nuevo Usuario"
2. Complete el formulario:
   - Nombre de usuario
   - Nombre completo
   - Correo electrónico
   - Contraseña
   - Rol (Administrador, Usuario o Maestro de Carga)
3. Haga clic en "Guardar Usuario"

### Editar Usuario

1. En la lista de usuarios, haga clic en el botón de editar
2. Modifique los campos necesarios
3. Haga clic en "Guardar Cambios"

### Eliminar Usuario

1. En la lista de usuarios, haga clic en el botón de eliminar
2. Confirme la eliminación en el cuadro de diálogo

### Registro de Auditoría

1. Haga clic en "Administración" > "Auditoría"
2. Verá un registro de todas las acciones importantes realizadas en el sistema

## Respaldos

### Respaldos Automáticos

El sistema realiza respaldos automáticos diarios de la base de datos. Los respaldos se almacenan en la carpeta `backups/` y se mantienen los últimos 7 días.

### Respaldo Manual

1. Haga clic en "Administración" > "Respaldo"
2. Haga clic en "Generar Respaldo"
3. Guarde el archivo generado

## Preguntas Frecuentes

### ¿Cómo cambio mi contraseña?

1. Haga clic en su nombre de usuario en la esquina superior derecha
2. Seleccione "Mi Perfil"
3. Ingrese su nueva contraseña y confirme
4. Haga clic en "Actualizar Perfil"

### ¿Qué hago si olvido mi contraseña?

Contacte al administrador del sistema para que restablezca su contraseña.

### ¿Cómo configuro un lector de códigos de barras?

La mayoría de los lectores USB funcionan automáticamente como dispositivos HID (teclado). Simplemente conéctelo a un puerto USB de su Raspberry Pi y debería funcionar sin configuración adicional.

### ¿Puedo acceder al sistema desde otros dispositivos?

Sí, puede acceder al sistema desde cualquier dispositivo en la misma red. Use la dirección IP de su Raspberry Pi seguida del puerto (por defecto 5000).

Ejemplo: `http://192.168.1.100:5000`

### ¿Cómo soluciono problemas con la cámara?

Si la cámara no funciona:

1. Asegúrese de que la cámara esté habilitada en su Raspberry Pi:
   \`\`\`
   sudo raspi-config
   \`\`\`
   Vaya a "Interfacing Options" > "Camera" y habilítela.

2. Reinicie su Raspberry Pi:
   \`\`\`
   sudo reboot
   \`\`\`

3. Verifique que su navegador tenga permisos para acceder a la cámara.

### ¿Cómo puedo hacer una copia de seguridad manual?

Ejecute el script de respaldo:
\`\`\`
sudo /opt/toolkinventario/backup.sh
\`\`\`

---

Para más información o soporte técnico, contacte a soporte@donnadieapps.com
\`\`\`
