
# What is it #
This project is for generating Ant build files for the source code of the book [GWT in Action 2nd Edition](https://code.google.com/p/gwtinaction2/).

The source code for the book  [GWT in Action 2nd Edition](https://code.google.com/p/gwtinaction2/) comes with maven.  However, if you do not use maven or do not like to use maven, this project  is for generating ant build files for the source code.

**Note** I am not associated with the book in any way.  I wrote this program to generate ant build files for my own need.  I am making it available with the hope that you might find it useful.

Bug reports, suggestions are welcome.

There is also a zip files with pre-generated build.xml and supported files.

# Synopsis #
```
 mk_antfiles.rb v1.01
 A script to generate Ant files for the book gwtinaction 2nd Ed
  https://code.google.com/p/ant-files-for-gwtinaction2-book/
   mk_antfiles.rb [options]
    -o, --overwrite                  Overwrite files
                                     Default is not to overwrite
    -h, --help                       Display this screen.
    -v, --version                    Print version and exit
    -c <pristine gwtinaction2 dir>   Remove all created files
        --clean                      Only works in Unix
    -d, --dir <directory>            Create files in this directory


 Error: Please run the script from inside gwtinaction2 directory
 Example:
  $ cd /path/of/gwtinaction2
  $ ruby /path/of/mk_antfiles.rb
```

# Generating Ant files #
You can get the build files in two ways:
  1. Just unzip the zip file [ant\_build\_files.zip](https://ant-files-for-gwtinaction2-book.googlecode.com/files/ant_build_files.zip) with pre-generated build files inside gwtinaction2 directory.
  1. If you have ruby installed,  generate build files yourself.

## Use pre-generated build files ##
  * First checkout the source code the from  [GWT in Action 2nd Edition page](https://code.google.com/p/gwtinaction2/source/checkout). Example:

```
svn checkout http://gwtinaction2.googlecode.com/svn/trunk/ gwtinaction2-read-only
```

  * Next Download [ant\_build\_files.zip](https://ant-files-for-gwtinaction2-book.googlecode.com/files/ant_build_files.zip)
  * unzip the file inside `gwtinaction2-read-only` directory:

```
$ cd gwtinaction2-read-only
$ unzip /path_of/ant_build_files.zip
```

## Generate build files yourself ##
  * First checkout the source code the from  [GWT in Action 2nd Edition page](https://code.google.com/p/gwtinaction2/source/checkout). Example:

```
svn checkout http://gwtinaction2.googlecode.com/svn/trunk/ gwtinaction2-read-only
```

  * Checkout ant-files-for-gwtinaction2-book:

```
svn checkout http://ant-files-for-gwtinaction2-book.googlecode.com/svn/trunk/ant-files-for-gwtinaction2-book \
  ant-files-for-gwtinaction2-book-read-only
```

  * Generate buld files:
You must have ruby installed.
```
$ cd gwtinaction2-read-only
$ ruby ../ant-files-for-gwtinaction2-book-read-only/mk_antfiles.rb
```



# Running Ant Tasks #
  * Before running the ant tasks, you must set the environment variable **GWT\_DIR** to the directory where GWT SDK is installed. Example, in Linux/Unix/Mac:
```
GWT_DIR=/usr/local/gwt-2.5.0; export GWT_DIR
```

A `buld.xml` file is created inside each chapter. The ant tasks can be run from from command line or from eclipse.
## From command line ##

```
$ cd gwtia-ch02-helloworld
$ ant -p
Buildfile: /Users/muquit/Documents/workspace/gwtinaction2/gwtia-ch02-helloworld/build.xml

Main targets:

 build            Build gwtia-ch02-helloworld project
 checkgwtdir      Check if GWT directory exists or not
 checkwebappsdir  Check if WEBAPPS_DIR env var is set or not
 clean            Cleans this project
 compile          GWT compile to JavaScript (production mode)
 compile-and-run  compile and run gwtia-ch02-helloworld in dev mode
 deploy           Deploy gwtia-ch02-helloworld.war to a Servlet container
 help             Show help
 javac            Compile java source to bytecode
 killdev          Kill GWT Devmode process (Unix only)
 libs             Copy libs to WEB-INF/lib
 run              Run gwtia-ch02-helloworld in development mode
 war              Create gwtia-ch02-helloworld.war
Default target: help
```

To run, type:
```
$ ant run
```
## From Eclipse ##
Load the specific Ant build.xml, In Eclipse, Click Window->Show View->Ant. Then Right click, Select Add Buldfiles.... Select build.xml and click OK. Open the ant tasks and run cmpile-and-run.

![http://ant-files-for-gwtinaction2-book.googlecode.com/svn/wiki/ant-tasks.png](http://ant-files-for-gwtinaction2-book.googlecode.com/svn/wiki/ant-tasks.png)
## Deploy ##
To deploy a war file to tomcat, jetty or any other servlet container, set the WEBAPPS\_DIR first. Example:
```
WEBAPPS_DIR=/usr/local/tomcat/webapps; export WEBAPPS_DIR
```
Then run the **deploy** ant task.  Example:
```
$ ant deploy
```
Then point your browser to the url: `http://localhost:8080/gwtia-ch02-helloworld`. Change the port configured for your servlet container.
# Known issues #
  * ch08 have issues with v1 and v2