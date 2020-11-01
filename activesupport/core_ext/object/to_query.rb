require 'active_support'
require 'active_support/core_ext'

class Hash
  @@valid_options_for_to_query = Set[:namespace, :preserve_order].freeze

  # Backwards-compatible with ActiveSupport 5.2 and 6.0's version of this method.
  # Now that many of us expect hash ordering to be consistent and reliable,
  # the lexicographic sorting provided by the original ActiveSupport .to_hash() can be an inconvenience.
  # Updated contract now supports an options hash with 2 values:
  # :namespace option serves the same role as the lone parameter that we can pass to the original version of the method.
  # :preserve_order option, when passed as true, overrides the default lexicographic sorting.
  # For example: {breakfast: 'eggs', lunch: 'sandwich', dinner: 'steak', dessert: 'pie'}
  # returns "breakfast=eggs&dessert=pie&dinner=steak&lunch=sandwich" if the original .to_hash() method is used,
  # and "breakfast=eggs&lunch=sandwich&dinner=steak&dessert=pie" if .to_hash(preserve_order: true) is called instead.
  def to_query(options_or_namespace = nil)
    if options_or_namespace.is_a?(Hash) && options_or_namespace.all? { |key, _value| @@valid_options_for_to_query.include?(key) }
      # support newer contract with an options hash
      namespace = options_or_namespace[:namespace]
      preserve_order = options_or_namespace[:preserve_order]
    else
      # support older contract with a single namespace argument
      namespace = options_or_namespace
      preserve_order = false
    end
    query = collect do |key, value|
      unless (value.is_a?(Hash) || value.is_a?(Array)) && value.empty?
        value.to_query(namespace ? "#{namespace}[#{key}]" : key)
      end
    end.compact
    query.sort! unless preserve_order || namespace.to_s.include?("[]")
    query.join("&")
  end

  alias_method :to_param, :to_query
end