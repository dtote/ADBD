-- MySQL Script generated by MySQL Workbench
-- Sun Nov 22 14:02:52 2020
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema catastro
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema catastro
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `catastro` DEFAULT CHARACTER SET utf8 ;
USE `catastro` ;

-- -----------------------------------------------------
-- Table `catastro`.`Zona`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `catastro`.`Zona` (
  `nombre_zona` VARCHAR(45) NOT NULL,
  `area` VARCHAR(45) NOT NULL,
  `concejal` VARCHAR(45) NULL,
  PRIMARY KEY (`nombre_zona`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `catastro`.`Vivienda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `catastro`.`Vivienda` (
  `calle` VARCHAR(45) NOT NULL,
  `numero` INT NOT NULL,
  `numero_personas` INT NULL,
  `Zona_nombre_zona` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`calle`, `Zona_nombre_zona`, `numero`),
  CONSTRAINT `fk_Vivienda_Zona1`
    FOREIGN KEY (`Zona_nombre_zona`)
    REFERENCES `catastro`.`Zona` (`nombre_zona`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `catastro`.`Bloque`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `catastro`.`Bloque` (
  `calle` VARCHAR(45) NOT NULL,
  `numero` INT NOT NULL,
  `numero_personas` INT NULL ,
  `Zona_nombre_zona` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`calle`, `numero`, `Zona_nombre_zona`),
  CONSTRAINT `fk_Bloque_Zona`
    FOREIGN KEY (`Zona_nombre_zona`)
    REFERENCES `catastro`.`Zona` (`nombre_zona`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `catastro`.`Piso`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `catastro`.`Piso` (
  `planta` INT NOT NULL,
  `letra` VARCHAR(3) NOT NULL,
  `Bloque_calle` VARCHAR(45) NOT NULL,
  `Bloque_numero` INT NOT NULL,
  `Bloque_Zona_nombre_zona` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`planta`, `letra`, `Bloque_calle`, `Bloque_numero`),
  CONSTRAINT `fk_piso_Bloque1`
    FOREIGN KEY (`Bloque_calle` , `Bloque_numero` , `Bloque_Zona_nombre_zona`)
    REFERENCES `catastro`.`Bloque` (`calle` , `numero` , `Zona_nombre_zona`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `catastro`.`Persona`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `catastro`.`Persona` (
  `DNI` VARCHAR(9) NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `fecha_nac` DATE NOT NULL,
  `dni_cabeza` VARCHAR(9) NOT NULL,
  `Vivienda_calle` VARCHAR(45) NULL,
  `Vivienda_Zona_nombre_zona` VARCHAR(45) NULL,
  `Vivienda_numero` INT NULL,
  `Piso_planta` INT NULL,
  `Piso_letra` VARCHAR(3) NULL,
  `Piso_Bloque_calle` VARCHAR(45) NULL,
  `Piso_Bloque_numero` INT NULL,
  PRIMARY KEY (`DNI`),
  CONSTRAINT `fk_Persona_Vivienda1`
    FOREIGN KEY (`Vivienda_calle` , `Vivienda_Zona_nombre_zona` , `Vivienda_numero`)
    REFERENCES `catastro`.`Vivienda` (`calle` , `Zona_nombre_zona` , `numero`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Persona_Piso1`
    FOREIGN KEY (`Piso_planta` , `Piso_letra` , `Piso_Bloque_calle` , `Piso_Bloque_numero`)
    REFERENCES `catastro`.`Piso` (`planta` , `letra` , `Bloque_calle` , `Bloque_numero`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- --------------------------------------------------------------------------
-- Trigger vivienda_unica: comprueba que una persona solo tenga una vivienda
-- --------------------------------------------------------------------------
-- Como tenemos estructuradas las tablas, solo necesitamos comprobar que la persona viva 
-- en una vivienda unifamiliar o en un piso, pero no en las dos cosas a la vez
DROP TRIGGER IF EXISTS vivienda_unica;
CREATE TRIGGER vivienda_unica BEFORE INSERT ON `catastro`.`Persona` 
FOR EACH ROW
BEGIN
  IF (new.Vivienda_calle IS NOT NULL AND new.Piso_Bloque_calle IS NOT NULL) THEN
    signal sqlstate '45000' set message_text = 'Una persona no puede vivir en dos viviendas';
  END IF;
END; 

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
