-------Actualizar inventario----------------
CREATE   PROCEDURE [contasoft].[actualizar_inventario]
    @id_inventario INT,
    @id_proveedor INT,
    @id_categoria INT,
    @nombre VARCHAR(255),
    @cantidad INT,
    @precio DECIMAL(18, 2),
    @observacion VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @rows_affected INT;
    DECLARE @status INT = 200;
    DECLARE @message VARCHAR(255) = 'Inventario actualizado exitosamente';
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE contasoft.Inventario
        SET
            id_proveedor = @id_proveedor,
            id_categoria = @id_categoria,
            nombre = @nombre,
            cantidad = @cantidad,
            precio = @precio,
            observacion = @observacion
        WHERE
            id_inventario = @id_inventario;
        
        SET @rows_affected = @@ROWCOUNT;
        
        IF @rows_affected = 0
        BEGIN
            SET @status = 404;
            SET @message = 'No se encontró el inventario especificado o no se realizaron cambios';
        END
        
        COMMIT TRANSACTION;
        
        SELECT @status AS status, @message AS message, @rows_affected AS rows_affected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @status = 500;
        SET @message = ERROR_MESSAGE();
        
        SELECT @status AS status, @message AS message, 0 AS rows_affected;
    END CATCH
END;


-----Craer Inventario-----------
CREATE PROCEDURE [contasoft].[create_inventario]
(
    @id_proveedor INT,
    @id_categoria INT,
    @id_asociacion INT,
    @nombre VARCHAR(255),
    @cantidad INT,
    @precio DECIMAL(18, 2),
    @observacion TEXT = NULL
)
AS
BEGIN
    INSERT INTO contasoft.Inventario (id_proveedor, id_categoria, id_asociacion, nombre, cantidad, precio, observacion)
    VALUES (@id_proveedor, @id_categoria, @id_asociacion @nombre, @cantidad, @precio, @observacion);
END;


----archivar --------------------
CREATE PROCEDURE [contasoft].[archivar_inventario]
@id_inventario INT
AS
BEGIN
    -- Verificar si el elemento existe
    IF EXISTS (SELECT 1 FROM contasoft.Inventario WHERE id_inventario = @id_inventario)
    BEGIN
       
        UPDATE contasoft.Inventario
        SET archivado = 1
        WHERE id_inventario = @id_inventario;
        
       
        SELECT 'Elemento archivado exitosamente.' AS Mensaje;
    END
    ELSE
    BEGIN
        SELECT 'El elemento no existe en el inventario.' AS Mensaje;
    END
END;



------cuenta el inventario-----
CREATE PROCEDURE [contasoft].[contar_elementos_inventario]
AS
BEGIN
    SELECT COUNT(*) AS total_elementos
    FROM contasoft.Inventario;
END;

-----cuenta elementos prestados-----
CREATE PROCEDURE [contasoft].[contar_elementos_prestados]
AS
BEGIN
    SELECT COUNT(*) AS total_elementos_prestados
    FROM contasoft.Inventario
    WHERE esta_prestado = 1;
END;


-----incertar un prestamos de inventario-----
CREATE PROCEDURE [contasoft].[insertar_prestamo]
(
    @id_inventario INT,
    @id_usuario INT,
    @cantidad INT,
    @fecha_devolucion DATETIME
)
AS
BEGIN
    DECLARE @cantidad_actual INT;
    DECLARE @veces_prestado INT;

    -- Obtener la cantidad actual en inventario y el número de veces prestado
    SELECT @cantidad_actual = cantidad, 
           @veces_prestado = veces_prestado
    FROM contasoft.Inventario
    WHERE id_inventario = @id_inventario;

    -- Verificar si hay suficiente cantidad en el inventario para prestar
    IF @cantidad_actual >= @cantidad
    BEGIN
        -- Reducir la cantidad en inventario
        UPDATE contasoft.Inventario
        SET cantidad = cantidad - @cantidad,
            esta_prestado = 1,
            veces_prestado = @veces_prestado + 1
        WHERE id_inventario = @id_inventario;

        -- Insertar el préstamo en la tabla Prestamo_Inventario
        INSERT INTO contasoft.Prestamo_Inventario (id_inventario, id_usuario, fecha_prestamo, fecha_devolucion, cantidad, devuelto)
        VALUES (@id_inventario, @id_usuario, GETDATE(), @fecha_devolucion, @cantidad, 0);

        -- Mensaje de éxito
        SELECT 'Préstamo registrado exitosamente' AS mensaje;
    END
    ELSE
    BEGIN
        -- Mensaje de error
        SELECT 'No hay suficiente cantidad en el inventario para realizar el préstamo' AS mensaje;
    END
END;


-------incertar un rol------------------
CREATE PROCEDURE [contasoft].[insertar_rol]
(
    @nombre VARCHAR(255)
)
AS
BEGIN
    -- Insertar el nuevo rol en la tabla Roles
    INSERT INTO contasoft.Roles (nombre)
    VALUES (@nombre);

    PRINT 'Rol registrado exitosamente';
END;


-----incertar un usuario----------------

CREATE PROCEDURE [contasoft].[insertar_usuario]
(
    @id_rol INT,
    @universidad_id INT,
    @primer_nombre VARCHAR(255),
    @segundo_nombre VARCHAR(255),
    @primer_apellido VARCHAR(255),
    @segundo_apellido VARCHAR(255),
    @email VARCHAR(255),
    @telefono VARCHAR(50)
   

)
AS
BEGIN
    -- Verificar si el rol existe
    IF EXISTS (SELECT 1 FROM contasoft.Roles WHERE id_rol = @id_rol)
    BEGIN
        -- Insertar el nuevo usuario en la tabla Usuarios
        INSERT INTO contasoft.Usuarios 
        (
            id_rol, 
            universidad_id, 
            primer_nombre, 
            segundo_nombre, 
            primer_apellido, 
            segundo_apellido, 
            email, 
            telefono
        )
        VALUES 
        (
            @id_rol, 
            @universidad_id, 
            @primer_nombre, 
            @segundo_nombre, 
            @primer_apellido, 
            @segundo_apellido, 
            @email, 
            @telefono
        );

        PRINT 'Usuario registrado exitosamente';
    END
    ELSE
    BEGIN
        -- Mostrar error si el rol no existe
        RAISERROR ('El rol especificado no existe', 16, 1);
    END
END;



--------obtener el inventario------

CREATE PROCEDURE [contasoft].[obtener_inventario_completo]
AS
BEGIN
    SELECT 
        I.id_inventario,
        I.nombre AS nombre_inventario,
        P.nombre AS nombre_proveedor,
        C.nombre AS nombre_categoria,
        I.cantidad,
        I.veces_prestado,
        I.esta_prestado,
        I.precio,
        I.observacion
    FROM 
        contasoft.Inventario I
    JOIN 
        contasoft.Proveedor P ON I.id_proveedor = P.id_proveedor
    JOIN 
        contasoft.Categoria C ON I.id_categoria = C.id_categoria
    ORDER BY 
        I.id_inventario DESC;
END;

---usuarios con entrgas tardias------
CREATE PROCEDURE [contasoft].[usuarios_con_entregas_tardias]
AS
BEGIN
    SELECT 
        U.primer_nombre,
        U.primer_apellido,
        U.email,
        U.telefono
    FROM 
        contasoft.Usuarios U
    JOIN 
        contasoft.Prestamo_Inventario P ON U.id = P.id_usuario
    WHERE 
        P.fecha_devolucion < GETDATE()
        AND P.devuelto = 0;
END;