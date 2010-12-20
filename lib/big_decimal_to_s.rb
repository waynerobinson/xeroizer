class BigDecimal
  
  def to_s_with_default_format(format = 'F')
    to_s_without_default_format(format)
  end
  alias_method :to_s_without_default_format, :to_s
  alias_method :to_s, :to_s_with_default_format
  
end