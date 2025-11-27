module Hotsock
  module Turbo
    class Config
      attr_accessor :uid_resolver

      def initialize
        @uid_resolver = ->(view) { view.session.id.to_s }
      end
    end
  end
end
