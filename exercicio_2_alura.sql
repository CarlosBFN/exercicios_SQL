-- Exercício 2

-- Consulta 1: Retornar a média de Notas dos Alunos em história.

SELECT 
    AVG(Nota) AS Nota_Media_Historia
FROM Notas
WHERE ID_Nota = 2
;

-- Consulta 2: Retornar as informações dos alunos cujo Nome começa com 'A'.

SELECT *
FROM Alunos
WHERE SUBSTR(Nome_Aluno, 1, 1) = "A"
;

-- Consulta 3: Buscar apenas os alunos que fazem aniversário em fevereiro.

SELECT *
FROM Alunos
WHERE STRFTIME('%m', Data_Nascimento) = "02"
;

-- Consulta 4: Realizar uma consulta que calcula a idade dos Alunos.

SELECT
    Nome_Aluno
    ,Data_Nascimento
    ,CAST(((JULIANDAY(CURRENT_DATE) - JULIANDAY(Data_Nascimento)) /365.25) AS INTENGER) AS Idade_Aluno
FROM Alunos
;

-- Consulta 5: Retornar se o aluno está ou não aprovado. Aluno é considerado aprovado se a sua nota foi igual ou maior que 6.

SELECT
    a.Nome_Aluno
    ,d.Nome_Disciplina
    ,n.Nota    
    ,CASE  
        WHEN n.Nota >= 6 THEN "Aprovado"
        ELSE "Reprovado"
    END AS Aprovacao
FROM Notas n
    LEFT JOIN Alunos a
        ON n.ID_Aluno = a.ID_Aluno
    LEFT JOIN Disciplinas d 
        ON n.ID_Disciplina = d.ID_Disciplina
;