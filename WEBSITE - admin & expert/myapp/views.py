import datetime

from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import Group
from django.core.files.storage import FileSystemStorage
from django.db.models import Q
from django.http import HttpResponse, JsonResponse
from django.shortcuts import render, redirect
# from pyasn1_modules.rfc7292 import localKeyId

# Create your views here.
from fitnessapp import settings
from myapp.models import *


def logout(request):
    request.session.flush()
    return HttpResponse('''<script>alert("Logouted ");window.location='/'</script>''')


def web_login(request):
    if 'submit' in request.POST:
        username = request.POST['username']
        password = request.POST['password']

        a= authenticate(username=username,password=password)
        if a is not None:
            if a.groups.filter(name='admin').exists():
                login(request,a)
                return HttpResponse('''<script>alert("Login successfully ");window.location='/admin_home'</script>''')
            elif a.groups.filter(name='trainer').exists():
                if Experts.objects.get(Login_id=a.id).status=='pending':
                    return HttpResponse('''<script>alert("Your account is pending");window.location='/'</script>''')
                else:
                    login(request,a)
                    return HttpResponse('''<script>alert("Login successfully ");window.location='/expert_home'</script>''')
            else:
                return HttpResponse('''<script>alert("Invalid ");window.location='/'</script>''')
        else:
            return HttpResponse('''<script>alert("Invalid ");window.location='/'</script>''')
    return  render(request,'loginindex.html')


@login_required(login_url='/')
def admin_home(request):
    return render(request,'admin/adminhome.html')

def expert_reg(request):
    if 'submit' in request.POST:
        name=request.POST['name']
        place=request.POST['place']
        post=request.POST['post']
        district=request.POST['district']
        phone=request.POST['phone']
        email=request.POST['email']
        type=request.POST['type']
        password=request.POST['password']

        image=request.FILES['image']
        fs=FileSystemStorage()

        fn=fs.save(image.name,image)
        path=fs.url(fn)

        proof=request.FILES['proof']
        fs1=FileSystemStorage()

        fn1=fs1.save(proof.name,proof)
        path1=fs1.url(fn1)
        if User.objects.filter(username=email).exists():
            return HttpResponse('''<script>alert("User already exists");window.location='/'</script>''')
        else:


            b = User.objects.create_user(username=email, password=password)
            b.groups.add(Group.objects.get(name='trainer'))

            a=Experts()
            a.Login=b
            a.name=name
            a.type=type
            a.place=place
            a.post=post
            a.district=district
            a.phone=phone
            a.email=email
            a.idproof=path1
            a.image=path
            a.save()
            return HttpResponse('''<script>alert("Registered ");window.location='/'</script>''')


    return render(request,'admin/add_expert.html')



@login_required(login_url='/')
def admin_verify_expert(request):
    a=Experts.objects.all()
    return render(request,'admin/view expert.html',{'a':a})

def admin_accept_expert(request,id):
    a=Experts.objects.get(Login_id=id)
    a.status='accept'
    a.save()
    return HttpResponse('''<script>alert("Accepted ");window.location='/admin_verify_expert'</script>''')


def admin_delete_expert(request,id):
    print(id)
    print(id)
    print(id)
    print(id)
    a=Experts.objects.get(Login_id=id)
    user=User.objects.get(id=id)
    user.delete()
    a.delete()
    return HttpResponse('''<script>alert("Deleted ");window.location='/admin_verify_expert'</script>''')


@login_required(login_url='/')
def admin_verify_expert_post(request):
    f=request.POST['f']
    a=Experts.objects.filter(name__icontains=f)
    if not a:  # If queryset is empty
        return HttpResponse('''<script>alert("Expert  not found");window.location='/admin_verify_expert'</script>''')

    return render(request,'admin/view expert.html',{'a':a})


@login_required(login_url='/')
def admin_view_expert_feedback(request,id):
    b=Expertfeedback.objects.filter(EXPERT_id=id).order_by('-id')
    return render(request,'admin/admin_view_expert_feedback.html',{'data':b})

@login_required(login_url='/')
def admin_view_user(request):
    a=Customer.objects.all()
    return render(request,'admin/admin_view_user.html',{'a':a})



@login_required(login_url='/')
def admin_view_complaints(request):
    a=Complaints.objects.all()
    return render(request,'admin/admin_view_complaints.html',{'a':a})


@login_required(login_url='/')
def assign_work(request):
    b=Experts.objects.all()
    c=Customer.objects.all()
    print(c)
    if 'submit' in request.POST:
        work=request.POST['work']
        details=request.POST['details']
        EXPERT=request.POST['EXPERT']
        CUSTOMER=request.POST['CUSTOMER']


        a=Workassign()
        a.work=work
        a.details=details
        a.EXPERT=Experts.objects.get(id=EXPERT)
        a.Customer=Customer.objects.get(id=CUSTOMER)
        a.date=datetime.datetime.now().today().date()
        a.status='Assigned'
        a.save()
        return HttpResponse('''<script>alert("Assigned ");window.location='/admin_view_assign'</script>''')
    return render(request,'admin/assign work.html',{'data':b,'customer':c})


@login_required(login_url='/')
def admin_view_assign(request):
    a=Workassign.objects.all()
    return render(request,'admin/view work.html',{'data':a})


def delete_assign_work(request,id):
    a=Workassign.objects.get(id=id)
    a.delete()
    return HttpResponse('''<script>alert("Deleted ");window.location='/admin_view_assign'</script>''')




@login_required(login_url='/')
def admin_reply(request,id):
    a=Complaints.objects.get(id=id)

    return render(request,'admin/reply.html',{'data':a})

def admin_reply_post(request):
    id=request.POST['id']
    reply=request.POST['c']
    c=Complaints.objects.get(id=id)
    c.reply=reply
    c.status="replied"
    c.save()
    return HttpResponse('''<script>alert("Replied ");window.location='/admin_view_complaints'</script>''')



@login_required(login_url='/')
def expert_home(request):
    return render(request,'expert/expertindex.html')

@login_required(login_url='/')
def expert_view_workout(request):
    ob=workout_main.objects.all()
    return render(request,'expert/view_workout_main.html',{"data":ob})

@login_required(login_url='/')
def view_workout_details(request,id):
    request.session['user_id']=id
    ob=workout_sub.objects.filter(USER=id,EXPERT__Login_id=request.user.id)
    ob=workout_sub.objects.filter(USER=id,EXPERT__Login_id=request.user.id)
    print(ob)
    return render(request,'expert/view_workout.html',{"data":ob})

@login_required(login_url='/')
def expert_add_workout(request):
    ob=workout_main.objects.all()
    return render(request,'expert/add_workout_sub.html',{"data":ob})

@login_required(login_url='/')
def expert_add_workout_post(request):
    print(request.POST,"***********************")
    category=request.POST['category']
    title=request.POST['title']
    description=request.POST['description']
    video=request.FILES['videoo']
    k = request.session['user_id']

    ob=workout_sub()
    ob.EXPERT=Experts.objects.get(Login=request.user.id)
    ob.USER=Customer.objects.get(id=k)
    ob.MAIN=workout_main.objects.get(id=category)
    ob.title=title
    ob.description=description
    ob.video=video
    ob.save()

    return redirect(f'/view_workout_details/{k}')

def delete_workout(request,id):
    workout_sub.objects.filter(id=id).delete()
    k = request.session['user_id']
    return redirect(f'/view_workout_details/{k}#about')



@login_required(login_url='/')
def expertview_user(request):
    assign_users = Workassign.objects.filter(EXPERT__Login_id=request.user.id)
    print(assign_users,'assign_users')
    return render(request,'expert/view user.html',{'data':assign_users})





@login_required(login_url='/')
def chatwithuser(request):
    ob = User.objects.all()
    return render(request,"expert/fur_chat.html",{'val':ob})




@login_required(login_url='/')
def expert_chat_to_user(request, id):
    request.session["userid"] = id
    cid = str(request.session["userid"])
    request.session["new"] = cid
    qry = Customer.objects.get(Login_id=cid)
    print(qry.Login_id,'login----------')

    # return render(request, "expert/Chat.html", { 'name': qry.Name, 'toid': cid})
    return render(request, "expert/Chat.html", {'photo': qry.Photo, 'name': qry.Name, 'toid': cid})


def chat_view(request):
    fromid = request.user.id

    toid = request.session["userid"]
    print(fromid,'===========,fromid ')
    print(toid,'===========toid ')

    # qry = User.objects.get(LOGIN_id=request.session["userid"])
    from django.db.models import Q
    res = Chat.objects.filter(Q(FROMID_id=fromid, TOID_id=toid) | Q(FROMID_id=toid, TOID_id=fromid)).order_by('id')
    l = []
    # print(qry.Name,'userssssssssss')

    for i in res:
        l.append({"id": i.id, "message": i.message, "to": i.TOID_id, "date": i.date, "from": i.FROMID_id})

    # return JsonResponse({'photo': qry.image, "data": l, 'name': qry.name, 'toid': request.session["userid"]})
    return JsonResponse({ "data": l, 'toid': request.session["userid"]})



def chat_send(request, msg):
    lid = request.user.id
    toid = request.session["userid"]
    print(lid, '===========fromid ')
    print(toid, '===========toid ')
    message = msg

    import datetime
    d = datetime.datetime.now().date()
    chatobt = Chat()
    chatobt.message = message
    chatobt.TOID_id = toid
    chatobt.FROMID_id = lid
    chatobt.date = d
    chatobt.save()

    return JsonResponse({"status": "ok"})




def expertchatview(request):

    users_with_accepted_requests = User.objects.all()

    # Prepare the data to be returned
    data = []
    for user in users_with_accepted_requests:
        r = {
            "name": user.name,
            "image": user.image,
            "email": user.email,
            "loginid": user.LOGIN.id
        }
        data.append(r)
    print(data)
    return JsonResponse(data, safe=False)


def expertcoun_insert_chat(request,msg,id):
    print("===",msg,id)
    ob=Chat()
    ob.FROMID=User.objects.get(id=request.session['lid'])
    ob.TOID=User.objects.get(id=id)
    ob.message=msg
    ob.date=datetime.datetime.now().strftime("%Y-%m-%d")
    ob.save()

    return JsonResponse({"task":"ok"})
    # refresh messages chatlist


def expertcoun_msg(request,id):

    ob1=Chat.objects.filter(FROMID_id=id,TOID__id=request.session['lid'])
    ob2=Chat.objects.filter(FROMID_id=request.session['lid'],TOID_id=id)
    combined_chat = ob1.union(ob2)
    combined_chat=combined_chat.order_by('id')
    res=[]
    for i in combined_chat:
        res.append({"from_id":i.FROMID.id,"msg":i.message,"date":i.date,"chat_id":i.id})

    obu=User.objects.get(LOGIN_id=id)


    return JsonResponse({"data":res,"name":obu.name,"photo":obu.image,"user_lid":obu.LOGIN.id})


@login_required(login_url='/')
def expert_view_feedback(request):
    a=Expertfeedback.objects.filter(EXPERT__Login_id=request.user.id)
    return render(request,'expert/view feedback.html',{'data':a})



@login_required(login_url='/')
def expert_view_assignedwork(request):

    a=Workassign.objects.filter(EXPERT__Login_id=request.user.id)
    return render(request,'expert/view assigned work.html',{'data':a})




@login_required(login_url='/')
def add_diet_chart(request):

    return render(request,"expert/add dataset diet.html")

# @login_required(login_url='/')
# def add_diet_chart_post(request):
#
#     Name=request.POST['textfield']
#     Date=request.POST['textfield2']
#     Diet_charts=request.FILES['fileField3']
#     BMI = request.POST['BMI']
#     Alcoholabuse = request.POST['Alcoholabuse']
#     Allergies = request.POST['Allergies']
#     Arthritis = request.POST['Arthritis']
#     Asthma = request.POST['Asthma']
#     Bloodpressure = request.POST['Bloodpressure']
#     Cancer = request.POST['Cancer']
#     Cholestrol = request.POST['Cholestrol']
#     Depression = request.POST['Depression']
#     Diabetes = request.POST['Diabetes']
#     Druguse = request.POST['Druguse']
#     Gender = request.POST['Gender']
#     Headaches = request.POST['Headaches']
#     Heartproblem = request.POST['Heartproblem']
#     Kidney = request.POST['Kidney']
#     Liver = request.POST['Liver']
#     Obicity = request.POST['Obicity']
#     Pregnancy = request.POST['Pregnancy']
#     Smoking = request.POST['Smoking']
#     Stroke = request.POST['Stroke']
#
#
#     yobj=Diet_chart()
#     yobj.Name=Name
#     yobj.Date=Date
#
#     fs = FileSystemStorage()
#     date = datetime.datetime.now().strftime("%Y%m%d-%H%M%S") + ".jpg"
#     fn = fs.save(date, Diet_charts)
#     path = fs.url(date)
#     yobj.Dietplan=path
#     yobj.Time= datetime.datetime.now().strftime("%H:%M:%S")
#     yobj.BMI=BMI
#     yobj.Alcoholabuse=Alcoholabuse
#     yobj.Allergies=Allergies
#     yobj.Arthritis=Arthritis
#     yobj.Asthma=Asthma
#     yobj.Bloodpressure=Bloodpressure
#     yobj.Cancer=Cancer
#     yobj.Cholestrol=Cholestrol
#     yobj.Depression=Depression
#     yobj.Diabetes=Diabetes
#     yobj.Druguse=Druguse
#     yobj.Gender=Gender
#     yobj.Headaches=Headaches
#     yobj.Heartproblem=Heartproblem
#     yobj.Kidney=Kidney
#     yobj.Liver=Liver
#     yobj.Obicity=Obicity
#     yobj.Pregnancy=Pregnancy
#     yobj.bmi=BMI
#     yobj.Smoking=Smoking
#     yobj.Stroke=Stroke
#     yobj.save()
#
#
#     return HttpResponse('''<script>alert('diet add');window.location="/add_diet_chart"</script>''')
#
#

@login_required(login_url='/')
def View_diet_chart(request):

    k = Diet_chart.objects.all()
    return render(request, "expert/view_diet_chart.html", {'data': k})


@login_required(login_url='/')
def View_diet_chart_post(request):

    search = request.POST['textfield']
    u = Diet_chart.objects.filter(Customer__Name__icontains=search)
    return render(request, "expert/view_diet_chart.html", {'data': u})






def delete_diet_chart(request,id):
    Diet_chart.objects.filter(id=id).delete()
    return HttpResponse('''<script>alert('Deleted');window.location="/View_diet_chart"</script>''')



def Edit_diet_chart(request,id):

    oi= Diet_chart.objects.get(id=id)
    diet = Diet()
    if request.method == 'POST':
        diet.health_condition = oi.health_condition
        diet.DIET_CHART = oi
        diet.date = datetime.datetime.now().strftime("%Y-%m-%d")
        diet.dietplan = request.POST['dietplan']
        diet.type = oi.main_health_concern
        diet.excersiseplan = request.POST['excersiseplan']
        diet.save()
    return render(request,"expert/Edit_diet_chart.html",{'data':oi,'id':id})

def flutter_login(request):
    username = request.POST['username']
    password = request.POST['psw']
    a = authenticate(username=username,password=password)
    if a is not None:
        if a.groups.filter(name='user').exists():
            return JsonResponse({"status": "ok", "lid":str(a.id),'type':'user'})
        else:
            return JsonResponse({"status": "no"})
    else:
        return JsonResponse({"status":"no"})



def user_reg(request):
    name=request.POST['name']
    dob=request.POST['dob']
    email=request.POST['email']
    place=request.POST['place']
    gender=request.POST['gender']
    district=request.POST['district']
    post=request.POST['post']
    pin=request.POST['pin']
    phone=request.POST['phone']
    password=request.POST['password']
    bloodtype=request.POST['bloodtype']
    photo=request.FILES['image']
    fs=FileSystemStorage()
    path=fs.save(photo.name,photo)



    aa=User.objects.filter(username=email)
    if aa.exists():
        return JsonResponse({"status": "not ok"})

    user = User.objects.create_user(username=email, password=password,first_name=name)
    user.groups.add(Group.objects.get(name='user'))

    f = Customer()
    f.Name = name
    f.Gender = gender
    f.Place = place
    f.Pin = pin
    f.Post = post
    f.Bloodtype = bloodtype
    f.Photo = path
    f.Email = email
    f.Phone = phone
    f.Login = user
    f.District = district
    f.Dob = dob
    f.save()

    return JsonResponse({"status": "ok"})



def view_diet_charts(request):
    diet_charts = Diet.objects.filter(DIET_CHART__Customer__Login_id=request.POST['lid']).values()
    return JsonResponse({"status": "ok", "data": list(diet_charts)})

import json
import numpy as np

def cosine_similarity(list1, list2):
    # Convert lists to numpy arrays
    vector1 = np.array(list1)
    vector2 = np.array(list2)

    # Calculate the dot product
    dot_product = np.dot(vector1, vector2)

    # Calculate the magnitudes of the vectors
    magnitude1 = np.linalg.norm(vector1)
    magnitude2 = np.linalg.norm(vector2)

    # Calculate cosine similarity
    similarity = dot_product / (magnitude1 * magnitude2)

    return similarity

import json
import logging
logger = logging.getLogger(__name__)


def generate_diet_plan(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            logger.info(f"Received diet plan request: {data}")

            client = genai.Client(api_key=settings.GEMINI_API_KEY)
            prompt = build_diet_prompt(data)

            generate_config = types.GenerateContentConfig(
                temperature=0.7,
                top_p=0.8,
                top_k=40,
                max_output_tokens=2048,  # Ensure this is high enough for a 7-day plan
                safety_settings=[
                    types.SafetySetting(category='HARM_CATEGORY_HARASSMENT', threshold='BLOCK_MEDIUM_AND_ABOVE'),
                    types.SafetySetting(category='HARM_CATEGORY_HATE_SPEECH', threshold='BLOCK_MEDIUM_AND_ABOVE'),
                    types.SafetySetting(category='HARM_CATEGORY_SEXUALLY_EXPLICIT', threshold='BLOCK_MEDIUM_AND_ABOVE'),
                    types.SafetySetting(category='HARM_CATEGORY_DANGEROUS_CONTENT', threshold='BLOCK_ONLY_HIGH'),
                    # Adjusted to prevent medical block
                ]
            )

            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=prompt,
                config=generate_config
            )

            # --- IMPROVED RESPONSE HANDLING ---

            # Check if the response was blocked by safety filters
            if not response.candidates or not response.candidates[0].content.parts:
                finish_reason = response.candidates[0].finish_reason if response.candidates else "Unknown"
                logger.error(f"AI Blocked Content. Reason: {finish_reason}")
                return JsonResponse({
                    'success': False,
                    'error': f'The AI could not complete the plan (Reason: {finish_reason}). Try adjusting your health conditions.'
                }, status=400)

            full_text = response.text


            # Check if the text was cut off (MAX_TOKENS reached)
            finish_reason = response.candidates[0].finish_reason
            if finish_reason == "MAX_TOKENS":
                full_text += "\n\n...(Plan truncated due to length limits)..."
                logger.warning("Response reached MAX_TOKENS and was truncated.")

            logger.info("Successfully generated diet plan")
            return JsonResponse({
                'success': True,
                'diet_plan': full_text,
                'recommendation': 'AI-generated personalized diet plan'
            })

        except Exception as e:
            logger.error(f"Error generating diet plan: {str(e)}")
            return JsonResponse({
                'success': False,
                'error': f'Internal Server Error: {str(e)}'
            }, status=500)

    return JsonResponse({'error': 'Method not allowed'}, status=405)

def build_diet_prompt(data):
    gender = data.get('Gender', 'Not specified')
    bmi = data.get('BMI', 'Not specified')
    blood_pressure = data.get('BloodPressure', 'Not specified')
    main_health_concern = data.get('MainHealthConcern', 'Not specified')
    lifestyle = data.get('Lifestyle', 'Not specified')
    health_conditions = data.get('HealthConditions', [])
    preweekcalories = data.get('PrevWeekCalories', '0')
    lid = data.get('lid', 'Not specified')

    # 1. Calculate BMI category
    bmi_category = "Not specified"
    try:
        bmi_value = float(bmi)
        if bmi_value < 18.5: bmi_category = "Underweight"
        elif 18.5 <= bmi_value < 25: bmi_category = "Normal weight"
        elif 25 <= bmi_value < 30: bmi_category = "Overweight"
        else: bmi_category = "Obese"
    except (ValueError, TypeError):
        pass

    # 2. Calculate Average Daily Calorie
    avg_calorie = 0.0
    try:
        avg_calorie = round(float(preweekcalories) / 7, 2)
    except (ValueError, TypeError, ZeroDivisionError):
        avg_calorie = "Unknown"

    conditions_text = ", ".join(health_conditions) if health_conditions else "None reported"

    # 3. THE REFINED PROMPT (Optimized for length and detail)
    prompt = f"""
    ACT as an expert nutritionist. Create a highly detailed daily diet profile and a weekly variety guide.

    USER DATA:
    - Baseline: {avg_calorie} kcal/day. 
    - Goal: {main_health_concern}. 
    - Profile: {gender}, BMI {bmi} ({bmi_category}), BP {blood_pressure}.
    - Medical: {conditions_text}.

    STRICT STRUCTURE (Stay within 800 words):
    1. **Caloric Target**: State the baseline vs new target (surplus/deficit).
    2. **Safety**: ⚠️ Specific foods to avoid for {conditions_text}.

    FORMATTING:
    - Use bold text for all measurements (e.g., **200g**).
    - Use a professional, concise tone.

    DISCLAIMER: AI-generated educational guide, not medical advice.
    """

    # 4. Database Operations
    try:
        from .models import Diet_chart, Customer
        die_chart = Diet_chart()
        die_chart.gender = gender
        die_chart.bmi_category = bmi_category
        die_chart.blood_pressure = blood_pressure
        die_chart.main_health_concern = main_health_concern
        die_chart.lifestyle = lifestyle
        die_chart.health_condition = conditions_text

        cus_id = Customer.objects.filter(Login_id=lid).first()
        if cus_id:
            die_chart.Customer = cus_id
            die_chart.save()
    except Exception as e:
        print(f"Database save error: {e}")

    return prompt

def user_view_expert(request):
    a=Experts.objects.all()
    l=[]
    for i in a:
        l.append({
            'id':i.id,'image':i.image,'name':i.name,'place':i.place,'LOGIN':str(i.Login.id),
        })
    print(l)
    return JsonResponse({
        'status':'ok','data':l
    })




def send_complaint(request):
    lid=request.POST['lid']
    complaint=request.POST['complaint']

    a=Complaints()
    a.Customer=Customer.objects.get(Login_id=lid)
    a.complaints=complaint
    a.date=datetime.datetime.now().today().date()
    a.reply='pending'
    a.save()
    return JsonResponse({"status": "ok"})


def user_view_reply(request):
    lid=request.POST['lid']
    a=Complaints.objects.filter(Customer__Login_id=lid)
    l=[]
    for i in a:
        l.append({'id': i.id,
                  'complaint': i.complaints,
                  'reply': i.reply,
                  'date': str(i.date) })
    return JsonResponse({"status": "ok",'data':l})


def user_viewchat(request):
    fromid = request.POST["from_id"]
    toid = request.POST["to_id"]
    # lmid = request.POST["lastmsgid"]    from django.db.models import Q

    res = Chat.objects.filter(Q(FROMID_id=fromid, TOID_id=toid) | Q(FROMID_id=toid, TOID_id=fromid)).order_by("id")
    l = []

    for i in res:
        l.append({"id": i.id, "msg": i.message, "from": i.FROMID_id, "date": i.date, "to": i.TOID_id})

    return JsonResponse({"status":"ok",'data':l})


def user_sendchat(request):
    FROM_id=request.POST['from_id']
    TOID_id=request.POST['to_id']
    print(FROM_id)
    print(TOID_id)
    msg=request.POST['message']

    from  datetime import datetime
    c=Chat()
    c.FROMID_id=FROM_id
    c.TOID_id=TOID_id
    c.message=msg
    c.date=datetime.now()
    c.save()
    return JsonResponse({'status':"ok"})


def send_feedback(request):
    lid=request.POST['lid']
    eid=request.POST['eid']
    feedback=request.POST['feedback']
    rating=request.POST['rating']

    a=Expertfeedback()
    a.Customer=Customer.objects.get(Login_id=lid)
    a.EXPERT=Experts.objects.get(id=eid)
    a.feedback=feedback
    a.rating=rating
    a.date=datetime.datetime.now().today().date()
    a.save()
    return JsonResponse({"status": "ok"})


def add_water(request):
    lid=request.POST['lid']
    type=request.POST['type']
    alert=request.POST['alert']

    a=Water()
    a.Customer=Customer.objects.get(Login_id=lid)
    a.type=type
    a.alert=alert
    a.date=datetime.datetime.now().today()
    a.save()
    return JsonResponse({"status": "ok"})


def user_view_waterlo(request):
    lid=request.POST['lid']
    l=[]
    a=Water.objects.filter(Customer__Login_id=lid)
    for i in a:
        l.append({
            'id':i.id,'type':i.type,'alert':i.alert,'date':str(i.date)
        })
    return JsonResponse({"status": "ok",'data':l})


def delete_water_log(request):
    wid=request.POST['wid']
    a=Water.objects.get(id=wid)
    a.delete()
    return JsonResponse({"status": "ok"})

def delete_food_log(request):
    wid=request.POST['wid']
    a=Food.objects.get(id=wid)
    a.delete()
    return JsonResponse({"status": "ok"})


def user_view_workout(request):
    l=[]
    a=workout_main.objects.all()
    for i in a:
        l.append({
            'id':str(i.id),
            'workout':i.workout,
        })
    return JsonResponse({"status": "ok",'data':l})

def user_view_full_workout(request):
    main=request.POST['mainid']
    lid=request.POST['lid']
    l=[]
    a=workout_sub.objects.filter(MAIN=main,USER__Login_id=lid)
    for i in a:
        video_url = request.build_absolute_uri(i.video.url)
        l.append({
            'id':str(i.id),
            'title':i.title,
            'description':i.description,
            'video':str(video_url),
        })
    return JsonResponse({"status": "ok",'data':l})


# def add_food(request):
#     lid=request.POST['lid']
#     type=request.POST['type']
#     gram=float(request.POST['gram'])
#     a=Food()
#     a.USER=User.objects.get(LOGIN_id=lid)
#     a.type=type
#     a.gram=gram
#     a.callorie=gram
#     a.date=datetime.datetime.now().today()
#     a.save()
#     return JsonResponse({"status": "ok"})


def user_view_foodlo(request):
    lid=request.POST['lid']
    l=[]
    a=Food.objects.filter(Customer__Login_id=lid)
    for i in a:
        l.append({
            'id':i.id,'type':i.type,'gram':str(i.gram),'date':str(i.date),'callorie':str(i.callorie)
        })
    return JsonResponse({"status": "ok",'data':l})













from .cal import getcalval

import datetime
from django.http import JsonResponse
from .models import Food, User

calories_per_gram = {
    # Fruits
    'apple': 0.52,
    'banana': 0.89,
    'broccoli': 0.34,
    'orange': 0.50,
    'apricot': 0.44,
    'grape': 0.54,
    'kiwi': 0.52,
    'mango': 0.62,
    'peach': 0.32,
    'lime': 0.22,
    'dates': 0.52,
    'guava': 0.62,
    'papaya': 0.82,
    'lemon': 0.32,
    'pineapple': 0.50,
    'strawberry': 0.32,
    'watermelon': 0.30,
    'blueberry': 0.57,
    'cherry': 0.63,
    'pomegranate': 0.83,

    # Vegetables
    'carrot': 0.41,
    'tomato': 0.18,
    'potato': 0.77,
    'onion': 0.40,
    'spinach': 0.23,
    'cauliflower': 0.25,
    'cucumber': 0.16,
    'bell pepper': 0.20,
    'eggplant': 0.24,
    'zucchini': 0.17,

    # Grains and Legumes
    'rice': 1.12,
    'chapati': 0.82,
    'dal': 1.10,
    'quinoa': 1.20,
    'lentils': 1.16,
    'chickpeas': 1.64,
    'oats': 3.89,
    'barley': 3.52,
    'buckwheat': 3.43,

    # Dairy
    'milk': 0.42,
    'yogurt': 0.61,
    'cheese': 4.02,
    'butter': 7.17,
    'paneer': 2.10,
    'ice cream': 2.06,

    # Meats and Fish
    'chicken': 2.39,
    'beef': 2.50,
    'pork': 2.42,
    'lamb': 2.94,
    'salmon': 2.08,
    'tuna': 1.32,
    'shrimp': 1.00,
    'egg': 1.43,

    # Indian Dishes
    'ghee roast': 1.10,
    'ghee rice': 1.4,
    'biriyani': 1.50,
    'chicken biriyani': 1.80,
    'egg biryani': 1.80,
    'beef biryani': 1.90,
    'pork biryani': 2.20,
    'kuzhi mandhi': 2.40,
    'alfaham mandhi': 2.40,
    'chicken tandoori': 2.10,
    'alfaham': 1.40,
    'samosa': 2.50,
    'chicken samosa': 2.80,
    'beef samosa': 2.90,
    'egg samosa': 2.20,
    'egg puffs': 1.20,
    'chicken puffs': 1.50,
    'puffs': 1.00,
    'pathiri': 1.00,
    'pani puri': 3.00,
    'aloo paratha': 1.50,
    'roti': 0.80,
    'dosa': 1.60,
    'idli': 1.10,
    'upma': 1.20,
    'pongal': 1.40,
    'vada': 2.20,
    'bhature': 2.50,
    'chole': 1.30,
    'pulao': 1.20,
    'kheer': 1.80,
    'gulab jamun': 3.00,
    'rasgulla': 2.50,
    'jalebi': 3.50,
    'laddu': 4.00,
    'sambar': 0.70,
    'vegetable curry': 1.00,
    'fish curry': 1.50,
    'chicken curry': 2.00,
    'mutton curry': 2.50,
    'egg curry': 1.50,
    'paneer butter masala': 2.20,
    'palak paneer': 1.80,
    'aloo gobi': 1.20,
    'baingan bharta': 1.00,
    'butter chicken': 2.50,
    'tandoori chicken': 2.00,
    'naan': 2.00,
    'paratha': 2.00,
    'porotta': 2.00,
    'pav bhaji': 2.20,
    'bhel puri': 2.50,
    'sev puri': 3.00,
    'dhokla': 1.10,
    'kachori': 3.50,
    'poha': 1.20,
    'masala dosa': 1.80,
    'mysore pak': 4.00,
    'halwa': 3.50,
    'barfi': 3.00,
    'peda': 3.50,
    'tea': 1.0,
    'coffee': 1.0,
    'boost': 1.20,
    'horlicks': 1.20,
    'bournvita ': 1.20,
    'pepsi ': 1.80,
    'cola': 1.80,
    'fruity': 1.80,
    'chappathi': 1.50,
    'rotti': 1.50,

    # Chinese Dishes
    'fried rice': 1.63,
    'chicken fried rice': 1.83,
    'egg fried rice': 1.63,
    'beef fried rice': 1.99,
    'spring roll': 1.50,
    'dim sum': 2.00,
    'sweet and sour chicken': 1.92,
    'kung pao chicken': 2.00,
    'mapo tofu': 1.00,
    'peking duck': 3.00,
    'wonton soup': 0.50,
    'chicken fry': 2.50,
    'puttu': 2.00,

    # Japanese Dishes
    'sushi': 1.30,
    'tempura': 2.00,
    'ramen': 1.80,
    'miso soup': 0.40,
    'teriyaki chicken': 1.90,
    'sashimi': 1.20,
    'udon': 1.30,

    # Italian Dishes
    'pizza': 2.66,
    'pasta': 1.58,
    'lasagna': 1.85,
    'risotto': 1.45,
    'tiramisu': 2.40,
    'gelato': 1.60,
    'panini': 2.00,

    # Mexican Dishes
    'taco': 2.00,
    'burrito': 2.50,
    'quesadilla': 2.20,
    'enchilada': 2.30,
    'guacamole': 1.67,
    'churros': 2.60,
    'tamales': 2.50,

    # Middle Eastern Dishes
    'hummus': 1.66,
    'falafel': 2.50,
    'shawarma': 2.20,
    'tabbouleh': 1.20,
    'baba ganoush': 1.00,
    'kebab': 2.30,
    'baklava': 4.00,

    # Other International Dishes
    'paella': 1.50,
    'croissant': 4.50,
    'crepe': 1.60,
    'bratwurst': 3.20,
    'sauerbraten': 1.80,
    'borscht': 0.30,
    'pierogi': 1.70,
    'poutine': 2.50,
    'feijoada': 2.10,
    'empanada': 2.70,

    'almonds': 5.76,
    'walnuts': 6.54,
    'cashews': 5.53,
    'peanuts': 5.67,
    'pistachios': 5.62,
    'hazelnuts': 6.26,
    'macadamia nuts': 7.18,
    'pumpkin seeds': 5.49,
    'sunflower seeds': 5.84,
    'chia seeds': 4.86,
    'flax seeds': 5.34,
    'sesame seeds': 5.73,
}


def user_add_food(request):
    print("Request Data:", request.POST)

    lid = request.POST.get('lid')
    food_type = request.POST.get('type')
    food_name = request.POST.get('name')
    gram = request.POST.get('gram')

    # Input validation
    if not all([lid, food_type, food_name, gram]):
        return JsonResponse({"status": "error", "message": "Missing required fields"}, status=400)

    try:
        gram = int(gram)
    except ValueError:
        return JsonResponse({"status": "error", "message": "Invalid gram value"}, status=400)

    print("====================================")
    print("====================================")

    user = Customer.objects.filter(Login_id=lid).first()
    if not user:
        return JsonResponse({"status": "error", "message": "User not found"}, status=400)

    # Define calories_per_gram dictionary (add this)
    calories_per_gram = {
        'cashew': 5.53, 'almond': 5.76, 'walnut': 6.54,
        'peanut': 5.67, 'pistachio': 5.62
    }

    if food_name.lower() in calories_per_gram:
        calories = int(calories_per_gram[food_name.lower()] * gram)
        print(f"Calories from local DB: {calories}")
    else:
        try:
            calorie_per_100g = float(getcalval(f"100gm{food_name}"))
            calories = int((calorie_per_100g / 100) * gram)
            print(f"Calories calculated: {calories} (from {calorie_per_100g} cal/100g)")
        except Exception as e:
            print(f"Calorie calculation error: {e}")
            return JsonResponse({"status": "error", "message": f"Failed to fetch calories: {str(e)}"}, status=400)

    food = Food(
        Customer=user,
        type=food_type,
        name=food_name,
        gram=gram,
        callorie=calories,
        date=datetime.date.today(),
    )
    food.save()

    return JsonResponse({"status": "ok", "calories": calories})

from django.http import JsonResponse
import datetime
from .models import Food

def user_view_take_calorie(request):
    lid = request.POST['lid']
    total_calories = 0
    l = []
    a = Food.objects.filter(Customer__Login_id=lid)

    for i in a:
        total_calories += i.callorie  # Sum up the calories
        l.append({
            'id': i.id,
            'type': i.type,
            'gram': str(i.gram),
            'date': str(i.date),
            'food':i.name,
            'callorie': str(i.callorie)
        })
    return JsonResponse({"status": "ok", 'data': l, 'total_calories': total_calories})




# chatbot


import json
from google import genai
from google.genai import types  # Required for configuration
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

# 1. Initialize the Client
GOOGLE_API_KEY = 'AIzaSyBc_enKL0Q9qMK4jszsr05HO33ZbxDLGbE' \
                 ''
client = genai.Client(api_key=GOOGLE_API_KEY)

@csrf_exempt
def chatbot_response(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            user_message = data.get('message', '').strip()

            if not user_message:
                return JsonResponse({'response': 'Please enter a valid question.'})

            # 2. Generate response with System Instructions
            # This ensures the bot stays in character as a fitness expert
            # and outputs plain text without bolding or markdown.
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=user_message,
                config=types.GenerateContentConfig(
                    system_instruction=(
                        "You are a fitness and diet expert chatbot for a fitness app. "
                        "Only answer questions related to fitness, exercise, and nutrition. "
                        "If a user asks anything else, politely explain that you are a fitness "
                        "chatbot and cannot answer that. Output your response as plain text only. "
                        "Do not use markdown, bolding (**), headings, or different font sizes."
                    )
                )
            )

            return JsonResponse({'response': response.text.strip()})

        except json.JSONDecodeError:
            return JsonResponse({'response': 'Invalid JSON format.'}, status=400)
        except Exception as e:
            return JsonResponse({'response': f'Error: {str(e)}'}, status=500)

    return JsonResponse({'response': 'Invalid request method. Use POST.'}, status=405)



#----------------------------------------------------------------------


import json
import re
import time
from django.http import JsonResponse
from google import genai
from google.genai import types
from google.api_core import exceptions  # Import for error handling
from django.conf import settings


def calculate_recipe_calories(request):
    if request.method == 'POST':

        body_data = json.loads(request.body)
        recipe_text = body_data.get('recipe_text', '')

        if not recipe_text:
            return JsonResponse({'success': False, 'error': 'No recipe provided'}, status=400)

        client = genai.Client(api_key=settings.GEMINI_API_KEY)

        prompt = f"""
        Analyze this recipe: "{recipe_text}"
        Calculate total calories and total weight.
        Return ONLY a JSON object:
        {{
            "total_calories": 0,
            "total_weight_grams": 0,
            "calories_per_100g": 0,
            "ingredients": []
        }}
        """

        # --- Retry Logic for 429 Errors ---
        max_retries = 3
        response = None

        for attempt in range(max_retries):
            try:
                response = client.models.generate_content(
                    model='gemini-2.5-flash',  # STABLE MODEL
                    contents=prompt,
                    config=types.GenerateContentConfig(
                        temperature=0.1,
                        response_mime_type="application/json"
                    )
                )
                break  # Success! Exit retry loop.

            except exceptions.ResourceExhausted as e:
                if attempt < max_retries - 1:
                    time.sleep(10)  # Wait 10 seconds and try again
                    continue
                else:
                    raise e  # Re-raise after all retries fail

        # --- Parse Response ---
        raw_text = response.text.strip()
        clean_json = re.sub(r'^```json\s*|```$', '', raw_text, flags=re.MULTILINE)
        result_data = json.loads(clean_json)
        print("88888************************************************")
        print(result_data)
        print("******************************************************")

        return JsonResponse({
            'success': True,
            'data': result_data
        })



def build_calorie_calculation_prompt(recipe_data):
    recipe_text = recipe_data.get('recipe_text', '')

    prompt = f"""
    Analyze the following recipe and calculate the total calories.

    RECIPE:
    {recipe_text}

    INSTRUCTIONS:
    1. Identify all ingredients and their quantities.
    2. Calculate the total calories for the entire recipe using standard nutritional data.
    3. Calculate the total weight of the finished dish in grams.
    4. Calculate the calories per 100g of this food.

    OUTPUT FORMAT:
    Please provide the result in this exact JSON format:
    {{
        "total_calories": float,
        "total_weight_grams": float,
        "calories_per_100g": float,
        "ingredient_breakdown": [
            {{"item": "string", "calories": float}}
        ]
    }}
    Return ONLY the JSON.
    """
    return prompt

def save_user_intake(request):

    data = json.loads(request.body)
    print(data)
    customer_id = data.get('lid')
    print(customer_id,"-----------------------------------")
    customer_obj = Customer.objects.get(Login=customer_id)
    food_entry = Food.objects.create(
        Customer=customer_obj,
        type="Recipe Analysis",
        name=data.get('food_name', 'Unknown Dish'),
        date=data.get('date', datetime.date.today()),
        gram=float(data.get('grams_consumed', 0)),
        callorie=int(float(data.get('calories_consumed', 0)))
    )

    return JsonResponse({
        'success': True,
        'message': 'Food logged successfully!',
        'id': food_entry.id
    }, status=201)


def user_view_user(request):
    lid = request.POST['lid']
    l = []
    ob = Customer.objects.exclude(Login_id=lid)
    for i in ob:
        l.append({
            'id': str(i.id),
            'loginid': str(i.Login.id),
            'Name': i.Name,
            'Email': i.Email,
        })
    print(l)
    return JsonResponse({"status": "ok", "data": l})


from django.http import JsonResponse
import datetime

def user_share_workout(request):
    lid = request.POST['from_lid']
    toid = request.POST['to_customer_id']
    workid = request.POST['workout_id']
    date = datetime.date.today()

    exists = share_workout.objects.filter(
        WORKOUT_id=workid,
        FROM_id=lid,
        TO_id=toid
    ).exists()

    if exists:
        return JsonResponse({"status": "already existed"})

    # If not exists, save
    ob = share_workout()
    ob.WORKOUT_id = workid
    ob.TO_id = toid
    ob.FROM_id = lid
    ob.date = date
    ob.save()

    return JsonResponse({"status": "ok"})

def user_view_shared_wordout(request):
    lid = request.POST['lid']
    print(lid,"****************************")
    l = []
    ob = share_workout.objects.filter(TO=lid)
    for i in ob:
        video_url = request.build_absolute_uri(i.WORKOUT.video.url)
        l.append({
            'id': str(i.id),
            'title': str(i.WORKOUT.title),
            'description': str(i.WORKOUT.description),
            'video': str(video_url),
            'from': i.FROM.first_name,
            'date': i.date,
        })
    print(l)
    return JsonResponse({"status": "ok", "data": l})


from django.core.mail import send_mail
from django.conf import settings


def forgot_password(request):
    email = request.POST['email']
    import random
    psw = random.randint(0000, 9999)
    if User.objects.filter(username=email).exists():
        g = User.objects.get(username=email)
        g.set_password(str(psw))
        g.save()
        send_mail("temp", str(psw), settings.EMAIL_HOST_USER, [email])
        return JsonResponse({'status': 'ok'})
    else:
        return JsonResponse({'status': 'no'})

def forgotpassword_get(request):
    return render(request, 'forgot_password.html')


def web_forgot_password(request):
    email = request.POST['email']
    import random
    psw = random.randint(0000, 9999)
    if User.objects.filter(username=email).exists():
        g = User.objects.get(username=email)
        g.set_password(str(psw))
        g.save()
        send_mail("temp", str(psw), settings.EMAIL_HOST_USER, [email])
        return redirect('/')
    else:
        return redirect('/forgotpassword_get/')




def user_view_profile(request):
    lid=request.POST['lid']
    var=Customer.objects.get(Login_id=lid)
    return JsonResponse(
        {
            'id':str(var.id),
            'Name':str(var.Name),
            'Photo':str(var.Photo.url),
        }
    )
