class DemoWorker
  include Sidekiq::Worker

  def perform(name)
    puts "Hello, #{name}"
  end
end
