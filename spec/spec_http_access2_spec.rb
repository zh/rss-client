require 'spec/helper'

describe 'http-access2' do

  before do
    @client = HTTPAccess2::Client.new
  end

  it 'should have an object identity' do
    @client.should_not == HTTPAccess2::Client.new
  end

end
