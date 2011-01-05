module Kernel

  def migration_file
    @@file ||= File.open('migration.sql', 'w')
  end

  def print_with_file_output(string)
    migration_file.write string
    print_without_file_output(string)
  end
  alias_method_chain :print, :file_output

end
