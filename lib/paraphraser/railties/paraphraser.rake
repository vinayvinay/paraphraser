namespace :db do
  desc 'provides a rake task to convert migrations to sql statements for *the dba*.'
  task :paraphrase => :environment do
    Paraphraser::Convertor.convert
  end
end
