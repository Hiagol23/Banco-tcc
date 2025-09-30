create database db_journey;
use db_journey;

select * from tbl_usuario;
select * from tbl_codigo_recuperacao;
select * from tbl_grupo;
select * from tbl_categoria;
select * from tbl_area;


CREATE TABLE tbl_usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome_completo VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL,
    data_nascimento DATE,
    foto_perfil VARCHAR(255),
    descricao TEXT,
    senha VARCHAR(255) NOT NULL,
    tipo_usuario ENUM('Profissional', 'Estudante') NOT NULL
);
CREATE TABLE tbl_codigo_recuperacao (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(60) NOT NULL,
    codigo VARCHAR(10) NOT NULL,
    expiracao DATETIME NOT NULL
);
CREATE TABLE tbl_grupo (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    limite_membros INT,
    descricao TEXT,
    imagem VARCHAR(255),
    id_area INT,
    id_usuario INT,
    CONSTRAINT fk_grupo_usuario FOREIGN KEY (id_usuario) REFERENCES tbl_usuario(id_usuario),
    CONSTRAINT fk_grupo_area FOREIGN KEY (id_area) REFERENCES tbl_area(id_area)
);
CREATE TABLE tbl_categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    categoria VARCHAR(100) NOT NULL
);
CREATE TABLE tbl_area (
    id_area INT AUTO_INCREMENT PRIMARY KEY,
    area VARCHAR(100) NOT NULL
);



ALTER TABLE tbl_categoria 
CHANGE nome categoria varchar(100);

drop table tbl_grupo; 


-----usuario------
DELIMITER $$

CREATE PROCEDURE inserir_usuario (
    IN p_nome_completo   VARCHAR(255),
    IN p_email           VARCHAR(255),
    IN p_senha           VARCHAR(255),
    IN p_data_nascimento DATE,
    IN p_foto_perfil     VARCHAR(255),
    IN p_descricao       TEXT,
    IN p_tipo_usuario    VARCHAR(50)
)
BEGIN
    INSERT INTO tbl_usuario (
        nome_completo,
        email,
        senha,
        data_nascimento,
        foto_perfil,
        descricao,
        tipo_usuario
    ) VALUES (
        p_nome_completo,
        p_email,
        p_senha,
        p_data_nascimento,
        p_foto_perfil,
        p_descricao,
        p_tipo_usuario
    );

    -- Retornar número de linhas afetadas
    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE update_usuario (
    IN p_id             INT,
    IN p_nome_completo  VARCHAR(255),
    IN p_email          VARCHAR(255),
    IN p_senha          VARCHAR(255),
    IN p_data_nascimento DATE,
    IN p_foto_perfil    VARCHAR(255),
    IN p_descricao      TEXT,
    IN p_tipo_usuario   VARCHAR(50)
)
BEGIN
    UPDATE tbl_usuario
    SET
        nome_completo   = p_nome_completo,
        email           = p_email,
        senha           = p_senha,
        data_nascimento = p_data_nascimento,
        foto_perfil     = p_foto_perfil,
        descricao       = p_descricao,
        tipo_usuario    = p_tipo_usuario
    WHERE id_usuario = p_id;

    -- Retorna quantas linhas foram afetadas
    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE delete_usuario (
    IN p_id INT
)
BEGIN
    DELETE FROM tbl_usuario
    WHERE id_usuario = p_id;

    -- Retorna quantas linhas foram afetadas
    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;


----REC-SENHA----
DELIMITER $$

CREATE PROCEDURE update_senha_usuario (
    IN p_id INT,
    IN p_nova_senha VARCHAR(255)
)
BEGIN
    UPDATE tbl_usuario
    SET senha = p_nova_senha
    WHERE id_usuario = p_id;

    -- Retorna quantas linhas foram afetadas
    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;


-----grupo------
DELIMITER $$

CREATE PROCEDURE inserir_grupo (
    IN p_nome            VARCHAR(100), 
    IN p_limite_membros  INT,
    IN p_descricao       TEXT,
    IN p_imagem          VARCHAR(255),
    IN p_id_usuario      INT,
    IN p_id_area         INT
)
BEGIN
    INSERT INTO tbl_grupo (
        nome,
        limite_membros,
        descricao,
        imagem,
        id_usuario,
        id_area
    ) VALUES (
        p_nome,
        p_limite_membros,
        p_descricao,
        p_imagem,
        p_id_usuario,
        p_id_area
    );

    -- Retornar número de linhas afetadas
    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE update_grupo (
    IN p_id              INT,
    IN p_nome            VARCHAR(100),
    IN p_limite_membros  INT,
    IN p_descricao       TEXT,
    IN p_imagem          VARCHAR(255),
    IN p_id_usuario      INT,
    IN p_id_area         INT
)
BEGIN
    UPDATE tbl_grupo
    SET
        nome           = p_nome,
        limite_membros = p_limite_membros,
        descricao      = p_descricao,
        imagem         = p_imagem,
        id_usuario     = p_id_usuario,
        id_area        = p_id_area
    WHERE id_grupo = p_id;

    -- Retorna quantas linhas foram afetadas
    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE delete_grupo (
    IN p_id INT
)
BEGIN
    DELETE FROM tbl_grupo
    WHERE id_grupo = p_id;

    -- Retorna quantas linhas foram afetadas
    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;


--categoria--
DELIMITER $$
CREATE PROCEDURE inserir_categoria(
	IN p_categoria VARCHAR(100)
)
BEGIN
    INSERT INTO tbl_categoria (
    categoria
) VALUES (
	p_categoria
);

END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE update_categoria(
	IN p_id INT, 
    IN p_categoria VARCHAR(100)
)
BEGIN
    UPDATE tbl_categoria
    SET categoria = p_categoria
    WHERE id_categoria = p_id;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE delete_categoria(IN p_id INT)
BEGIN
    DELETE FROM tbl_categoria
    WHERE id_categoria = p_id;
END $$
DELIMITER ;


--area--
DELIMITER $$
CREATE PROCEDURE inserir_area(
	IN p_area VARCHAR(100)
)
BEGIN
    INSERT INTO tbl_area (
	area
) VALUES (
	p_area
);

END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_area(
	IN p_id INT, 
    IN p_area VARCHAR(100)
)
BEGIN
    UPDATE tbl_area
    SET area = p_area
    WHERE id_area = p_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE delete_area(
	IN p_id INT
)
BEGIN
    DELETE FROM tbl_area
    WHERE id_area = p_id;
END $$
DELIMITER ;


-- Criando uma View --
CREATE VIEW vw_grupo_id AS
SELECT id_grupo, id_area, id_usuario, nome, limite_membros, descricao, imagem FROM tbl_grupo;

CREATE VIEW vw_categoria_id AS
SELECT id_categoria, categoria FROM tbl_categoria;

CREATE VIEW vw_area_id AS
SELECT id_area, area FROM tbl_area;

CREATE VIEW vw_usuario_id AS
SELECT id_usuario, nome_completo, email, data_nascimento, foto_perfil, descricao, senha, tipo_usuario FROM tbl_usuario;


select * from vw_grupo_id;
select * from vw_categoria_id;
select * from vw_area_id;
select * from vw_usuario_id;

-- Excluir uma View --
drop view vw_grupo_id;


INSERT INTO tbl_grupo (
  nome, 
  limite_membros,
  descricao, 
  imagem,
  id_area,
  id_usuario
) VALUES
(
  "Programadores Full Stack",
  30,
  "Grupo voltado para troca de conhecimento sobre desenvolvimento web, mobile e APIs.",
  "fullstack.png",
  "2",
  "4"
),
(
  "Fotógrafos Amadores",
  25,
  "Espaço para compartilhar técnicas de fotografia, dicas de edição e experiências no mundo da fotografia.",
  "fotografia.jpg",
  "3",
  "1"
),
(
  "Clube do Xadrez",
  20,
  "Grupo para amantes do xadrez, com torneios semanais e análise de partidas famosas.",
  "xadrez.png",
  "1",
  "4"
),
(
  "Sustentabilidade em Ação",
  30,
  "Comunidade voltada para discutir práticas sustentáveis, reciclagem e preservação ambiental.",
  "sustentabilidade.jpg",
  "3",
  "4"
),
(
  "Gamers Retrô",
  15,
  "Grupo para os apaixonados por consoles clássicos e jogos que marcaram época.",
  "retro_gamer.png",
  "2",
  "5"
);

INSERT INTO tbl_usuario (
    nome_completo,
    email,
    data_nascimento,
    foto_perfil,
    descricao,
    senha,
    tipo_usuario
) VALUES
('Ana Souza', 'ana.souza@email.com', '1995-03-12', 'ana.jpg', 'Professora de matemática apaixonada por tecnologia.', 'senha123', 'Profissional'),
('Carlos Lima', 'carlos.lima@email.com', '2000-07-25', 'carlos.png', 'Estudante de engenharia de software.', 'segredo456', 'Estudante'),
('Mariana Alves', 'mariana.alves@email.com', '1998-11-09', NULL, 'Formada em Letras, busca oportunidades de networking.', 'minhasenha789', 'Profissional'),
('João Pedro', 'joao.pedro@email.com', '1992-05-18', 'joao.jpg', 'Analista de sistemas com experiência em banco de dados.', 'senha321', 'Profissional'),
('Beatriz Fernandes', 'beatriz.fernandes@email.com', '2001-09-30', 'beatriz.png', 'Estudante de ciência da computação interessada em IA.', 'segredo654', 'Estudante');

INSERT INTO tbl_categoria (categoria) VALUES
('Tecnologia'),
('Educação'),
('Ciências'),
('Artes'),
('Saúde');

INSERT INTO tbl_area (area) VALUES
('Desenvolvimento Web'),
('Inteligência Artificial'),
('Banco de Dados'),
('Redes de Computadores'),
('Segurança da Informação');

