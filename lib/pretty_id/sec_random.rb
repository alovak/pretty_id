module PrettyId
  # taken from Ruby 2.5 implementation
  class SecRandom
    ALPHANUMERIC = [*'A'..'Z', *'a'..'z', *'0'..'9']

    def self.alphanumeric(n=nil)
      n = 16 if n.nil?
      choose(ALPHANUMERIC, n)
    end

    def self.choose(source, n)
      size = source.size
      m = 1
      limit = size
      while limit * size <= 0x100000000
        limit *= size
        m += 1
      end
      result = ''.dup
      while m <= n
        rs = SecureRandom.random_number(limit)
        is = rs.digits(size)
        (m-is.length).times { is << 0 }
        result << source.values_at(*is).join('')
        n -= m
      end
      if 0 < n
        rs = SecureRandom.random_number(limit)
        is = rs.digits(size)
        if is.length < n
          (n-is.length).times { is << 0 }
        else
          is.pop while n < is.length
        end
        result.concat source.values_at(*is).join('')
      end
      result
    end
  end
end
