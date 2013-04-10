from miserables.models import App, Notice, Library
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
        "time": notice.time.strftime('%Y-%m-%d %H:%M:%S'),
        "content": notice.content,
    }

@json_response
def library(request):
    librarys = Library.objects.all()
    return [].append({
        "id": library.id,
        "time": library.time.strftime('%Y-%m-%d %H:%M:%S'),
        "url": library.url,
    } for library in librarys)
