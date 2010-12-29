module Paraphraser
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'lib/tasks/paraphraser.rake'
    end
  end
end
