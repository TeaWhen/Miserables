from miserables.models import App
from miserables.helpers import json_response

@json_response
def version(request):
    app = App.objects.all()[0]
    return {
        'stable': app.version_stable,
        'beta': app.version_beta
    }
