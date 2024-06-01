from django.shortcuts import render, redirect
from django.http import Http404
from django.http import HttpResponse
from django.contrib.auth import authenticate
from django.contrib import auth
from django.contrib.auth.models import User
from django.urls import resolve
from django.urls.exceptions import Resolver404
from django.views.decorators.csrf import csrf_exempt
from django.http import Http404
import json
from .models import UserProfile
#
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .forms import BloodPressureEntryForm
from .models import BloodPressureEntry

#
# Create your views here.

#decorector
def islogin(func_name):
	def wrapper(request,*args,**kwargs):
		if request.session.get('uname',''):
            # 說明當前處於登入狀態，直接呼叫func_name即可
			return func_name(request,*args,**kwargs)
		else:
			# 此時需要獲取使用者所點選的url，並儲存到cookie當中，再跳轉到登入頁面。
			response = redirect('/login/')
            # 使用者點選連結，會發送GET請求，對應的request物件中，含有要請求的url地址、請求引數，等等
			response.set_cookie('click_url',request.get_full_path())
			return response
	return wrapper

@islogin
def home(request):
    return render(request, 'home.html', locals())



def login(request):
	if request.method=='GET':
		return render(request, 'login.html', locals())

	elif request.method=='POST':
		try:
			name=request.POST['uname']
			password=request.POST['password']
		except:
			print(request.POST)
		user = auth.authenticate(username=name,password=password)
		if user is not None:
			if user.is_active:
				request.session['uname'] = name
				auth.login(request,user)
				user_click_url = request.COOKIES.get('click_url','')
				if not user_click_url:
                    # 說明是使用者直接訪問的就是登入頁面
					return redirect('/')
				else:
                    # 說明是點選其他連結，跳轉過來的。
					try:
						match = resolve(user_click_url)
						view_name = match.url_name
						return redirect(user_click_url)
					except Resolver404:
						return redirect('/')
			else:
				alert='帳號尚未啟用'
				print(alert)
		else:
			alert='帳號密碼輸入錯誤'
			print(alert)
		return render(request, 'login.html', locals())

def signup(request):
	if request.method == 'POST':
		print(request.POST)
		
		try:
			mUserprofile=UserProfile.objects.get(userID=request.POST['userID'])
		except UserProfile.DoesNotExist:
			mUserprofile=UserProfile(userID=request.POST['userID'])
			mUserprofile.userpwd=request.POST['pwd']
			mUserprofile.email=request.POST['useremail']
			mUserprofile.institutionID=request.POST['userinstitution']
			mUserprofile.save()

		try:
			user=User.objects.get(username=request.POST['userID'])
		except User.DoesNotExist:
			user = User.objects.create_user(username=request.POST['userID'],password=request.POST['pwd'])
			user.email=request.POST['useremail']
			user.is_active=False
			user.save()
			

		return render(request, 'register_finish.html', locals())
	elif request.method == 'GET':
		return render(request, 'register.html', locals())


def logout(request):
    auth.logout(request)
    return redirect('/login/')

@csrf_exempt
def check_user_existence(request):
	if request.method == 'POST':
		received_json_data=json.loads(request.body.decode("utf-8"))
		userID=received_json_data["userID"]
		try:
			User=UserProfile.objects.get(userID=userID)
			dic_Response={'Code':'A02','Status':'user exists'}	
			return HttpResponse(json.dumps(dic_Response, indent = 4,ensure_ascii=False), content_type="application/json")
		except UserProfile.DoesNotExist:
			dic_Response={'Code':'A01','Status':'user does not exist'}	
			return HttpResponse(json.dumps(dic_Response, indent = 4,ensure_ascii=False), content_type="application/json")	
		except:
			dic_Response={'Code':'E99','Status':'Error: {}. {}, line: {}'.format(sys.exc_info()[0],sys.exc_info()[1],sys.exc_info()[2].tb_lineno) }	
			print({'Code':'E99','Status':'Error: {}. {}, line: {}'.format(sys.exc_info()[0],sys.exc_info()[1],sys.exc_info()[2].tb_lineno)})
			return HttpResponse(json.dumps(dic_Response, indent = 4,ensure_ascii=False), content_type="application/json")				
	elif request.method == 'GET':
		redirect ('/')

def user_list(request):
    users = UserProfile.objects.all()  # 獲取所有用戶的數據
    return render(request, 'list.html', locals())  # 將數據傳遞給模板

def user_detail(request, user_id):
    try:
        # 直接使用objects.get方法來獲取對象
        user = User.objects.get(pk=user_id)
    except User.DoesNotExist:
        # 如果用戶不存在，則拋出Http404異常
        raise Http404("User does not exist")
    
    return render(request, 'detail.html', {'user': user})


@login_required
def enter_blood_pressure(request):
    if request.method == 'POST':
        form = BloodPressureEntryForm(request.POST)
        if form.is_valid():
            entry = form.save(commit=False)
            entry.user = request.user
            entry.save()
            return redirect('blood_pressure_success')
    else:
        form = BloodPressureEntryForm()
    return render(request, 'enter_blood_pressure.html', {'form': form})

@login_required
def blood_pressure_success(request):
    return render(request, 'blood_pressure_success.html')


@login_required
def list_blood_pressure_entries(request):
    entries = BloodPressureEntry.objects.filter(user=request.user)
    return render(request, 'list_blood_pressure_entries.html', {'entries': entries})
