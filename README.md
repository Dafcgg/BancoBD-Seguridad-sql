# Taller: Seguridad, Permisos y Prevención de SQL Injection en MySQL

Implementación práctica de un sistema bancario (`BancoBD`) enfocada en buenas prácticas de seguridad en bases de datos: gestión de usuarios y roles, asignación granular de privilegios, y prevención de inyección SQL mediante sentencias preparadas.

## 📋 Contenido del taller

El script cubre los siguientes pasos:

1. **Preparación del entorno** — Creación de la base de datos `BancoBD` y sus tablas (`cuentas`, `historial_transferencias`) con relación de clave foránea.
2. **Higiene de seguridad** — Eliminación de usuarios anónimos (`''@'localhost'`, `''@'%'`).
3. **Creación de usuarios por rol**:
   - `admin_banco` — Administrador local.
   - `cajero_app` — Acceso restringido a columnas específicas.
   - `auditor_consulta` — Acceso remoto de solo lectura.
   - `app_backend` — Usuario de aplicación con permisos DML.
4. **Asignación granular de privilegios (`GRANT`)** — Aplicando el principio de mínimo privilegio, incluyendo permisos a nivel de columna.
5. **Verificación y revocación (`SHOW GRANTS` / `REVOKE`)** — Auditoría y ajuste de permisos otorgados.
6. **Prevención de SQL Injection** — Uso de sentencias preparadas (`PREPARE` / `EXECUTE` / `DEALLOCATE PREPARE`) para evitar la concatenación directa de entradas de usuario.

## 🗂️ Estructura del repositorio

```
├── sql/
│   └── taller-seguridad-permisos.sql
├── evidencias/
│   ├── 01-diagrama-er.png
│   ├── 02-datos-iniciales.png
│   ├── 03-grants-cajero.png
│   ├── 04-grants-backend.png
│   └── 05-sentencia-preparada.png
└── README.md
```

