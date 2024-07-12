-- Exercício 1

-- Preparação da base

/*
-- Criei uma nova coluna chamada "Data_Avaliacao_Julianday" para ter uma data no formato padrão para a tabela Notas, o que utilizei em mais de um dos exercícios.
-- Comentei todo o trecho para que novas alterações na tabela não fossem feitas por acaso.

ALTER TABLE Notas
ADD COLUMN Data_Avaliacao_Julianday DATE 
;

UPDATE Notas
SET Data_Avaliacao_Julianday = 

(SUBSTR(Data_Avaliacao, -4)) ||"-"||
(TRIM(("0" || SUBSTR(Data_Avaliacao, 1, INSTR(Data_Avaliacao,"/")-1)), "/")) ||"-"||
(CASE
    WHEN LENGTH(TRIM(("0" || SUBSTR(Data_Avaliacao, INSTR(Data_Avaliacao,"/") +1, INSTR(Data_Avaliacao,"/"))), "/")) = 3
        THEN SUBSTR(Data_Avaliacao, INSTR(Data_Avaliacao,"/") +1, INSTR(Data_Avaliacao,"/"))
    ELSE TRIM(("0" || SUBSTR(Data_Avaliacao, INSTR(Data_Avaliacao,"/") +1, INSTR(Data_Avaliacao,"/"))), "/")
END)
*/

-- 1.Selecione os primeiros 5 registros da tabela clientes (Alunos), ordenando-os pelo nome em ordem crescente.

SELECT DISTINCT *
FROM Alunos
ORDER BY Nome_Aluno
LIMIT 5
;

-- 2.Encontre todos os produtos na tabela produtos (Disciplinas) que não têm uma descrição associada (suponha que a coluna de descrição possa ser nula).

SELECT 
    Nome_Disciplina
    ,Descricao
FROM Disciplinas
WHERE (Descricao IS NULL OR Descricao = "")
;

-- 3.Liste os funcionários (Professores) cujo nome começa com 'A' e termina com 's' na tabela funcionarios.

SELECT 
    Nome_Professor
FROM Professores
WHERE TRUE
    AND SUBSTR(Nome_Professor, 1, 1) = "A"
    AND SUBSTR(Nome_Professor, -1, INSTR(Nome_Professor," ") -1) = "s"
;

-- 4.Exiba o departamento (disciplina) e a média salarial dos funcionários (média de notas dos alunos nas disciplinas) em cada departamento na tabela funcionarios, agrupando por departamento, apenas para os departamentos cuja média salarial é superior a $5000 (5,0).

SELECT 
    a.Nome_Disciplina
    ,b.ID_Disciplina
    ,AVG(b.Nota) AS Media_Notas
FROM Notas b
    LEFT JOIN Disciplinas a
        ON b.ID_Disciplina = a.ID_Disciplina
GROUP BY b.ID_Disciplina, a.Nome_Disciplina
HAVING Media_Notas > 5
;

-- 5.Selecione todos os clientes da tabela clientes (alunos) e concatene o primeiro e o último nome, além de calcular o comprimento total do nome completo.

SELECT 
    SUBSTR(Nome_Aluno, 1, INSTR(Nome_Aluno," ")) AS Primeiro_Nome
    ,SUBSTR(Nome_Aluno, INSTR(Nome_Aluno," ") +1) AS Segundo_Nome
    ,LENGTH(REPLACE(Nome_Aluno, " ", "")) AS Comprimento_Nome
FROM Alunos
;

-- 6.Para cada venda (nota) na tabela vendas, exiba o ID da venda, a data da venda e a diferença em dias entre a data da venda e a data atual.

SELECT 
    ID_Nota
    ,Data_Avaliacao
    ,Data_Avaliacao_Julianday
    ,CURRENT_DATE AS Data_Atual
    ,CAST(JULIANDAY(CURRENT_DATE) - JULIANDAY(Data_Avaliacao_Julianday) AS INTEGER) AS Dias_Decorridos
FROM Notas
;

-- 7.Selecione todos os itens da tabela pedidos (notas) e arredonde o preço total para o número inteiro mais próximo.

SELECT
    b.Data_Avaliacao
    ,a.Nome_Disciplina
    ,ROUND(b.Nota, 0) AS Nota
FROM Notas b
    LEFT JOIN Disciplinas a
        ON b.ID_Disciplina = a.ID_Disciplina
GROUP BY b.Data_Avaliacao, a.Nome_Disciplina, b.Nota
ORDER BY b.Data_Avaliacao DESC, Nota DESC

-- 8.Converta a coluna data_string da tabela eventos (avaliações), que está em formato de texto (YYYY-MM-DD), para o tipo de data e selecione todos os eventos após '2023-01-01' ('2023-08-01').

WITH
Base AS(
    SELECT
        a.Nome_Disciplina
        ,(
        (SUBSTR(Data_Avaliacao, -4)) ||"-"||
        (TRIM(("0" || SUBSTR(Data_Avaliacao, 1, INSTR(Data_Avaliacao,"/")-1)), "/")) ||"-"||
        (CASE
            WHEN LENGTH(TRIM(("0" || SUBSTR(Data_Avaliacao, INSTR(Data_Avaliacao,"/") +1, INSTR(Data_Avaliacao,"/"))), "/")) = 3
                THEN SUBSTR(Data_Avaliacao, INSTR(Data_Avaliacao,"/") +1, INSTR(Data_Avaliacao,"/"))
            ELSE TRIM(("0" || SUBSTR(Data_Avaliacao, INSTR(Data_Avaliacao,"/") +1, INSTR(Data_Avaliacao,"/"))), "/")
        END)
        ) AS Data_Avaliacao
        
    FROM Notas b
        LEFT JOIN Disciplinas a
            ON b.ID_Disciplina = a.ID_Disciplina
)

SELECT DISTINCT *
FROM Base
WHERE Data_Avaliacao > "2023-08-01"
    

-- 9.Na tabela avaliações (Notas), classifique cada avaliação como 'Boa', 'Média', ou 'Ruim' com base na pontuação: 1-3 para 'Ruim', 4-7 para 'Média', e 8-10 para 'Boa'.

SELECT
    b.Data_Avaliacao
    ,a.Nome_Disciplina
    ,b.Nota
    ,CASE  
        WHEN b.Nota <= 3 THEN "Ruim"
        WHEN b.Nota >= 8 THEN "Boa"
        ELSE "Média"
    END AS Avaliacao
    ,CASE  
        WHEN b.Nota >= 7 THEN "Aprovado"
        ELSE "Reprovado"
    END AS Aprovacao
FROM Notas b
    LEFT JOIN Disciplinas a
        ON b.ID_Disciplina = a.ID_Disciplina
ORDER BY b.Data_Avaliacao DESC, Nota DESC

-- 10.Altere o nome da coluna data_nasc para data_nascimento na tabela funcionarios e selecione todos os funcionários que nasceram após '1990-01-01'.

