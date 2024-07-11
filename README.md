# Exercícios de SQL básicos para bases genéricas #

Exercícios de SQL de nível básico da plataforma Alura.
Voltados à prática com quaisquer bases genéricas (pode precisar de alguma adaptação dependendo da fonte).

___

## Arquivos

1. README.md - Arquivo de texto que documenta o projeto
2. exercicio.sql - Querys de resolução dos exercícios
3. sqlite.db - BD simulado de registros escolares

___

## Questões

1. Selecione os primeiros 5 registros da tabela clientes, ordenando-os pelo nome em ordem crescente.
2. Encontre todos os produtos na tabela produtos que não têm uma descrição associada (suponha que a coluna de descrição possa ser nula).
3. Liste os funcionários cujo nome começa com 'A' e termina com 's' na tabela funcionarios.
4. Exiba o departamento e a média salarial dos funcionários em cada departamento na tabela funcionarios, agrupando por departamento, apenas para os departamentos cuja média salarial é superior a $5000.
5. Selecione todos os clientes da tabela clientes e concatene o primeiro e o último nome, além de calcular o comprimento total do nome completo.
6. Para cada venda na tabela vendas, exiba o ID da venda, a data da venda e a diferença em dias entre a data da venda e a data atual.
7. Selecione todos os itens da tabela pedidos e arredonde o preço total para o número inteiro mais próximo.
8. Converta a coluna data_string da tabela eventos, que está em formato de texto (YYYY-MM-DD), para o tipo de data e selecione todos os eventos após '2023-01-01'.
9. Na tabela avaliacoes, classifique cada avaliação como 'Boa', 'Média', ou 'Ruim' com base na pontuação: 1-3 para 'Ruim', 4-7 para 'Média', e 8-10 para 'Boa'.
10. Altere o nome da coluna data_nasc para data_nascimento na tabela funcionarios e selecione todos os funcionários que nasceram após '1990-01-01'.