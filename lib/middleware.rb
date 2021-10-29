require './lib/condition'
require 'json'
require 'logger'

module Maintenance
  class Middleware
    def initialize(
      app,
      condition: default_condition,
      status: default_status,
      header: default_header,
      body: default_body,
      logger: default_logger
    )
      @app = app
      @condition = condition
      @status = status
      @header = header
      @body = body
      @response = [@status, @header, [@body]].freeze
      @logger = logger
    end

    def call(env)
      if @condition.call(env)
        @logger.warn(
          message: "endpoint #{env['REQUEST_METHOD']} #{env['REQUEST_PATH']} is under maintenance",
          method: env['REQUEST_METHOD'],
          path: env['REQUEST_PATH'],
          status: @response[0],
          tags: ['maintenance']
        )
        return @response
      end

      @app.call(env)
    end

    def default_condition
      ->(_) { false }.freeze
    end

    def default_status
      503
    end

    def default_header
      { 'Content-Type' => 'application/json' }
    end

    def default_body
      {
        errors: [{ message: 'This endpoint is under maintenance, please try again later.' }],
        meta: { http_status: @status }
      }.to_json
    end

    def default_logger
      Logger.new(STDERR)
    end
  end
end
