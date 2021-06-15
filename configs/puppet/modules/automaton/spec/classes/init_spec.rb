require 'spec_helper'
describe 'automaton' do

  context 'with defaults for all parameters' do
    it { should contain_class('automaton') }
  end
end
