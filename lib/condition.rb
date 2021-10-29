module Maintenance
  module Condition
    def self.include_method(*methods)
      lambda do |env|
        method = env['REQUEST_METHOD']
        methods.include? method
      end
    end

    def self.exclude_method(*methods)
      lambda do |env|
        method = env['REQUEST_METHOD']
        !methods.include? method
      end
    end

    def self.include_path(*regex_paths)
      lambda do |env|
        path = env['REQUEST_PATH']
        regex_paths.any? { |regex_path| path.match? regex_path }
      end
    end

    def self.and(*conditions)
      lambda do |env|
        conditions.all? { |condition| condition.call(env) }
      end
    end

    def self.or(*conditions)
      lambda do |env|
        conditions.any? { |condition| condition.call(env) }
      end
    end
  end
end
