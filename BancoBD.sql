CREATE DATABASE IF NOT EXISTS BancoBD;
USE BancoBD;

DROP TABLE IF EXISTS historial_transferencias;
DROP TABLE IF EXISTS cuentas;

CREATE TABLE cuentas (
    id_cuenta INT PRIMARY KEY AUTO_INCREMENT,
    titular VARCHAR(100) NOT NULL,
    saldo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    estado VARCHAR(20) DEFAULT 'Activa'
);

CREATE TABLE historial_transferencias (
    id_transferencia INT AUTO_INCREMENT PRIMARY KEY,
    cuenta_origen INT NOT NULL,
    cuenta_destino INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cuenta_origen) REFERENCES cuentas(id_cuenta),
    FOREIGN KEY (cuenta_destino) REFERENCES cuentas(id_cuenta)
);

INSERT INTO cuentas (id_cuenta, titular, saldo, estado) VALUES
(1, 'Ana López', 5000.00, 'Activa'),
(2, 'Carlos Pérez', 3000.00, 'Activa'),
(3, 'Roberto Silva', 120000.00, 'Bloqueada');

DROP PROCEDURE IF EXISTS TransferirFondos;

DELIMITER //

CREATE PROCEDURE TransferirFondos(
    IN p_origen INT,
    IN p_destino INT,
    IN p_monto DECIMAL(10,2),
    OUT p_codigo_respuesta INT,
    OUT p_nombre_titular_origen VARCHAR(100)
)
BEGIN
    DECLARE v_saldo_origen DECIMAL(10,2);
    DECLARE v_existe_destino INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_codigo_respuesta = 500;
        SET p_nombre_titular_origen = NULL;
    END;

    START TRANSACTION;

    IF p_monto <= 0 THEN
        SET p_codigo_respuesta = 401;
        SELECT titular INTO p_nombre_titular_origen FROM cuentas WHERE id_cuenta = p_origen;
        ROLLBACK;
    ELSE
        SELECT saldo, titular INTO v_saldo_origen, p_nombre_titular_origen 
        FROM cuentas 
        WHERE id_cuenta = p_origen 
        FOR UPDATE;

        IF v_saldo_origen IS NULL OR v_saldo_origen < p_monto THEN
            SET p_codigo_respuesta = 400;
            ROLLBACK;
        ELSE
            SELECT COUNT(*) INTO v_existe_destino FROM cuentas WHERE id_cuenta = p_destino;
            
            IF v_existe_destino = 0 THEN
                SET p_codigo_respuesta = 400;
                ROLLBACK;
            ELSE
                UPDATE cuentas 
                SET saldo = saldo - p_monto 
                WHERE id_cuenta = p_origen;

                UPDATE cuentas 
                SET saldo = saldo + p_monto 
                WHERE id_cuenta = p_destino;

                INSERT INTO historial_transferencias (cuenta_origen, cuenta_destino, monto) 
                VALUES (p_origen, p_destino, p_monto);

                COMMIT;

                SET p_codigo_respuesta = 200;
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;

SELECT * FROM cuentas;

CALL TransferirFondos(1, 2, 1000.00, @codigo, @titular_origen);
SELECT @codigo AS CodigoRespuesta, @titular_origen AS TitularOrigen;

CALL TransferirFondos(1, 2, 10000.00, @codigo, @titular_origen);
SELECT @codigo AS CodigoRespuesta, @titular_origen AS TitularOrigen;

CALL TransferirFondos(1, 2, -500.00, @codigo, @titular_origen);
SELECT @codigo AS CodigoRespuesta, @titular_origen AS TitularOrigen;

SELECT * FROM cuentas;
SELECT * FROM historial_transferencias;

DROP USER IF EXISTS ''@'localhost';
DROP USER IF EXISTS ''@'%';

DROP USER IF EXISTS 'admin_banco'@'localhost';
DROP USER IF EXISTS 'cajero_app'@'localhost';
DROP USER IF EXISTS 'auditor_consulta'@'%';
DROP USER IF EXISTS 'app_backend'@'localhost';

CREATE USER 'admin_banco'@'localhost' IDENTIFIED BY 'AdminBank2026!#';
CREATE USER 'cajero_app'@'localhost' IDENTIFIED BY 'CajeroPass2026!';
CREATE USER 'auditor_consulta'@'%' IDENTIFIED BY 'AuditorPass2026!';
CREATE USER 'app_backend'@'localhost' IDENTIFIED BY 'AppBackend2026!Sec';

GRANT ALL PRIVILEGES ON BancoBD.* TO 'admin_banco'@'localhost' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE ON BancoBD.* TO 'app_backend'@'localhost';
GRANT SELECT (id_cuenta, titular, saldo), UPDATE (saldo) ON BancoBD.cuentas TO 'cajero_app'@'localhost';
GRANT SELECT ON BancoBD.* TO 'auditor_consulta'@'%';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'cajero_app'@'localhost';
SHOW GRANTS FOR 'app_backend'@'localhost';

REVOKE UPDATE ON BancoBD.cuentas FROM 'cajero_app'@'localhost';
FLUSH PRIVILEGES;

PREPARE stmt_buscar_cuenta FROM 
'SELECT id_cuenta, titular, saldo, estado FROM cuentas WHERE id_cuenta = ? AND estado = ?';

SET @id_busqueda = 1;
SET @estado_busqueda = 'Activa';

EXECUTE stmt_buscar_cuenta USING @id_busqueda, @estado_busqueda;

DEALLOCATE PREPARE stmt_buscar_cuenta;