Given(/^I have the shell script$/) do |script_contents|
  workfolder.join('script.sh').open('w') do |w|
    w.puts script_contents
  end
end

When(/^I run this script in a simulated environment$/) do
  @status = simulated_environment.execute 'script.sh 2>&1'
end

Then(/^the exitstatus will not be (\d+)$/) do |statuscode|
  expect(@status.exitstatus).not_to eql statuscode.to_i
end
