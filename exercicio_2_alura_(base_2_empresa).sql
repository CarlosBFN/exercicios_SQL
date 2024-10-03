-- Exercício 3 (base_2_empresa)

-- 1. Retornar tabela com todos os fornecedores e colaboradores e seus endereços

SELECT 
    "Colaborador"               AS Tipo
    ,nome                       AS Nome
    ,bairro                     AS Bairro
    ,cidade                     AS Cidade
    ,estado                     AS Estado
    ,SUBSTR(cep, 1,5) || "-"
        || SUBSTR(cep, 6)       AS CEP

FROM colaboradores

UNION ALL

SELECT 
    "Fornecedor"                AS Tipo
    ,nome                       AS Nome
    ,bairro                     AS Bairro
    ,cidade                     AS Cidade
    ,estado                     AS Estado
    ,SUBSTR(cep, 1,5) || "-"
        || SUBSTR(cep, 6)       AS CEP

FROM fornecedores
;

-- 2. Identificar qual ou quais clientes fizeram compras às 9:30 em 22 de janeiro de 2023

SELECT 
    c.nome                                      AS Nome
    ,t.ddd
        || SUBSTR(t.telefone, -4, -5) || "-"
        || SUBSTR(t.telefone, -4)               AS Telefone_cliente

FROM clientes c
    LEFT JOIN arruma_telefones t
        ON c.id = t.id

WHERE 1=1
    AND c.id = (
        SELECT
            idcliente
        
        FROM pedidos

        WHERE TRUE 
            AND datahorapedido = "2023-01-22 09:30:00"
    )
;

-- 3. Identificar qual ou quais clientes fizeram compras em janeiro

SELECT 
    c.nome                                        AS Nome
    ,t.ddd
        || SUBSTR(t.telefone, -4, -5) || "-"
        || SUBSTR(t.telefone, -4)                 AS Telefone_cliente
    ,DATE(p.datahorapedido)                       AS Data_pedido

FROM clientes c
    LEFT JOIN arruma_telefones t
        ON c.id = t.id

    LEFT JOIN pedidos p
        ON c.id = p.idcliente

WHERE 1=1
    AND c.id IN (
        SELECT
            idcliente
        
        FROM pedidos

        WHERE 1=1
            AND STRFTIME('%m', datahorapedido) = "01"
    )
;

-- 4. Quais produtos tem preços acima da média de preço dos produtos

SELECT
    nome                                    AS Nome
    ,categoria                              AS Categoria
    ,"R$ " || PRINTF('%.2f', preco)         AS Preço
    ,CASE
        WHEN preco > media_preco THEN "Sim"
        ELSE "Não"
    END                                     AS Preço_acima_da_média

FROM produtos
    CROSS JOIN(
        SELECT AVG(preco) AS media_preco

        FROM produtos
    )

ORDER BY preco DESC
;

-- 4. Quais produtos tem preços acima da média de preço dos produtos (solução alternativa)

SELECT
    nome                                    AS Nome
    ,categoria                              AS Categoria
    ,"R$ " || PRINTF('%.2f', preco)         AS Preço

FROM produtos

GROUP BY 1,2,3

HAVING preco > (
    SELECT 
        AVG(preco)
    
    FROM produtos)

ORDER BY preco DESC
;

-- 5. Identificar quais clientes fizeram algum pedido

WITH
conta_pedidos AS(
    SELECT
        idcliente
        ,COUNT(id)  AS contagem_pedidos
    
    FROM pedidos

    GROUP BY 1
),

media_pedidos AS(
    SELECT
        AVG(contagem_pedidos)   AS media_pedidos
    
    FROM conta_pedidos
)

SELECT
    c.nome                              AS Nome_cliente
    ,cp.contagem_pedidos                AS Total_pedidos_cliente
    ,CASE
        WHEN cp.contagem_pedidos > mp.media_pedidos THEN "Comprador acima da média"
        ELSE "Comprador abaixo da média"
    END                                 AS Média_compras
    ,MIN(DATE(p.datahorapedido))        AS Primeira_compra
    ,MAX(DATE(p.datahorapedido))        AS Última_compra

FROM clientes c
    INNER JOIN pedidos p
        ON c.id = p.idcliente

    LEFT JOIN conta_pedidos cp
        ON c.id = cp.idcliente

    CROSS JOIN media_pedidos mp

GROUP BY 1,2,3
ORDER BY c.nome
;

-- 6. Identificar itens sem pedidos no mês de outubro

SELECT
    p.nome                              AS Nome_produto
    ,IFNULL(i.idpedido, "N/A")          AS ID_pedido
    ,"R$ " || PRINTF('%.2f', p.preco)   AS Valor_unitário
    ,p.categoria                        AS Categoria_produto

FROM produtos p
    LEFT JOIN (
        SELECT 
            i.idpedido
            ,i.idproduto
        
        FROM pedidos p
            JOIN itenspedidos i 
                ON p.id = i.idpedido

        WHERE 1=1
            AND strftime('%m', p.DataHoraPedido) = "10" 
    ) i 
        ON p.id = i.idproduto

GROUP BY 1,2,3

HAVING idpedido IS NULL
;

-- 7. Retorne o nome dos clientes que ainda não fizeram pedidos

CREATE VIEW arruma_telefones AS
SELECT
    id
    ,"(" || SUBSTR(c.telefone, 1, 2) || ")"     AS ddd
    ,CAST(SUBSTR(c.telefone, 3) AS STRING)      AS telefone

FROM clientes c
;

SELECT
    c.nome                                      AS Nome_cliente
    ,t.ddd
        || SUBSTR(t.telefone, -4, -5) || "-"
        || SUBSTR(t.telefone, -4)               AS Telefone_cliente
    ,CASE
        WHEN c.email = "Sem email" THEN "-"
        ELSE c.email
    END                                         AS Email_cliente

FROM clientes c
    LEFT JOIN pedidos p
        ON c.id = p.idcliente

    LEFT JOIN arruma_telefones t
        ON c.id = t.id

WHERE 1=1
    AND p.id IS NULL

ORDER BY nome
;    

-- 8. Retorne o valor total dos pedidos

WITH
BASE_ITENSPEDIDOS AS(
    SELECT
        idpedido
        ,idproduto
        ,quantidade
        ,precounitario
        ,precounitario * quantidade AS Valor_Total_Pedido

    FROM itenspedidos ip
),

BASE_PEDIDOS AS(
SELECT
    ip.idpedido
    ,pe.idcliente
    ,ip.Valor_Total_Pedido
    ,pe.datahorapedido
    ,pe.status

FROM BASE_ITENSPEDIDOS ip
    LEFT JOIN pedidos pe
        ON ip.idpedido = pe.id
)

SELECT
    CAST(pe.idpedido AS INTENGER)                           AS Pedido
    ,cl.nome                                                AS Cliente
    ,"R$ " || PRINTF('%.2f', SUM(pe.Valor_Total_Pedido))    AS Valor_Total_Pedido
    ,pe.datahorapedido                                      AS Data_hora_pedido
    ,pe.status                                              AS Status

FROM BASE_PEDIDOS pe
    LEFT JOIN clientes cl
        ON pe.idcliente = cl.id

GROUP BY 1,2
ORDER BY 1
;

-- 9. Construir um modelo de nota para as vendas 

SELECT
    CAST(ip.idpedido AS INTENGER)       AS Pedido
    ,ip.nome || " - " 
        || ip.quantidade || "un. x " || "R$ " || PRINTF('%.2f', SUM(ip.precounitario)) 
        || " - Total: " || "R$ " || PRINTF('%.2f', SUM(ip.Valor_Total_Pedido))    AS Nota
    ,"Pedido feito às " || strftime('%H:%m', pe.datahorapedido) 
        || " da " || CASE WHEN CAST(strftime('%H', pe.datahorapedido) AS INTENGER) >= 12 THEN "tarde " ELSE "manhã " END
        || "no dia " || strftime('%d/%m/%Y', pe.datahorapedido)  AS Data_hora_pedido

FROM (
    SELECT
        idpedido
        ,idproduto
        ,pr.nome
        ,quantidade
        ,precounitario
        ,precounitario * quantidade AS Valor_Total_Pedido

    FROM itenspedidos ip
        LEFT JOIN produtos pr
            ON ip.idproduto = pr.id
) ip
    LEFT JOIN pedidos pe
        ON ip.idpedido = pe.id

GROUP BY idpedido, idproduto
ORDER BY 1
;

-- 10. Retorne o nome de cada cliente e o valor total dos pedidos que cada um deles comprou

WITH
BASE1 AS(
    SELECT
        c.nome
        ,p.id

    FROM clientes c
        LEFT JOIN pedidos p
            ON c.id = p.idcliente
),

BASE2 AS(
    SELECT 
        b.nome 
        ,i.quantidade
        ,i.precounitario
        ,SUM(i.quantidade * i.precounitario) AS valor

    FROM BASE1 b
        LEFT JOIN itenspedidos i
            ON b.id = i.idpedido

    GROUP BY 1
)

SELECT
    nome                               AS Nome
    ,"R$ " || PRINTF('%.2f', valor)    AS Valor_total_gasto
    ,"R$ " || PRINTF('%.2f', AVG(valor) OVER())                    AS Gasto_médio
    ,CASE 
        WHEN valor >= (AVG(valor) OVER()) * 1.2 THEN "Maiores gastadores"
        WHEN valor >= (AVG(valor) OVER()) * 0.8 AND valor < (AVG(valor) OVER()) * 1.2 THEN "Gastadores medianos"
        WHEN valor <= (AVG(valor) OVER()) * 0.8 THEN "Menores gastadores"
        ELSE "Sem gastos"
    END                                     AS Tipo_cliente

FROM BASE2

GROUP BY 1
ORDER BY valor DESC
;

-- 11. Com o auxílio de uma view faça uma query que retorne os dados de pedidos que estão em andamento

CREATE VIEW pedidos_em_andamento AS(
SELECT
    id
    ,status

FROM pedidos

WHERE TRUE
    AND status = "Em Andamento"
)
;

SELECT
    p.id_pedido
    ,c.nome             AS cliente
    ,p.data_hora_pedido

FROM(  
    SELECT
        p.id                AS id_pedido
        ,p.idcliente
        ,p.datahorapedido   AS data_hora_pedido

    FROM pedidos_em_andamento a 

        LEFT JOIN pedidos p
            ON a.id = p.id
) p
    LEFT JOIN clientes c
        ON c.id = p.idcliente
;

-- 12. Contruir um TRIGGER para que o faturamento diário esteja sempre atualizado

CREATE TABLE FaturamentoDiario (
    Dia DATE,
    FaturamentoTotal DECIMAL(10, 2)
)
;

INSERT INTO FaturamentoDiario (Dia, FaturamentoTotal)
    SELECT
        DATE(p.datahorapedido)                              AS Dia
        ,"R$ " || PRINTF('%.2f', SUM(ip.precounitario))     AS Faturamento

    FROM pedidos p
        INNER JOIN itenspedidos ip
            ON p.id = ip.idpedido

    GROUP BY 1
    ORDER BY 1 DESC
;

CREATE TRIGGER CalculaFaturamentoDiario
AFTER INSERT ON itenspedidos
FOR EACH ROW
BEGIN
    DELETE FROM FaturamentoDiario;
    INSERT INTO FaturamentoDiario (Dia, FaturamentoTotal)
        SELECT
            DATE(p.datahorapedido)                              AS Dia
            ,"R$ " || PRINTF('%.2f', SUM(ip.precounitario))     AS Faturamento

        FROM pedidos p
            INNER JOIN itenspedidos ip
                ON p.id = ip.idpedido

        GROUP BY 1
        ORDER BY 1 DESC;
END
;

--Teste do TRIGGER
INSERT INTO pedidos(id, idcliente, datahorapedido, status) VALUES 
(451, 27, '2023-10-07 14:30:00', 'Em Andamento')
;

INSERT INTO ItensPedidos(idpedido, idproduto, quantidade, precounitario) VALUES 
(451, 14, 1, 6.0),
(451, 13, 1, 7.0)
;

INSERT INTO Pedidos (id, idcliente, datahorapedido, status) VALUES 
(452, 28, '2023-10-07 14:35:00', 'Em Andamento')
;

INSERT INTO ItensPedidos (idpedido, idproduto, quantidade, precounitario) VALUES 
(452, 10, 1, 5.0),
(452, 31, 1, 12.50)
;

-- 13. Atualizar dados já existentes na base (novo preço para a lasanha e nova descrição para o croisssant de amêndoas).

UPDATE produtos SET preco = 13.0 WHERE id = 31
;
UPDATE produtos SET descricao = 'Crossaint recheado com amêndoas.' WHERE id = 28
;
SELECT * 
FROM produtos 
WHERE nome LIKE 'croissant%' OR nome LIKE 'lasanha%'
;

-- 14. Remover dados existentes (colaborador Pedro Almeida	desligado, cliente Paulo Sousa que pediu exclusão dos dados)

DELETE FROM colaboradores WHERE id = 3
;
UPDATE clientes SET 
    nome = "Removido", 
    telefone = "Removido", 
    email = "Sem email",
    endereco = "Sem endereço"
    WHERE id = 27
;

-- 15. Traga todos os dados da cliente Maria Silva.

SELECT 
    c.id
    ,c.nome
    ,t.ddd
        || SUBSTR(t.telefone, -4, -5) || "-"
        || SUBSTR(t.telefone, -4)               AS telefone
    ,c.email
    ,c.endereco
    ,p.status
    ,p.qtd_pedidos
    ,ultimo_pedido

FROM clientes c
    LEFT JOIN arruma_telefones t
        USING(id)

    LEFT JOIN(
        SELECT 
            idcliente
            ,status
            ,COUNT(id)              AS qtd_pedidos
            ,MAX(datahorapedido)    AS ultimo_pedido

        FROM pedidos

        GROUP BY 1,2
    ) p
        ON c.id = p.idcliente

WHERE TRUE
    AND nome = "Maria Silva"

ORDER BY status
;

-- 16. Retorne todos os produtos onde o preço seja maior que 10 e menor que 15.

SELECT
    p.id
    ,p.nome
    ,p.descricao
    ,p.preco 

FROM produtos p

WHERE 1=1
    AND preco > 10 
    AND preco < 15

ORDER BY 1
;

-- 17. Busque o nome e cargo dos colaboradores que foram contratados entre 2022-01-01 e 2022-06-31.

SELECT
    c.id
    ,c.nome
    ,c.cargo
    ,c.datacontratacao

FROM colaboradores c

WHERE 1=1
    AND c.DataContratacao BETWEEN "2022-01-01" AND "2022-06-31"
;

-- 18. Recupere o nome do cliente que fez o primeiro pedido.

SELECT
    c.id    AS id_cliente
    ,c.nome
    ,p.id   AS id_pedido
    ,p.datahorapedido
    ,p.status

FROM pedidos p
    LEFT JOIN clientes c
        ON p.idcliente = c.id

WHERE 1=1
    AND p.id = 1
;

-- 19. Liste os produtos que nunca foram pedidos.

/*
INSERT INTO produtos (id, nome, descricao, preco, categoria) VALUES 
(32, "Pastel de queijo", "Pastel frito tradicional de feira sabor queijo", 7, "Almoço"),
(33, "Pastel de carne", "Pastel frito tradicional de feira sabor carne", 7, "Almoço")
;
*/

SELECT 
    p.*

FROM produtos p
    LEFT JOIN (
        SELECT DISTINCT
            ip.idproduto
            
        FROM itenspedidos ip
    ) ip
        ON ip.idproduto = p.id

WHERE 1=1
    AND ip.idproduto IS NULL
;

-- 20. Recupere os nomes dos produtos que estão em menos de 15 pedidos.

SELECT 
    p.id
    ,p.nome
    ,p.categoria
    ,p.descricao
    ,"R$ " || PRINTF('%.2f', p.preco)                      AS preco
    ,ip.qt_pedidos
    ,"R$ " || PRINTF('%.2f', (ip.qt_pedidos * p.preco))     AS faturamento_bruto

FROM produtos p
    LEFT JOIN (
        SELECT DISTINCT
            idproduto
            ,COUNT(DISTINCT idpedido)   AS qt_pedidos

        FROM itenspedidos

        GROUP BY 1
    ) ip
        ON ip.idproduto = p.id

WHERE 1=1
    AND ip.qt_pedidos >= 15

ORDER BY qt_pedidos DESC
;

-- 21. Liste os produtos e o ID do pedido que foram realizados pelo cliente "Pedro Alves" ou pela cliente "Ana Rodrigues".

WITH
base_clientes AS(
    SELECT
        c.id
        ,c.nome

    FROM clientes c

    WHERE TRUE
        AND nome IN ("Pedro Alves", "Ana Rodrigues") 
),

base_pedidos AS(
    SELECT
        p.id        AS id_pedido
        ,bc.id      AS id_cliente
        ,bc.nome    AS cliente

    FROM base_clientes bc

        LEFT JOIN pedidos p
            ON bc.id = p.idcliente
),

base_produtos AS(
    SELECT
        bp.*
        ,ip.idproduto                                                   AS id_produto
        ,ip.quantidade
        ,"R$ " || PRINTF('%.2f', ip.precounitario)                      AS preco_unitario
        ,"R$ " || PRINTF('%.2f', (ip.quantidade * ip.precounitario))    AS faturamento_bruto

    FROM base_pedidos bp
        LEFT JOIN itenspedidos ip
            ON bp.id_pedido = ip.idpedido
)

SELECT 
    CAST(bp.id_pedido AS INTENGER)      AS id_pedido
    ,bp.id_cliente
    ,bp.cliente
    ,CAST(bp.id_produto AS INTENGER)    AS id_produto
    ,p.nome                             AS produto
    ,bp.quantidade
    ,bp.preco_unitario
    ,bp.faturamento_bruto

FROM base_produtos bp
    LEFT JOIN produtos p
        ON p.id = bp.id_produto

ORDER BY 1, 3, 4
;

-- 22. Recupere o nome e o ID do cliente que mais comprou em valor.

WITH
base_pedidos AS(
    SELECT
        idpedido
        --,"R$ " || PRINTF('%.2f', SUM(faturamento_bruto))   AS faturamento_bruto
        ,SUM(faturamento_bruto)   AS faturamento_bruto

    FROM(
        SELECT
            CAST(ip.idpedido AS INTENGER)       AS idpedido
            ,ip.quantidade
            ,ip.precounitario
            ,ip.quantidade * ip.precounitario    AS faturamento_bruto

        FROM itenspedidos ip

        GROUP BY 1,2,3
    )

    GROUP BY 1
)
SELECT
    id_cliente
    ,cliente
    ,"R$ " || PRINTF('%.2f', faturamento_bruto)     AS faturamento_bruto

FROM(
    SELECT
        p.idcliente                     AS id_cliente
        ,c.nome                         AS cliente
        ,SUM(bp.faturamento_bruto)      AS faturamento_bruto

    FROM pedidos p
        LEFT JOIN base_pedidos bp
            ON bp.idpedido = p.id

        LEFT JOIN clientes c
            ON c.id = p.idcliente

    GROUP BY 1
    ORDER BY 3 DESC, 1 ASC
)
LIMIT 1
;