module Colors
  COLORS = {
    :blink  => 5,
    :red    => 31,
    :green  => 32,
    :yellow => 33,
    :blue   => 34,
  }

  def self.colored(text='', color=:blink)
    if ENV['COLOR']=='true'
      "\e[#{COLORS[color]}m#{text}\e[0m"
    else
      text
    end
  end
end
