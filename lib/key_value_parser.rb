class KeyValueParser

  def initialize defaults={}, options={}
    @defaults = defaults
    @options = {
      separator: /\s*[=:]\s*/,
      normalize_keys: true,
      typecast_values: true,
      array_values: true
    }.merge(options)
  end

  def parse kvs
    @defaults.merge(
      Hash[
        kvs.map do |a| 
          k, *v = a.split(@options[:separator], @options[:array_values] ? 0 : 2)
          if v.size==1
            v = v[0]
          elsif v.size==0
            v = nil
          end
          [
            @options[:normalize_keys] ? normalize_key(k) : k, 
            @options[:typecast_values] ? typecast(v) : v
          ]
        end
      ]
    )
  end

  private

  def normalize_key k
    k.sub(/^--/,'').gsub(/[\s\-]+/, '_').to_sym
  end

  def typecast v
    if v.is_a? Array
      return v.map{|item| typecast(item)}
    end
    if v=='true' or v.nil?
      v = true
    elsif v=='false'
      v = false
    elsif v=~/^-?\d*\.\d+$/
      v = v.to_f
    elsif v=~/^-?\d+$/
      v = v.to_i
    else
      v
    end
  end

end

