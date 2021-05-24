# Generated by Django 3.2.3 on 2021-05-24 10:56

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='AuthPermission',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=255)),
                ('codename', models.CharField(max_length=100)),
            ],
            options={
                'db_table': 'auth_permission',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='AuthUser',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('password', models.CharField(max_length=128)),
                ('last_login', models.DateTimeField(blank=True)),
                ('is_superuser', models.BooleanField()),
                ('username', models.CharField(max_length=150, unique=True)),
                ('first_name', models.CharField(max_length=150)),
                ('last_name', models.CharField(max_length=150)),
                ('email', models.CharField(max_length=254)),
                ('is_staff', models.BooleanField()),
                ('is_active', models.BooleanField()),
                ('date_joined', models.DateTimeField()),
            ],
            options={
                'db_table': 'auth_user',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='AuthUserGroups',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('group_id', models.IntegerField()),
            ],
            options={
                'db_table': 'auth_user_groups',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='AuthUserUserPermissions',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
            ],
            options={
                'db_table': 'auth_user_user_permissions',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='DjangoAdminLog',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('action_time', models.DateTimeField()),
                ('object_id', models.TextField(blank=True)),
                ('object_repr', models.CharField(max_length=200)),
                ('action_flag', models.SmallIntegerField()),
                ('change_message', models.TextField()),
            ],
            options={
                'db_table': 'django_admin_log',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='DjangoContentType',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('app_label', models.CharField(max_length=100)),
                ('model', models.CharField(max_length=100)),
            ],
            options={
                'db_table': 'django_content_type',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='DjangoMigrations',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('app', models.CharField(max_length=255)),
                ('name', models.CharField(max_length=255)),
                ('applied', models.DateTimeField()),
            ],
            options={
                'db_table': 'django_migrations',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='DjangoSession',
            fields=[
                ('session_key', models.CharField(max_length=40, primary_key=True, serialize=False)),
                ('session_data', models.TextField()),
                ('expire_date', models.DateTimeField()),
            ],
            options={
                'db_table': 'django_session',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='Orders',
            fields=[
                ('o_oid', models.CharField(max_length=15, primary_key=True, serialize=False)),
                ('o_departuredate', models.DateField()),
                ('o_departuretime', models.TimeField()),
                ('o_seattype', models.TextField()),
                ('o_orderstatus', models.TextField(blank=True)),
                ('o_departurestation', models.CharField(max_length=20)),
                ('o_arrivalstation', models.CharField(max_length=20)),
            ],
            options={
                'db_table': 'orders',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='Stations',
            fields=[
                ('s_stationname', models.CharField(max_length=20, primary_key=True, serialize=False)),
                ('s_city', models.CharField(max_length=20)),
            ],
            options={
                'db_table': 'stations',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='Trainitems',
            fields=[
                ('ti_tid', models.CharField(max_length=5, primary_key=True, serialize=False)),
                ('ti_seq', models.IntegerField()),
                ('ti_arrivaltime', models.TimeField(blank=True)),
                ('ti_departuretime', models.TimeField(blank=True)),
                ('ti_hseprice', models.FloatField(blank=True)),
                ('ti_sseprice', models.FloatField(blank=True)),
                ('ti_hsuprice', models.FloatField(blank=True)),
                ('ti_hsmprice', models.FloatField(blank=True)),
                ('ti_hslprice', models.FloatField(blank=True)),
                ('ti_ssuprice', models.FloatField(blank=True)),
                ('ti_sslprice', models.FloatField(blank=True)),
            ],
            options={
                'db_table': 'trainitems',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='Users',
            fields=[
                ('u_idnumber', models.CharField(max_length=18, primary_key=True, serialize=False)),
                ('u_name', models.CharField(max_length=20)),
                ('u_phone', models.CharField(max_length=11, unique=True)),
                ('u_creditcard', models.CharField(max_length=16)),
                ('u_username', models.CharField(max_length=20)),
            ],
            options={
                'db_table': 'users',
                'managed': False,
            },
        ),
    ]
