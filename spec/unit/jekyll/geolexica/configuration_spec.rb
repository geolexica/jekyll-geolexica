# (c) Copyright 2020 Ribose Inc.
#

RSpec.describe ::Jekyll::Geolexica::Configuration do
  let(:described_module) { described_class }

  let(:wrapper) do
    wrapper = OpenStruct.new(site: fake_site)
    wrapper.extend(described_module)
    wrapper
  end

  let(:fake_site) do
    instance_double(
      Jekyll::Site,
      config: fake_config,
      source: fake_site_source,
    )
  end

  let(:fake_config) { load_plugin_config }
  let(:fake_site_source) { "/some/path" }
  let(:fake_geolexica_config) { fake_config["geolexica"] }

  describe "#glossary_config" do
    subject { wrapper.method(:glossary_config) }

    it "returns a Geolexica configuration" do
      fake_geolexica_config.replace({some: "entries"})
      expect(subject.()).to eq(fake_geolexica_config)
    end

    it "has some sensible defaults" do
      expect(subject.()).to be_a(Hash)
      expect(subject.()).not_to be_empty
    end
  end

  describe "#concepts_glob" do
    subject { wrapper.method(:concepts_glob) }

    it "returns a configured glob path to concepts" do
      fake_geolexica_config.replace({"concepts_glob" => "./some/glob/*"})
      expect(subject.()).to eq(File.expand_path("#{fake_site_source}/some/glob/*"))
    end

    it "has some sensible defaults" do
      expect(subject.()).to be_a(String) & match(/\*/)
    end
  end

  describe "term languages" do
    specify "are configurable in Geolexica, and have sensible defaults" do
      langs = fake_geolexica_config["term_languages"]
      expect(langs).to be_an(Array) & include("eng")
    end

    specify "are accessible via #term_languages method" do
      retval = wrapper.term_languages
      expect(retval).to be_an(Array)
      expect(retval).to eq(fake_geolexica_config["term_languages"])
    end
  end

  describe "output formats" do
    specify "are configurable in Geolexica, and have sensible defaults" do
      formats = fake_geolexica_config["formats"]
      expect(formats).to be_an(Array) & include("html")
    end

    specify "settings are accessible via convenience methods" do
      expect(wrapper).to respond_to(:output_html?)
      expect(wrapper).to respond_to(:output_json?)
      expect(wrapper).to respond_to(:output_jsonld?)
      expect(wrapper).to respond_to(:output_tbx?)
      expect(wrapper).to respond_to(:output_turtle?)
      expect(wrapper).to respond_to(:output_yaml?)
    end

    specify "can be enabled in configuration" do
      fake_geolexica_config["formats"] =
        %w[html json json-ld tbx-iso-tml turtle yaml]

      expect(wrapper.output_html?).to be(true)
      expect(wrapper.output_json?).to be(true)
      expect(wrapper.output_jsonld?).to be(true)
      expect(wrapper.output_tbx?).to be(true)
      expect(wrapper.output_turtle?).to be(true)
      expect(wrapper.output_yaml?).to be(true)
    end

    specify "can be disabled in configuration" do
      fake_geolexica_config["formats"] = []

      expect(wrapper.output_html?).to be(false)
      expect(wrapper.output_json?).to be(false)
      expect(wrapper.output_jsonld?).to be(false)
      expect(wrapper.output_tbx?).to be(false)
      expect(wrapper.output_turtle?).to be(false)
      expect(wrapper.output_yaml?).to be(false)
    end
  end

  def load_plugin_config
    path = File.expand_path("../../../../_config.yml", __dir__)
    yaml = File.read(path)
    YAML.safe_load(yaml, permitted_classes: [Time])
  end
end
