require './ci/common'

def jenkins_version
  ENV['FLAVOR_VERSION'] || '1.7.11' # TODO: set default version
end

def jenkins_rootdir
  "#{ENV['INTEGRATIONS_DIR']}/jenkins_#{jenkins_version}" # TODO: is this a reasonable way to set this up?
end

namespace :ci do
  namespace :jenkins do |flavor|
    task before_install: ['ci:common:before_install']

    task install: ['ci:common:install'] do
      # Downloads
	    # TODO: this is from the nginx.rb; make it do jenkins stuff?
      # http://nginx.org/download/nginx-#{nginx_version}.tar.gz
      #unless Dir.exist? File.expand_path(nginx_rootdir)
      #  sh %(curl -s -L\
      #       -o $VOLATILE_DIR/nginx-#{nginx_version}.tar.gz\
      #       https://s3.amazonaws.com/dd-agent-tarball-mirror/nginx-#{nginx_version}.tar.gz)
    end

    task before_script: ['ci:common:before_script'] do
	    # TODO: put jenkins conf, key, etc here if needed.
	    # Probably but the example output files here.
    #  sh %(cp $TRAVIS_BUILD_DIR/ci/resources/nginx/nginx.conf\
           #{nginx_rootdir}/conf/nginx.conf)
    end

    task script: ['ci:common:script'] do
      this_provides = [
        'jenkins'
      ]
      Rake::Task['ci:common:run_tests'].invoke(this_provides)
    end

    task before_cache: ['ci:common:before_cache'] do
      # Conf is regenerated at every run TODO: remove whatever we added in before_script
      #sh %(rm -f #{nginx_rootdir}/conf/nginx.conf)
    end

    task cache: ['ci:common:cache']

    task cleanup: ['ci:common:cleanup'] do
      #sh %(kill `cat $VOLATILE_DIR/nginx.pid`) # TODO: uh, they were running nginx, I think, but we just want build files?
    end

    task :execute do
      exception = nil
      begin
        %w(before_install install before_script
           script before_cache cache).each do |t|
          Rake::Task["#{flavor.scope.path}:#{t}"].invoke
        end
      rescue => e
        exception = e
        puts "Failed task: #{e.class} #{e.message}".red
      end
      if ENV['SKIP_CLEANUP']
        puts 'Skipping cleanup, disposable environments are great'.yellow
      else
        puts 'Cleaning up'
        Rake::Task["#{flavor.scope.path}:cleanup"].invoke
      end
      fail exception if exception
    end
  end
end