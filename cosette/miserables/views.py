from miserables.models import App, Notice
from miserables.helpers import json_response

@json_response
def version(request):
    app = App.objects.all()[0]
    return {
        'stable': app.version_stable,
        'beta': app.version_beta,
        'db': app.db,
    }

@json_response
def notice(request):
    notice = Notice.objects.all()[0]
    return {
        "time": notice.time,
        "content": notic.content,
    }

@json_response
def library(request):
    library = Library.objects.all()[0]
    return {
        "id": library.id,
        "time": library.time,
        "url": library.url,
    }
