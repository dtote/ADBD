-- MySQL Script generated by MySQL Workbench
-- Fri Nov 13 13:28:15 2020
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema viveros
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema viveros
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `viveros` DEFAULT CHARACTER SET utf8 ;
USE `viveros` ;

-- -----------------------------------------------------
-- Table `viveros`.`Zona`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `viveros`.`Zona` (
  `cod_zona` INT NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `num_empleados` INT NULL,
  PRIMARY KEY (`nombre`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `viveros`.`Producto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `viveros`.`Producto` (
  `cod_prod` INT NOT NULL,
  `tipo` VARCHAR(45) NULL,
  `precio` FLOAT NOT NULL,
  `stock` INT NULL,
  PRIMARY KEY (`cod_prod`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `viveros`.`Vivero`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `viveros`.`Vivero` (
  `localizacion_x` FLOAT NOT NULL,
  `localizacion_y` FLOAT NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `superficie` FLOAT NULL,
  `ZONA_nombre` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`localizacion_x`, `ZONA_nombre`, `localizacion_y`),
  CONSTRAINT `fk_VIVERO_ZONA1`
    FOREIGN KEY (`ZONA_nombre`)
    REFERENCES `viveros`.`Zona` (`nombre`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `viveros`.`Empleado`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `viveros`.`Empleado` (
  `dni` VARCHAR(45) NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `sueldo` FLOAT NOT NULL,
  `fecha_ini` DATE NOT NULL,
  `fecha_fin` DATE NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`dni`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `viveros`.`Cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `viveros`.`Cliente` (
  `dni` VARCHAR(45) NOT NULL,
  `codigo` INT NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `fecha_nac` DATE NOT NULL,
  `volumen_mensual` FLOAT NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`dni`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `viveros`.`Pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `viveros`.`Pedido` (
  `codigo` INT NOT NULL,
  `fecha` DATE NOT NULL,
  `importe` FLOAT NOT NULL,
  `EMPLEADO_dni` VARCHAR(45) NOT NULL,
  `CLIENTE_dni` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`codigo`, `EMPLEADO_dni`, `CLIENTE_dni`),
  CONSTRAINT `fk_PEDIDO_EMPLEADO1`
    FOREIGN KEY (`EMPLEADO_dni`)
    REFERENCES `viveros`.`Empleado` (`dni`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_PEDIDO_CLIENTE1`
    FOREIGN KEY (`CLIENTE_dni`)
    REFERENCES `viveros`.`Cliente` (`dni`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `viveros`.`Zona_has_Producto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `viveros`.`Zona_has_Producto` (
  `Zona_nombre` VARCHAR(45) NOT NULL,
  `Producto_cod_prod` INT NOT NULL,
  PRIMARY KEY (`Zona_nombre`, `Producto_cod_prod`),
  CONSTRAINT `fk_Zona_has_Producto_Zona1`
    FOREIGN KEY (`Zona_nombre`)
    REFERENCES `viveros`.`Zona` (`nombre`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Zona_has_Producto_Producto1`
    FOREIGN KEY (`Producto_cod_prod`)
    REFERENCES `viveros`.`Producto` (`cod_prod`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `viveros`.`Zona_has_Empleado`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `viveros`.`Zona_has_Empleado` (
  `Zona_nombre` VARCHAR(45) NOT NULL,
  `Empleado_dni` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Zona_nombre`, `Empleado_dni`),
  CONSTRAINT `fk_Zona_has_Empleado_Zona1`
    FOREIGN KEY (`Zona_nombre`)
    REFERENCES `viveros`.`Zona` (`nombre`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Zona_has_Empleado_Empleado1`
    FOREIGN KEY (`Empleado_dni`)
    REFERENCES `viveros`.`Empleado` (`dni`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `viveros`.`Pedido_has_Producto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `viveros`.`Pedido_has_Producto` (
  `Pedido_codigo` INT NOT NULL,
  `Pedido_EMPLEADO_dni` VARCHAR(45) NOT NULL,
  `Pedido_CLIENTE_dni` VARCHAR(45) NOT NULL,
  `Producto_cod_prod` INT NOT NULL,
  `cant_prod` INT NULL,
  PRIMARY KEY (`Pedido_codigo`, `Pedido_EMPLEADO_dni`, `Pedido_CLIENTE_dni`, `Producto_cod_prod`),
  CONSTRAINT `fk_Pedido_has_Producto_Pedido1`
    FOREIGN KEY (`Pedido_codigo` , `Pedido_EMPLEADO_dni` , `Pedido_CLIENTE_dni`)
    REFERENCES `viveros`.`Pedido` (`codigo` , `EMPLEADO_dni` , `CLIENTE_dni`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Pedido_has_Producto_Producto1`
    FOREIGN KEY (`Producto_cod_prod`)
    REFERENCES `viveros`.`Producto` (`cod_prod`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------------------------------------
-- Procedimiento crear_email: devuelve una dirección de correo electrónico
-- -----------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS crear_email;

USE `viveros`;
CREATE PROCEDURE crear_email(IN nombre_cliente VARCHAR(45), IN id_persona VARCHAR(45), IN code varchar(45), IN dominio VARCHAR(24), OUT nuevo_email VARCHAR(45)) 
BEGIN
    SET nuevo_email = CONCAT(nombre_cliente,code,'@',dominio);
END;


-- -------------------------------------------------------------------------------------------
-- Trigger trigger_crear_email_before_insert: devuelve una dirección de correo electrónico
-- ------------------------------------------------------------------------------------------- 
DROP TRIGGER IF EXISTS trigger_crear_email_before_insert;
CREATE TRIGGER trigger_crear_email_before_insert BEFORE INSERT ON `viveros`.`Cliente`
FOR EACH ROW
BEGIN
  IF (NEW.email IS NULL) THEN
    CALL crear_email(new.nombre, new.dni, new.codigo, 'ull.edu.es', NEW.email);
  END IF;
END; 

-- ----------------------------------------------------------------------
-- Trigger trigger_actualizar_stock: actualiza el stock de un producto
-- ----------------------------------------------------------------------

DROP TRIGGER IF EXISTS trigger_actualizar_stock;
CREATE TRIGGER trigger_actualizar_stock AFTER INSERT ON `viveros`.`Pedido_has_Producto`
FOR EACH ROW
BEGIN
  UPDATE Producto SET stock = stock - new.cant_prod WHERE new.Producto_cod_prod = cod_prod;
END;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
