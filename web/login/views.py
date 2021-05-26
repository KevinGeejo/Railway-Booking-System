from django.shortcuts import render, redirect
import rail.models
from . import forms


# Create your views here.

def index(request):
    if not request.session.get('user_stat', None):
        return redirect("/login/")
    return redirect("/rail/")


def login(request):
    # 不允许重复登陆
    if request.session.get('user_stat', None):
        return redirect("/rail/")

    if request.method == "POST":
        username = request.POST.get('username')
        if username.strip():  # 确保用户名不为空
            if username == 'admin':
                request.session['admin_stat'] = True
                return redirect('/rail/AdminPage')
            try:
                user = rail.models.Users.objects.get(
                    u_username=username)
            except rail.models.Users.DoesNotExist:
                message = '用户 ' + username + ' 未注册!'
                return render(request,
                              'login/login.html',
                              {'message': message})

            request.session['user_stat'] = True
            request.session['user_name'] = user.u_name
            request.session['user_id'] = user.u_idnumber
            return redirect('/rail/')

    return render(request, 'login/login.html')


def register(request):
    if request.session.get('user_stat', None):
        return redirect('/index/')
    if request.method == 'POST':
        username = request.POST.get('u_username')
        name = request.POST.get('u_name')
        creditcard = request.POST.get('u_creditcard')
        phone = request.POST.get('u_phone')
        idnumber = request.POST.get('u_idnumber')

        message = '请检查您填写的内容是否符合要求!'

        # 检验重复
        same_username_user = rail.models.Users.objects.filter(
            u_username=username)
        if same_username_user:
            message = '用户名已存在, 请尝试使用其他用户名'
            return render(request, 'login/register.html',
                          locals())

        same_phone_user = rail.models.Users.objects.filter(
            u_phone=phone)
        if same_phone_user:
            message = '电话号码已被其他用户注册, 请更换电话号码'
            return render(request, 'login/register.html',
                          locals())

        same_idnumber_user = rail.models.Users.objects.filter(
            u_idnumber=idnumber)
        if same_idnumber_user:
            message = '身份证已被其他用户注册, 请检查您的身份证信息'
            return render(request, 'login/register.html',
                          locals())

        new_user = rail.models.Users()
        new_user.u_name = name
        new_user.u_username = username
        new_user.u_phone = phone
        new_user.u_idnumber = idnumber
        new_user.u_creditcard = creditcard
        new_user.save()
        return render(request,
                      "login/login.html",
                      {'message': '注册成功, 请登录.'})

    return render(request, 'login/register.html')


def logout(request):
    if not request.session.get('user_stat', None):
        # 如果本来就未登录，也就没有登出一说
        return redirect("/login/")
    request.session.flush()

    return redirect("/login/")
