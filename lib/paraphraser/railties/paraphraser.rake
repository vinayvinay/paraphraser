namespace :db do
  namespace :paraphrase do
    
    desc 'provides a rake task to convert all migrations to sql statements for *the dba*.'
    task :all => :environment do
      Paraphraser::Convertor.convert
    end

    desc 'provides a rake task to convert all migrations in range to sql statements for *the dba*.'
    task :in_range => :environment do
      Paraphraser::Convertor.convert
    end
    
  end
end
