# (c) Copyright 2020 Ribose Inc.
#

RSpec.describe ::Jekyll::Geolexica::Hooks do
  subject do
    w = Object.new
    w.extend(described_class)
    w
  end

  let(:page) do
    instance_double(
      Jekyll::Geolexica::ConceptPage::HTML,
      output: page_output,
      html?: is_html,
    )
  end

  describe ".convert_math" do
    context "when page is HTML" do
      let(:is_html) { true }

      let(:page_output) do
        "foo stem:[a_2] bar"
      end

      let(:expected_output) do
        <<~OUTPUT.strip
          foo <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline">
            <mstyle displaystyle="true">
              <msub>
                <mi>a</mi>
                <mn>2</mn>
              </msub>
            </mstyle>
          </math>
           bar
        OUTPUT
      end

      it "should convert stem:[] to MathML" do
        expect { subject.send(:convert_math, page) }
          .to change { page.output }
          .from(page_output)
          .to(expected_output)
      end
    end

    context "when page is not HTML" do
      let(:is_html) { false }

      let(:page_output) do
        "foo stem:[a_2] bar"
      end

      let(:expected_output) do
        <<~OUTPUT.strip
          foo <math xmlns=\\"http://www.w3.org/1998/Math/MathML\\" display=\\"inline\\">  <mstyle displaystyle=\\"true\\">    <msub>      <mi>a</mi>      <mn>2</mn>    </msub>  </mstyle></math> bar
        OUTPUT
      end

      it "should convert stem:[] to MathML" do
        expect { subject.send(:convert_math, page) }
          .to change { page.output }
          .from(page_output)
          .to(expected_output)
      end
    end
  end
end
