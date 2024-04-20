CREATE DATABASE ex_triggers_07
GO
USE ex_triggers_07
GO
CREATE TABLE cliente (
codigo INT NOT NULL,
nome VARCHAR(70) NOT NULL
PRIMARY KEY(codigo)
)
GO
CREATE TABLE venda (
codigo_venda INT NOT NULL,
codigo_cliente INT NOT NULL,
valor_total DECIMAL(7,2) NOT NULL
PRIMARY KEY (codigo_venda)
FOREIGN KEY (codigo_cliente) REFERENCES cliente(codigo)
)
GO
CREATE TABLE pontos (
codigo_cliente INT NOT NULL,
total_pontos DECIMAL(4,1) NOT NULL
PRIMARY KEY (codigo_cliente)
FOREIGN KEY (codigo_cliente) REFERENCES cliente(codigo)
)

insert into cliente
    values
        (0, 'Luan'),
        (1, 'Carina')

insert into cliente
values
    (2, 'Felipe')

insert into venda
values
    (0, 0, 120.00),
    (1, 1, 320.20)



-- - Para não prejudicar a tabela venda, nenhum produto pode ser deletado, mesmo que não
-- venha mais a ser vendido

create trigger t_delvend on venda
for delete
as
begin
    rollback transaction -- volta atras e não reliza a operação
    raiserror (N'Não é possível excluir venda', 16, 1)
end

delete venda
where venda.codigo_cliente = 0


-- - Para não prejudicar os relatórios e a contabilidade, a tabela venda não pode ser alterada.
-- - Ao invés de alterar a tabela venda deve-se exibir uma tabela com o nome do último cliente que
-- comprou e o valor da última compra

create trigger t_updvend on venda
instead of update -- ao inves de atuliazar a tabela, ira relizar esta trigger
as
begin
    -- Pega o ultimo dado inserido na tabela
    select top 1
        cliente.nome,
        venda.valor_total
    from venda, cliente
    where venda.codigo_cliente = cliente.codigo
    order by codigo_venda desc
end


-- - Após a inserção de cada linha na tabela venda, 10% do total deverá ser transformado em
-- pontos.
-- - Se o cliente ainda não estiver na tabela de pontos, deve ser inserido automaticamente após
-- sua primeira compra
-- - Se o cliente atingir 1 ponto, deve receber uma mensagem (PRINT SQL Server) dizendo que
-- ganhou e remove esse 1 ponto da tabela de pontos

create trigger t_insevend on venda
after insert -- after insert, quer dizer que esse trigger sera realizado depois do insert
as
begin
    declare @pontos decimal(4, 1),
            @total decimal(7, 2),
            @codigo_cliente int,
            @cliente_ponto int
    set @total = (select inserted.valor_total from inserted) -- com o comando inserted é possivel pegar os dados que foram inseridos pelo INSERT
    set @pontos = @total * 0.1
    set @codigo_cliente = (select inserted.codigo_cliente from inserted)
    set @cliente_ponto = (select pontos.codigo_cliente from pontos where pontos.codigo_cliente = @codigo_cliente)

    if (@cliente_ponto is not null )
    begin
        update pontos
        set total_pontos = total_pontos + @pontos
        where codigo_cliente = @codigo_cliente

        set @pontos = (select total_pontos from pontos where pontos.codigo_cliente = @codigo_cliente)
        if (@pontos >= 1)
        begin
            print 'Ganhou!'

            update pontos
            set total_pontos = total_pontos - 1
            where codigo_cliente = @codigo_cliente
        end
    end
    else
    begin
        insert into pontos
        values
            (@codigo_cliente, @pontos)

        set @pontos = (select total_pontos from pontos where pontos.codigo_cliente = @codigo_cliente)
        if (@pontos >= 1)
        begin
            print 'Ganhou!'

            update pontos
            set total_pontos = total_pontos - 1
            where codigo_cliente = @codigo_cliente
        end
    end

end
-- tambem podendo utilizar o deleted, caso a função fosse sobre DELETE

insert into venda
values
    (3, 1, 100.22)

--


