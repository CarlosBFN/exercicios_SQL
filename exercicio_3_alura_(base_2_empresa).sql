-- Exercício 3 (base_2_empresa)

-- 1. Retornar tabela com todos os fornecedores e colaboradores e seus endereços

SELECT 
    "Colaborador"   AS Tipo
    ,nome           AS Nome
    ,bairro         AS Bairro
    ,cidade         AS Cidade
    ,estado         AS Estado
    ,cep            AS CEP

FROM colaboradores

UNION ALL

SELECT 
    "Fornecedor"   AS Tipo
    ,nome          AS Nome
    ,bairro        AS Bairro
    ,cidade        AS Cidade
    ,estado        AS Estado
    ,cep           AS CEP

FROM fornecedores
;

-- 2. Identificar qual ou quais clientes fizeram compras às 9:30 em 22 de janeiro de 2023

SELECT 
    c.nome                                      AS Nome
    ,"(" || SUBSTR(c.telefone, 1, 2) || ")"
        || SUBSTR(c.telefone, 3, 4) || "-"
        || SUBSTR(c.telefone, 7)                AS Telefone

FROM clientes c

WHERE 1=1
    AND id = (
        SELECT
            idcliente
        
        FROM pedidos

        WHERE datahorapedido = "2023-01-22 09:30:00"
    )
;

-- 3. Identificar qual ou quais clientes fizeram compras às em janeiro

SELECT 
    nome                                        AS Nome
    ,"(" || SUBSTR(c.telefone, 1, 2) || ")"
        || SUBSTR(c.telefone, 3, 4) || "-"
        || SUBSTR(c.telefone, 7)                AS Telefone

FROM clientes

WHERE 1=1
    AND id IN (
        SELECT
            idcliente
        
        FROM pedidos

        WHERE STRFTIME('%m', datahorapedido) = "01"
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
    SELECT AVG(preco)
    FROM produtos)

ORDER BY preco DESC
;

-- 5. Identificar quais clientes fizeram algum pedido

SELECT
    c.nome              AS Nome_cliente
    ,p.id               AS ID_pedido
    ,p.datahorapedido   AS Data_hora_pedido
    ,p.status           AS Status_pedido

FROM clientes c
    INNER JOIN pedidos p
        ON c.id = p.idcliente

ORDER BY datahorapedido
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

SELECT
    c.nome                                      AS Nome_cliente
    ,"(" || SUBSTR(c.telefone, 1, 2) || ")"
        || SUBSTR(c.telefone, 3, 4) || "-"
        || SUBSTR(c.telefone, 7)                AS Telefone_cliente
    ,CASE
        WHEN c.email = "Sem email" THEN "-"
        ELSE c.email
    END                                         AS Email_cliente

FROM clientes c
    LEFT JOIN pedidos p
        ON c.id = p.idcliente

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

-- 11. Com o auxílio de uma view que retorne os dados de pedidos que estão em andamento

CREATE VIEW pedidos_em_andamento AS
SELECT
    id
    ,status

FROM pedidos

WHERE status = "Em Andamento"
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

