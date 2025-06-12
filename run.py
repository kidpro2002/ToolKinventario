#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Punto de entrada principal para ToolKinventario
Sistema de inventario para Raspberry Pi por Don Nadie Apps
"""

import os
import sys
from flask import Flask, render_template, redirect, url_for, flash, request
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

# Configuración de la aplicación
app = Flask(__name__)
app.config['SECRET_KEY'] = 'toolkinventario_secret_key_cambiar_en_produccion'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database/toolkinventario.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Inicializar extensiones
db = SQLAlchemy(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'
login_manager.login_message = 'Por favor inicie sesión para acceder a esta página.'

# Modelos de base de datos
class Usuario(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(120), nullable=False)
    es_admin = db.Column(db.Boolean, default=False)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class Producto(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    descripcion = db.Column(db.Text)
    codigo_barras = db.Column(db.String(50), unique=True)
    precio = db.Column(db.Float, default=0.0)
    stock_actual = db.Column(db.Integer, default=0)
    stock_minimo = db.Column(db.Integer, default=0)
    categoria = db.Column(db.String(50))
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)

class Movimiento(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    producto_id = db.Column(db.Integer, db.ForeignKey('producto.id'), nullable=False)
    tipo = db.Column(db.String(20), nullable=False)  # 'entrada' o 'salida'
    cantidad = db.Column(db.Integer, nullable=False)
    motivo = db.Column(db.String(100))
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuario.id'), nullable=False)
    fecha = db.Column(db.DateTime, default=datetime.utcnow)
    
    producto = db.relationship('Producto', backref='movimientos')
    usuario = db.relationship('Usuario', backref='movimientos')

@login_manager.user_loader
def load_user(user_id):
    return Usuario.query.get(int(user_id))

# Rutas de la aplicación
@app.route('/')
def index():
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = Usuario.query.filter_by(username=username).first()
        
        if user and user.check_password(password):
            login_user(user)
            return redirect(url_for('dashboard'))
        else:
            flash('Usuario o contraseña incorrectos', 'error')
    
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard():
    total_productos = Producto.query.count()
    productos_bajo_stock = Producto.query.filter(Producto.stock_actual <= Producto.stock_minimo).count()
    movimientos_recientes = Movimiento.query.order_by(Movimiento.fecha.desc()).limit(5).all()
    
    return render_template('dashboard.html', 
                         total_productos=total_productos,
                         productos_bajo_stock=productos_bajo_stock,
                         movimientos_recientes=movimientos_recientes)

@app.route('/productos')
@login_required
def productos():
    productos = Producto.query.all()
    return render_template('productos.html', productos=productos)

@app.route('/productos/nuevo', methods=['GET', 'POST'])
@login_required
def nuevo_producto():
    if request.method == 'POST':
        producto = Producto(
            nombre=request.form['nombre'],
            descripcion=request.form['descripcion'],
            codigo_barras=request.form['codigo_barras'],
            precio=float(request.form['precio']) if request.form['precio'] else 0.0,
            stock_actual=int(request.form['stock_actual']) if request.form['stock_actual'] else 0,
            stock_minimo=int(request.form['stock_minimo']) if request.form['stock_minimo'] else 0,
            categoria=request.form['categoria']
        )
        db.session.add(producto)
        db.session.commit()
        flash('Producto creado exitosamente', 'success')
        return redirect(url_for('productos'))
    
    return render_template('nuevo_producto.html')

@app.route('/movimientos')
@login_required
def movimientos():
    movimientos = Movimiento.query.order_by(Movimiento.fecha.desc()).all()
    return render_template('movimientos.html', movimientos=movimientos)

def crear_usuario_admin():
    """Crear usuario administrador por defecto"""
    admin = Usuario.query.filter_by(username='admin').first()
    if not admin:
        admin = Usuario(
            username='admin',
            email='admin@toolkinventario.com',
            es_admin=True
        )
        admin.set_password('admin123')
        db.session.add(admin)
        db.session.commit()
        print("✅ Usuario administrador creado: admin / admin123")

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
    app = Flask(__name__)
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    # Inicializar extensiones
    db = SQLAlchemy(app)
    login_manager = LoginManager()
    login_manager.init_app(app)
    login_manager.login_view = 'login'
    login_manager.login_message = 'Por favor inicie sesión para acceder a esta página.'
    
    # Crear directorios necesarios
    os.makedirs('database', exist_ok=True)
    os.makedirs('templates', exist_ok=True)
    os.makedirs('static', exist_ok=True)
    
    # Crear base de datos y tablas
    with app.app_context():
        db.create_all()
        crear_usuario_admin()
    
    print("=" * 60)
    print("🔧 ToolKinventario - Sistema de Inventario")
    print("📱 Por Don Nadie Apps")
    print("🍓 Optimizado para Raspberry Pi")
    print("=" * 60)
    print("🌐 Servidor iniciando en http://0.0.0.0:5000")
    print("👤 Usuario: admin | Contraseña: admin123")
    print("=" * 60)
    
    try:
        app.run(host='0.0.0.0', port=5000, debug=False)
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        sys.exit(1)

if __name__ == '__main__':
    main()
