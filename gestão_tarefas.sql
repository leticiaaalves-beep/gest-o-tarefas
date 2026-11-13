CREATE TABLE colaboradores(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    atividade BOOLEAN NOT NULL
)


CREATE TABLE categoria(
id serial primary KEY,
nome VARCHAR(150) NOT NULL

)


CREATE TABLE tarefas(
id serial primary KEY,
id_colaboradores int not null,
FOREIGN KEY (id_colaboradores) REFERENCES colaboradores(id),
id_categoria int not null,
foreign key (id_categoria) REFERENCES categoria(id),
titulo VARCHAR(150) NOT NULL,
descricao VARCHAR(200) not null,
prazo_entrega date,
status VARCHAR(30) DEFAULT 'pendente' CHECK(status in ('pendente', 'em andamento', 'concluida')),
data_criacao timestamp DEFAULT current_timestamp

)

CREATE TABLE historico_tarefas(
id serial primary KEY,
id_tarefas int not null,
FOREIGN KEY (id_tarefas) REFERENCES tarefas(id),
data_criacao TIMESTAMP DEFAULT current_timestamp,
data_entrega date


)

INSERT INTO colaboradores (nome, email, cpf, senha, atividade)
VALUES
('Ana', 'ana@gmail.com', '12345678901', 'ana123', TRUE),
('Bruno', 'bruno@gmail.com', '23456789012', 'bruno123', TRUE),
('Carla', 'carla@gmail.com', '34567890123', 'carla123', FALSE);

INSERT INTO categoria (nome)
VALUES
('Desenvolvimento'),
('Documentação'),
('Reunião')


INSERT INTO tarefas (id_colaboradores, id_categoria, titulo, descricao, prazo_entrega, status)
VALUES
(1, 1, 'Criar tela inicial', 'Desenvolver a tela inicial do sistema', '2026-11-20', 'em andamento'),
(2, 2, 'Documentar projeto', 'Criar a documentação do sistema', '2026-11-18', 'pendente'),
(1, 3, 'Reuniao de equipe', 'Organizar as tarefas do projeto', '2026-11-25', 'concluida');

INSERT INTO historico_tarefas (id_tarefas, data_entrega)
VALUES
(1, '2026-11-20'),
(2, '2026-11-18'),
(3, '2026-11-25');

CREATE OR REPLACE FUNCTION fn_trg_validar_tarefa()
RETURNS TRIGGER AS $$
DECLARE
    v_ativo BOOLEAN;
BEGIN

    SELECT atividade INTO v_ativo
    FROM colaboradores
    WHERE id = NEW.id_colaboradores;

    IF v_ativo IS NULL OR NOT v_ativo THEN
        RAISE EXCEPTION
        'Não é possível atribuir tarefas a um colaborador inativo ou inexistente.';
    END IF;

    NEW.data_criacao := CURRENT_TIMESTAMP;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_tarefa
BEFORE INSERT ON tarefas
FOR EACH ROW
EXECUTE FUNCTION fn_trg_validar_tarefa();


CREATE OR REPLACE FUNCTION fn_trg_historico_tarefa()
RETURNS TRIGGER AS $$
BEGIN

    INSERT INTO historico_tarefas (id_tarefas, data_criacao, data_entrega)
    VALUES (NEW.id, NEW.data_criacao, NEW.prazo_entrega);

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_historico_tarefa
AFTER INSERT ON tarefas
FOR EACH ROW
EXECUTE FUNCTION fn_trg_historico_tarefa();


CREATE OR REPLACE FUNCTION fn_buscar_colaboradores(p_termo VARCHAR)
RETURNS TABLE (
    id INT,
    nome VARCHAR,
    email VARCHAR,
    cpf VARCHAR,
    atividade BOOLEAN
) AS $$
BEGIN

    RETURN QUERY
    SELECT
        colaboradores.id,
        colaboradores.nome,
        colaboradores.email,
        colaboradores.cpf,
        colaboradores.atividade
    FROM colaboradores 
    WHERE LOWER(colaboradores.nome) LIKE LOWER('%' || p_termo || '%')
       OR LOWER(colaboradores.email) LIKE LOWER('%' || p_termo || '%');

END;
$$ LANGUAGE plpgsql;


