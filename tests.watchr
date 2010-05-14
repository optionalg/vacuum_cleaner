# Run me with:
#
#   $ watchr tests.watchr [env]
#
# If [env] is omitted, it's run against all defined envs in the $ENVS
# hash, feel free to change/adapt the $ENVS to suit your environment.
#

# --------------------------------------------------
# Environment fiddling, i.e. which ruby/rake binaries to use
# --------------------------------------------------
$ENVS = {
  :system  => { :ruby_bin => 'ruby',   :rake_bin => 'rake'   },
  :ruby19  => { :ruby_bin => 'ruby19', :rake_bin => 'rake19' },
  :jruby   => { :ruby_bin => 'jruby',  :rake_bin => 'jrake' }
}

# --------------------------------------------------
# Growl support, if available
# --------------------------------------------------
def run_all(bin, options)
  cli_env = ARGV.last.to_sym rescue nil
  if [:all, :any, :'*'].include?(cli_env)
    $ENVS.each do |env, bins|
      run_and_notify("#{bins[bin]} #{options}", env)
    end
  else
    cli_env = :system unless $ENVS.include?(cli_env)
    run_and_notify("#{$ENVS[cli_env][bin]} #{options}", cli_env)
  end
end

def run_and_notify(cmd, env = :system)
  result = `#{cmd}`
  puts result

  if system("growlnotify -v 1>/dev/null")
    message = result.split("\n").select { |l| l =~ /\d+ tests, \d+ asser/ }.join("\n").gsub(/\e\[(?:[34][0-7]|[0-9])?m/, '')
    status = (message =~ /[1-9]\d* failures/ or message =~ /[1-9]\d* errors/) ? "FAILURE" : "SUCCESS"
    system "growlnotify -w -n Watchr --image '.#{status.downcase}.png' -m '#{message}' 'vacuum_cleaner:#{env} #{status}' &"
  end
end

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch( '^lib/vacuum_cleaner/normalizations/active_support.rb' ) { |m| run_all :ruby_bin, "-Ilib:test test/integration/active_support_*_test.rb" }
watch( '^lib/vacuum_cleaner/(.*)\.rb' )   { |m| run_all :ruby_bin, "-Ilib:test test/unit/vacuum_cleaner/%s_test.rb" % m[1]                      }
watch( '^lib/vacuum_cleaner\.rb'      )   { |m| run_all :rake_bin, "-s test:unit"         }
watch( '^test/*/.*_test\.rb'          )   { |m| run_all :ruby_bin, "-Ilib:test %s" % m[0] }
watch( '^test/test_helper\.rb'        )   { |m| run_all :rake_bin, "-s test:unit"         }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  puts " --- Running all unit and integration tests ---\n\n"
  run_all :rake_bin, "-s test:all"
end

# Ctrl-C
Signal.trap('INT') { abort("\n") }
