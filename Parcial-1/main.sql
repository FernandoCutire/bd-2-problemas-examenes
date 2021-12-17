CREATE TABLE TELEFONO_EMPLEADO(
  em_cod_tel  number not null,
  em_primer_tel varchar2(45),
  em_segundo_tel varchar2(45),
  em_tercer_tel varchar2(45),
  CONSTRAINT pk_telefono_empleado PRIMARY KEY (em_cod_tel)
);

CREATE TABLE TELEFONO_SUCURSALES(
  su_cod_tel number not null,
  su_primer_tel varchar2(45),
  su_segundo_tel varchar2(45),
  su_tercer_tel varchar2(45),
  CONSTRAINT pk_telefono_sucursales PRIMARY KEY (su_cod_tel)
);

CREATE TABLE EMPLEADO(
  CIP number not null,
  nombre VARCHAR2(45),
  primer_apellido VARCHAR2(45),
  segundo_apellido VARCHAR2(45),
  em_cod_tel number,
  CONSTRAINT pk_empleado PRIMARY KEY (CIP),
  CONSTRAINT fk_em_cod_tel FOREIGN KEY (em_cod_tel) 
    REFERENCES TELEFONO_EMPLEADO(em_cod_tel)
);



CREATE TABLE SUCURSAL (
  cod_sucursal number not null,
  domicilio varchar2(45),
  su_cod_tel number,
  CONSTRAINT pk_sucursal PRIMARY KEY (cod_sucursal),
  CONSTRAINT fk_su_cod_tel FOREIGN KEY (su_cod_tel)
    REFERENCES TELEFONO_SUCURSALES (su_cod_tel)
);

CREATE TABLE EMPLEADO_SUCURSAL(
  CIP number not null,
  cod_sucursal number not null,
  CONSTRAINT pk_empleado_seccion PRIMARY KEY (CIP, cod_sucursal),
  CONSTRAINT fk_cip FOREIGN KEY (CIP)
    REFERENCES EMPLEADO (CIP),
  CONSTRAINT fk_cod_sucursal FOREIGN KEY (cod_sucursal)
    REFERENCES SUCURSAL (cod_sucursal)
);

CREATE TABLE SECCION_FIJA (
  n_seccion number not null,
  titlo varchar2(45),
  extension varchar2(45),
  CONSTRAINT pk_seccion_fija PRIMARY KEY(n_seccion)
);

CREATE TABLE ESPECIALIDAD (
  cod_espe number not null,
  especialidad varchar2(45),
  CONSTRAINT pk_especialidad PRIMARY KEY (cod_espe)
);

CREATE TABLE TELEFONO_PERIODISTA(
  pe_cod_tel number not null,
  pe_primer_tel varchar2(45),
  pe_segundo_tel varchar2(45),
  pe_tercer_tel varchar2(45),
  CONSTRAINT pk_telefono_periodista PRIMARY KEY (pe_cod_tel)
);

CREATE TABLE EJEMPLAR(
  n_ejemplar number not null,
  n_pag number,
  fecha date,
  n_ejem_vendidos number,
  CONSTRAINT pk_ejemplar PRIMARY KEY (n_ejemplar)
);

CREATE TABLE TIPO(
  cod_tipo number not null,
  descripcion varchar2(45),
  CONSTRAINT pk_tipo PRIMARY KEY (cod_tipo)
);

CREATE TABLE PERIODISTA(
  cip number not null,
  nombre varchar2(45),
  primer_apellido varchar2(45),
  segundo_apellido varchar2(45),
  pe_cod_tel number,
  pe_cod_espe number,
  CONSTRAINT pk_periodista PRIMARY KEY (cip),
  CONSTRAINT fk_pe_cod_tel FOREIGN KEY (pe_cod_tel)
    REFERENCES TELEFONO_PERIODISTA(pe_cod_tel),
  CONSTRAINT fk_pe_cod_espe FOREIGN KEY (pe_cod_espe)
    REFERENCES ESPECIALIDAD (cod_espe)
);


CREATE TABLE REVISTA (
  n_registro number not null,
  titulo varchar2(45),
  cod_tipo number,
  cod_periodista number,
  CONSTRAINT pk_revista PRIMARY KEY (n_registro),
  CONSTRAINT fk_cod_tipo FOREIGN KEY (cod_tipo)
    REFERENCES TIPO (cod_tipo),
  CONSTRAINT fk_cod_periodista FOREIGN KEY (cod_periodista)
    REFERENCES PERIODISTA (cip)
);

CREATE TABLE REVISTA_SECCION(
  n_registro number not null,
  n_seccion number not null,
  CONSTRAINT pk_revista_seccion PRIMARY KEY (n_registro, n_seccion),
  CONSTRAINT fk_n_registro FOREIGN KEY (n_registro)
    REFERENCES REVISTA (n_registro),
  CONSTRAINT fk_n_seccion FOREIGN KEY (n_seccion)
    REFERENCES SECCION_FIJA (n_seccion)
);

CREATE TABLE REVISTA_EJEMPLAR (
  n_registro number not null,
  n_ejemplar number not null,
  CONSTRAINT pk_revista_ejemplar PRIMARY KEY (n_registro, n_ejemplar),
  CONSTRAINT fk_re_n_registro FOREIGN KEY (n_registro)
    REFERENCES REVISTA (n_registro),
  CONSTRAINT fk_n_ejemplar FOREIGN KEY (n_ejemplar)
    REFERENCES EJEMPLAR (n_ejemplar)
);

