class UnknownOption < StandardError

  def initialize(name)
    super("Unknown option '#{name}'.")
  end

end

class UnknownArgument < StandardError

  def initialize(name)
    super("Unknown argument '#{name}'.")
  end

end

class ArgumentMissing < StandardError

  def initialize(name)
    super("The '#{name}' argument is required.")
  end

end

class SettingMissing < StandardError

  def initialize(name, suggested_value="value", config_file="global")
    super("The `#{name}` setting is not set. Set it using `enzyme config #{name} '#{suggested_value}' --#{config_file}`.")
  end

end

class ConfigFileNotFound < StandardError

  def initialize(path)
    super("Config file could not be found at '#{path}'.")
  end

end

class SyncServerRequired < StandardError

  def initialize
    super("Sync server could not be found. Make sure the `sync.share_name` & `sync.host_name` settings are correct and you are connected to the right network.")
  end

end

class ProjectAlreadyExists < StandardError

  def initialize(path)
    super("A project already exists at '#{path}'.")
  end

end

class CannotFindProject < StandardError

  def initialize(path)
    super("Cannot find a project at '#{path}'.")
  end

end

class ArgumentOrSettingMissing < StandardError

  def initialize(argument_name, setting_name)
    super("The '#{argument_name}' argument was not provided and the '#{setting_name}' setting is not set.")
  end

end

class UnknownCommand < StandardError

  def initialize(command)
    super("Unable to find command `#{command}`.")
  end

end
