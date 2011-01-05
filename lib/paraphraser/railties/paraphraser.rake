namespace :db do
  namespace :paraphrase do
    
    desc 'provides a rake task to convert all migrations to sql statements for *the dba*.'
    task :all, [:rails_env] => :environment do |t, args|
      Rails.env = args[:rails_env] || 'test'
      Paraphraser::Convertor.convert
    end

  end
end
