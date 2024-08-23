------Script de la base de datos-----------------------
create TABLE contasoft.Usuarios (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_rol INT NOT NULL,
    universidad_id INT,
    primer_nombre VARCHAR(255) NOT NULL,
    segundo_nombre VARCHAR(255),
    primer_apellido VARCHAR(255) NOT NULL,
    segundo_apellido VARCHAR(255),
    email VARCHAR(255) NOT NULL UNIQUE,
    telefono VARCHAR(50),
    fecha_creacion DATETIME DEFAULT GETDATE(),
    active BIT DEFAULT 1,
    FOREIGN KEY (id_rol) REFERENCES contasoft.Roles(id_rol)
);


CREATE TABLE contasoft.Roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
);

CREATE TABLE contasoft.Asociacion (
    id_asociacion INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha DATE,
    estado VARCHAR(50) NOT NULL
);

CREATE TABLE contasoft.Asociacion_Usuario (
    id_asociacion_usuario INT IDENTITY(1,1) PRIMARY KEY,
    id_asociacion INT NOT NULL,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_asociacion) REFERENCES contasoft.Asociacion(id_asociacion),
    FOREIGN KEY (id_usuario) REFERENCES contasoft.Usuarios(id)
);

CREATE TABLE contasoft.Actividad (
    id_actividad INT IDENTITY(1,1) PRIMARY KEY,
    descripcion TEXT NOT NULL,
    presupuesto_deseado DECIMAL(18, 2),
    encargado VARCHAR(255)
);

CREATE TABLE contasoft.Tipo_Reporte (
    id_tipo_reporte INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
);

CREATE TABLE contasoft.Reporte (
    id_reporte INT IDENTITY(1,1) PRIMARY KEY,
    id_asociacion INT NOT NULL,
    id_tipo_reporte INT NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_generado DATETIME DEFAULT GETDATE(),
    fecha_inicial DATE,
    fecha_final DATE,
    FOREIGN KEY (id_asociacion) REFERENCES contasoft.Asociacion(id_asociacion),
    FOREIGN KEY (id_tipo_reporte) REFERENCES contasoft.Tipo_Reporte(id_tipo_reporte)
);

CREATE TABLE contasoft.Tipo_Registro (
    id_tipo_registro INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE contasoft.Registro_Financiero (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_asociacion INT NOT NULL,
    id_tipo_registro INT NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    monto DECIMAL(18, 2) NOT NULL,
    date_create DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_asociacion) REFERENCES contasoft.Asociacion(id_asociacion),
    FOREIGN KEY (id_tipo_registro) REFERENCES contasoft.Tipo_Registro(id_tipo_registro)
);

CREATE TABLE contasoft.Categoria (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
);

CREATE TABLE contasoft.Proveedor (
    id_proveedor INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    correo VARCHAR(255)
);

CREATE TABLE contasoft.Inventario (
    id_inventario INT IDENTITY(1,1) PRIMARY KEY,
    id_asociacion INT NOT NULL,
    id_proveedor INT NOT NULL,
    id_categoria INT NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    cantidad INT NOT NULL,
    veces_prestado INT DEFAULT 0,
    esta_prestado BIT DEFAULT 0,
    precio DECIMAL(18, 2),
    observacion TEXT,
    FOREIGN KEY (id_proveedor) REFERENCES contasoft.Proveedor(id_proveedor),
    FOREIGN KEY (id_categoria) REFERENCES contasoft.Categoria(id_categoria),
    FOREIGN KEY (id_asociacion) REFERENCES contasoft.Asociacion(id_asociacion)
);


CREATE TABLE contasoft.Prestamo_Inventario (
    id_prestamo INT IDENTITY(1,1) PRIMARY KEY,
    id_inventario INT NOT NULL,
    universidad_id INT NOT NULL,
    fecha_prestamo DATETIME NOT NULL,
    fecha_devolucion DATETIME,
    cantidad INT NOT NULL,
    devuelto BIT DEFAULT 0,
    FOREIGN KEY (id_inventario) REFERENCES contasoft.Inventario(id_inventario),
    FOREIGN KEY (universidad_id) REFERENCES contasoft.Usuarios(universidad_id)
);

