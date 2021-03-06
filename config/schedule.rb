# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :puma,  "cd :path && bundle exec rails :task -e :environment "
job_type :pumactl,  "cd :path && RAILS_ENV=:environment bundle exec pumactl -F config/puma.rb :task "

every :reboot do
    script "delayed_job start"
    puma "s"
    rake "ts:rebuild"
end

every 1.day, at: '4:30 am' do
    pumactl "restart"
end

