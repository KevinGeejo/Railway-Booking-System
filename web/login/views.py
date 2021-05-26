from django.shortcuts import render, redirect
from rail import models


# Create your views here.

def index(request):
    pass
    return redirect("/rail/")


def login(request):
    # 不允许重复登陆
    if request.session.get('is_login', None):
        return redirect("/rail/")

    if request.method == "POST":
        username = request.POST.get('username')
        if username.strip():  # 确保用户名不为空
            try:
                user = models.Users.objects.get(u_username=username)
            except models.Users.DoesNotExist:
                message = '用户 ' + username + ' 未注册!'
                return render(request,
                              'login/login.html',
                              {'message': message})

            request.session['is_login'] = True
            request.session['user_name'] = user.u_name
            request.session['user_id'] = user.u_idnumber
            return redirect('/rail/')

            # tiny demo
            # if models.Users.objects.filter(u_username=username).exists():
            #     user = models.Users.objects.get(u_username=username)
            #     request.session['is_login'] = True
            #     request.session['user_name'] = user.u_name
            #     request.session['user_id'] = user.u_idnumber
            #     return redirect('/rail/')
            # else:
            #     message = '用户 ' + username + ' 未注册!'
            #     return render(request,
            #                   'login/login.html',
            #                   {'message': message})

    return render(request, 'login/login.html')


def register(request):
    # TODO: 注册, 插入用户
    return render(request, 'login/register.html')


def logout(request):
    if not request.session.get('is_login', None):
        # 如果本来就未登录，也就没有登出一说
        return redirect("/login/")
    request.session.flush()

    return redirect("/login/")
