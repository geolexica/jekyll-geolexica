# (c) Copyright 2020 Ribose Inc.
#

RSpec.describe ::Jekyll::Geolexica::ConceptsGenerator do
  it "is a Jekyll generator" do
    expect(described_class.ancestors).to include(::Jekyll::Generator)
  end
end
