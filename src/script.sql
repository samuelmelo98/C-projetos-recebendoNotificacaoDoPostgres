CREATE TABLE IF NOT EXISTS tb_teste (
    id SERIAL PRIMARY KEY,       -- Identificador único com incremento automático
    nome VARCHAR(100) NOT NULL,  -- Nome com limite de 100 caracteres
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Data/hora da criação com valor padrão
);

CREATE OR REPLACE FUNCTION notify_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Enviar uma notificação chamada 'usuario_insert' com o ID inserido
    PERFORM pg_notify('meu_canal','teste---' || NEW.id::text);
   
   PERFORM notify_count();

    RETURN NEW; -- Continua o fluxo normal
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_usuario_insert_notify
AFTER INSERT ON tb_teste
FOR EACH ROW
EXECUTE FUNCTION notify_insert();

INSERT INTO public.tb_teste
(id, nome, criado_em)
VALUES(nextval('tb_teste_id_seq'::regclass), 'teste2', CURRENT_TIMESTAMP);


CREATE OR REPLACE FUNCTION notify_count()
RETURNS VOID AS $$
DECLARE
    total_registros INTEGER;
BEGIN
    -- Contar os registros na tabela
    SELECT COUNT(*) INTO total_registros FROM tb_teste;

    -- Enviar o total na notificação
    PERFORM pg_notify('meu_canal', 'Total de registros: ' || total_registros::TEXT);
END;
$$ LANGUAGE plpgsql;



-- testa notificação na aplicação usando postgres  
NOTIFY meu_canal, 'Total de registros';


select count(*) from tb_teste tt ;


Recebida notificação: usuario_insert - 1


