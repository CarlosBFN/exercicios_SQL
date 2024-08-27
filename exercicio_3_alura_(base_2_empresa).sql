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
