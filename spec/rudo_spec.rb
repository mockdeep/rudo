require 'rspec'

require './lib/rudo.rb'

describe Rudo do

  it "should pass a dumb test" do
    r = Rudo.new
    r.class.should == Rudo
  end

end
