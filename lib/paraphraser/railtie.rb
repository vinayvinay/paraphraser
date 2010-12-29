module Paraphraser
  class Railtie < Rails::Railtie
    rake_tasks do
      load '..//tasks/paraphraser.rake'
    end
  end
end
