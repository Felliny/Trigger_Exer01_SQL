create database TriggerEstoqueProd
go
use TriggerEstoqueProd

create table produto(
    codigo          int             not null,
    nome            varchar(40)     not null,
    descricao       varchar(100)    not null ,
    valor_unitario  decimal(7, 2)   not null ,
    primary key (codigo)
)
go
create table estoque(
    codigo_produto          int         not null ,
    qtd_estoque             int         not null ,
    estoque_min             int         not null ,
    primary key (codigo_produto),
    foreign key (codigo_produto) references produto(codigo)
)
go
create table venda(
    nota_fiscal         int         not null ,
    codigo_produto      int         not null ,
    quantidade          int         not null ,
    primary key (nota_fiscal),
    foreign key (codigo_produto) references produto(codigo)
)


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
    declare @quant  int
    set @quant = (select qtd_estoque from estoque where codigo_produto = inserted.codigo_produto)
    -- CONTINUA...................
end

