module Paraphraser
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.join(File.dirname(__FILE__), '..', 'tasks', 'paraphraser.rake')
    end
  end
end
