CREATE TABLE colaboradores(
id serial primary KEY,
nome VARCHAR(150) NOT NULL,
email VARCHAR(150) NOT NULL,
cpf VARCHAR(11) not null unique,
atividade BOOLEAN not null
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
data_criacao TIMESTAMP DEFAULT current_timestamp,
data_entrega date


)

