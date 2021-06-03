# dbms-21sp-prj: Online Railway Ticket Booking System

## Project Schedule

### Recent Target

- [x] Basic: Users can do queries, buy tickets and manage their orders
- [x] Medium: Administrator can see overall data (**use django's admin tool** or **implement another set of logic**)
- [ ] Advanced: Polish the website

### Schedule

- [x] **(Due 5.5)** Finish designing part of the database: ER graph, BCNF-normalization, schema

- [x] **(Due 5.5)** Finish design doc 1

- [x] **(Due 5.8)** Finish SQL query templates

- [x] **(Due 5.14)** Finish the method of building back-end database

- [x] **(Due 5.14)** Have a basic front-end framework in the project

  [Overdue] Realize most functions (nearly finished)

  [Overdue] Polish the front-end design

  [Overdue] Finish design doc 2
  
- [x] **(Due 5.26)** Prepare for presentation

- [x] **(At 5.27)** Do presentation at class

  [Overdue] Finish whole project

## Repo Structure

```
|-project_root/
    |--- db_dump_file/          # database info
       |--- modify_csv/            # original data that imported in db
       |--- sql_template/          # original create tables and functions
       |--- *-dump.sql             # database backup (can be used to import db)
    |--- design/                # design doc(s) and schema(s)
    |--- web/                   # site folder (django project)
       |--- login/                 # login app
       |--- rail/                  # rail app (main part)
       |--- template/              # temlate for project
       |--- web/                   # site settings
       |--- manage.py              # main func in the django framework
       |--- requirements.txt       # python package dependencies for the project
```

## Usages

### Toolchain

- Front End: Python 3.9.5 & django 3.2.x
- Back End: PostgreSQL 13

> **Tip**: We adopted *PyCharm Professional* and *DataGrip* as IDE, it really boosted our development!

### Front End

Folder `web/` is a django site project, which includes a `requirements.txt` . 

You should first install all the dependencies, or the project won't be able to run as expected.

### Back End

Database `rail` can be directly import from  `rail_localhost-2021_06_03_00_08_55-dump.sql`, which located in the folder `db_dump_file` .

The django project `web/` default connect the psql database at port `5432` , with user `dbms` (password: `123 ` ) and database named `rail` . You can edit `web/settings.py` with your local settings.

## Other Information That You May Need

### Site Superuser Info [not used in the project]

```
administrator username: admin
administrator password: 123
```

### Contact

email: zxz9325[At]outlook.com

