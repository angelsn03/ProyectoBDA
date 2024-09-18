CREATE TRIGGER validar_disponibilidad
BEFORE INSERT ON compras
FOR EACH ROW
BEGIN
    DECLARE cantidad_actual INT;
    SELECT cantidad_disponible INTO cantidad_actual
    FROM boletos
    WHERE id = NEW.boleto_id;

    IF cantidad_actual <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Boleto no disponible.';
    END IF;
END;

CREATE TRIGGER actualizar_estado_boleto
AFTER UPDATE ON boletos
FOR EACH ROW
BEGIN
    IF NEW.cantidad_disponible = 0 THEN
        UPDATE boletos
        SET estado = 'agotado'
        WHERE id = NEW.id;
    END IF;
END;

START TRANSACTION;

-- 1. Verificar la disponibilidad del boleto
DECLARE cantidad_disponible INT;
SELECT cantidad_disponible INTO cantidad_disponible
FROM boletos
WHERE id = :boleto_id;

IF cantidad_disponible <= 0 THEN
    ROLLBACK; -- Si no hay boletos, revertir la transacción
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Boleto no disponible.';
END IF;

-- 2. Registrar la compra
INSERT INTO compras (usuario_id, boleto_id, fecha_compra)
VALUES (:usuario_id, :boleto_id, NOW());

-- 3. Actualizar el stock de boletos
UPDATE boletos
SET cantidad_disponible = cantidad_disponible - 1
WHERE id = :boleto_id;

COMMIT;


CREATE PROCEDURE realizar_compra(
    IN p_usuario_id INT,
    IN p_boleto_id INT
)
BEGIN
    DECLARE cantidad_disponible INT;

    -- Verificar disponibilidad
    SELECT cantidad_disponible INTO cantidad_disponible
    FROM boletos
    WHERE id = p_boleto_id;

    IF cantidad_disponible <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Boleto no disponible.';
    ELSE
        -- Registrar la compra
        INSERT INTO compras (usuario_id, boleto_id, fecha_compra)
        VALUES (p_usuario_id, p_boleto_id, NOW());

        -- Actualizar stock de boletos
        UPDATE boletos
        SET cantidad_disponible = cantidad_disponible - 1
        WHERE id = p_boleto_id;

        -- Notificar al usuario
        INSERT INTO notificaciones (usuario_id, mensaje, fecha)
        VALUES (p_usuario_id, 'Compra de boleto realizada con éxito.', NOW());
    END IF;
END;

CREATE PROCEDURE obtener_historial_compras(
    IN p_usuario_id INT
)
BEGIN
    SELECT c.id, c.fecha_compra, b.nombre AS nombre_boleto
    FROM compras c
    JOIN boletos b ON c.boleto_id = b.id
    WHERE c.usuario_id = p_usuario_id;
END;
