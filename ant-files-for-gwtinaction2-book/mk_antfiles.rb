#!/usr/bin/env ruby

##############################################################################
# Create Ant build.xml files for the code of the book GWT in Action 2nd
# Editon. If you use ant, you might find it useful.
#
# Run the script at the base of the project. A build.xml file will be created
# the directory of each chapter.
#
# Copyright
# =========
# This is free code.
# Redistribution and use of this script with or without modification is permitted.
#
# muquit@muquit.com Feb-17-2013 
##############################################################################

require 'fileutils'
require 'optparse'
require 'logger'

class MakeAntBuildXml
  VERSION_S = "1.01"
  ME_SHORT = File.basename($0)
  ME = File.expand_path(__FILE__)
  BASEDIR = Dir.pwd

  def initialize
    $stdout.sync = true
    $stderr.sync = true
    @log = Logger.new(STDERR)
    @opthash = {}
    @opts = nil
  end

  def log(msg)
#    @log.info(msg)
  puts msg
  end

  def clean
    if @opthash[:gwtinacion2dir]
      log "Clean"
      dir = @opthash[:gwtinacion2dir]
      if !gwtinaction2_basedir?(dir)
        log "Error: #{dir} is not a gwtinaction2 directory"
        exit 1
      end
      files = `diff -r --brief #{BASEDIR} #{dir}`
      files_array = files.split("\n")
      files_array.each do |line|
        line = line.strip
        next if line =~ /.svn/
        next if line =~ /#{ME_SHORT}/
#Only in /Users/muquit/Documents/workspace/gwtinaction2/gwtia-ch15-mvp-enhanced: build.xml
        if line =~ /^Only in (#{BASEDIR})(.*): (.*)$/
          x = "#{$1}/#{$2}/#{$3}"
          if File.exists?(x)
            begin
              FileUtils.rm_rf(x)
            rescue => e
              log "Error: could not delete #{x}: #{e}"
            end
          end
        end
      end
      exit 1
    end
  end

  def doit
    @opts = parse_options
    if !gwtinaction2_basedir?(BASEDIR)

      usage
      puts <<EOD

 Error: Please run the script from inside gwtinaction2 directory
 Example:
  $ cd /path/of/gwtinaction2
  $ ruby /path/of/#{ME_SHORT}
EOD
      exit 1
    end
    log "Starting #{ME_SHORT} v#{VERSION_S}"
    clean # will exit if ran with -c <dir>
    create_build_xml_files
  end

  def gwtinaction2_basedir?(basedir)
    # just check few key directories to check we are in the base 
    dirs = []
    dirs << basedir + "/" + "gwtia-ch10-data-presentation-widgets"
    dirs << basedir + "/" + "gwtia-ch02-helloworld"
    dirs << basedir + "/" + "gwtia-ch04-widgets"
    dirs << basedir + "/" + "gwtia-ch14-events"
    dirs.each do |dir|
      if File.exists?(dir) && File.directory?(dir)
        return true
      end
    end
    return false
  end

  def create_build_xml_files
    Dir.foreach(BASEDIR) do |chapter_dir|
      if chapter_dir =~ /^gwtia-(ch[0-9]+).*$/
        chapter = $1
        create_build_xml_file(chapter_dir, chapter)
      end
    end
  end

  def create_client_xml_file(dir, chapter)
    log "Create client xml file #{chapter}"
    client_dir = BASEDIR + "/" + dir + "/src/com/manning/gwtia/" + chapter
    log " dir: #{client_dir}"
    Dir.foreach(client_dir) do |e|
      if e != "client.gwt.xml"
        if e =~ /.xml$/
          to_file = client_dir + "/client.gwt.xml"
          from_file = client_dir + "/" + e
          log "#{from_file} -> #{to_file}"
          check_if_exists!(to_file)
          FileUtils.cp(from_file, to_file)
        end
      end
    end
  end

  def get_tohtmlfile_path(module_base, chapter_dir)
    basedir = @opthash[:ddir]
    basedir = BASEDIR if !basedir
    log "basedir: #{basedir}"
    log "module base: #{module_base}"
    log "war_dir: #{chapter_dir}"
    to_html_file = basedir + "/" + chapter_dir + "/war/" + module_base + ".html"
    log "html_file: #{to_html_file}"
    return to_html_file
  end

  def create_html_file(module_base, war_dir, to_file)
    log "war_dir: #{war_dir}"
    Dir.foreach(war_dir) do |x|
      # copy the first html
      if x =~ /\.html/
        from_file = war_dir + "/" + x
        log "> #{from_file} -> #{to_file}"
        FileUtils.cp(from_file, to_file)
        break
      end
    end
  end

  #------------------------------------------------- 
  # return the base naem of the module xml file.
  # for exmaple, module for for ch02 is
  #  gwtia-ch02-helloworld/src/com/manning/gwtia/ch02/HelloWorld.gwt.xml
  #  therefor HelloWorld will be returned
  #------------------------------------------------- 
  def get_module_base(dir, chapter)
    if dir == 'gwtia-ch08-requestfactory'
      chapter = chapter + "/v0"
    end
    module_file_dir = dir + "/src/com/manning/gwtia/" + chapter
    log "Module file dir: #{module_file_dir}"
    Dir.foreach(module_file_dir) do |x|
      if x =~ /(.*).gwt.xml$/
        return $1
      end
    end
    return nil
  end

  def get_buildfile_path(chapter_dir)
    basedir = @opthash[:ddir]
    basedir = BASEDIR if !basedir
    build_xml = basedir + "/" + chapter_dir + "/build.xml"
    return build_xml
  end

  def create_basedir(file)
    basedir = File.dirname(file)
    log "Create basedir: #{basedir}"
    if !File.exists?(basedir)
      log "create directory: #{basedir}"
      begin
        FileUtils.mkdir_p(basedir)
      rescue => e
        log "Error creating directory: #{e}"
      end
    end
  end

  def create_build_xml_file(chapter_dir, chapter)
    d = Time.new
    dir = chapter_dir
    gwtdir     = '${env.GWT_DIR}'
    webappsdir = '${env.WEBAPPS_DIR}' 
    warfile    = "#{dir}.war"

    build_file = get_buildfile_path(dir)
    log "Creating build file: #{build_file}"
    create_basedir(build_file)

    check_if_exists!(build_file)

    module_base = get_module_base(dir, chapter)
    return if !module_base

    to_html_file = get_tohtmlfile_path(module_base, dir)
    create_basedir(to_html_file)

    if !File.exists?(to_html_file)
      create_html_file(module_base, dir + "/war", to_html_file)
    end

    html_file = module_base + ".html"
    if chapter_dir == 'gwtia-ch08-requestfactory'
      chapter = chapter + ".v0"
      html_file = module_base.downcase + ".html"
    end

    f = STDOUT
    begin
      f = File.open(build_file,"w")
    rescue => e
      log "Error: Failed to create #{build_file}: #{e}"
      exit 1
    end

    f.puts <<EOD
<?xml version="1.0" encoding="UTF-8"?>
<project name="#{dir}" default="help" basedir=".">

<!--
 WARNING: This file is auto generated. DO NOT MODIFY.
 The file is created by #{ME} 
   v#{VERSION_S} on #{d}
 Type: ant -p to see the targets
-->
	
  <!-- Arguments to compile and run targets -->
  <property name="gwt.args" value="" />

  <!-- path of GWT -->
  <property environment="env"/>
  <property name="gwt.sdk" value="#{gwtdir}" />

  <!-- path of webapps directory for deployment -->
  <property name="webapps.dir" value="#{webappsdir}" />


  <path id="project.class.path">
    <pathelement location="war/WEB-INF/classes"/>
    <pathelement location="${gwt.sdk}/gwt-user.jar"/>
    <fileset dir="${gwt.sdk}" includes="gwt-dev*.jar"/>
    <!-- Add any additional non-server libs (such as JUnit) -->
    <fileset dir="war/WEB-INF/lib" includes="**/*.jar"/>
  </path>

  <target name="libs" description="Copy libs to WEB-INF/lib">
    <mkdir dir="war/WEB-INF/lib" />
    <copy todir="war/WEB-INF/lib" file="${gwt.sdk}/gwt-servlet.jar" />
    <copy todir="war/WEB-INF/lib" file="${gwt.sdk}/gwt-servlet-deps.jar" />
    <!-- Add any additional server libs that need to be copied -->
  </target>
  
  <target name="compile" depends="checkgwtdir,clean,javac" description="GWT compile to JavaScript (production mode)">
    <java failonerror="true" fork="true" classname="com.google.gwt.dev.Compiler">
      <classpath>
        <pathelement location="src"/>
        <path refid="project.class.path"/>
        <pathelement location="${gwt.sdk}/validation-api-1.0.0.GA.jar" />
        <pathelement location="${gwt.sdk}validation-api-1.0.0.GA-sources.jar" />
      </classpath>
      <!-- add jvmarg -Xss16M or similar if you see a StackOverflowError -->
      <jvmarg value="-Xmx256M"/>
      <arg line="-war"/>
      <arg value="war"/>
      <!-- Additional arguments like -style PRETTY or -logLevel DEBUG -->
      <arg line="${gwt.args}"/>
      <arg value="com.manning.gwtia.#{chapter}.#{module_base}"/>
    </java>
  </target>
  
  <target name="compile-and-run" depends="compile,run" description="compile and run #{dir} in dev mode"/>
  
  <target name="javac" depends="libs" description="Compile java source to bytecode">
    <mkdir dir="war/WEB-INF/classes"/>
    <javac includeantruntime="false" srcdir="src" includes="**" encoding="utf-8"
        destdir="war/WEB-INF/classes"
        source="1.5" target="1.5" nowarn="true"
        debug="true" debuglevel="lines,vars,source">
      <classpath refid="project.class.path"/>
    </javac>
    <copy todir="war/WEB-INF/classes">
      <fileset dir="src" excludes="**/*.java"/>
    </copy>
  </target>

   <target name="run" depends="javac" description="Run #{dir} in development mode">
    <java failonerror="true" fork="true" classname="com.google.gwt.dev.DevMode">
      <classpath>
        <pathelement location="src"/>
        <path refid="project.class.path"/>
        <pathelement location="${gwt.sdk}/validation-api-1.0.0.GA.jar" />
        <pathelement location="$}gwt.sdk}/validation-api-1.0.0.GA-sources.jar" />
      </classpath>
      <jvmarg value="-Xmx256M"/>
      <arg value="-startupUrl"/>
      <arg value="#{html_file}"/>
      <arg line="-war"/>
      <arg value="war"/>
      <!-- Additional arguments like -style PRETTY or -logLevel DEBUG -->
      <arg line="${gwt.args}"/>
      <arg value="com.manning.gwtia.#{chapter}.#{module_base}"/>
    </java>
  </target>

  <target name="clean" description="Cleans this project">
    <delete dir="war/WEB-INF/classes" failonerror="false" />
    <delete dir="war/com.manning.gwtia.#{chapter}.client" failonerror="false" />
    <delete dir="reports" failonerror="false" />
    <delete file="war/#{warfile}" failonerror="false" />
  </target>

  <target name="build" depends="compile" description="Build #{dir} project"/>

  <target name="war" depends="build" description="Create #{warfile}">
    <zip destfile="war/#{warfile}" basedir="war"/>
  </target>

  <target name="copy">
      <echo message="Copying log4j.properties to classes directory"/>
      <copy file="${basedir}/log4j/log4j.properties"
          tofile="${basedir}/war/WEB-INF/classes/log4j.properties"
          overwrite="true"/>
  </target>

  <target name="help" description="Show help">
    <echo>
 Before running any of the ant tasks. Please set the GWT_DIR environemnt
 variable to the location where GWT SK is installed.
 
 In Linux:
    $ GWT_DIR=/usr/local/gwt-2.5.0; export GWT_DIR
 MacOS X:
    $ launchctl setenv GWT_DIR /usr/local/gwt-2.5.0

 o Type: "ant -p" to see all the Ant tasks
    </echo>
  </target>

  <target name="checkgwtdir" description="Check if GWT directory exists or not">
    <fail unless="env.GWT_DIR" message="GWT_DIR environemnt variable is not set"/>    
    <echo message="GWT_DIR=${env.GWT_DIR}"/>
  </target>

  <target name="checkwebappsdir" description="Check if WEBAPPS_DIR env var is set or not">
    <fail unless="env.WEBAPPS_DIR" message="WEBAPPS_DIR environemnt variable is not set"/>    
    <echo message="WEBAPPS_DIR=${env.WEBAPPS_DIR}"/>
  </target>

  <target name="killdev" description="Kill GWT Devmode process (Unix only)">
    <exec dir="${basedir}" executable="ruby">
        <arg value="killgwtdevmode.rb"/>
    </exec>
  </target>
  
  <target name="deploy" depends="checkwebappsdir,war" description="Deploy #{warfile} to a Servlet container">
    <fail unless="env.WEBAPPS_DIR"
        message="WEBAPPS_DIR environemnt variable is not set"/>    
    <echo message="webapps directory: #{webappsdir}"/>
    <copy file="${basedir}/war/#{warfile}" tofile="#{webappsdir}/#{warfile}"/>
  </target>

</project>
EOD
  f.close
  end

  def usage
  puts <<EOD
 #{ME_SHORT} v#{VERSION_S}
 A script to generate Ant files for the book gwtinaction 2nd Ed
  https://code.google.com/p/ant-files-for-gwtinaction2-book/
 #{@opts}
EOD
  end

  #  exit with 1 if file exists
  def check_if_exists!(file)
  if File.exists?(file)
    if !@opthash[:overwrite]
      puts "File '#{file}' exists. exiting"
      puts "Please use the flag -o if you want to overwrite files"
      exit 1
    end
  end
  end

  def parse_options
    begin
    opthash = {}
    opthash[:overwrite] = false
    opts = OptionParser.new do |o|
      o.banner = <<EOD
  #{ME_SHORT} [options]
EOD
      @opts = opts
=begin
      o.on("-g", "--gwt DIR", String,
          "Path of GWT directory",
          "Default is env var GWT_DIR") do |x|
        if File.exists?(x) && File.directory?(x)
          opthash[:gwtdir] = x
        else
          puts "Error: GWT directory '#{x}' does not exist"
          exit 1
        end
      end

      o.on("-w", "--webapps-dir DIR", String,
          "Path of webapps directoy for deployment",
          " Default is NONE") do |x|
        if File.exists?(x) && File.directory?(x)
          opthash[:webappsdir] = x
        else
          puts "Error: webapps directory '#{x}' does not exist"
          exit 1
        end
      end
=end
      o.on("-o","--overwrite",
          "Overwrite files",
          "Default is not to overwrite") do |x|
        opthash[:overwrite] = true
      end

      o.on("-h", "--help",
          "Display this screen.") do |x|
        puts opts
        exit 1
      end

      o.on("-v", "--version",
          "Print version and exit") do |x|
        puts "#{ME_SHORT} v#{VERSION_S}"
        exit 0
      end

      o.on("-c", "--clean <pristine gwtinaction2 dir>",String,
          "Remove all created files",
          "Only works in Unix") do |x|
        opthash[:gwtinacion2dir] = x
      end

      o.on("-d", "--dir <directory>", String,
          "Create files in this directory") do |x|
        opthash[:ddir] = x
      end

    end # opts

    opts.parse!(ARGV)
    @opthash = opthash  
    return opts
    
    rescue OptionParser::ParseError
      $stderr.puts "Error - #{$!}"
      exit 1
    end
  end


end

if __FILE__ == $0
  MakeAntBuildXml.new.doit
end
