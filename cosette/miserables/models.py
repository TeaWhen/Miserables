from django.db import models

class App(models.Model):
    version_beta = models.CharField(max_length=30)
    version_stable = models.CharField(max_length=30)
    
    def __unicode__(self):
        return 'Beta: {}  -  Stable: {}'.format(self.version_beta, self.version_stable)