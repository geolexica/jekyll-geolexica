# (c) Copyright 2021 Ribose Inc.
#

RSpec.describe ::Jekyll::Geolexica::JbuilderTag do
  subject { instance }

  let :instance do
    described_class.new
  end

  it "renders JSON template with Jbuilder" do
    tpl = <<~LIQUID
      {% jbuilder %}
      json.one 1
      json.two 2
      {% endjbuilder %}
    LIQUID

    actual = render_template(tpl)
    expected = render_hash({ one: 1, two: 2 })

    expect(actual).to eq(expected)
  end

  it "provides access to rendering context" do
    tpl = <<~LIQUID
      {% jbuilder %}
      json.one page["one"]
      json.two context["page"]["two"]
      {% endjbuilder %}
    LIQUID

    actual = render_template(tpl, { "one" => 1, "two" => 2 })
    expected = render_hash({ one: 1, two: 2 })

    expect(actual).to eq(expected)
  end

  def render_template(template_string, front_matter = {})
    template = Liquid::Template.parse(template_string)
    template_data = { "page" => front_matter }
    template.render(template_data).strip
  end

  def render_hash(hash)
    JSON.pretty_generate(hash).strip
  end
end
