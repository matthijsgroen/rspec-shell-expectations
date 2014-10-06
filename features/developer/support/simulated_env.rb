require 'rspec/shell/expectations'
#:nodoc:
module SimulatedEnv
  def simulated_environment
    @sim_env ||= Rspec::Shell::Expectations::StubbedEnv.new
  end
end

World(SimulatedEnv)
