create table XXX_t( x number(3), s varchar2(50));
insert into XXX_t values (1, 'Nik');
insert into XXX_t values (2, 'Mar');
insert into XXX_t values (3, 'Dar');
commit COMMENT 'first commit';

UPDATE XXX_t set s = 'LLL' where x = 2;
UPDATE XXX_t set s = 'AAA' where x = 3;
commit COMMENT 'update my values';

select * FROM XXX_t;
select s from XXX_t where x between 2 and 3;
select x from XXX_t where s = 'Nik';

delete from XXX_t where x = 1;
commit COMMENT 'delete row';

drop table XXX_t;