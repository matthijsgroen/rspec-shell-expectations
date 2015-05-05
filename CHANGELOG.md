# 1.3.0

  * Improved assertion message

# 1.2.0

  * Support for output filenames based on input arguments
    (`.outputs('something', to: [:arg2, '.png'])`
  * Updates local `ENV['PATH']` to easy test execution from private code
  * Add `stubbed_env.cleanup` to cleanup `ENV['PATH']` manually

# 1.1.0

  * Support chaining of arguments in multiple steps
    (`.with_args(...).with_args(...)`

# 1.0.0

 * Initial release
 * Support for
   * `create_stubbed_env`
   * Execute script with env-vars
   * Stubbing commands, output and exitstatus
   * Asserting calls, arguments and stdin
