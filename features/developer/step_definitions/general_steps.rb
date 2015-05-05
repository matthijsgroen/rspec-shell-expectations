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

Given(/^I have stubbed "(.*?)" with args as "(.*)":$/) do |command, call, table|
  # table is a Cucumber::Ast::Table
  args = table.hashes.map { |d| d['args'] }
  @stubbed_command = simulated_environment.stub_command(command)
                     .with_args(*args)
  @remembered_commands ||= {}
  @remembered_commands[call] = @stubbed_command
end

Given(/^I have stubbed "(.*?)" with args:$/) do |command, table|
  # table is a Cucumber::Ast::Table
  args = table.hashes.map { |d| d['args'] }
  @stubbed_command = simulated_environment.stub_command(command)
                     .with_args(*args)
end

sc = /^the stubbed command/
Given(/#{sc} returns exitstatus (\d+)$/) do |statuscode|
  @stubbed_command.returns_exitstatus(statuscode.to_i)
end

Given(/#{sc} outputs "(.*?)" to standard\-out$/) do |output|
  @stubbed_command.outputs(output, to: :stdout)
end

Given(/#{sc} outputs "(.*?)" to standard\-error$/) do |output|
  @stubbed_command.outputs(output, to: :stderr)
end

Given(/#{sc} outputs "(.*?)" to "(.*?)"$/) do |output, target|
  @stubbed_command.outputs(output, to: target)
  files_to_delete.push Pathname.new(target)
end

When(/^I run this script in a simulated environment$/) do
  @stdout, @stderr, @status = simulated_environment.execute "#{@script} 2>&1"
end

When(/^I run this script in a simulated environment with env:$/) do |table|
  env = Hash[table.hashes.map do |hash|
    [hash[:name], hash[:value]]
  end]

  @stdout, @stderr, @status = simulated_environment.execute(
    @script,
    env
  )
end

Then(/^the exitstatus will not be (\d+)$/) do |statuscode|
  expect(@status.exitstatus).not_to eql statuscode.to_i
end

Then(/^the exitstatus will be (\d+)$/) do |statuscode|
  expect(@status.exitstatus).to eql statuscode.to_i
end

c = /^(the command "[^"]+")/
Transform(/^the command "(.*)"/) do |command|
  cmd = (@remembered_commands || {})[command]
  cmd || simulated_environment.stub_command(command)
end

Then(/#{c} is called$/) do |command|
  expect(command).to be_called
end

Then(/#{c} is called with "(.*?)"$/) do |command, argument|
  expect(command.with_args(argument)).to be_called
end

Then(/#{c} is not called$/) do |command|
  expect(command).not_to be_called
end

Then(/#{c} has received "(.*?)" from standard\-in$/) do |command, contents|
  expect(command.stdin).to match contents
end

Then(/^the file "(.*?)" contains "(.*?)"$/) do |filename, contents|
  files_to_delete.push Pathname.new(filename)
  expect(Pathname.new(filename).read).to eql contents
end
