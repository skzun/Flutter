CREATE DATABASE IF NOT EXISTS trufas_db;
USE trufas_db;

CREATE TABLE usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  senha VARCHAR(200) NOT NULL,
  perfil VARCHAR(20) NOT NULL
);

CREATE TABLE configuracoes (
  id INT PRIMARY KEY,
  comissao DECIMAL(5,2) NOT NULL
);

CREATE TABLE producoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  quantidade INT NOT NULL,
  estoque INT NOT NULL,
  valor_unitario DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  comissao DECIMAL(5,2) NOT NULL,
  valor_comissao DECIMAL(10,2) NOT NULL,
  valor_final DECIMAL(10,2) NOT NULL,
  data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE compras (
  id INT AUTO_INCREMENT PRIMARY KEY,
  producao_id INT NOT NULL,
  usuario_id INT NOT NULL,
  quantidade INT NOT NULL,
  valor_unitario DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  comissao DECIMAL(5,2) NOT NULL,
  valor_comissao DECIMAL(10,2) NOT NULL,
  valor_final DECIMAL(10,2) NOT NULL,
  data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO usuarios (nome, email, senha, perfil) VALUES
('Gerente', 'gerente@trufas.com', '$2y$10$bYryGbjCNWDxhfdqcQ73Beam2ySzzpMfVotdAEddnGxQrD2lmCdIi', 'gerente');

INSERT INTO configuracoes (id, comissao) VALUES (1, 10.00);
