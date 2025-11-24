-- ==========================================
-- 1. LIMPEZA (DROP)
-- Remove as tabelas antigas para recriar do zero.
-- ==========================================

DROP TABLE emprestimo;
DROP TABLE usuario;
DROP TABLE livro;

-- ==========================================
-- 2. CRIAÇÃO DA ESTRUTURA (DDL)
-- ==========================================

CREATE TABLE usuario (
    id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    matricula VARCHAR(50) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) DEFAULT 'aluno',
    CONSTRAINT pk_usuario PRIMARY KEY (id)
);

CREATE TABLE livro (
    id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    editora VARCHAR(100),
    isbn VARCHAR(20),
    quantidade_total INTEGER NOT NULL DEFAULT 1,
    quantidade_disponivel INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT pk_livro PRIMARY KEY (id),
    CONSTRAINT ck_qtd_positiva CHECK (quantidade_disponivel >= 0)
);

CREATE TABLE emprestimo (
    id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
    usuario_id INTEGER NOT NULL,
    livro_id INTEGER NOT NULL,
    data_emprestimo DATE NOT NULL,
    data_prevista_devolucao DATE NOT NULL,
    data_devolucao_real DATE,
    multa DECIMAL(10, 2) DEFAULT 0.0,
    CONSTRAINT pk_emprestimo PRIMARY KEY (id),
    CONSTRAINT fk_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id),
    CONSTRAINT fk_livro FOREIGN KEY (livro_id) REFERENCES livro(id)
);

-- ==========================================
-- 3. INSERÇÃO DE DADOS (DML - DATAS FIXAS)
-- ==========================================

-- --- USUÁRIOS ---
INSERT INTO usuario (nome, email, matricula, senha, tipo) 
VALUES ('Administrador Sistema', 'admin@teste.com', 'ADM001', 'admin', 'admin');

INSERT INTO usuario (nome, email, matricula, senha, tipo) 
VALUES ('Sandro Estudante', 'sandro@teste.com', '2025001', '123', 'aluno');

INSERT INTO usuario (nome, email, matricula, senha, tipo) 
VALUES ('Maria Silva', 'maria@teste.com', '2025002', '123', 'aluno');

INSERT INTO usuario (nome, email, matricula, senha, tipo) 
VALUES ('João Caloteiro', 'caloteiro@teste.com', 'BAD001', '123', 'aluno');


-- --- LIVROS ---
INSERT INTO livro (titulo, autor, editora, isbn, quantidade_total, quantidade_disponivel) 
VALUES ('Java: Como Programar', 'Paul Deitel', 'Pearson', '978-8543004792', 10, 10);

INSERT INTO livro (titulo, autor, editora, isbn, quantidade_total, quantidade_disponivel) 
VALUES ('Clean Code', 'Robert C. Martin', 'Alta Books', '978-8576082675', 5, 4);

INSERT INTO livro (titulo, autor, editora, isbn, quantidade_total, quantidade_disponivel) 
VALUES ('Engenharia de Software Moderna', 'Marco Tulio Valente', 'Independente', '978-6500019506', 1, 1);

INSERT INTO livro (titulo, autor, editora, isbn, quantidade_total, quantidade_disponivel) 
VALUES ('O Senhor dos Anéis', 'J.R.R. Tolkien', 'HarperCollins', '978-8595084742', 3, 0);

INSERT INTO livro (titulo, autor, editora, isbn, quantidade_total, quantidade_disponivel) 
VALUES ('The Phoenix Project', 'Gene Kim', 'IT Revolution', '978-0988262591', 4, 4);

INSERT INTO livro (titulo, autor, editora, isbn, quantidade_total, quantidade_disponivel) 
VALUES ('Compiladores: Princípios e Práticas', 'Aho, Lam, Sethi', 'Pearson', '978-8588639249', 2, 1);


-- --- EMPRÉSTIMOS (Lógica Simplificada) ---

-- CENÁRIO 1: Empréstimo NO PRAZO
-- Estratégia: Data prevista no futuro distante (Ano 2030)
INSERT INTO emprestimo (usuario_id, livro_id, data_emprestimo, data_prevista_devolucao, data_devolucao_real, multa) 
VALUES (
    (SELECT id FROM usuario WHERE email = 'sandro@teste.com'), 
    (SELECT id FROM livro WHERE titulo = 'Java: Como Programar'), 
    CURRENT_DATE,   -- Pegou hoje
    '2030-12-31',   -- Devolve só em 2030 (Nunca ficará atrasado)
    NULL, 
    0.0
);

-- CENÁRIO 2: Empréstimo ATRASADO
-- Estratégia: Datas fixas no passado recente (ex: Início de 2024)
INSERT INTO emprestimo (usuario_id, livro_id, data_emprestimo, data_prevista_devolucao, data_devolucao_real, multa) 
VALUES (
    (SELECT id FROM usuario WHERE email = 'maria@teste.com'), 
    (SELECT id FROM livro WHERE titulo = 'Clean Code'), 
    '2024-02-01',   -- Pegou em Fev/2024
    '2024-02-08',   -- Deveria devolver em Fev/2024 (Já passou, gera multa)
    NULL, 
    0.0
);

-- CENÁRIO 3: Empréstimo DEVOLVIDO
-- Estratégia: Tudo no passado, com data real preenchida
INSERT INTO emprestimo (usuario_id, livro_id, data_emprestimo, data_prevista_devolucao, data_devolucao_real, multa) 
VALUES (
    (SELECT id FROM usuario WHERE email = 'sandro@teste.com'), 
    (SELECT id FROM livro WHERE titulo = 'The Phoenix Project'), 
    '2024-01-01', 
    '2024-01-08', 
    '2024-01-07', -- Devolveu antes do prazo (sem multa)
    0.0
);

-- CENÁRIO 4: MULTA ALTA (MUITO ATRASADO)
-- Estratégia: Data bem antiga (Ano 2020)
INSERT INTO emprestimo (usuario_id, livro_id, data_emprestimo, data_prevista_devolucao, data_devolucao_real, multa) 
VALUES (
    (SELECT id FROM usuario WHERE email = 'caloteiro@teste.com'), 
    (SELECT id FROM livro WHERE titulo = 'Compiladores: Princípios e Práticas'), 
    '2020-01-01', 
    '2020-01-08', -- Venceu em 2020 (Muitos anos de multa acumulada)
    NULL, 
    0.0
);