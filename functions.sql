create function create_database()
	returns void language sql as $$
		create table if not exists "Department"(
			id text primary key not null,
			name text not null,
			last_update timestamptz default current_timestamp not null
		);
		create table if not exists "Person"(
			id integer primary key not null generated always as identity,
			title text not null,
			FIO text not null,
			department text not null
		);
		create index if not exists FIO on "Person" (FIO);

		create or replace function update_time()
			returns trigger as $u$
			begin
				new.last_update = current_timestamp;
				return new;
			end;
		$u$ language plpgsql;

		drop trigger if exists trigger_update on "Department";

		create trigger trigger_update before update on "Department"
			for row execute procedure update_time();
$$;

select "create_database"();

create function get_departments()
	returns json language plpgsql as $$
		begin
			return (select json_agg(json_build_object(
				'id', "Department".id,
				'name', "Department".name,
				'last_update', "Department".last_update
				)) from "Department");
		end
	$$;

create function get_persons()
	returns json language plpgsql as $$
		begin
			return (select json_agg(json_build_object(
				'id', "Person".id,
				'title', "Person".title,
				'FIO', "Person".FIO,
				'department', "Person".department
				)) from "Person");
		end
	$$;

create function add_to_department(in id text, in name text)
	returns void language sql as $$
		insert into "Department"(id, name) values (id, name)
	$$;

create function add_to_person(in title text, in FIO text, in department text)
	returns void language sql as $$
		insert into "Person"(title, FIO, department) values (title, FIO, department)
	$$;

create function clear_departments()
	returns void language sql as $$
		truncate "Department"
	$$;

create function clear_persons()
	returns void language sql as $$
		truncate "Person"
	$$;

create function clear_all()
	returns void language sql as $$
		truncate "Department";
		truncate "Person"
	$$;

create function find_person(in query text)
	returns json language plpgsql as $$
		begin
			return (select json_agg(json_build_object(
				'id', "Person".id,
				'title', "Person".title,
				'FIO', "Person".FIO,
				'department', "Person".department
				)) from "Person" where "Person".FIO like concat('%', query, '%'));
		end;
	$$;

create function find_department(in query text)
	returns json language plpgsql as $$
		begin
			return (select json_agg(json_build_object(
				'id', "Department".id,
				'name', "Department".name,
				'last_update', "Department".last_update
				)) from "Department" where "Department".id in (
					select department from "Person" where "Person".FIO like concat('%', query, '%')
				)
			);
		end;
	$$;

create function delete_person_by_FIO(in FIO_ text)
	returns void language plpgsql as $$
		begin
			delete from "Person" where FIO = FIO_;
		end;
	$$;

create function delete_department_chosen(in id_ text)
	returns void language plpgsql as $$
		begin
			delete from "Department" where id = id_;
		end;
	$$;

create function delete_person_chosen(in id_ integer)
	returns void language plpgsql as $$
		begin
			delete from "Person" where id = id_;
		end;
	$$;

create function update_department_by_id(in new_id text, in id_ text)
	returns void language plpgsql as $$
		begin
			update "Department" set id = new_id where id = id_;
		end;
	$$;

create function update_department_by_name(in new_name text, in id_ text)
	returns void language plpgsql as $$
		begin
			update "Department" set name = new_name where id = id_;
		end;
	$$;

create function update_person_by_title(in new_title text, in id_ integer)
	returns void language plpgsql as $$
		begin
			update "Person" set title = new_title where id = id_;
		end;
	$$;

create function update_person_by_FIO(in new_FIO text, in id_ integer)
	returns void language plpgsql as $$
		begin
			update "Person" set FIO = new_FIO where id = id_;
		end;
	$$;

create function update_person_by_department(in new_department text, in id_ integer)
	returns void language plpgsql as $$
		begin
			update "Person" set department = new_department where id = id_;
		end;
	$$;