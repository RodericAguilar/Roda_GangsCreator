
CREATE TABLE IF NOT EXISTS `roda_gangs` (
  `name` varchar(50) NOT NULL,
  `label` varchar(250) NOT NULL,
  `acciones` longtext,
  `points` longtext,
  `color` varchar(50) DEFAULT NULL,
  `logo` longtext,
  `vehicles` longtext,
  `m_outfit` longtext CHARACTER SET utf8 COLLATE utf8_general_ci,
  `f_outfit` longtext,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

ALTER TABLE `users` ADD COLUMN `gang` VARCHAR(50) NULL DEFAULT NULL AFTER `job`;
ALTER TABLE `users` ADD COLUMN `gang_grade` INT(11) NULL DEFAULT NULL AFTER `gang`;