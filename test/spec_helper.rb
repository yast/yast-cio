if ENV["COVERAGE"]
  require "simplecov"

  # use coveralls for on-line code coverage reporting at Travis CI
  if ENV["TRAVIS"]
    require "coveralls"

    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      Coveralls::SimpleCov::Formatter
    ]
  end

  SimpleCov.start
end

$:.unshift(File.expand_path("../../src/lib", __FILE__))
