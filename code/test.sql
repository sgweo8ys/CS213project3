create table test(id int, name varchar(30), value int);
copy test(id, name, value) from '/opt/test/tu1.csv' DELIMITER ',' CSV HEADER;

explain analyse select * from test where id = 1;

explain analyse select * from test where id = 67364;

explain analyse select * from test where id > 46736 and id < 46759;

explain analyse select * from test where name like '%abc%';

explain analyse select * from test where name = 'okvqibkayswynkfbkprk';

begin;
explain analyse update test set name = 'hello' where id = 4762;
rollback;

begin;
explain analyse insert into test values(100001, 'hello world', 176);
rollback;

begin;
explain analyse delete from test where value < 100;
rollback;

create table test(id int, name varchar(30), value int);
copy test(id, name, value) from '/opt/test/tu1.csv' DELIMITER ',' CSV HEADER;

explain analyse select * from test where id = 3987654;

begin;
explain analyse update test set name = 'hello' where value = 101;
rollback;

begin;
explain analyse delete from test where value < 15;
rollback;

begin;
\timing on
do $$
    begin
        for i in 1..100000 loop
            insert into test values(i, 'hello', i % 300);
            end loop;
    end;
$$;
\timing off
rollback;

create index ind1 on test(id);

explain analyse select * from test where id = 3987655;

create table jointable1(id1 int, name varchar(30), grp int);
copy jointable1(id1, name, grp) from '/opt/test/jointest1.csv' DELIMITER ',' CSV HEADER;

create table jointable2(id2 int, name varchar(30), grp int);
copy jointable2(id2, name, grp) from '/opt/test/jointest2.csv' DELIMITER ',' CSV HEADER;

create table jointable3(id3 int, name varchar(30), grp int);
copy jointable3(id3, name, grp) from '/opt/test/jointest3.csv' DELIMITER ',' CSV HEADER;

explain analyse select * from jointable1
	join jointable2 on jointable2.grp = jointable1.grp
	join jointable3 on jointable3.grp = jointable2.grp
where id1 + id2 + id3 = 8297;

explain analyse
select id, name, value, id * value, id % (value + 1) from test
where log(id) * value < 1000;