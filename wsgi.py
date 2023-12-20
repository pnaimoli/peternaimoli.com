from flask import Flask
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from werkzeug.serving import run_simple

# Needs to be done because there's a hyphen in measure-hider
import importlib
measure_hider_modeler = importlib.import_module("measure-hider.build.measure_hider_modeler")
measure_app = measure_hider_modeler.app
from chordmania.build.xmlserver import app as chord_app

# Define a default app
default_app = Flask(__name__)

@default_app.route('/')
def homepage():
    return '''
    <html>
        <head>
            <title>Peter Naimoli's Homepage</title>
        </head>
        <body>
            <h1>Welcome to Peter Naimoli's Homepage</h1>
            <p>This is the default landing page.</p>
        </body>
    </html>
    '''

application = DispatcherMiddleware(default_app, {
    '/measure-hider': measure_app,
    '/chordmania': chord_app,
})

if __name__ == '__main__':
    run_simple('localhost', 4999, application, use_reloader=True, use_debugger=True)
