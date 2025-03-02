\c devops

CREATE TABLE test (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    pass VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

INSERT INTO test (name, pass, phone)
VALUES
('Oleksandr', 'cm105nv53bds', '+3800000000'),
('Denys', 'mfk3v02mvh5', '+3800000001'),
('Artem', '32ndk4v92', '+3800000002'),
('Nazarii', 'cn38vfm23ld0', '+3800000003');
