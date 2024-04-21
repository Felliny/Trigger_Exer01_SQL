create database TriggerEstoqueProd
go
use TriggerEstoqueProd

create table produto(
    codigo          int             not null,
    nome            varchar(40)     not null,
    descricao       varchar(100)    not null ,
    valor_unitario  decimal(7, 2)   not null 
    primary key (codigo)
)
go
create table estoque(
    codigo_produto          int         not null ,
    qtd_estoque             int         not null ,
    estoque_min             int         not null 
    primary key (codigo_produto)
    foreign key (codigo_produto) references produto(codigo)
)
go
create table venda(
    nota_fiscal         int         not null ,
    codigo_produto      int         not null ,
    quantidade          int         not null 
    primary key (nota_fiscal)
    foreign key (codigo_produto) references produto(codigo)
)

insert into produto
values
    (0, 'PS5', 'VideoGame', 1300.20),
    (1, 'PS4', 'VideoGame', 300.20)

insert into estoque
values
    (0, 40, 20),
    (1, 20, 5)


-- - Fazer uma TRIGGER AFTER na tabela Venda que, uma vez feito um INSERT, verifique se a quantidade
-- está disponível em estoque. Caso esteja, a venda se concretiza, caso contrário, a venda deverá ser
-- cancelada e uma mensagem de erro deverá ser enviada. A mesma TRIGGER deverá validar, caso a
-- venda se concretize, se o estoque está abaixo do estoque mínimo determinado ou se após a venda,
-- ficará abaixo do estoque considerado mínimo e deverá lançar um print na tela avisando das duas
-- situações.


create trigger t_insevend on venda
after insert
as
begin
    declare @quant_estoque      int,
            @quant              int,
            @min_estoque        int,
            @estoque_pos_venda  int,
            @codigo_prod    int
    set @codigo_prod = (select inserted.codigo_produto from inserted)
    set @quant = (select  inserted.quantidade from inserted)
    set @quant_estoque = (select qtd_estoque from estoque where codigo_produto = @codigo_prod)
    set @min_estoque = (select estoque_min from estoque where codigo_produto = @codigo_prod)

    if (@quant > @quant_estoque)
    begin
        rollback transaction
        raiserror ('Produto sem quantidade escolhida!', 16, 1)
    end

    set @estoque_pos_venda = @quant_estoque - @quant
    if (@quant_estoque < @min_estoque)
    begin
        print 'O produto esta com o estoque abaixo do Estoque Minimo'
        print 'Estoque: ' + cast(@estoque_pos_venda as varchar(10))
    end
    else if (@estoque_pos_venda < @min_estoque)
    begin
        print N'O produto após esta venda, ficara com o estoque abaixo do Estoque Minimo'
        print N'Estoque pós venda: ' + cast(@estoque_pos_venda as varchar(10))
    end

    update estoque
    set qtd_estoque = @estoque_pos_venda
    where codigo_produto = @codigo_prod
end

insert into venda
values
    (5, 1, 16)



