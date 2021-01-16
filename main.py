import GDL
import falcon
import json
import json_tricks
import logging
from wsgiref import simple_server


class HelloWorld:

    LOGGER: logging.Logger = logging.getLogger()

    # Handles POST requests
    def on_post(self, req, resp):
        kgon = req.get_param('kgon') or 4

        request_json = json_tricks.loads(json.load(req.bounded_stream))

        self.LOGGER.info('Request handled')

        xs = request_json['x']
        ys = request_json['y']
        res = GDL.function("poly_kgon", xs, ys, kgon=kgon)

        if type(res) == int and res == -1:
            resp.status = falcon.HTTP_500
        else:
            resp.status = falcon.HTTP_200
            resp.body = json_tricks.dumps({"response": res, "status": resp.status})


# falcon.API instance , callable from gunicorn
app = falcon.API()

# instantiate helloWorld class
hello = HelloWorld()

# map URL to HelloWorld class
app.add_route("/test", hello)

if __name__ == '__main__':
    httpd = simple_server.make_server('0.0.0.0', 8000, app)
    httpd.serve_forever()
