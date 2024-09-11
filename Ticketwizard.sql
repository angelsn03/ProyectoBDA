
CREATE DATABASE Ticketwizard;
USE Ticketwizard;

CREATE TABLE Usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    domicilio VARCHAR(255),
    fecha_nacimiento DATE,
    edad INT,
    saldo DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE Eventos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha DATE NOT NULL,
    venue VARCHAR(100),
    ciudad VARCHAR(100),
    estado VARCHAR(100),
    descripcion TEXT
);

CREATE TABLE Boletos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_serie CHAR(8) NOT NULL UNIQUE,
    fila VARCHAR(10),
    asiento VARCHAR(10),
    numero_control INT NOT NULL,
    precio_original DECIMAL(10, 2) NOT NULL,
    id_evento INT NOT NULL,
    id_dueno INT NOT NULL,
    vendido_por_reventa BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_evento) REFERENCES Eventos(id),
    FOREIGN KEY (id_dueno) REFERENCES Usuarios(id)
);

CREATE TABLE Transacciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_comprador INT NOT NULL,
    id_vendedor INT NOT NULL,
    monto_total DECIMAL(10, 2) NOT NULL,
    comision_total DECIMAL(10, 2) NOT NULL,
    fecha_transaccion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_comprador) REFERENCES Usuarios(id),
    FOREIGN KEY (id_vendedor) REFERENCES Usuarios(id)
);

CREATE TABLE Transacciones_Detalle (
    folio INT NOT NULL PRIMARY KEY,
    id_boleto INT NOT NULL,
    comision DECIMAL(10, 2),
    monto_ DECIMAL(10, 2) NOT NULL,
    tipo ENUM('COMPRA', 'REVENTA') NOT NULL,
    FOREIGN KEY (id_boleto) REFERENCES Boletos(id),
    FOREIGN KEY (folio) REFERENCES Transacciones(id)
);

CREATE TABLE MovimientosSaldo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    fecha_movimiento DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo ENUM('CREDITO', 'DEBITO') NOT NULL,
    descripcion VARCHAR(255),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id)
);

CREATE TABLE Apartados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_boleto INT NOT NULL,
    id_comprador INT NOT NULL,
    fecha_apartado DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_limite DATETIME NOT NULL,
    FOREIGN KEY (id_boleto) REFERENCES Boletos(id),
    FOREIGN KEY (id_comprador) REFERENCES Usuarios(id)
);
