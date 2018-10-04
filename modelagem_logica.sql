/* MODELAGEM DE CLIENTE */
CREATE DATABASE COMERCIO

USE COMERCIO

CREATE TABLE CLIENTE(
	IDCLIENTE INT PRIMARY KEY AUTO_INCREMENT,
	NOME VARCHAR(30) NOT NULL,
	SEXO ENUM('M','F') NOT NULL,
	EMAIL VARCHAR(50) UNIQUE,
	CPF VARCHAR(15) UNIQUE
);

CREATE TABLE TELEFONE(
	IDTELEFONE INT PRIMARY KEY AUTO_INCREMENT,
	TIPO ENUM('COM','RES','CEL'),
	NUMERO VARCHAR(10),
	ID_CLIENTE INT,
	FOREIGN KEY(ID_CLIENTE) REFERENCES CLIENTE(IDCLIENTE) 
);

CREATE TABLE ENDERECO(
	IDENDERECO INT PRIMARY KEY AUTO_INCREMENT,
	RUA VARCHAR(30) NOT NULL,
	BAIRRO VARCHAR(30) NOT NULL,
	CIDADE VARCHAR(30) NOT NULL,
	ESTADO CHAR(2) NOT NULL,
	ID_CLIENTE INT UNIQUE,
	FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTE(IDCLIENTE)	
);

/* CHAVE ESTRANGEIRA - FOREIGN KEY (FK) */

/* RELACIONAMENTOS 1 X 1 - A CHAVE ESTRANGEIRA FICA NA TABELA MAIS FRACA */

/* RELACIONAMENTOS 1 X N - A CHAVE PRIMARIA FICA EM N */

/* JUNCAO */
SELECT NOME, SEXO, BAIRRO, CIDADE, NOW() AS "DATA"
FROM CLIENTE, ENDERECO
WHERE IDCLIENTE = ID_CLIENTE /* SELECAO - INCORRETO */
AND BAIRRO = 'CENTRO';

/* JOIN */
SELECT NOME, SEXO, BAIRRO, CIDADE /* PROJECAO */
FROM CLIENTE
INNER JOIN ENDERECO /* JUNCAO */
ON IDCLIENTE = ID_CLIENTE 
WHERE BAIRRO = 'CENTRO' /* SELECAO */

/* TRABALHANDO COM CLAUSULA AMBIGUA */
/* UTILIZANDO PONTEIROS */
SELECT CLIENTE.NOME, CLIENTE.SEXO, ENDERECO.BAIRRO, ENDERECO.CIDADE, TELEFONE.TIPO, TELEFONE.NUMERO
FROM CLIENTE
INNER JOIN ENDERECO
ON CLIENTE.IDCLIENTE = ENDERECO.ID_CLIENTE
INNER JOIN TELEFONE
ON CLIENTE.IDCLIENTE = ENDERECO.ID_CLIENTE

/* CRIANDO APELIDOS */
SELECT C.NOME, C.SEXO, 
E.BAIRRO, E.CIDADE, 
T.TIPO, T.NUMERO /* PROJECAO */
FROM CLIENTE C
INNER JOIN ENDERECO E /* JUNCAO*/
ON C.IDCLIENTE = E.ID_CLIENTE
INNER JOIN TELEFONE T /* JUNCAO */
ON C.IDCLIENTE = E.IDCLIENTE
WHERE SEXO = 'M', /* SELECAO */

/* IFNUL */
SELECT C.NOME AS "CLIENTE", 
	   IFNULL(C.EMAIL,'SEM EMAIL') AS "EMAIL", 
	   T.NUMERO AS "CELULAR"
FROM CLIENTE C
INNER JOIN TELEFONE T
ON C.IDCLIENTE = T.ID_CLIENTE
INNER JOIN ENDERECO E
ON C.IDCLIENTE = E.ID_CLIENTE
WHERE TIPO = 'CEL' AND ESTADO = 'RJ';

/* VIEW OU VISOES */
CREATE VIEW V_RELATORIO AS
SELECT C.NOME AS "CLIENTE", 
	   IFNULL(C.EMAIL,'SEM EMAIL') AS "EMAIL", 
	   T.NUMERO AS "CELULAR"
FROM CLIENTE C
INNER JOIN TELEFONE T
ON C.IDCLIENTE = T.ID_CLIENTE
INNER JOIN ENDERECO E
ON C.IDCLIENTE = E.ID_CLIENTE
WHERE TIPO = 'CEL' AND ESTADO = 'RJ';

SELECT * FROM V_RELATORIO;

/* QUERY EM CIMA DA VIEW */
SELECT * FROM V_RELATORIO
WHERE SEXO = 'F';

/* ID CELIA = 6 - UPDATE NO EMAIL */
UPDATE CLIENTE
SET EMAIL = 'CELIA@GMAIL.COM'
WHERE IDCLIENTE = 6;

DROP VIEW V_RELATORIO;

/* PROJECAO NA VIEW */
SELECT NOME 
FROM V_RELATORIO;

/* ORDER BY */
SELECT NOME, SEXO, CPF, CIDADE
FROM CLIENTE 
INNER JOIN ENDERECO
ON IDCLIENTE = ID_CLIENTE
ORDER BY NOME, CPF ASC;

/* ORDENANDO PELO NUMERO DA COLUNA */
SELECT NOME, SEXO, CPF, CIDADE
FROM CLIENTE 
INNER JOIN ENDERECO
ON IDCLIENTE = ID_CLIENTE
ORDER BY 4;

/* DELIMITADOR */
DELIMITER $

/* CONSULTANDO DEMILITADOR*/
STATUS

/* CRIANDO UMA PROCEDURE */
CREATE PROCEDURE CONTA()
BEGIN
	SELECT 10 + 10 AS "CONTA";
END
$

/* CHAMANDO A PROCEDURE */
CALL CONTA()$

/* AGAPAGANDO PROCEDURE*/
DROP PROCEDURE CONTA;

/* PROCEDURE COM PARAMETRO */
CREATE PROCEDURE CONTA(N1 INT, N2 INT)
BEGIN
	SELECT N1 + N2 AS "CONTA";
END
$

/* EXEMPLO PROCEDURE */
CREATE TABLE CURSOS(
	IDCURSO INT PRIMARY KEY AUTO_INCREMENT,
	NOME VARCHAR(30) NOT NULL,
	HORAS INT(3) NOT NULL,
	VALOR FLOAT(18,2) NOT NULL
);

/* SEMPRE MUDAR DELIMITADOR */
DELIMITER $

CREATE PROCEDURE CAD_CURSO(P_NOME VARCHAR(30), P_HORAS INT(3), P_PRECO FLOAT(10,2))
BEGIN
	INSERT INTO CURSOS(NULL, P_NOME, P_HORAS, P_PRECO);
END
$

DELIMITER ;

CALL CAD_CURSO('BI SQL SERVER', 35, 200.00);

CREATE PROCEDURE SEL_CURSO()
BEGIN
	SELECT IDCURSO, NOME, HORAS, VALOR
	FROM CURSOS;
END
$

/* FUNCOES DE AGREGACAO NUMERICAS */
/* TRUNCATE */
CREATE TABLE VENDEDORES (
	IDVENDEDOR INT PRIMARY KEY AUTO_INCREMENT,
	NOME VARCHAR(30),
	SEXO CHAR(1),
	JANEIRO FLOAT(10,2),
	FEVEREIRO FLOAT(10,2),
	MARCO FLOAT(10,2)
);

SELECT MAX(JANEIRO) AS MAX_JAN,
	   MIN(JANEIRO) AS MIN_JAV,
	   TRUNCATE(AVG(JANEIRO,2)) AS MEDIA_JAN
FROM VENDEDORES;
		
/* SUM */
SELECT SEXO, SUM(MARCO) AS TOTAL_MARCO
FROM VENDEDORES
GROUP BY SEXO;

/* SUBQUERIES*/

/* VENDEDOR QUE VENDEU MENOS EM MARCO E SEU NOME */
/* NOME E VALOR DE QUEM VENDEU MAIS EM MARCO */
/* QUEM VENDEU MAIS QUE O VALOR MEDIO DE FEV */

SELECT NOME, MARCO
FROM VENDEDORES
WHERE MARCO = (SELECT MIN(MARCO) FROM VENDEDORES);

SELECT NOME, MARCO
FROM VENDEDORES
WHERE MARCO = (SELECT MAX(MARCO) FROM VENDEDORES);

SELECT NOME, MARCO
FROM VENDEDORES
WHERE FEVEREIRO > (SELECT AVG(FEVEREIRO) FROM VENDEDORES);

/* OPERANDO EM LINHA */
SELECT NOME,
	   JANEIRO,
	   FEVEREIRO,
	   MARCO,
	   (JANEIRO+FEVEREIRO+MARCO) AS "TOTAL",
	   (JANEIRO+FEVEREIRO+MARCO) * .25 AS "DESCONTO",
	   TRUNCATE((JANEIRO+FEVEREIRO+MARCO)/3,2) AS "MEDIA"
	   FROM VENDEDORES;

/* ALTERANDO TABELAS */

CREATE TABLE TABELA(
	COLUNA1 VARCHAR(30);
	COLUNA2 VARCHAR(30);
	COLUNA3 VARCHAR(30);
);
/* ADICIONANDO PK */
ALTER TABLE TABELA
ADD PRIMARY KEY(COLUNA1);
/* ADICIONANDO COLUNA SEM POSICAO - ULTIMA POSICAO */
ALTER TABLE TABELA
ADD COLUNA VARCHAR(30);

/* CONFIRMANDO */
DESC TABELA;

/* ADICIONANDO COLUNA COM POSICAO */
ALTER TABLE TABELA
ADD COLUMN COLUNA4 VARCHAR(30) NOT NULL UNIQUE
AFTER COLUNA3;

/* MODIFICANDO O TIPO DE UM CAMPO */
ALTER TABLE TABELA MODIFY DATE NOT NULL;
-- SE HOUVER DADO ARMAZENADO, OS DADOS DEVEM SER COMPATIVEIS
-- COM O NOVO TIPO DO CAMPO ALTERADO

/* RENOMEADO TABELA */
ALTER TABLE TABELA
RENAME PESSOA;

CREATE TABLE EQUIPE(
	IDEQUIPE INT PRIMARY KEY AUTO_INCREMENT,
	EQUIPE VARCHAR(30),
	ID_PESSOA VARCHAR(30)
);

/* ADICIONANDO FOREIGN KEY */
ALTER TABLE EQUIPE
ADD FOREIGN KEY(ID_PESSOA)
REFERENCES PESSOA(COLUNA1); 

/* VERIFICANDO AS CHAVES */
SHOW CREATE TABLE TIME;
 
 
 /* DICIONARIO DE DADOS */
 
 SHOW DATABASES;
 
 USE INFORMATION_SCHEMA;
 
 STATUS
 
 SHOW TABLES;
 
 DESC TABLE_CONSTRAINTS;
 
 SELECT CONSTRAINT_SCHEMA AS "BANCO",
		TABLE_NAME AS "TABELA",
		CONSTRAINT_NAME AS "NOME REGRA",
		CONSTRAINT_TYPE AS "TIPO",
FROM INFORMATION_SCHEMA
WHERE CONSTRAINT_SCHEMA = "COMERCIO";

/* APAGANDO CONSTRAINTS */
ALTER TABLE TELEFONE
DROP CONSTRAINT FK_CLIENTE_TELEFONE;
-- NECESSARIO ESTAR NO BANCO CUJA CONSTRAINT PERTENCE (USE) 

CREATE TRIGGER NOME
BEFORE/AFTER INSERT/DELETE/UPDATE ON TABELA
FOR EACH ROW (PARA CADA LINHA)
BEGIN
	QUALQUER COMANDO SQL
END 
		