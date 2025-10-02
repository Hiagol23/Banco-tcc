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
    limite_membros INT NOT NULL,
    descricao TEXT NOT NULL,
    imagem VARCHAR(255) NOT NULL,
    id_area INT NOT NULL,
    id_usuario INT NOT NULL,
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
CREATE TABLE tbl_calendario (
	id_calendario INT AUTO_INCREMENT PRIMARY KEY,
    nome_evento VARCHAR(100) NOT NULL,
    data_evento DATE NOT NULL,
    hora_evento TIME NOT NULL,
    descricao TEXT NOT NULL,
    link VARCHAR(500) NOT NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT fk_calendario_usuario FOREIGN KEY (id_usuario) REFERENCES tbl_usuario(id_usuario)
);
CREATE TABLE tbl_mensagens (
	id_mensagens INT AUTO_INCREMENT PRIMARY KEY,
    conteudo TEXT NOT NULL,
    enviado_em TIMESTAMP NOT NULL,
    id_chat INT NOT NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT fk_mensagens_chat FOREIGN KEY (id_chat) REFERENCES tbl_chat(id_chat),
    CONSTRAINT fk_mensagens_usuario FOREIGN KEY (id_usuario) REFERENCES tbl_usuario(id_usuario)
);
CREATE TABLE tbl_chat (
    id_chat INT AUTO_INCREMENT PRIMARY KEY,
    criado_em TIMESTAMP NOT NULL,
    remetente INT NOT NULL,
    destinatario INT NOT NULL,
    CONSTRAINT fk_chat_remetente FOREIGN KEY (remetente) REFERENCES tbl_usuario (id_usuario),
    CONSTRAINT fk_chat_destinatario FOREIGN KEY (destinatario) REFERENCES tbl_usuario (id_usuario)
);
CREATE TABLE tbl_ebooks (
	id_ebooks INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    descricao TEXT NOT NULL,
    link_imagem VARCHAR(255) NOT NULL,
    link_arquivo_pdf VARCHAR(255),
    id_usuario INT NOT NULL,
    CONSTRAINT fk_ebooks_usuario FOREIGN KEY (id_usuario) REFERENCES tbl_usuario (id_usuario)
);
CREATE TABLE tbl_usuario_grupo (
    id_usuario_grupo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_grupo INT NOT NULL,
    entrou_em TIMESTAMP NOT NULL,
	CONSTRAINT fk_usuario_grupo_usuario FOREIGN KEY (id_usuario) REFERENCES tbl_usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_usuario_grupo_grupo FOREIGN KEY (id_grupo) REFERENCES tbl_grupo (id_grupo) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE tbl_ebooks_categoria (
    id_ebooks_categoria INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    id_ebooks INT NOT NULL,
	CONSTRAINT fk_ebooks_categoria_categoria FOREIGN KEY (id_categoria) REFERENCES tbl_categoria (id_categoria) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ebooks_categoria_ebooks FOREIGN KEY (id_ebooks) REFERENCES tbl_ebooks (id_ebooks) ON DELETE CASCADE ON UPDATE CASCADE
);



ALTER TABLE tbl_calendario 
CHANGE descricao descricao TEXT;

ALTER TABLE tbl_calendario
ADD COLUMN id_usuario INT NOT NULL;

ALTER TABLE tbl_calendario
ADD CONSTRAINT fk_calendario_usuario FOREIGN KEY (id_usuario) 
REFERENCES tbl_usuario(id_usuario);

drop table tbl_codigo_recuperacao; 


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

--CALENDARIO--
DELIMITER $$

CREATE PROCEDURE inserir_calendario (
    IN p_nome_evento     VARCHAR(100), 
    IN p_data_evento     DATE,
    IN p_hora_evento     TIME,
    IN p_descricao       TEXT,
    IN p_link            VARCHAR(500),
    IN p_id_usuario   	 INT
)
BEGIN
    INSERT INTO tbl_calendario (
        nome_evento,
        data_evento,
        hora_evento,
        descricao,
        link,
        id_usuario
    ) VALUES (
        p_nome_evento,
        p_data_evento,
        p_hora_evento,
        p_descricao,
        p_link,
        p_id_usuario
    );

    -- Retornar número de linhas afetadas
    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE update_calendario (
    IN p_id             INT,
    IN p_nome_evento    VARCHAR(100),
    IN p_data_evento  	DATE,
    IN p_hora_evento  	TIME,
    IN p_descricao      TEXT,
    IN p_link          	VARCHAR(500),
    IN p_id_usuario  	INT 
)
BEGIN
    UPDATE tbl_calendario
    SET
        nome_evento     = p_nome_evento,
        data_evento 	= p_data_evento,
        hora_evento 	= p_hora_evento,
        descricao      	= p_descricao,
        link         	= p_link,
        id_usuario   	= p_id_usuario
    WHERE id_categoria 	= p_id;

    -- Retorna quantas linhas foram afetadas
    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE delete_calendario (
    IN p_id INT
)
BEGIN
    DELETE FROM tbl_calendario
    WHERE id_calendario = p_id;

    -- Retorna quantas linhas foram afetadas
    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;

--MENSAGENS--
DELIMITER $$

CREATE PROCEDURE inserir_mensagem (
    IN p_conteudo   TEXT,
    IN p_enviado_em TIMESTAMP,
    IN p_id_chat    INT,
    IN p_id_usuario INT
)
BEGIN
    INSERT INTO tbl_mensagens (
        conteudo,
        enviado_em,
        id_chat,
        id_usuario
    ) VALUES (
        p_conteudo,
        p_enviado_em,
        p_id_chat,
        p_id_usuario
    );

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

CREATE PROCEDURE update_mensagem (
    IN p_id         INT,
    IN p_conteudo   TEXT,
    IN p_enviado_em TIMESTAMP,
    IN p_id_chat    INT,
    IN p_id_usuario INT
)
BEGIN
    UPDATE tbl_mensagens
    SET
        conteudo   = p_conteudo,
        enviado_em = p_enviado_em,
        id_chat    = p_id_chat,
        id_usuario = p_id_usuario
    WHERE id_mensagens = p_id;

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

CREATE PROCEDURE delete_mensagem (
    IN p_id INT
)
BEGIN
    DELETE FROM tbl_mensagens
    WHERE id_mensagens = p_id;

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;

--chat--
DELIMITER $$

CREATE PROCEDURE inserir_chat (
    IN p_criado_em   TIMESTAMP,
    IN p_remetente   INT,
    IN p_destinatario INT
)
BEGIN
    INSERT INTO tbl_chat (
        criado_em,
        remetente,
        destinatario
    ) VALUES (
        p_criado_em,
        p_remetente,
        p_destinatario
    );

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

CREATE PROCEDURE update_chat (
    IN p_id           INT,
    IN p_criado_em    TIMESTAMP,
    IN p_remetente    INT,
    IN p_destinatario INT
)
BEGIN
    UPDATE tbl_chat
    SET
        criado_em    = p_criado_em,
        remetente    = p_remetente,
        destinatario = p_destinatario
    WHERE id_chat = p_id;

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

CREATE PROCEDURE delete_chat (
    IN p_id INT
)
BEGIN
    DELETE FROM tbl_chat
    WHERE id_chat = p_id;

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;

--EBOOKS--
DELIMITER $$

CREATE PROCEDURE inserir_ebook (
    IN p_titulo          VARCHAR(100),
    IN p_preco           DECIMAL(10,2),
    IN p_descricao       TEXT,
    IN p_link_imagem     VARCHAR(255),
    IN p_link_arquivo_pdf VARCHAR(255),
    IN p_id_usuario      INT
)
BEGIN
    INSERT INTO tbl_ebooks (
        titulo,
        preco,
        descricao,
        link_imagem,
        link_arquivo_pdf,
        id_usuario
    ) VALUES (
        p_titulo,
        p_preco,
        p_descricao,
        p_link_imagem,
        p_link_arquivo_pdf,
        p_id_usuario
    );

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

CREATE PROCEDURE update_ebook (
    IN p_id              INT,
    IN p_titulo          VARCHAR(100),
    IN p_preco           DECIMAL(10,2),
    IN p_descricao       TEXT,
    IN p_link_imagem     VARCHAR(255),
    IN p_link_arquivo_pdf VARCHAR(255),
    IN p_id_usuario      INT
)
BEGIN
    UPDATE tbl_ebooks
    SET
        titulo           = p_titulo,
        preco            = p_preco,
        descricao        = p_descricao,
        link_imagem      = p_link_imagem,
        link_arquivo_pdf = p_link_arquivo_pdf,
        id_usuario       = p_id_usuario
    WHERE id_ebooks = p_id;

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

CREATE PROCEDURE delete_ebook (
    IN p_id INT
)
BEGIN
    DELETE FROM tbl_ebooks
    WHERE id_ebooks = p_id;

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;

--USUARIO_GRUPO N/N--
DELIMITER $$

CREATE PROCEDURE inserir_usuario_grupo (
    IN p_id_usuario INT,
    IN p_id_grupo   INT,
    IN p_entrou_em  TIMESTAMP
)
BEGIN
    INSERT INTO tbl_usuario_grupo (
        id_usuario,
        id_grupo,
        entrou_em
    ) VALUES (
        p_id_usuario,
        p_id_grupo,
        p_entrou_em
    );

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

CREATE PROCEDURE update_usuario_grupo (
    IN p_id          INT,
    IN p_id_usuario  INT,
    IN p_id_grupo    INT,
    IN p_entrou_em   TIMESTAMP
)
BEGIN
    UPDATE tbl_usuario_grupo
    SET
        id_usuario = p_id_usuario,
        id_grupo   = p_id_grupo,
        entrou_em  = p_entrou_em
    WHERE id_usuario_grupo = p_id;

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

CREATE PROCEDURE delete_usuario_grupo (
    IN p_id INT
)
BEGIN
    DELETE FROM tbl_usuario_grupo
    WHERE id_usuario_grupo = p_id;

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;



--EBOOKS_CATEGORIAS N/N--
DELIMITER $$

CREATE PROCEDURE inserir_ebook_categoria (
    IN p_id_categoria INT,
    IN p_id_ebooks    INT
)
BEGIN
    INSERT INTO tbl_ebooks_categoria (
        id_categoria,
        id_ebooks
    ) VALUES (
        p_id_categoria,
        p_id_ebooks
    );

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

CREATE PROCEDURE update_ebook_categoria (
    IN p_id           INT,
    IN p_id_categoria INT,
    IN p_id_ebooks    INT
)
BEGIN
    UPDATE tbl_ebooks_categoria
    SET
        id_categoria = p_id_categoria,
        id_ebooks    = p_id_ebooks
    WHERE id_ebooks_categoria = p_id;

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

CREATE PROCEDURE delete_ebook_categoria (
    IN p_id INT
)
BEGIN
    DELETE FROM tbl_ebooks_categoria
    WHERE id_ebooks_categoria = p_id;

    SELECT ROW_COUNT() AS linhas_afetadas;
END$$

DELIMITER ;



-- Criando uma View --
CREATE VIEW vw_grupo AS
SELECT id_grupo, id_area, id_usuario, nome, limite_membros, descricao, imagem FROM tbl_grupo;

CREATE VIEW vw_categoria AS
SELECT id_categoria, categoria FROM tbl_categoria;

CREATE VIEW vw_area AS
SELECT id_area, area FROM tbl_area;

CREATE VIEW vw_usuario AS
SELECT id_usuario, nome_completo, email, data_nascimento, foto_perfil, descricao, senha, tipo_usuario FROM tbl_usuario;

CREATE VIEW vw_calendario AS 
SELECT id_calendario, id_usuario, nome_evento, data_evento, hora_evento, descricao, link FROM tbl_calendario;

CREATE VIEW vw_chat AS
SELECT id_chat, remetente, destinatario, criado_em FROM tbl_chat;

CREATE VIEW vw_ebooks AS
SELECT id_ebooks, id_usuario, titulo, preco, descricao, link_imagem, link_arquivo_pdf FROM tbl_ebooks;

CREATE VIEW vw_ebooks_categoria AS
SELECT id_ebooks_categoria, id_ebooks, id_categoria FROM tbl_ebooks_categoria;

CREATE VIEW vw_mensagens AS
SELECT id_mensagens, id_chat, id_usuario, conteudo, enviado_em FROM tbl_mensagens;

CREATE VIEW vw_usuario_grupo AS
SELECT id_usuario_grupo, id_usuario, id_grupo, entrou_em FROM tbl_usuario_grupo;

-- Excluir uma View --
drop view vw_grupo;


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
  2,
  4
),
(
  "Fotógrafos Amadores",
  25,
  "Espaço para compartilhar técnicas de fotografia, dicas de edição e experiências no mundo da fotografia.",
  "fotografia.jpg",
  3,
  1
),
(
  "Clube do Xadrez",
  20,
  "Grupo para amantes do xadrez, com torneios semanais e análise de partidas famosas.",
  "xadrez.png",
  1,
  4
),
(
  "Sustentabilidade em Ação",
  30,
  "Comunidade voltada para discutir práticas sustentáveis, reciclagem e preservação ambiental.",
  "sustentabilidade.jpg",
  3,
  4
),
(
  "Gamers Retrô",
  15,
  "Grupo para os apaixonados por consoles clássicos e jogos que marcaram época.",
  "retro_gamer.png",
  2,
  5
);

INSERT INTO tbl_usuario (
    nome_completo,
    email,
    data_nascimento,
    foto_perfil,
    descricao,
    senha,
    tipo_usuario
) VALUES(
'Ana Souza', 
'ana.souza@email.com', 
'1995-03-12', 
'ana.jpg', 
'Professora de matemática apaixonada por tecnologia.', 
'senha123', 
'Profissional'
),
(
'Carlos Lima', 
'carlos.lima@email.com', 
'2000-07-25', 
'carlos.png', 
'Estudante de engenharia de software.', 
'segredo456', 
'Estudante'
),
(
'Mariana Alves', 
'mariana.alves@email.com', 
'1998-11-09', 
NULL, 
'Formada em Letras, busca oportunidades de networking.', 
'minhasenha789', 
'Profissional'
),
(
'João Pedro', 
'joao.pedro@email.com', 
'1992-05-18', 
'joao.jpg', 
'Analista de sistemas com experiência em banco de dados.', 
'senha321', 
'Profissional'
),
(
'Beatriz Fernandes', 
'beatriz.fernandes@email.com', 
'2001-09-30', 
'beatriz.png', 
'Estudante de ciência da computação interessada em IA.', 
'segredo654', 
'Estudante'
);

INSERT INTO tbl_categoria (
categoria
) VALUES (
'Tecnologia'
),
(
'Educação'
),
(
'Ciências'
),
(
'Artes'
),
(
'Saúde'
);

INSERT INTO tbl_area (
area
) VALUES (
'Desenvolvimento Web'
),
(
'Inteligência Artificial'
),
(
'Banco de Dados'
),
(
'Redes de Computadores'
),
(
'Segurança da Informação'
);

INSERT INTO tbl_calendario (
    nome_evento,
    data_evento,
    hora_evento,
    descricao,
    link,
    id_usuario
) VALUES 
(
'Workshop de Inteligência Artificial', 
'2025-10-15', 
'14:00:00', 
'Encontro para discutir aplicações práticas de IA em negócios e startups.', 
'https://evento.com/ia2025',
1
),
(
'Palestra sobre Segurança da Informação', 
'2025-11-05', 
'19:30:00', 
'Palestra voltada para prevenção de ataques cibernéticos e boas práticas.', 
'https://evento.com/seguranca2025',
2
),
(
'Hackathon Universitário', 
'2025-12-01', 
'08:00:00', 
'Competição de programação para estudantes com duração de 48 horas.', 
'https://evento.com/hackathon2025',
3
),
(
'Congresso de Educação e Tecnologia', 
'2026-01-20', 
'09:00:00', 
'Congresso que reúne profissionais da educação e tecnologia para debater tendências.', 
'https://evento.com/congresso2026',
4
),
(
'Encontro de Desenvolvedores Web', 
'2026-02-10', 
'18:00:00', 
'Meetup para troca de experiências em desenvolvimento web e frameworks modernos.', 
'https://evento.com/devweb2026',
5
);

INSERT INTO tbl_chat (
criado_em, 
remetente, 
destinatario
) VALUES (
NOW(), 
1, 
2
),
(
NOW(), 
2, 
3
),
(
NOW(), 
3, 
1
);

INSERT INTO tbl_mensagens (
conteudo, 
enviado_em, 
id_chat, 
id_usuario
) VALUES (
'Olá, tudo bem?', 
NOW(), 
1, 
1
),
(
'Tudo ótimo! E você?', 
NOW(), 
1, 
2
),
(
'Bora marcar a reunião?', 
NOW(), 
2, 
2
),
(
'Sim, estou disponível amanhã.', 
NOW(), 
2, 
3
),
(
'Não esqueça do evento hoje!', 
NOW(), 
3, 
3
);

INSERT INTO tbl_ebooks (
titulo, 
preco, 
descricao, 
link_imagem, 
link_arquivo_pdf, 
id_usuario
) VALUES (
'Introdução a Banco de Dados', 
29.90, 
'Ebook sobre fundamentos de bancos de dados relacionais.', 
'https://img.com/db.png', 
'https://ebooks.com/db.pdf', 
1
),
(
'Segurança da Informação',
39.90, 
'Conceitos e práticas sobre segurança digital.', 
'https://img.com/seguranca.png', 
'https://ebooks.com/seguranca.pdf', 
2),
(
'Machine Learning para Iniciantes', 
49.90, 
'Guia prático sobre aprendizado de máquina.', 
'https://img.com/ml.png', 
'https://ebooks.com/ml.pdf', 
3
);

13:59:59	INSERT INTO tbl_usuario_grupo ( id_usuario,  id_grupo,  entrou_em ) VALUES ( 1,  1, NOW() ), ( 2, 1,  NOW() ), ( 3,  2,  NOW() ), ( 4,  2,  NOW() ), ( 5,  3,  NOW() )	Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`db_journey`.`tbl_usuario_grupo`, CONSTRAINT `fk_usuario_grupo_grupo` FOREIGN KEY (`id_grupo`) REFERENCES `tbl_grupo` (`id_grupo`) ON DELETE CASCADE ON UPDATE CASCADE)	0.0012 sec


INSERT INTO tbl_usuario_grupo (
id_usuario, 
id_grupo, 
entrou_em
) VALUES (
1, 
8,
NOW()
),
(
2,
10, 
NOW()
),
(
3, 
6, 
NOW()
),
(
4, 
7, 
NOW()
),
(
5, 
9, 
NOW()
);

INSERT INTO tbl_ebooks_categoria (
id_categoria, 
id_ebooks
) VALUES (
1, 
1
), 
(
2, 
2
),
(
3, 
3
),
(
1, 
3
); 



select * from vw_grupo;
select * from vw_categoria;
select * from vw_area;
select * from vw_usuario;
select * from vw_calendario;
select * from vw_chat;
select * from vw_mensagens;
select * from vw_ebooks;
select * from vw_usuario_grupo;
select * from vw_ebooks_categoria;