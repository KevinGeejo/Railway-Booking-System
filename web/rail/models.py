# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group_id = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group_id'),)


class AuthUserUserPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.SmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    id = models.BigAutoField(primary_key=True)
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'


class Orders(models.Model):
    o_oid = models.CharField(primary_key=True, max_length=15)
    o_idnumber = models.ForeignKey('Users', models.DO_NOTHING, db_column='o_idnumber')
    o_tid = models.ForeignKey('Trainitems', models.DO_NOTHING, db_column='o_tid')
    o_departuredate = models.DateField()
    o_departuretime = models.TimeField()
    o_seattype = models.TextField()  # This field type is a guess.
    o_orderstatus = models.TextField(blank=True)  # This field type is a guess.
    o_departurestation = models.CharField(max_length=20)
    o_arrivalstation = models.CharField(max_length=20)

    class Meta:
        managed = False
        db_table = 'orders'

    def __str__(self):
        return self.o_oid


class Stations(models.Model):
    s_stationname = models.CharField(primary_key=True, max_length=20)
    s_city = models.CharField(max_length=20)

    class Meta:
        managed = False
        db_table = 'stations'

    def __str__(self):
        return self.s_stationname


class Trainitems(models.Model):
    ti_tid = models.CharField(primary_key=True, max_length=5)
    ti_seq = models.IntegerField()
    ti_arrivalstation = models.ForeignKey(Stations, models.DO_NOTHING, db_column='ti_arrivalstation')
    ti_arrivaltime = models.TimeField(blank=True, null=True)
    ti_departuretime = models.TimeField(blank=True, null=True)
    ti_hseprice = models.FloatField(blank=True, null=True)
    ti_sseprice = models.FloatField(blank=True, null=True)
    ti_hsuprice = models.FloatField(blank=True, null=True)
    ti_hsmprice = models.FloatField(blank=True, null=True)
    ti_hslprice = models.FloatField(blank=True, null=True)
    ti_ssuprice = models.FloatField(blank=True, null=True)
    ti_sslprice = models.FloatField(blank=True, null=True)
    ti_offsetday = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'trainitems'
        unique_together = (('ti_tid', 'ti_arrivalstation'),)


class Users(models.Model):
    u_idnumber = models.CharField(primary_key=True, max_length=18)
    u_name = models.CharField(max_length=20)
    u_phone = models.CharField(unique=True, max_length=11)
    u_creditcard = models.CharField(max_length=16)
    u_username = models.CharField(max_length=20)

    class Meta:
        managed = False
        db_table = 'users'

    def __str__(self):
        return self.u_idnumber
