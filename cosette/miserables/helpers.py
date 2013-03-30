# -*- coding: utf-8 -*-

from json import dumps
from django.http import HttpResponse
from django.conf import settings

def json_response(func):
    def inner(request=None, *args, **kwargs):
        status_code = 200
        response = func(request, *args, **kwargs)
        content = response
        if isinstance(response, tuple):
            content = response[0]
            status_code = response[1]
        if settings.DEBUG:
            return HttpResponse(dumps(content, ensure_ascii=False, indent=2),
              mimetype="application/json", status=status_code)
        else:
            return HttpResponse(dumps(content, ensure_ascii=False, separators=(',',':')),
              mimetype="application/json", status=status_code)

    return inner
