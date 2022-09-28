# (c) Copyright 2020 Ribose Inc.
#

module FixtureHelper
  def fixture(name)
    File.read(fixture_path(name))
  end

  def fixture_path(name)
    File.expand_path(name, fixtures_dir)
  end

  def fixtures_dir
    File.expand_path("../concept_fixtures", __dir__)
  end

  def load_concept_fixture(fixture_name)
    data = YAML.safe_load(fixture(fixture_name), permitted_classes: [Time])
    ::Jekyll::Geolexica::Glossary::Concept.new(data)
  end
end

RSpec.configure do |config|
  config.include FixtureHelper
end
