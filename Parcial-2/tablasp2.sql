
create table habitaciones (
 piso integer NOT NULL,
 habitacion varchar(2) NOT NULL,
 tipo varchar(10) DEFAULT 'Doble'
CONSTRAINT nn_tipo NOT NULL
CONSTRAINT ch_Tipo  CHECK (tipo IN ('Individual','Doble', 'Suite')),
 primary key(piso,habitacion));

create table reservas (
 piso integer,
 habitacion varchar(2),
 fechaentrada date DEFAULT SYSDATE,
 noches integer,
 
 primary key(piso,habitacion,fechaentrada),
 foreign key (piso,habitacion) references habitaciones
);

create table temporadas (
 nombre varchar(10) not null,
 mesInicio integer not null,
 diaInicio integer not null,
 mesFin integer not null,
 diaFin integer not null,
 primary key(nombre,mesInicio,diaInicio)
);

CREATE TABLE estadistica_hotel (
  id_cadena number not null,
  nombre_hotel varchar2(50) not null,
  habitacionesocupadas number default 0, --Se podría meter default de 0
  habitacionesdisponibles number,
  habitacionesreservadas number default 0, --Se podría meter default de 0
  CONSTRAINT pk_cadena PRIMARY KEY (id_cadena)
);

