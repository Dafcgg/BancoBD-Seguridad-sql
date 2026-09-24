CREATE DATABASE IF NOT EXISTS BancoDB;
USE BancoDB;

DROP TABLE IF EXISTS historial_transferencias;
DROP TABLE IF EXISTS cuentas;

CREATE TABLE cuentas (
    id_cuenta INT PRIMARY KEY AUTO_INCREMENT,
    titular VARCHAR(100) NOT NULL,
    tipo_cuenta VARCHAR(20) NOT NULL DEFAULT 'Ahorros',
    saldo DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    estado VARCHAR(20) NOT NULL DEFAULT 'Activa',
    fecha_apertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE historial_transferencias (
    id_transferencia INT AUTO_INCREMENT PRIMARY KEY,
    cuenta_origen INT NOT NULL,
    cuenta_destino INT NOT NULL,
    monto DECIMAL(12, 2) NOT NULL,
    estado_transferencia VARCHAR(20) NOT NULL DEFAULT 'Exitosa',
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cuenta_origen) REFERENCES cuentas(id_cuenta),
    FOREIGN KEY (cuenta_destino) REFERENCES cuentas(id_cuenta)
);

DELIMITER //
CREATE PROCEDURE CargarDatosPrueba()
BEGIN
    DECLARE i INT DEFAULT 1;
    
    WHILE i <= 1000 DO
        INSERT INTO cuentas (titular, tipo_cuenta, saldo, estado, fecha_apertura)
        VALUES (
            CONCAT('Cliente_', i),
            IF(i % 2 = 0, 'Ahorros', 'Corriente'),
            ROUND(RAND() * 10000000, 2),
            IF(i % 10 = 0, 'Bloqueada', 'Activa'),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY)
        );
        SET i = i + 1;
    END WHILE;

    SET i = 1;
    WHILE i <= 10000 DO
        INSERT INTO historial_transferencias (cuenta_origen, cuenta_destino, monto, estado_transferencia, fecha)
        VALUES (
            FLOOR(1 + RAND() * 999),
            FLOOR(1 + RAND() * 999),
            ROUND(1000 + RAND() * 500000, 2),
            IF(i % 15 = 0, 'Fallida', 'Exitosa'),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 180) DAY)
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL CargarDatosPrueba();
DROP PROCEDURE IF EXISTS CargarDatosPrueba;

EXPLAIN ANALYZE
SELECT id_transferencia, cuenta_origen, monto, fecha
FROM historial_transferencias
WHERE estado_transferencia = 'Exitosa'
  AND fecha >= '2026-01-01 00:00:00';

CREATE INDEX idx_transf_estado_fecha ON historial_transferencias(estado_transferencia, fecha);

EXPLAIN ANALYZE
SELECT id_transferencia, cuenta_origen, monto, fecha
FROM historial_transferencias
WHERE estado_transferencia = 'Exitosa'
  AND fecha >= '2026-01-01 00:00:00';

EXPLAIN ANALYZE
SELECT id_transferencia, cuenta_origen, cuenta_destino, monto, estado_transferencia, fecha
FROM historial_transferencias 
WHERE fecha >= '2026-02-15 00:00:00' 
  AND fecha < '2026-02-16 00:00:00';

CREATE INDEX idx_cuentas_cubriente ON cuentas(estado, titular, saldo, tipo_cuenta);

EXPLAIN ANALYZE
SELECT titular, saldo, tipo_cuenta
FROM cuentas
WHERE estado = 'Activa';

CREATE INDEX idx_cuentas_estado_id ON cuentas(estado, id_cuenta);
CREATE INDEX idx_transf_origen_monto ON historial_transferencias(cuenta_origen, monto);

EXPLAIN ANALYZE
SELECT c.id_cuenta, c.titular, ht.id_transferencia, ht.monto, ht.fecha
FROM cuentas c
JOIN historial_transferencias ht ON c.id_cuenta = ht.cuenta_origen
WHERE c.estado = 'Activa'
  AND ht.monto > 300000.00;