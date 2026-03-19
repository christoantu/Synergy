from django.contrib.auth.models import User
from django.db import models

# Create your models here.

class Experts(models.Model):
    Login = models.ForeignKey(User, on_delete=models.CASCADE)
    image = models.CharField(max_length=500)
    idproof = models.CharField(max_length=500)
    name = models.CharField(max_length=100)
    place = models.CharField(max_length=100)
    post = models.CharField(max_length=100)
    district = models.CharField(max_length=100)
    phone = models.BigIntegerField()
    email = models.CharField(max_length=100)
    type = models.CharField(max_length=100)
    gender = models.CharField(max_length=100)  # Add this line
    status=models.CharField(max_length=100,default='pending')



class Customer(models.Model):
    Login = models.ForeignKey(User, on_delete=models.CASCADE)
    Name = models.CharField(max_length=100)
    Dob = models.DateField()
    Gender = models.CharField(max_length=100)
    Place = models.CharField(max_length=100)
    Pin = models.CharField(max_length=100)
    Post = models.CharField(max_length=100)
    Bloodtype = models.CharField(max_length=100)
    Photo = models.FileField()
    Email = models.CharField(max_length=100)
    Phone = models.BigIntegerField()
    District = models.CharField(max_length=100)

class Complaints(models.Model):
    Customer=models.ForeignKey(Customer,on_delete=models.CASCADE,default='')
    complaints=models.CharField(max_length=400)
    date=models.DateField()
    reply=models.CharField(max_length=400)

class Chat(models.Model):
    FROMID = models.ForeignKey(User, on_delete=models.CASCADE,related_name='fromid')
    TOID = models.ForeignKey(User, on_delete=models.CASCADE,related_name='toid')
    date =  models.DateField()
    message = models.CharField(max_length=2000)

class Expertfeedback(models.Model):
    Customer=models.ForeignKey(Customer,on_delete=models.CASCADE,default='')
    EXPERT=models.ForeignKey(Experts,on_delete=models.CASCADE,default='')
    feedback=models.CharField(max_length=400)
    rating=models.CharField(max_length=400)
    date=models.DateField()

class Food(models.Model):
    Customer = models.ForeignKey(Customer, on_delete=models.CASCADE, default='')
    type = models.CharField(max_length=500)
    name = models.CharField(max_length=500)
    date = models.DateField()
    gram = models.FloatField()
    callorie=models.IntegerField()

class Water(models.Model):
    Customer = models.ForeignKey(Customer, on_delete=models.CASCADE, default='')
    type = models.CharField(max_length=500)
    alert = models.CharField(max_length=500)
    status = models.CharField(max_length=500)
    date = models.DateField()

class Chatbot(models.Model):
    Customer = models.ForeignKey(Customer, on_delete=models.CASCADE, default='')
    question = models.CharField(max_length=500)
    answer = models.CharField(max_length=500)
    date = models.DateField()

class Workassign(models.Model):
    EXPERT = models.ForeignKey(Experts, on_delete=models.CASCADE, default='')
    work = models.CharField(max_length=500)
    details = models.CharField(max_length=500)
    status = models.CharField(max_length=100)
    date = models.DateField()
    Customer = models.ForeignKey(Customer, on_delete=models.CASCADE)

class Diet_chart(models.Model):
    gender = models.CharField(max_length=100)
    bmi_category = models.CharField(max_length=100)
    blood_pressure = models.CharField(max_length=100)
    main_health_concern = models.CharField(max_length=100)
    lifestyle = models.CharField(max_length=100)
    health_condition = models.CharField(max_length=100)
    Customer = models.ForeignKey(Customer, on_delete=models.CASCADE)

class Diet(models.Model):
    type = models.CharField(max_length=100)
    dietplan = models.TextField()
    excersiseplan = models.TextField()
    DIET_CHART = models.ForeignKey(Diet_chart, on_delete=models.CASCADE)

class workout_main(models.Model):
    workout=models.CharField(max_length=250)

class workout_sub(models.Model):
    EXPERT = models.ForeignKey(Experts, on_delete=models.CASCADE)
    MAIN = models.ForeignKey(workout_main, on_delete=models.CASCADE)
    USER = models.ForeignKey(Customer, on_delete=models.CASCADE)
    title=models.CharField(max_length=250)
    description=models.TextField()
    video=models.FileField()

class share_workout(models.Model):
    WORKOUT = models.ForeignKey(workout_sub, on_delete=models.CASCADE)
    FROM = models.ForeignKey(User, on_delete=models.CASCADE,related_name='from_id')
    TO = models.ForeignKey(User, on_delete=models.CASCADE,related_name='to_id')
    date=models.DateField()

# class User(models.Model):
#     LOGIN=models.ForeignKey(User,on_delete=models.CASCADE)
#     name=models.CharField(max_length=100)
#     place=models.CharField(max_length=100)
#     gender=models.CharField(max_length=20)
#     dob=models.CharField(max_length=30)
#     height=models.CharField(max_length=100)
#     weight=models.CharField(max_length=100)
#     post=models.CharField(max_length=100)
#     district=models.CharField(max_length=100)
#     email=models.CharField(max_length=100)
#     phone=models.CharField(max_length=100)
#     image=models.CharField(max_length=400)
#     bmi=models.CharField(max_length=400)
#     date=models.DateField()
#     calorie=models.FloatField()
#     type=models.CharField(max_length=40)