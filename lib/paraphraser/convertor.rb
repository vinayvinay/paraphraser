module Paraphraser
  class Convertor

    @@direction = :up
    cattr_accessor :direction

    @@migrations_path = 'db/migrate'
    cattr_accessor :migrations_path

    class << self

      def convert
        with_activerecord_stubbed do
          migrations.each { |migration| migration.migrate(direction) }
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
        apply_stubs
        yield
        reset_stubs
      end

      def apply_stubs
        connection.instance_eval do
          alias_method :real_execute, :execute

          def execute(*args)
            p '--', args.first
          end
        end
      end

      def reset_stubs
        connection.instance_eval do
          alias_method :execute, :real_execute
        end
      end
      
    end
    
  end
end

