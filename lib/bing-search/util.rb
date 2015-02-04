module BingSearch

  # @private
  module Util
    class << self
      def underscore(string)
        string.gsub(/([^A-Z])([A-Z])/, '\1_\2').downcase
      end

      def camelcase(string)
        string.gsub(/(?:^|_)([a-z])/) { $1.upcase }
      end

      def slice_hash(hash, *keys)
        keys.each_with_object(Hash.new) do |key, result|
          result[key] = hash[key] if hash.has_key?(key)
        end
      end
    end
  end

end
