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
    nome        AS Nome
    ,telefone   AS Telefone

FROM clientes

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
    nome        AS Nome
    ,telefone   AS Telefone

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

        WHERE strftime('%m', p.DataHoraPedido) = "10" 
    ) i 
        ON p.id = i.idproduto

GROUP BY 1,2,3

HAVING idpedido IS NULL
;