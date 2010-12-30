module Paraphraser
  class Convertor

    @@direction = :up
    cattr_accessor :direction

    @@migrations_path = 'db/migrate'
    cattr_accessor :migrations_path

    class << self

      def convert
        with_activerecord_stubbed do
          migrations.each do |migration|
            announce "#{migration.version} : #{migration.name}"
            migration.migrate(direction)
            update_schema_migrations_table(migration.version)
          end
        end
      end

      private

      def connection
        ActiveRecord::Base.connection
      end

      def migrations
        @migrations ||= ActiveRecord::Migrator.new(direction, migrations_path).migrations
      end

      def with_activerecord_stubbed(&block)
        ActiveRecord::Migration.verbose = false
        apply_overrides
        yield
      end

      def apply_overrides
        connection.class.send(:define_method, :execute) do |sql, name = nil, skip_logging = false|
          print "#{sql};\n"
          STDOUT.flush
        end
        connection.class.send(:define_method, :initialize_schema_migrations_table) { }
        connection.class.send(:define_method, :tables) { |*args| [] }
        connection.class.send(:define_method, :index_name_exists?) {|*args| false }
        connection.class.send(:define_method, :rename_column) do |table_name, column_name, new_column_name|
          execute "ALTER TABLE #{quote_table_name(table_name)} RENAME COLUMN #{quote_column_name(column_name)} TO #{quote_column_name(new_column_name)}"
        end
        connection.class.send(:define_method, :change_column) do |table_name, column_name, type, options = {}|
          execute "ALTER TABLE #{quote_table_name(table_name)} ALTER COLUMN #{quote_column_name(column_name)} TYPE #{type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
        end
        connection.class.send(:define_method, :change_column_default) do |table_name, column_name, default|
          execute "ALTER TABLE #{quote_table_name(table_name)} ALTER COLUMN #{quote_column_name(column_name)} SET DEFAULT #{quote(default)}"
        end
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
