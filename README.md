# Exercícios de SQL

Este projeto contém uma série de exercícios básicos e intermediários em SQL, projetados para melhorar suas habilidades em manipulação de bancos de dados e execução de consultas SQL. Os exercícios cobrem tópicos como joins, triggers, views, funções de agregação e manipulação de strings, e são adequados para estudantes e profissionais em busca de prática.

Voltados à prática com quaisquer bases genéricas (pode precisar de alguma adaptação dependendo da fonte).

Palavras-chave: SQL; JOIN; WITH; VIEW; TRIGGER; HAVING; filtros; análise


## Plataformas e ferramentas usadas

- **VSCode v1.90.2**: Usado como editor de código.
- **SQLite v0.14.1**: Extensão do VSCode para trabalhar com bancos de dados SQLite.
- **SQLite Online**: Usada para criar os arquivos '.db'. Pode também ser usada como ferramenta alternativa para executar queries SQL diretamente no navegador.

## Arquivos do projeto

1. README.md    - Arquivo de texto que documenta o projeto
<br><br>

2. [Base 1](data/base_1_escola.db)   - Base de dados simulada de registros escolares
3. [Exercício 1](exercicio_1_alura_(base_1_escola).sql) - Queries de resolução dos exercícios com a **Base 1**
<br> <br>

5. [Base 2](data/base_2_empresa.db)  - Base de dados simulada de registros de uma empresa
6. [Base 2 - Criação de tabelas](data/base_2_empresa_(criacao_das_tabelas).sql)  - Arquivo para criação da **Base 2**
7. [Base 2 - Preenchimento das tabelas 1](data/base_2_empresa_(preenchimento_das_tabelas_1).sql) - Query para preenchimento da **Base 2**
8. [Base 2 - Preenchimento das tabelas 2](data/base_2_empresa_(preenchimento_das_tabelas_2_(itens_de_pedido)).csv)    - Arquivo para preenchimento da **Base 2**
9. [Base 2 - Preenchimento das tabelas 3](data/base_2_empresa_(preenchimento_das_tabelas_3_(pedidos)).csv)    - Arquivo para preenchimento da **Base 2**
10. [Exercício 2](exercicio_2_alura_(base_2_empresa).sql)   - Queries de resolução dos exercícios com **Base 2**

### Estrutura do projeto
```
exercicios_SQL/
│
├── data/                                       # Pasta de dados
│   ├── processed/                              # Dados brutos, como foram obtidos
│   └── raw/                                    # Dados processados
│
├── exercicio_1_alura_(base_1_escola).sql       # Consulta SQL
├── exercicio_2_alura_(base_2_empresa).sql      # Consulta SQL
└── README.md                                   # Arquivo de documentação principal
```

### Como usar os arquivos

1. a) Baixe os bancos de dados (.db) da pasta `data/processed` e abra-os usando o SQLite no VSCode ou em outra ferramenta de sua escolha. b) Ou baixe os arquivos de criação das bases da pasta `data/raw` e as recrie. 

2. Abra os arquivos de query (.sql) e execute as consultas no banco de dados correspondente.

## Questões - Exercício 1
_Objetivo: Praticar ordenação de registros com ORDER BY, agrupamento com GROUP BY, diferentes formas de filtragem usando com WHERE e HAVING, tranformações de texto com SUBSTR e "||" , operações com datas, validações e tranformações com CASE ,particionamento de consulta com WITH e interaçõa entre diferentes tabelas com LEFT JOIN._

1. Selecione os primeiros 5 registros da tabela clientes (Alunos), ordenando-os pelo nome em ordem crescente.

2. Encontre todos os produtos na tabela produtos (Disciplinas) que não têm uma descrição associada (suponha que a coluna de descrição possa ser nula).
3. iste os funcionários (Professores) cujo nome começa com 'A' e termina com 's' na tabela funcionarios.
4. Exiba o departamento (disciplina) e a média salarial dos funcionários (média de notas dos alunos nas disciplinas) em cada departamento na tabela funcionarios, agrupando por departamento, apenas para os departamentos cuja média salarial é superior a $5000 (5,0).
5. Selecione todos os clientes da tabela clientes (alunos) e concatene o primeiro e o último nome, além de calcular o comprimento total do nome completo.
6. Para cada venda (nota) na tabela vendas, exiba o ID da venda, a data da venda e a diferença em dias entre a data da venda e a data atual.
7. Selecione todos os itens da tabela pedidos (notas) e arredonde o preço total para o número inteiro mais próximo.
8. Converta a coluna data_string da tabela eventos (avaliações), que está em formato de texto (YYYY-MM-DD), para o tipo de data e selecione todos os eventos após '2023-01-01' ('2023-08-01').
9. Na tabela avaliações (Notas), classifique cada avaliação como 'Boa', 'Média', ou 'Ruim' com base na pontuação: 1-3 para 'Ruim', 4-7 para 'Média', e 8-10 para 'Boa'.
10. Retornar a média de Notas dos Alunos em história.
11. Retornar as informações dos alunos cujo Nome começa com 'A'.
12. Buscar apenas os alunos que fazem aniversário em fevereiro.
13. Realizar uma que calcula a idade dos Alunos.
14. Retornar se o aluno está ou não aprovado. Aluno é considerado aprovado se a sua nota foi igual ou maior que 6.
15. Retornar o nome do aluno que obteve a maior nota em cada disciplina.
16. Buscar o nome do professor e a turma que ele é orientador
17. Listar os Alunos e as disciplinas em que estão matriculados

## Questões - Exercício 2
_Objetivo: Praticar mesclagem de tabelas com UNION ALL, mais tranformaçãoes de texto com SUBSTR e "||" , outros tipos de JOIN, consultas encapsuladas dentro de JOIN, criação de VIEW e TRIGGER._

1. Retornar tabela com todos os fornecedores e colaboradores e seus endereços

2. Identificar qual ou quais clientes fizeram compras às 9:30 em 22 de janeiro de 2023
3. Identificar qual ou quais clientes fizeram compras em janeiro
4. Quais produtos tem preços acima da média de preço dos produtos (duas soluções)
5. Identificar quais clientes fizeram algum pedido
6. Identificar itens sem pedidos no mês de outubro
7. Retorne o nome dos clientes que ainda não fizeram pedidos
8. Retorne o valor total dos pedidos
9. Construir um modelo de nota para as vendas 
10. Retorne o nome de cada cliente e o valor total dos pedidos que cada um deles comprou
11. Com o auxílio de uma view faça uma query que retorne os dados de pedidos que estão em andamento
12. Contruir um TRIGGER para que o faturamento diário esteja sempre atualizado
13. Atualizar dados já existentes na base (novo preço para a lasanha e nova descrição para o croisssant de amêndoas)
14. Remover dados existentes (colaborador Pedro Almeida	desligado, cliente Paulo Sousa que pediu exclusão dos dados)
15. Traga todos os dados da cliente Maria Silva.
16. Retorne todos os produtos onde o preço seja maior que 10 e menor que 15.
17. Busque o nome e cargo dos colaboradores que foram contratados entre 2022-01-01 e 2022-06-31.
18. Recupere o nome do cliente que fez o primeiro pedido.
19. Liste os produtos que nunca foram pedidos.
20. Recupere os nomes dos produtos que estão em menos de 15 pedidos.
21. Liste os produtos e o ID do pedido que foram realizados pelo cliente "Pedro Alves" ou pela cliente "Ana Rodrigues".
22. Recupere o nome e o ID do cliente que mais comprou em valor.