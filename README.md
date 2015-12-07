# Start app

Startup a terminal to run app.

    $ cd app/
    $ virtualenv venv
    $ . venv/bin/activate
    (venv) $ pip install Flask
    (venv) $ python app.py 

run the following command to exit after test

    (venv) $ deactivate


## Run Test

Startup another terminal to run test.

    $ cd test
    $ ./virtualenv.pl venv
    $ source venv/bin/activate
    (venv) $ cpanm Test::Base Test::Deep LWP::UserAgent Smart::Comments JSON
    (venv) $ prove -v
    (venv) $ perl t/test.t # to run a single test 

run the following command to exist perl

    (venv) $ source venv/bin/deactivate
