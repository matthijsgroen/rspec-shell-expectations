Given(/^I have the shell script$/) do |script_contents|
  @script = workfolder.join('script.sh')
  @script.open('w') do |w|
    w.puts script_contents
  end
  @script.chmod 0777
end

Given(/^I have stubbed "(.*?)"$/) do |command|
  @stubbed_command = simulated_environment.stub_command command
end

Given(/^I have stubbed "(.*?)" with args:$/) do |command, table|
  # table is a Cucumber::Ast::Table
  args = table.hashes.map { |d| d['args'] }
  @stubbed_command = simulated_environment.stub_command(command)
    .with_args(*args)
end

Given(/^the stubbed command returns exitstatus (\d+)$/) do |statuscode|
  @stubbed_command.returns_exitstatus(statuscode.to_i)
end

When(/^I run this script in a simulated environment$/) do
  @status = simulated_environment.execute "#{@script} 2>&1"
end

Then(/^the exitstatus will not be (\d+)$/) do |statuscode|
  expect(@status.exitstatus).not_to eql statuscode.to_i
end

Then(/^the exitstatus will be (\d+)$/) do |statuscode|
  expect(@status.exitstatus).to eql statuscode.to_i
end

Then(/^the command "(.*?)" is called$/) do |command|
  stubbed_command = simulated_environment.stub_command command
  expect(stubbed_command).to be_called
end

Then(/^the command "(.*?)" is not called$/) do |command|
  stubbed_command = simulated_environment.stub_command command
  expect(stubbed_command).not_to be_called
end
