# 🚴 Bikershop – UrbanBikeShop

Aplicación móvil de comercio electrónico para una tienda de bicicletas, desarrollada con **Flutter** y conectada a una **API REST** en Node.js. Permite a los clientes explorar productos, gestionar un carrito de compras y realizar reservas, mientras que los administradores cuentan con herramientas para gestionar productos, usuarios, proveedores y reservaciones.

El proyecto sigue una arquitectura por capas (pantallas – servicios – widgets) y utiliza `shared_preferences` para persistir la sesión y el carrito localmente.

---

## 📋 Características principales

### Para clientes
- 🛍️ **Catálogo de productos** con imágenes, precios y categorías.
- 🔍 **Búsqueda** de productos por nombre.
- 📂 **Navegación por categorías**.
- 🛒 **Carrito de compras** persistente (se guarda localmente).
  - Agregar, eliminar y actualizar cantidades.
  - Cálculo automático de totales.
- 📅 **Reservas** de productos (creación de reservaciones).
- 👤 **Perfil de usuario** y cierre de sesión.

### Para administradores
- 📊 **Panel de administración** (home).
- 📦 **Gestión de productos** (crear, editar, eliminar).
- 👥 **Gestión de usuarios**.
- 🚚 **Gestión de proveedores**.
- 📋 **Gestión de reservaciones**.

### Generales
- 🔐 **Autenticación** con inicio de sesión y registro.
- 🔄 **Persistencia de sesión** mediante token JWT.
- 🎨 Interfaz moderna y limpia con Material Design.

---

## 🧰 Tecnologías utilizadas

| Tecnología / Paquete | Versión | Uso |
|-----------------------|---------|-----|
| **Flutter**           | SDK ^3.9.0 | Framework principal |
| **Dart**              | —       | Lenguaje |
| **http**              | ^0.13.6 | Peticiones a la API REST |
| **shared_preferences**| ^2.2.2  | Almacenamiento local (token, usuario, carrito) |
| **flutter_lints**     | ^5.0.0  | Reglas de linting |
| **Material Design**   | —       | Diseño de la interfaz |

> ⚠️ La aplicación **requiere una API REST** en funcionamiento (por defecto en `http://localhost:3000/api`). El código de la API no está incluido en este repositorio.

---

## 📂 Estructura del proyecto

```
bikershop/
├── android/                  # Configuración Android
├── ios/                      # Configuración iOS
├── linux/                    # Configuración Linux
├── macos/                    # Configuración macOS
├── web/                      # Configuración Web
├── windows/                  # Configuración Windows
├── assets/
│   └── images/               # Imágenes estáticas
├── lib/
│   ├── main.dart             # Punto de entrada y rutas
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── registro_screen.dart
│   │   ├── admin/            # Pantallas de administración
│   │   │   ├── admin_home_screen.dart
│   │   │   ├── admin_products_screen.dart
│   │   │   ├── admin_reservations_screen.dart
│   │   │   ├── admin_suppliers_screen.dart
│   │   │   └── admin_users_screen.dart
│   │   └── cliente/          # Pantallas del cliente
│   │       ├── home_screen.dart
│   │       ├── carrito_screen.dart
│   │       ├── categorias_screen.dart
│   │       ├── producto_detalle_screen.dart
│   │       ├── search_results_screen.dart
│   │       └── user_screen.dart
│   ├── services/
│   │   ├── api_service.dart   # Comunicación con la API REST
│   │   └── cart_service.dart  # Lógica del carrito (singleton)
│   └── widgets/
│       ├── buscador.dart
│       ├── comentarios.dart
│       ├── contacto.dart
│       ├── fila_productos.dart
│       └── producto_card.dart
├── pubspec.yaml
└── README.md
```

---

## 🚀 Instalación y ejecución

### Requisitos previos

- **Flutter SDK** (versión compatible con Dart ^3.9.0).
- **Dart** incluido con Flutter.
- Un emulador o dispositivo físico (Android, iOS, Web, etc.).
- **API REST** en ejecución (ver sección de API).

### Pasos

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/AcronMaster/bikershop.git
   cd bikershop
   ```

2. **Obtener dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar la URL de la API**
   En `lib/services/api_service.dart`, ajusta `baseUrl` según tu entorno:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
   // static const String baseUrl = 'http://localhost:3000/api'; // iOS/Web
   // static const String baseUrl = 'http://<TU_IP>:3000/api'; // Dispositivo físico
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```
   O selecciona un dispositivo específico:
   ```bash
   flutter run -d chrome    # Web
   flutter run -d emulator-5554  # Android
   ```

5. **Compilar para producción** (opcional)
   ```bash
   flutter build apk          # Android
   flutter build ios          # iOS
   flutter build web          # Web
   ```

---

## 🔌 API REST (referencia)

La aplicación consume los siguientes endpoints (según `api_service.dart`):

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/auth/register` | Registro de usuario |
| `POST` | `/auth/login` | Inicio de sesión (devuelve token) |
| `GET`  | `/products` | Listar productos |
| `GET`  | `/products/:id` | Obtener producto por ID |
| `POST` | `/reservations` | Crear reservación (requiere token) |

> 🔑 Las rutas protegidas esperan un encabezado `Authorization: Bearer <token>`. El token se obtiene en el login y se guarda con `shared_preferences`.

---

## 🖥️ Uso de la aplicación

### Flujo de inicio

1. Al abrir la app, `AuthWrapper` verifica si existe un token guardado.
   - Si **hay sesión activa** → redirige a `HomeScreen`.
   - Si **no hay sesión** → muestra `LoginScreen`.
2. Desde el login se puede acceder a `RegistroScreen` para crear una cuenta nueva.

### Experiencia de cliente

- **Home**: lista de productos con buscador y categorías.
- **Detalle de producto**: información completa y opción de agregar al carrito.
- **Carrito**: edición de cantidades, eliminación de ítems y resumen de compra.
- **Reservas**: creación de reservaciones con los productos seleccionados.
- **Perfil**: datos del usuario y cierre de sesión.

### Experiencia de administrador

- **Admin Home**: panel con accesos rápidos.
- **Productos**: CRUD de productos.
- **Usuarios**: listado y gestión.
- **Proveedores**: listado y gestión.
- **Reservaciones**: visualización y gestión de reservas.

> 💡 El rol del usuario (admin o cliente) se determina a partir de los datos devueltos por la API en el login y se almacena localmente.

---

## 🏗️ Arquitectura

```
main.dart
 ├── AuthWrapper (verifica sesión)
 │    ├── LoginScreen / RegistroScreen
 │    └── HomeScreen (cliente)
 │         ├── CategoriasScreen
 │         ├── SearchResultsScreen
 │         ├── ProductoDetalleScreen
 │         ├── CarritoScreen
 │         └── UserScreen
 └── (admin) AdminHomeScreen
      ├── AdminProductsScreen
      ├── AdminUsersScreen
      ├── AdminSuppliersScreen
      └── AdminReservationsScreen
```

### Servicios clave

| Servicio | Responsabilidad |
|----------|-----------------|
| `ApiService` | Peticiones HTTP, autenticación, manejo de token y usuario. |
| `CartService` | Singleton que gestiona el carrito en memoria y lo persiste con `shared_preferences`. |

### Widgets reutilizables

- `ProductoCard`: tarjeta de producto para listados.
- `Buscador`: campo de búsqueda.
- `FilaProductos`: fila de productos.
- `Comentarios`, `Contacto`: secciones adicionales.

---

## 📌 Notas y limitaciones

- **API externa requerida**: el repositorio **no incluye** el backend. Debes desplegar la API REST en `http://localhost:3000/api` o ajustar `baseUrl`.
- **Persistencia local**: el carrito y la sesión se guardan con `shared_preferences`; si se borran los datos de la app, se pierden.
- **Roles**: la distinción admin/cliente depende de los datos que devuelva la API; no hay una validación de rol a nivel de frontend más allá de la navegación.
- **No hay pruebas unitarias** incluidas en el repositorio actual.
- **Compatibilidad**: el proyecto incluye carpetas para Android, iOS, Web, Linux, macOS y Windows, pero no se ha verificado su funcionamiento en todas las plataformas.

---

## 👨‍💻 Autor

**Luis Adrián Cauich Dzul**  
GitHub: [@AcronMaster](https://github.com/AcronMaster)
