module Paraphraser
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'paraphraser/railties/paraphraser.rake'
    end
  end
end
