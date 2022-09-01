# frozen_string_literal: true

require_relative "sparkl/version"

module Sparkl
  class InvalidActionsError < StandardError; end

  DECORATORS_CONST_NAME = "Decorators".freeze
  private_constant :DECORATORS_CONST_NAME

  module Decoration
    ACTIONS = %i[
      before_action
      after_action
      skip_before_action
      skip_after_action
      prepend_before_action
      prepend_after_action
    ].to_set.freeze

    def self.extended(other)
      super
      module_container_for_decorator_methods = Module.new
      other.const_set DECORATORS_CONST_NAME, module_container_for_decorator_methods
      other.extend(module_container_for_decorator_methods)

      other.define_singleton_method :extended do |beyond|
        super beyond
        beyond.extend module_container_for_decorator_methods
      end
    end

    def decorator(name, **opts)
      if opts.empty? or opts.any? { |k, _| !ACTIONS.member?(k.to_sym) }
        raise InvalidOptionsError, "Invalid options #{opts}. Allowed: #{ACTIONS}"
      end

      const_get(DECORATORS_CONST_NAME).define_method name do |action_name|
        opts.each do |opt, args|
          public_send opt, *args, only: [action_name]
        end

        action_name
      end
    end

    alias def_decorator decorator
  end
end
