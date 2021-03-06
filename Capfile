require "bundler/capistrano"
load 'deploy'
#load 'deploy/assets'
load 'config/deploy' # remove this line to skip loading any of the default tasks

desc "tail production log files"
task :tail_logs, :roles => :app do
  trap("INT") { puts 'Interupted'; exit 0; }
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

after 'deploy:finalize_update', 'deploy:config_symlink'
after 'deploy:update_code', 'deploy:assets:precompile'

namespace :deploy do

  task :restart do
    puts "\n\n=== Restarting Passenger! ===\n\n"
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :config_symlink, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/initializers/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
    run "rm -rf  #{release_path}/assets"
    run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
  end

  namespace :assets do

    task :precompile, :roles => :web do
      #from = source.next_revision(current_revision)
      #if 1 or capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ lib/assets/ app/assets/ | wc -l").to_i > 0
        run_locally("rake assets:clean && rake assets:precompile")
        run_locally "cd public && tar -jcf assets.tar.bz2 assets"
        top.upload "public/assets.tar.bz2", "#{shared_path}", :via => :scp
        run "cd #{shared_path} && tar -jxf assets.tar.bz2 && rm assets.tar.bz2"
        run_locally "rm public/assets.tar.bz2"
        run_locally("rake assets:clean")
      #else
      #  logger.info "Skipping asset precompilation because there were no asset changes"
      #end
    end


  end
end

namespace :faye do
  desc "Start Faye"
  task :start do
    run "cd #{deploy_to}/current && bundle exec rackup #{faye_config} -s thin -E production -D --pid #{faye_pid}"
  end
  desc "Stop Faye"
  task :stop do
    run "kill `cat #{faye_pid}` || true"
  end
end
before 'deploy:update_code', 'faye:stop'
after 'deploy:finalize_update', 'faye:start'
