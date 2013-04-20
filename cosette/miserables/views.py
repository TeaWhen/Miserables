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
    if Notice.objects.count() == 0:
        return {
            "time": '1987-09-14 00:00:00',
            "content": 'Across the Great Wall, we can reach every corner in the world.',
        }
    else:
        notice = Notice.objects.all()[0]
        return {
            "time": notice.time.strftime('%Y-%m-%d %H:%M:%S'),
            "content": notice.content,
        }

@json_response
def library(request):
    librarys = Library.objects.all()
    response = [{
        "id": library.id,
        "time": library.time.strftime('%Y-%m-%d %H:%M:%S'),
        "url": library.url,
        "md5": library.md5
    } for library in librarys]
    return response
