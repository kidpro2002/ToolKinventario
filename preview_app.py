#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Vista previa simplificada de ToolKinventario
Solo para demostración de la interfaz
"""

from flask import Flask, render_template, jsonify
from datetime import datetime
import os

app = Flask(__name__)
app.secret_key = 'preview_key'

# Datos de ejemplo para la vista previa
PRODUCTOS_EJEMPLO = [
    {
        'id': 1,
        'codigo': 'P001',
        'nombre': 'Tornillos Phillips 3/4"',
        'categoria': 'Ferretería',
        'cantidad': 150,
        'precio': 0.25,
        'stock_minimo': 50,
        'ubicacion': 'Estante A-1'
    },
    {
        'id': 2,
        'codigo': 'P002',
        'nombre': 'Destornillador Plano',
        'categoria': 'Herramientas',
        'cantidad': 8,
        'precio': 12.50,
        'stock_minimo': 10,
        'ubicacion': 'Estante B-2'
    },
    {
        'id': 3,
        'codigo': 'P003',
        'nombre': 'Cable Eléctrico 2.5mm',
        'categoria': 'Electricidad',
        'cantidad': 3,
        'precio': 45.00,
        'stock_minimo': 5,
        'ubicacion': 'Estante C-1'
    }
]

MOVIMIENTOS_EJEMPLO = [
    {
        'id': 1,
        'producto': 'Tornillos Phillips 3/4"',
        'tipo': 'entrada',
        'cantidad': 100,
        'fecha': datetime.now(),
        'usuario': 'admin'
    },
    {
        'id': 2,
        'producto': 'Destornillador Plano',
        'tipo': 'salida',
        'cantidad': 2,
        'fecha': datetime.now(),
        'usuario': 'operador'
    }
]

@app.route('/')
def index():
    return render_template('preview_dashboard.html',
                          total_productos=len(PRODUCTOS_EJEMPLO),
                          total_categorias=3,
                          total_movimientos=len(MOVIMIENTOS_EJEMPLO),
                          productos_stock_bajo=[p for p in PRODUCTOS_EJEMPLO if p['cantidad'] <= p['stock_minimo']],
                          ultimos_movimientos=MOVIMIENTOS_EJEMPLO,
                          productos_mas_movidos=PRODUCTOS_EJEMPLO[:3])

@app.route('/productos')
def productos():
    return render_template('preview_productos.html', productos=PRODUCTOS_EJEMPLO)

@app.route('/movimientos')
def movimientos():
    return render_template('preview_movimientos.html', movimientos=MOVIMIENTOS_EJEMPLO)

@app.route('/login')
def login():
    return render_template('preview_login.html')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
