CREATE TABLE contact (
    id int auto_increment primary key,
    from varchar(255) null,
    to varchar(255) null,
    subjet varchar(255) null,
    content text null,
    created_at datetime     not null,
    updated_at datetime     null
    );

INSERT INTO contact (from, to, subjet, content, created_at) VALUES ("test@test.com", "contact@cloudnative.dev", "Nouvelle demande", "Hello world!", NOW());
