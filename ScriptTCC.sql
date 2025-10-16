drop database db_journey;
create database db_journey;
use db_journey;

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
CREATE TABLE tbl_categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    categoria VARCHAR(100) NOT NULL
);
CREATE TABLE tbl_area (
    id_area INT AUTO_INCREMENT PRIMARY KEY,
    area VARCHAR(100) NOT NULL
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
CREATE TABLE tbl_ebooks_categoria (
    id_ebooks_categoria INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    id_ebooks INT NOT NULL,
	CONSTRAINT fk_ebooks_categoria_categoria FOREIGN KEY (id_categoria) REFERENCES tbl_categoria (id_categoria) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ebooks_categoria_ebooks FOREIGN KEY (id_ebooks) REFERENCES tbl_ebooks (id_ebooks) ON DELETE CASCADE ON UPDATE CASCADE
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
CREATE TABLE tbl_usuario_grupo (
    id_usuario_grupo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_grupo INT NOT NULL,
    entrou_em TIMESTAMP NOT NULL,
	CONSTRAINT fk_usuario_grupo_usuario FOREIGN KEY (id_usuario) REFERENCES tbl_usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_usuario_grupo_grupo FOREIGN KEY (id_grupo) REFERENCES tbl_grupo (id_grupo) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE tbl_chat ( 
	id_chat INT AUTO_INCREMENT PRIMARY KEY, 
	tipo ENUM('publico','privado') NOT NULL, 
	id_grupo INT DEFAULT NULL,
	remetente INT DEFAULT NULL, 
	destinatario INT DEFAULT NULL, 
	criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
	CONSTRAINT fk_chat_grupo FOREIGN KEY (id_grupo) REFERENCES tbl_grupo(id_grupo) ON DELETE CASCADE, 
	CONSTRAINT fk_chat_remetente FOREIGN KEY (remetente) REFERENCES tbl_usuario(id_usuario) ON DELETE CASCADE,
	CONSTRAINT fk_chat_destinatario FOREIGN KEY (destinatario) REFERENCES tbl_usuario(id_usuario) ON DELETE CASCADE 
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
CREATE TABLE tbl_calendario (
	id_calendario INT AUTO_INCREMENT PRIMARY KEY,
    nome_evento VARCHAR(100) NOT NULL,
    data_evento DATE NOT NULL,
    descricao TEXT NOT NULL,
    link VARCHAR(500) NOT NULL,
    id_grupo INT NOT NULL,
    CONSTRAINT fk_calendario_evento_grupo FOREIGN KEY (id_grupo) REFERENCES tbl_grupo(id_grupo)
);
CREATE TABLE tbl_calendario_pessoal (
	id_calendario_pesoal INT AUTO_INCREMENT PRIMARY KEY,
	id_calendario INT NOT NULL,
	id_usuario INT NOT NULL,
	CONSTRAINT fk_calendario_pessoal_calendario FOREIGN KEY (id_calendario) REFERENCES tbl_calendario(id_calendario),
	CONSTRAINT fk_calendario_pessoal_usuario FOREIGN KEY (id_usuario) REFERENCES tbl_usuario(id_usuario)
);


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
    IN p_descricao       TEXT,
    IN p_link            VARCHAR(500),
    IN p_id_usuario   	 INT
)
BEGIN
    INSERT INTO tbl_calendario (
        nome_evento,
        data_evento,
        descricao,
        link,
        id_usuario
    ) VALUES (
        p_nome_evento,
        p_data_evento,
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
    IN p_descricao      TEXT,
    IN p_link          	VARCHAR(500),
    IN p_id_usuario  	INT 
)
BEGIN
    UPDATE tbl_calendario
    SET
        nome_evento     = p_nome_evento,
        data_evento 	= p_data_evento,
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
SELECT id_calendario, id_grupo, nome_evento, data_evento, descricao, link FROM tbl_calendario;

CREATE VIEW vw_chat AS
SELECT id_chat, id_grupo, tipo, remetente, destinatario, criado_em FROM tbl_chat;

CREATE VIEW vw_ebooks AS
SELECT id_ebooks, id_usuario, titulo, preco, descricao, link_imagem, link_arquivo_pdf FROM tbl_ebooks;

CREATE VIEW vw_ebooks_categoria AS
SELECT id_ebooks_categoria, id_ebooks, id_categoria FROM tbl_ebooks_categoria;

CREATE VIEW vw_mensagens AS
SELECT id_mensagens, id_chat, id_usuario, conteudo, enviado_em FROM tbl_mensagens;

CREATE VIEW vw_usuario_grupo AS
SELECT id_usuario_grupo, id_usuario, id_grupo, entrou_em FROM tbl_usuario_grupo;



-- Trigger para limitar máximo de participantes em grupos <= 30 --
DELIMITER $$

CREATE TRIGGER trg_limite_grupo
BEFORE INSERT ON tbl_usuario_grupo
FOR EACH ROW
BEGIN
    DECLARE qtd_membros INT;

    -- Conta quantos membros o grupo já tem
    SELECT COUNT(*) INTO qtd_membros
    FROM tbl_usuario_grupo
    WHERE id_grupo = NEW.id_grupo;

    -- Se já tiver 30 ou mais, bloqueia a inserção
    IF qtd_membros >= 30 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este grupo já atingiu o limite máximo de 30 participantes.';
    END IF;
END$$

DELIMITER ;

SHOW TRIGGERS;

SELECT COUNT(*) FROM tbl_usuario_grupo WHERE id_grupo = 8;


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
),
('Lucas Martins', 'lucas.martins@email.com', '1997-08-10', 'lucas.jpg', 'Desenvolvedor front-end entusiasta por design responsivo.', 'senha001', 'Profissional'),
('Fernanda Ribeiro', 'fernanda.ribeiro@email.com', '1999-02-21', 'fernanda.png', 'Estudante de análise de sistemas buscando experiência prática.', 'senha002', 'Estudante'),
('Rafael Costa', 'rafael.costa@email.com', '1993-06-14', 'rafael.jpg', 'Administrador de redes com foco em segurança digital.', 'senha003', 'Profissional'),
('Juliana Silva', 'juliana.silva@email.com', '2002-01-05', 'juliana.png', 'Estudante de TI e apaixonada por inovação.', 'senha004', 'Estudante'),
('Pedro Henrique', 'pedro.henrique@email.com', '1994-09-12', 'pedro.jpg', 'Engenheiro de software com foco em backend.', 'senha005', 'Profissional'),
('Camila Rocha', 'camila.rocha@email.com', '2000-04-27', 'camila.png', 'Estudante de design gráfico e UX.', 'senha006', 'Estudante'),
('Bruno Almeida', 'bruno.almeida@email.com', '1991-12-03', 'bruno.jpg', 'Gestor de projetos com experiência em metodologias ágeis.', 'senha007', 'Profissional'),
('Patrícia Gomes', 'patricia.gomes@email.com', '1998-10-19', 'patricia.png', 'Estudante de administração e entusiasta de startups.', 'senha008', 'Estudante'),
('Gustavo Ferreira', 'gustavo.ferreira@email.com', '1995-05-11', 'gustavo.jpg', 'Analista de sistemas e mentor de programação.', 'senha009', 'Profissional'),
('Larissa Carvalho', 'larissa.carvalho@email.com', '2001-08-29', 'larissa.png', 'Estudante de psicologia com interesse em tecnologia educacional.', 'senha010', 'Estudante'),
('Rodrigo Santos', 'rodrigo.santos@email.com', '1990-03-02', 'rodrigo.jpg', 'Desenvolvedor full stack apaixonado por Node.js.', 'senha011', 'Profissional'),
('Vanessa Oliveira', 'vanessa.oliveira@email.com', '1999-06-07', 'vanessa.png', 'Estudante de ciência da computação e curiosa por IA.', 'senha012', 'Estudante'),
('Felipe Nogueira', 'felipe.nogueira@email.com', '1996-07-18', 'felipe.jpg', 'Especialista em banco de dados e arquitetura de sistemas.', 'senha013', 'Profissional'),
('Aline Teixeira', 'aline.teixeira@email.com', '2000-11-25', 'aline.png', 'Estudante de engenharia elétrica.', 'senha014', 'Estudante'),
('Tiago Moreira', 'tiago.moreira@email.com', '1994-01-09', 'tiago.jpg', 'Programador e instrutor de cursos online.', 'senha015', 'Profissional'),
('Isabela Castro', 'isabela.castro@email.com', '1998-09-14', 'isabela.png', 'Estudante de marketing digital e design.', 'senha016', 'Estudante'),
('Marcelo Barbosa', 'marcelo.barbosa@email.com', '1992-10-23', 'marcelo.jpg', 'Consultor de TI especializado em cloud.', 'senha017', 'Profissional'),
('Carolina Pires', 'carolina.pires@email.com', '2001-02-17', 'carolina.png', 'Estudante de engenharia ambiental.', 'senha018', 'Estudante'),
('Eduardo Tavares', 'eduardo.tavares@email.com', '1995-12-28', 'eduardo.jpg', 'Arquiteto de software com foco em microsserviços.', 'senha019', 'Profissional'),
('Sofia Mendes', 'sofia.mendes@email.com', '1999-04-22', 'sofia.png', 'Estudante de ciência da computação apaixonada por robótica.', 'senha020', 'Estudante'),
('André Carvalho', 'andre.carvalho@email.com', '1993-07-30', 'andre.jpg', 'Engenheiro de dados com experiência em big data.', 'senha021', 'Profissional'),
('Bruna Lopes', 'bruna.lopes@email.com', '2002-05-16', 'bruna.png', 'Estudante de pedagogia e amante de novas tecnologias.', 'senha022', 'Estudante'),
('Diego Araújo', 'diego.araujo@email.com', '1996-03-11', 'diego.jpg', 'Desenvolvedor backend especializado em APIs REST.', 'senha023', 'Profissional'),
('Letícia Farias', 'leticia.farias@email.com', '2000-09-09', 'leticia.png', 'Estudante de moda interessada em tecnologia têxtil.', 'senha024', 'Estudante'),
('Renato Borges', 'renato.borges@email.com', '1991-06-04', 'renato.jpg', 'Analista de infraestrutura e redes.', 'senha025', 'Profissional'),
('Marina Duarte', 'marina.duarte@email.com', '2003-02-14', 'marina.png', 'Estudante de biologia curiosa por bioinformática.', 'senha026', 'Estudante'),
('Ricardo Pinto', 'ricardo.pinto@email.com', '1994-08-02', 'ricardo.jpg', 'Programador mobile com experiência em Flutter.', 'senha027', 'Profissional'),
('Gabriela Moura', 'gabriela.moura@email.com', '1998-11-26', 'gabriela.png', 'Estudante de jornalismo interessada em tecnologia.', 'senha028', 'Estudante'),
('Vitor Almeida', 'vitor.almeida@email.com', '1997-01-08', 'vitor.jpg', 'Desenvolvedor DevOps focado em automação.', 'senha029', 'Profissional'),
('Paula Rezende', 'paula.rezende@email.com', '1999-10-05', 'paula.png', 'Estudante de engenharia civil e inovação.', 'senha030', 'Estudante');


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

INSERT INTO tbl_usuario_grupo (
  id_usuario, 
  id_grupo, 
  entrou_em
) VALUES
(1, 4, NOW()),
(2, 5, NOW()),
(3, 1, NOW()),
(4, 2, NOW()),
(5, 3, NOW()),
(6, 4, NOW()),
(7, 5, NOW()),
(8, 1, NOW()),
(9, 2, NOW()),
(10, 3, NOW()),
(11, 4, NOW()),
(12, 5, NOW()),
(13, 1, NOW()),
(14, 2, NOW()),
(15, 3, NOW()),
(16, 4, NOW()),
(17, 5, NOW()),
(18, 1, NOW()),
(19, 2, NOW()),
(20, 3, NOW()),
(21, 4, NOW()),
(22, 5, NOW()),
(23, 1, NOW()),
(24, 2, NOW()),
(25, 3, NOW()),
(26, 4, NOW()),
(27, 5, NOW()),
(28, 1, NOW()),
(29, 2, NOW()),
(30, 3, NOW()),
(2, 4, NOW()),
(3, 4, NOW()),
(4, 4, NOW()),
(5, 4, NOW()),
(7, 4, NOW()),
(8, 4, NOW()),
(9, 4, NOW()),
(10, 4, NOW()),
(12, 4, NOW()),
(13, 4, NOW()),
(14, 4, NOW()),
(15, 3, NOW()),
(17, 4, NOW()),
(18, 4, NOW()),
(19, 4, NOW()),
(20, 4, NOW()),
(22, 4, NOW()),
(23, 4, NOW()),
(24, 4, NOW()),
(25, 4, NOW()),
(27, 4, NOW()),
(28, 4, NOW());




INSERT INTO tbl_chat (
	tipo,
	id_grupo, 
	remetente, 
	destinatario
) VALUES
-- Chat público (grupo 1)
('publico', 1, NULL, NULL),

-- Chat público (grupo 2)
('publico', 2, NULL, NULL),

-- Chat privado entre usuário 3 e 7
('privado', NULL, 3, 7),

-- Chat privado entre usuário 5 e 9
('privado', NULL, 5, 9),

-- Chat privado entre usuário 2 e 10
('privado', NULL, 2, 10);


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


INSERT INTO tbl_calendario (
    nome_evento,
    data_evento,
    descricao,
    link,
    id_grupo
) VALUES 
(
'Workshop de Inteligência Artificial', 
'2025-10-15',
'Encontro para discutir aplicações práticas de IA em negócios e startups.', 
'https://evento.com/ia2025',
1
),
(
'Palestra sobre Segurança da Informação', 
'2025-11-05', 
'Palestra voltada para prevenção de ataques cibernéticos e boas práticas.', 
'https://evento.com/seguranca2025',
2
),
(
'Hackathon Universitário', 
'2025-12-01',  
'Competição de programação para estudantes com duração de 48 horas.', 
'https://evento.com/hackathon2025',
3
),
(
'Congresso de Educação e Tecnologia', 
'2026-01-20', 
'Congresso que reúne profissionais da educação e tecnologia para debater tendências.', 
'https://evento.com/congresso2026',
4
),

(
'Encontro de Desenvolvedores Web', 
'2026-02-10', 
'Meetup para troca de experiências em desenvolvimento web e frameworks modernos.', 
'https://evento.com/devweb2026',
5
);




-- Inserir um novo participante acima do 30 *TEM QUE DAR ERRO*--
INSERT INTO tbl_usuario_grupo (
id_usuario, 
id_grupo,
entrou_em
) VALUES (
34, 
4,
NOW()
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
