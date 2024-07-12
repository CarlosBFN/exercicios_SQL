-- Exercícios

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

WITH
BASE AS(
    SELECT 
        ID_Nota
        ,Data_Avaliacao
        ,SUBSTR(Data_Avaliacao, -4) AS Ano_Avaliacao_Julianday
        ,TRIM(("0" || SUBSTR(Data_Avaliacao, 1, INSTR(Data_Avaliacao,"/")-1)), "/") AS Mes_Avaliacao_Julianday
        ,CASE
            WHEN LENGTH(TRIM(("0" || SUBSTR(Data_Avaliacao, INSTR(Data_Avaliacao,"/") +1, INSTR(Data_Avaliacao,"/"))), "/")) = 3
                THEN SUBSTR(Data_Avaliacao, INSTR(Data_Avaliacao,"/") +1, INSTR(Data_Avaliacao,"/"))
            ELSE TRIM(("0" || SUBSTR(Data_Avaliacao, INSTR(Data_Avaliacao,"/") +1, INSTR(Data_Avaliacao,"/"))), "/")
        END AS Dia_Avaliacao_Julianday
    FROM Notas
)

SELECT 
    ID_Nota
    ,Data_Avaliacao
    ,Ano_Avaliacao_Julianday ||"-"|| Mes_Avaliacao_Julianday ||"-"|| Dia_Avaliacao_Julianday AS Data_Avaliacao_Julianday
    ,CURRENT_DATE AS Data_Atual
    ,CAST(JULIANDAY(CURRENT_DATE) - JULIANDAY(Ano_Avaliacao_Julianday ||"-"|| Mes_Avaliacao_Julianday ||"-"|| Dia_Avaliacao_Julianday) AS INTEGER) AS Dias_Decorridos
FROM BASE
;

-- 7.Selecione todos os itens da tabela pedidos e arredonde o preço total para o número inteiro mais próximo.



-- 8.Converta a coluna data_string da tabela eventos, que está em formato de texto (YYYY-MM-DD), para o tipo de data e selecione todos os eventos após '2023-01-01'.



-- 9.Na tabela avaliacoes, classifique cada avaliação como 'Boa', 'Média', ou 'Ruim' com base na pontuação: 1-3 para 'Ruim', 4-7 para 'Média', e 8-10 para 'Boa'.



-- 10.Altere o nome da coluna data_nasc para data_nascimento na tabela funcionarios e selecione todos os funcionários que nasceram após '1990-01-01'.