from django.shortcuts import render, redirect
from rail import models


# Create your views here.

def index(request):
    pass
    return redirect("/rail/")


def login(request):
    if request.method == "POST":
        username = request.POST.get('username')
        if username.strip():  # 确保用户名不为空
            # TODO: 查询, 看看数据库里面有没有!
            return redirect('/rail/')
    return render(request, 'login/login.html')


def register(request):
    # TODO: 注册, 插入用户
    return render(request, 'login/register.html')


def logout(request):
    pass
    return redirect("/login/")
