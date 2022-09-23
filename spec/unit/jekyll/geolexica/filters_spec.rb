# (c) Copyright 2020 Ribose Inc.
#

RSpec.describe Jekyll::Geolexica::Filters do
  let(:wrapper) do
    w = Object.new
    w.extend(described_class)
    w
  end

  describe "#display_authoritative_source" do
    subject { wrapper.method(:display_authoritative_source) }

    # Stub stock Liquid filter.
    before do
      def wrapper.escape_once(str); "!#{str}!"; end
    end

    let(:link) { "http://standards.example.test/a#chapter" }
    let(:ref) { "ISO 123:1984" }
    let(:clause) { "1.2.3" }

    it "returns 'ref' as link and ', clause' as string " \
      "when ref, clause, and link are given" do
      input = {
        "origin" => { "ref" => ref, "clause" => clause, "link" => link },
      }
      retval = subject.call(input)
      expect(retval).to eq(%(<a href="#{link}">!#{ref}!</a>, !#{clause}!))
    end

    it "returns 'ref, clause' as string when ref, and clause are given" do
      input = { "origin" => { "ref" => ref, "clause" => clause } }
      retval = subject.call(input)
      expect(retval).to eq("!#{ref}!, !#{clause}!")
    end

    it "returns 'ref' as link when ref, and link are given" do
      input = { "origin" => { "ref" => ref, "link" => link } }
      retval = subject.call(input)
      expect(retval).to eq(%(<a href="#{link}">!#{ref}!</a>))
    end

    it "returns 'ref' as string when ref, and clause are given" do
      input = { "origin" => { "ref" => ref } }
      retval = subject.call(input)
      expect(retval).to eq("!#{ref}!")
    end

    it "returns 'link' as link when only link is given" do
      input = { "origin" => { "link" => link } }
      retval = subject.call(input)
      expect(retval).to eq(%(<a href="#{link}">!#{link}!</a>))
    end

    it "returns an empty string when only clause is given" do
      input = { "clause" => clause }
      retval = subject.call(input)
      expect(retval).to eq("")
    end

    it "returns an empty string when neither of ref, clause, and link " +
      "is given" do
      input = {}
      retval = subject.call(input)
      expect(retval).to eq("")

      input = { "comment" => "some text" }
      retval = subject.call(input)
      expect(retval).to eq("")
    end

    it "returns an empty string for nil input" do
      retval = subject.call(nil)
      expect(retval).to eq("")
    end
  end

  describe "#concepts_url" do
    subject { wrapper.method(:concepts_url) }

    context "when base_url is nil or empty" do
      it { expect(subject.call(nil)).to be_nil }
      it { expect(subject.call("")).to be_nil }
    end

    context "when base_url ends with `/`" do
      let(:base_url) { "https://test-url/" }

      it { expect(subject.call(base_url)).to eq("#{base_url}concepts/") }
    end

    context "when base_url do not ends with `/`" do
      let(:base_url) { "https://test-url" }

      it { expect(subject.call(base_url)).to eq("#{base_url}/concepts/") }
    end
  end

  describe "#extract_concept_id" do
    subject { wrapper.method(:extract_concept_id) }

    context "when url is nil or empty" do
      it { expect(subject.call(nil)).to be_nil }
      it { expect(subject.call("")).to be_nil }
    end

    context "when url contains id" do
      let(:url) { "https://test-url/concepts/147" }

      it { expect(subject.call(url)).to eq("147") }
    end
  end

  describe "#abbreviation?" do
    subject { wrapper.method(:abbreviation?) }

    it "returns true if term is valid abbreviation" do
      expect(subject.call("type" => "truncation")).to eq(true)
      expect(subject.call("type" => "acronym")).to eq(true)
      expect(subject.call("type" => "initialism")).to eq(true)
    end

    it "returns false if term is not a valid abbreviation" do
      expect(subject.call("type" => "invalid")).to eq(false)
      expect(subject.call("type" => "hello_world")).to eq(false)
    end
  end

  describe "#preferred?" do
    subject { wrapper.method(:preferred?).call(term) }

    context "when normative_status is `preferred`" do
      let(:term) { { "normative_status" => "preferred" } }

      it { is_expected.to be(true) }
    end

    context "when normative_status is `invalid`" do
      let(:term) { { "normative_status" => "invalid" } }

      it { is_expected.to be(false) }
    end
  end

  describe "#deprecated?" do
    subject { wrapper.method(:deprecated?).call(term) }

    context "when normative_status is `deprecated`" do
      let(:term) { { "normative_status" => "deprecated" } }

      it { is_expected.to be(true) }
    end

    context "when normative_status is `invalid`" do
      let(:term) { { "normative_status" => "invalid" } }

      it { is_expected.to be(false) }
    end
  end

  describe "#get_authoritative" do
    subject { wrapper.method(:get_authoritative) }

    it "returns authoritative source if available in given sources" do
      sources = [
        { "type" => "authoritative" },
        { "type" => "lineage" },
      ]

      expect(subject.call(sources)).to eq(sources[0])
    end

    it "returns nil if authoritative source is not in given sources" do
      sources = [
        { "type" => "lineage" },
      ]

      expect(subject.call(sources)).to eq(nil)
    end

    it "returns nil if given sources are nil" do
      expect(subject.call(nil)).to eq(nil)
    end
  end

  describe "with term" do
    let(:term) do
      {
        "designation" => "admitted term",
        "geographical_area" => "GB",
        "usage_info" => "science",
        "grammar_info" => [{
          "preposition" => false,
          "participle" => false,
          "adj" => true,
          "verb" => false,
          "adverb" => false,
          "noun" => false,
          "gender" => ["m"],
          "number" => ["singular"],
        }],
      }
    end

    describe "#extract_grammar_info" do
      subject { wrapper.method(:extract_grammar_info) }

      it "return grammar_info from term" do
        expect(subject.call(term)).to eq("m singular adj")
      end

      it "return empty when grammar_info is not present" do
        expect(subject.call({})).to eq(nil)
      end
    end

    describe "#extract_parts_of_speech" do
      subject { wrapper.method(:extract_parts_of_speech) }

      it "return all parts of speech from grammar_info" do
        expect(subject.call(term["grammar_info"].first)).to eq("adj")
      end

      it "return empty when grammar_info is not present" do
        expect(subject.call({})).to eq("")
      end
    end

    describe "#display_terminological_data" do
      subject { wrapper.method(:display_terminological_data) }

      it "return all parts of speech from grammar_info" do
        expect(subject.call(term)).to eq(", &lt;science&gt; m singular adj GB")
      end

      it "return empty when grammar_info is not present" do
        expect(subject.call({})).to eq("")
      end
    end
  end
end
