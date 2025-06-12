# API Reference - ToolKinventario

## Introducción

ToolKinventario proporciona una API interna para interactuar con el sistema programáticamente. Esta documentación detalla los endpoints disponibles, los parámetros requeridos y las respuestas esperadas.

**Nota**: Esta API está diseñada principalmente para uso interno y extensiones del sistema. No está destinada a ser expuesta públicamente sin medidas de seguridad adicionales.

## Autenticación

Todas las solicitudes a la API requieren autenticación. La autenticación se realiza mediante un token JWT que debe incluirse en el encabezado `Authorization` de cada solicitud.

### Obtener Token

\`\`\`
POST /api/auth/token
\`\`\`

**Parámetros de solicitud:**

\`\`\`json
{
  "username": "usuario",
  "password": "contraseña"
}
\`\`\`

**Respuesta:**

\`\`\`json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2023-12-31T23:59:59Z"
}
\`\`\`

### Usar Token

Incluya el token en el encabezado de sus solicitudes:

\`\`\`
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
\`\`\`

## Endpoints

### Productos

#### Listar Productos

\`\`\`
GET /api/productos
\`\`\`

**Parámetros de consulta:**

- `page`: Número de página (por defecto: 1)
- `per_page`: Elementos por página (por defecto: 20)
- `busqueda`: Texto para buscar en código, nombre o descripción
- `categoria_id`: Filtrar por categoría
- `stock_bajo`: Si es 1, muestra solo productos con stock bajo

**Respuesta:**

\`\`\`json
{
  "productos": [
    {
      "id": 1,
      "codigo": "P001",
      "nombre": "Producto de ejemplo",
      "descripcion": "Descripción del producto",
      "categoria_id": 1,
      "categoria_nombre": "Categoría de ejemplo",
      "ubicacion": "Estante A",
      "cantidad": 10,
      "precio": 15.99,
      "proveedor_id": 1,
      "proveedor_nombre": "Proveedor de ejemplo",
      "fecha_vencimiento": "2023-12-31",
      "stock_minimo": 5,
      "fecha_creacion": "2023-01-01T12:00:00Z",
      "fecha_actualizacion": "2023-01-01T12:00:00Z"
    }
  ],
  "total": 100,
  "paginas": 5,
  "pagina_actual": 1
}
\`\`\`

#### Obtener Producto

\`\`\`
GET /api/productos/{id}
\`\`\`

**Respuesta:**

\`\`\`json
{
  "id": 1,
  "codigo": "P001",
  "nombre": "Producto de ejemplo",
  "descripcion": "Descripción del producto",
  "categoria_id": 1,
  "categoria_nombre": "Categoría de ejemplo",
  "ubicacion": "Estante A",
  "cantidad": 10,
  "precio": 15.99,
  "proveedor_id": 1,
  "proveedor_nombre": "Proveedor de ejemplo",
  "fecha_vencimiento": "2023-12-31",
  "stock_minimo": 5,
  "fecha_creacion": "2023-01-01T12:00:00Z",
  "fecha_actualizacion": "2023-01-01T12:00:00Z",
  "movimientos_recientes": [
    {
      "id": 1,
      "tipo": "entrada",
      "cantidad": 5,
      "fecha": "2023-01-01T12:00:00Z",
      "usuario": "admin"
    }
  ]
}
\`\`\`

#### Crear Producto

\`\`\`
POST /api/productos
\`\`\`

**Parámetros de solicitud:**

\`\`\`json
{
  "codigo": "P002",
  "nombre": "Nuevo producto",
  "descripcion": "Descripción del nuevo producto",
  "categoria_id": 1,
  "ubicacion": "Estante B",
  "cantidad": 20,
  "precio": 25.99,
  "proveedor_id": 1,
  "fecha_vencimiento": "2023-12-31",
  "stock_minimo": 5
}
\`\`\`

**Respuesta:**

\`\`\`json
{
  "id": 2,
  "codigo": "P002",
  "nombre": "Nuevo producto",
  "mensaje": "Producto creado correctamente"
}
\`\`\`

#### Actualizar Producto

\`\`\`
PUT /api/productos/{id}
\`\`\`

**Parámetros de solicitud:**

\`\`\`json
{
  "nombre": "Producto actualizado",
  "descripcion": "Descripción actualizada",
  "categoria_id": 2,
  "ubicacion": "Estante C",
  "precio": 29.99,
  "proveedor_id": 2,
  "fecha_vencimiento": "2024-06-30",
  "stock_minimo": 10
}
\`\`\`

**Respuesta:**

\`\`\`json
{
  "id": 2,
  "nombre": "Producto actualizado",
  "mensaje": "Producto actualizado correctamente"
}
\`\`\`

#### Eliminar Producto

\`\`\`
DELETE /api/productos/{id}
\`\`\`

**Respuesta:**

\`\`\`json
{
  "mensaje": "Producto eliminado correctamente"
}
\`\`\`

### Movimientos

#### Listar Movimientos

\`\`\`
GET /api/movimientos
\`\`\`

**Parámetros de consulta:**

- `page`: Número de página (por defecto: 1)
- `per_page`: Elementos por página (por defecto: 50)
- `tipo`: Filtrar por tipo (entrada, salida, ajuste)
- `producto_id`: Filtrar por producto
- `fecha_desde`: Filtrar desde fecha (formato: YYYY-MM-DD)
- `fecha_hasta`: Filtrar hasta fecha (formato: YYYY-MM-DD)

**Respuesta:**

\`\`\`json
{
  "movimientos": [
    {
      "id": 1,
      "producto_id": 1,
      "producto_codigo": "P001",
      "producto_nombre": "Producto de ejemplo",
      "usuario_id": 1,
      "usuario_nombre": "admin",
      "tipo": "entrada",
      "cantidad": 5,
      "cantidad_anterior": 5,
      "cantidad_nueva": 10,
      "fecha": "2023-01-01T12:00:00Z",
      "comentario": "Entrada inicial",
      "referencia": "FAC-001"
    }
  ],
  "total": 100,
  "paginas": 2,
  "pagina_actual": 1
}
\`\`\`

#### Registrar Movimiento

\`\`\`
POST /api/movimientos
\`\`\`

**Parámetros de solicitud:**

\`\`\`json
{
  "producto_id": 1,
  "tipo": "entrada",
  "cantidad": 5,
  "comentario": "Reposición de stock",
  "referencia": "FAC-002"
}
\`\`\`

**Respuesta:**

\`\`\`json
{
  "id": 2,
  "producto_id": 1,
  "producto_nombre": "Producto de ejemplo",
  "tipo": "entrada",
  "cantidad": 5,
  "cantidad_anterior": 10,
  "cantidad_nueva": 15,
  "mensaje": "Movimiento registrado correctamente"
}
\`\`\`

### Categorías

#### Listar Categorías

\`\`\`
GET /api/categorias
\`\`\`

**Respuesta:**

\`\`\`json
{
  "categorias": [
    {
      "id": 1,
      "nombre": "Categoría de ejemplo",
      "descripcion": "Descripción de la categoría",
      "productos_count": 5
    }
  ]
}
\`\`\`

#### Crear Categoría

\`\`\`
POST /api/categorias
\`\`\`

**Parámetros de solicitud:**

\`\`\`json
{
  "nombre": "Nueva categoría",
  "descripcion": "Descripción de la nueva categoría"
}
\`\`\`

**Respuesta:**

\`\`\`json
{
  "id": 2,
  "nombre": "Nueva categoría",
  "mensaje": "Categoría creada correctamente"
}
\`\`\`

### Proveedores

#### Listar Proveedores

\`\`\`
GET /api/proveedores
\`\`\`

**Respuesta:**

\`\`\`json
{
  "proveedores": [
    {
      "id": 1,
      "nombre": "Proveedor de ejemplo",
      "contacto": "Juan Pérez",
      "telefono": "123456789",
      "email": "juan@ejemplo.com",
      "direccion": "Calle Ejemplo 123",
      "productos_count": 3
    }
  ]
}
\`\`\`

#### Crear Proveedor

\`\`\`
POST /api/proveedores
\`\`\`

**Parámetros de solicitud:**

\`\`\`json
{
  "nombre": "Nuevo proveedor",
  "contacto": "María López",
  "telefono": "987654321",
  "email": "maria@ejemplo.com",
  "direccion": "Avenida Ejemplo 456"
}
\`\`\`

**Respuesta:**

\`\`\`json
{
  "id": 2,
  "nombre": "Nuevo proveedor",
  "mensaje": "Proveedor creado correctamente"
}
\`\`\`

### Usuarios

**Nota**: Estos endpoints solo están disponibles para administradores.

#### Listar Usuarios

\`\`\`
GET /api/usuarios
\`\`\`

**Respuesta:**

\`\`\`json
{
  "usuarios": [
    {
      "id": 1,
      "username": "admin",
      "nombre": "Administrador",
      "email": "admin@ejemplo.com",
      "rol": "admin",
      "activo": true,
      "ultimo_acceso": "2023-01-01T12:00:00Z"
    }
  ]
}
\`\`\`

#### Crear Usuario

\`\`\`
POST /api/usuarios
\`\`\`

**Parámetros de solicitud:**

\`\`\`json
{
  "username": "nuevo_usuario",
  "nombre": "Nuevo Usuario",
  "email": "nuevo@ejemplo.com",
  "password": "contraseña",
  "rol": "usuario"
}
\`\`\`

**Respuesta:**

\`\`\`json
{
  "id": 2,
  "username": "nuevo_usuario",
  "mensaje": "Usuario creado correctamente"
}
\`\`\`

### Reportes

#### Reporte de Stock

\`\`\`
GET /api/reportes/stock
\`\`\`

**Parámetros de consulta:**

- `formato`: Formato de salida (json, csv)

**Respuesta (JSON):**

\`\`\`json
{
  "fecha_reporte": "2023-01-01T12:00:00Z",
  "total_productos": 100,
  "valor_total": 5000.00,
  "productos_stock_bajo": 10,
  "productos": [
    {
      "id": 1,
      "codigo": "P001",
      "nombre": "Producto de ejemplo",
      "categoria": "Categoría de ejemplo",
      "cantidad": 10,
      "precio": 15.99,
      "valor_total": 159.90,
      "stock_minimo": 5,
      "estado": "normal"
    }
  ]
}
\`\`\`

#### Reporte de Movimientos

\`\`\`
GET /api/reportes/movimientos
\`\`\`

**Parámetros de consulta:**

- `fecha_desde`: Fecha inicial (formato: YYYY-MM-DD)
- `fecha_hasta`: Fecha final (formato: YYYY-MM-DD)
- `tipo`: Tipo de movimiento (opcional)
- `formato`: Formato de salida (json, csv)

**Respuesta (JSON):**

\`\`\`json
{
  "fecha_reporte": "2023-01-01T12:00:00Z",
  "fecha_desde": "2023-01-01",
  "fecha_hasta": "2023-01-31",
  "total_movimientos": 50,
  "entradas": 30,
  "salidas": 15,
  "ajustes": 5,
  "movimientos": [
    {
      "id": 1,
      "fecha": "2023-01-01T12:00:00Z",
      "producto": "Producto de ejemplo",
      "tipo": "entrada",
      "cantidad": 5,
      "usuario": "admin",
      "referencia": "FAC-001"
    }
  ]
}
\`\`\`

### Códigos de Barras

#### Buscar por Código de Barras

\`\`\`
GET /api/barcode/{codigo}
\`\`\`

**Respuesta:**

\`\`\`json
{
  "encontrado": true,
  "producto": {
    "id": 1,
    "codigo": "P001",
    "nombre": "Producto de ejemplo",
    "cantidad": 10,
    "precio": 15.99
  }
}
\`\`\`

#### Procesar Imagen de Código de Barras

\`\`\`
POST /api/barcode/scan
\`\`\`

**Parámetros de solicitud:**
- Archivo de imagen (multipart/form-data)

**Respuesta:**

\`\`\`json
{
  "codigo_detectado": "P001",
  "encontrado": true,
  "producto": {
    "id": 1,
    "codigo": "P001",
    "nombre": "Producto de ejemplo",
    "cantidad": 10,
    "precio": 15.99
  }
}
\`\`\`

## Códigos de Estado

- `200 OK`: La solicitud se completó correctamente
- `201 Created`: El recurso se creó correctamente
- `400 Bad Request`: La solicitud contiene parámetros inválidos
- `401 Unauthorized`: Falta autenticación o credenciales inválidas
- `403 Forbidden`: No tiene permisos para acceder al recurso
- `404 Not Found`: El recurso solicitado no existe
- `500 Internal Server Error`: Error interno del servidor

## Límites de Tasa

Para proteger el sistema, se aplican los siguientes límites de tasa:

- Máximo 100 solicitudes por minuto por IP
- Máximo 1000 solicitudes por hora por usuario autenticado

## Ejemplos de Uso

### Ejemplo 1: Obtener lista de productos con stock bajo

\`\`\`bash
curl -X GET "http://localhost:5000/api/productos?stock_bajo=1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
\`\`\`

### Ejemplo 2: Registrar una entrada de inventario

\`\`\`bash
curl -X POST "http://localhost:5000/api/movimientos" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "producto_id": 1,
    "tipo": "entrada",
    "cantidad": 5,
    "comentario": "Reposición de stock",
    "referencia": "FAC-002"
  }'
\`\`\`

### Ejemplo 3: Exportar reporte de stock en CSV

\`\`\`bash
curl -X GET "http://localhost:5000/api/reportes/stock?formato=csv" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -o "reporte_stock.csv"
\`\`\`

## Notas Adicionales

- Todos los timestamps están en formato ISO 8601 (UTC)
- Los valores monetarios se expresan en la moneda configurada en el sistema
- Para operaciones masivas, considere utilizar la importación/exportación de CSV en lugar de múltiples llamadas a la API

---

Para más información o soporte técnico, contacte a soporte@donnadieapps.com
\`\`\`
