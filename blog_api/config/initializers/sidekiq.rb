require 'sidekiq'
require 'sidekiq-cron'

schedule_file = Rails.root.join('config/sidekiq.yml')

if File.exist?(schedule_file)
  schedule_hash = YAML.load_file(schedule_file)
  schedule_hash = schedule_hash.deep_symbolize_keys
  Sidekiq::Cron::Job.load_from_hash(schedule_hash[:schedule] || {})
end
