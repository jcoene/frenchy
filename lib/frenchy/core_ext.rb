class Hash
  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end unless {}.respond_to?(:stringify_keys!)
end

class String
  def camelize
    dup.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end unless "".respond_to?(:camelize)

  def constantize
    names = self.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end

    constant
  end unless "".respond_to?(:constantize)

  def underscore
    dup.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end unless "".respond_to?(:underscore)
end