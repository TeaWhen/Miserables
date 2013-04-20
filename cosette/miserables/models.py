from django.db import models

class App(models.Model):
    version_beta = models.CharField(max_length=30)
    version_stable = models.CharField(max_length=30)
    db = models.CharField(max_length=30)
    
    def __unicode__(self):
        return u'Beta: {}  -  Stable: {} - Db: {}'.format(self.version_beta, self.version_stable, self.db)

class Notice(models.Model):
    time = models.DateTimeField(auto_now=True)
    content = models.TextField()

    def __unicode__(self):
        return u'Time: {} - Content: {}'.format(self.time, self.content)

class Library(models.Model):
    time = models.DateTimeField(auto_now=True)
    url = models.CharField(max_length=300)
    md5 = models.CharField(max_length=128)

    def __unicode__(self):
        return u'Id: {} - Time: {} - Url: {}'.format(self.pk, self.time, self.url)
