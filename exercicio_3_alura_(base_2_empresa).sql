-- Exercício 3 (base_2_empresa)

-- 1. Retornar tabela com todos os fornecedores e colaboradores e seus endereços

SELECT 
    "Colaborador"   AS Tipo
    ,nome
    ,bairro
    ,cidade
    ,estado
    ,cep 

FROM colaboradores

UNION ALL

SELECT 
    "Fornecedor"   AS Tipo
    ,nome
    ,bairro
    ,cidade
    ,estado
    ,cep 

FROM fornecedores
;

-- 2. Identificar qual ou quais clientes fizeram compras às 9:30 em 22 de janeiro de 2023

SELECT 
    nome
    ,telefone

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


