# 🍦 Heladería Barrilito - Punto de Venta (POS) Móvil

**Heladería Barrilito** es una aplicación móvil de Punto de Venta (POS) fuera de línea (Offline-First) desarrollada en **Flutter** con **Dart**. Está diseñada para gestionar las ventas diarias de helados, paletas y productos complementarios de forma rápida, intuitiva y 100% optimizada para dispositivos móviles (Android e iOS).

---

## 🚀 Características Principales

* **🛒 Catálogo & Punto de Venta Adaptativo:**
  * Cuadrícula fluida y responsiva de productos con tarjetas táctiles grandes.
  * Carrito de compras desplegable tipo panel inferior (*Bottom Sheet*) para optimizar el espacio en pantalla.
  * Registro rápido de cobro en efectivo en un solo toque.

* **🍨 Gestión Completa de Catálogo (CRUD):**
  * Creación, edición y eliminación de productos y tamaños predefinidos (*Chico, Mediano, Grande, 1/2 Litro, 1 Litro, etc.*).
  * Clasificación por categorías con colores e íconos dinámicos (*Helados, Paletas, Otros*).
  * Chips interactivos para asignación rápida de tamaños.

* **📊 Registro de Ventas & Corte de Caja Diario:**
  * Historial cronológico de tickets/ventas realizadas durante el día con hora y folio.
  * Opción para editar el monto total de una venta o eliminar registros por error de marcado.
  * Consolidación y cierre de caja (*Cerrar día y reiniciar ciclo*) con archivo permanente.

* **📜 Historial de Cortes de Caja:**
  * Módulo dedicado para consultar cortes anteriores almacenados localmente.

---

## 🛠️ Tecnologías y Arquitectura

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Gestión de Estado:** [Provider](https://pub.dev/packages/provider)
* **Base de Datos Local:** [SQLite](https://pub.dev/packages/sqflite) (`sqflite`) para funcionamiento offline ligero y rápido.
* **UI/UX:** Material Design 3 con paleta de colores corporativa *Azul Marino & Turquesa Fresco*.
* **Formato de Fechas y Moneda:** `intl` (Pesos Mexicanos MXN).

---

## 📂 Estructura del Proyecto

```text
lib/
├── data/
│   ├── database/    # Configuración de SQLite, tablas e inserciones iniciales (db_helper.dart)
│   └── models/      # Modelo de datos de Productos (product_model.dart)
├── providers/       # Gestión de estado global con Provider (pos_provider.dart)
└── ui/
    ├── screens/
    │   ├── pos_screen.dart        # Pantalla principal de ventas y catálogo
    │   ├── catalog_screen.dart    # Administración del catálogo (Agregar/Editar/Eliminar)