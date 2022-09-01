# frozen_string_literal: true

RSpec.describe Sparkl do
  it "has a version number" do
    expect(Sparkl::VERSION).not_to be nil
  end

  it "doesn't allow decorator leaking across classes" do
    Class.new(ActionController::Base) do
      extend Sparkl::Decoration

      decorator :foo, before_action: ->{}
    end

    new = Class.new(ActionController::Base)
    expect { new.foo }.to raise_error NoMethodError
  end

  it "appends to the controller's process_action" do
    cl = Class.new ActionController::Base do
      extend Sparkl::Decoration

      decorator :foo, before_action: ->{}
    end

    expect {
      cl.instance_eval do
        foo def bar; end

        foo def baz; end
      end
    }.to change { cl.__callbacks[:process_action].instance_variable_get(:@chain).count }.by 2
  end

  it "works with def_decorator" do
    expect do
      Class.new(ActionController::Base) do
        extend Sparkl::Decoration

        before_action :authorize

        private def authorize
          puts "authorized"
        end

        def_decorator :allow_unauthorized, skip_before_action: :authorize

        allow_unauthorized def show
          render "Hello world"
        end
      end
    end.not_to raise_error
  end

  it "allows abstraction" do
    mod = Module.new do
      extend Sparkl::Decoration

      decorator :authorize, before_action: ->{}
    end

    expect do
      Class.new(ActionController::Base) do
        extend mod

        authorize def show; end
      end
    end.not_to raise_error
  end

  describe "skip_before_action" do
    it "allows you to define a decorator" do
      expect do
        Class.new(ActionController::Base) do
          extend Sparkl::Decoration

          before_action :authorize

          private def authorize
            puts "authorized"
          end

          decorator :allow_unauthorized, skip_before_action: :authorize

          allow_unauthorized def show
            render "Hello world"
          end
        end
      end.not_to raise_error
    end

    it "raises if the action isn't defined" do
      expect do
        Class.new(ActionController::Base) do
          extend Sparkl::Decoration

          decorator :allow_unauthorized, skip_before_action: :authorize

          allow_unauthorized def show
            render "Hello world"
          end
        end
      end.to raise_error(ArgumentError)
    end
  end

  describe "before_action" do
    it "allows you to define a decorator" do
      expect do
        Class.new(ActionController::Base) do
          extend Sparkl::Decoration

          private def perform_auth
            puts "authorized"
          end

          decorator :authorize, before_action: :perform_auth

          authorize def show
            render "Hello world"
          end
        end
      end.not_to raise_error
    end
  end

  describe "after_action" do
    it "allows you to define a decorator" do
      expect do
        Class.new(ActionController::Base) do
          extend Sparkl::Decoration

          private def perform_auth
            puts "authorized"
          end

          decorator :authorize, after_action: :perform_auth

          authorize def show
            render "Hello world"
          end
        end
      end.not_to raise_error
    end
  end

  describe "skip_after_action" do
    it "allows you to define a decorator" do
      expect do
        Class.new(ActionController::Base) do
          extend Sparkl::Decoration

          after_action :authorize

          private def authorize
            puts "authorized"
          end

          decorator :allow_unauthorized, skip_after_action: :authorize

          allow_unauthorized def show
            render "Hello world"
          end
        end
      end.not_to raise_error
    end

    it "raises if the action isn't defined" do
      expect do
        Class.new(ActionController::Base) do
          extend Sparkl::Decoration

          decorator :allow_unauthorized, skip_after_action: :authorize

          allow_unauthorized def show
            render "Hello world"
          end
        end
      end.to raise_error(ArgumentError)
    end
  end

  describe "prepend_before_action" do
    it "allows you to define a decorator" do
      expect do
        Class.new(ActionController::Base) do
          extend Sparkl::Decoration

          private def perform_auth
            puts "authorized"
          end

          decorator :authorize, prepend_before_action: :perform_auth

          authorize def show
            render "Hello world"
          end
        end
      end.not_to raise_error
    end
  end

  describe "prepend_after_action" do
    it "allows you to define a decorator" do
      expect do
        Class.new(ActionController::Base) do
          extend Sparkl::Decoration

          private def perform_auth
            puts "authorized"
          end

          decorator :authorize, prepend_after_action: :perform_auth

          authorize def show
            render "Hello world"
          end
        end
      end.not_to raise_error
    end
  end
end
