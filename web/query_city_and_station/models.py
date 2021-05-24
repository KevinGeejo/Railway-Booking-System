from django.db import models


# Create your models here.

class AskStation(models.Model):
    question_text = models.CharField(max_length=200)
    pub_date = models.DateTimeField('date published')


class AnswerCity(models.Model):
    question = models.ForeignKey(AskStation, on_delete=models.CASCADE)
    choice_text = models.CharField(max_length=200)
    votes = models.IntegerField(default=0)
