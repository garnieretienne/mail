Warning
=======

This application is still a work in progress and is not ready for use yet.

Directories
===========

* /apps          : this node application is splitted into several application (api, webmail, authentication)
* /assets        : Stylesheets and Javascripts assets (coffee and less files) managed by the asset pipeline
* /bin           : Binaries for this app
* /components    : Browser side libraries managed by Bower 
* /docs          : Various documentations and RFCs
* /lib           : Libraries used by models
* /models        : Models used by Express
* /public        : All assets not managed by the asset pipeline (ex: images)
* /test/frontend : All Backbone application test files (managed by Jasmine)
* /test/apps     : All Express application test files (managed by Mocha)
* /test/lib      : All models libraries test files (managed by Mocha)
* /test/models   : All Express models test files (managed by Mocha)
* /views         : Express layouts

Note on Bower
=============

* Bower: http://twitter.github.com/bower/

Client side dependency libraries are managed using Twitter Bower to easily upgrade any component.

Note on Assets
==============

* Connect-assets: https://github.com/TrevorBurnham/connect-assets

Asset pipeline in this application is managed using 'connect-assets' middleware.

Note on Twitter Bootstrap
=========================

Twitter Bootstrap is installed using 'bower' to support quick update.
Each javascript components are declared under 'assets/javascripts/application.coffee' file. Only needed javascript components are enabled.
Each stylesheets less component are imported manually under 'assets/stylesheets/application.less' to support variable override.
To override a Bootstrap variable value, create a less file with the same name than the original, plus '-override', and add your change into this file.

Exemple: To override a variable value in the 'variables.less' Bootstrap file, create a 'variables-override.less' file into 'assets/stylesheets/' with your overrided value in it, and add an import line into the 'application.less' file, just under the original file.

Note on Riak
============

To search in the database for providers, riak need to support search and auto-indexing of the 'providers' bucket.
More informations: http://docs.basho.com/riak/latest/cookbooks/Riak-Search---Indexing-and-Querying-Riak-KV-Data/

* Enable search in /etc/app.config:

```
%% Riak Search Config
 {riak_search, [
                %% To enable Search functionality set this 'true'.
                {enabled, true}
               ]},
```

* Set up indexing on the providers bucket

```
search-cmd install providers
```

Testing
=======

Backbone
--------

* Jasmine: http://pivotal.github.com/jasmine/

Jasmine 1.2.0 is installed manually (no auto-update).

Test the backbone 'Mail' application using './bin/jasmine'. 
The bash script run a Chromium ('chromium-browser') window to show test result.
Assets and Spec directories are 'watched' (fired on any folder content modification) to auto-recompile coffee-script files into 'test/frontend/javascripts' folder.

To add spec files, add coffee-script files into 'test/frontend/spec' and edit the SpecRunner file ('test/frontend/SpecRunner.html') to manually include your files.

Express
-------

* Mocha: http://visionmedia.github.com/mocha/
* Chai: http://chaijs.com/
* Cheerio: https://github.com/MatthewMueller/cheerio#readme

Express unit and browser testing are executed using Mocha test framework. Mocha can use any assertion library; this application uses Chai as it, and Cheerio as JQuery selector.

Test the express application using './bin/mocha' or 'npm test'.