module Paraphraser
  class Convertor

    @@direction = :up
    cattr_accessor :direction

    @@migrations_path = 'db/migrate'
    cattr_accessor :migrations_path

    class << self

      def convert
        apply_obj_overrides
        
        exit(0) unless agree_to_proceed?

        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke
        
        with_ar_stubbed do
          announce "CreateSchemaMigrations"
          migrations.each do |migration|
            announce "#{migration.version} : #{migration.name}"
            migration.migrate(direction)
            update_schema_migrations_table(migration.version)
          end
        end
        
        print_without_file_output "\nWe're done! You could either copy the output above or give ./migration.sql for *the dba review*\n\n"
      end

      private

      def agree_to_proceed?
        print_without_file_output "\nThe way paraphraser works, it will drop and re-create a database and will output the migration sql in the process.\n" +
          "All data in #{::Rails.configuration.database_configuration[::Rails.env]['database']} at #{::Rails.configuration.database_configuration[::Rails.env]['host'] || 'localhost'} will be wiped-out. proceed? (Y/n): "
        choice = STDIN.gets.chomp

        case(choice)
        when 'Y' then
          return true
        when 'n', 'no', 'No' then
          print_without_file_output "\nYou can choose to run against a different Rails.env by passing an argument to paraphraser as, rake 'db:paraphrase:all[test]'\n\n"
          return false
        else
          print_without_file_output "\nYour input was neither 'Yes' nor 'n', so exiting.\n\n"
          return false
        end
      end

      def connection
        ActiveRecord::Base.connection
      end

      def migrations
        @@migrations ||= ActiveRecord::Migrator.new(direction, migrations_path).migrations
      end

      def with_ar_stubbed(&block)
        ActiveRecord::Migration.verbose = false
        apply_ar_overrides
        yield
      end

      def apply_ar_overrides
        connection.class.send(:define_method, :execute_with_paraphrasing) do |sql, name = nil|
          print "#{sql};\n" and STDOUT.flush unless sql =~ /^SHOW/
          execute_without_paraphrasing sql, name
        end
        connection.class.send(:alias_method_chain, :execute, :paraphrasing)
      end

      def apply_obj_overrides        
        Object.send(:define_method, :migration_file) { @@file ||= File.open('migration.sql', 'w') }
        Object.send(:define_method, :print_with_file_output) do |string|
          migration_file.write string
          print_without_file_output(string)
        end
        Object.send(:alias_method_chain, :print, :file_output)
      end

      def update_schema_migrations_table(version)
        connection.execute "INSERT INTO `schema_migrations` (version) VALUES ('#{version}')"
      end

      def announce(text)
        length = [0, 90 - text.length].max
        print "\n-- %s %s\n" % [text, "-" * length]
      end

    end    
  end
end
