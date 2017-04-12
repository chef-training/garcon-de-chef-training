require 'spec_helper'
require_relative '../../lib/garcon_de_chef_training/markdown'

# rubocop:disable BlockLength
describe GarconDeChefTraining::Markdown do
  let(:mock_config) do
    { 'class_type' => 'rspec-essentials' }
  end

  let(:mock_terraform_output) do
    '{
      "classroom_info": {
        "value": "mock_value"
      }
    }'
  end
  let(:markdown_dir) { 'mock/dir/markdown' }
  let(:output_filepath) do
    File.join(markdown_dir, "#{markdown_dir}_classroom_info.md")
  end

  let(:run_create_markdown_file) do
    GarconDeChefTraining::Markdown.create_markdown!(
      mock_config,
      mock_terraform_output,
      markdown_dir
    )
  end

  before do
    mock_erb = '<%= info[\'class_type\'] %>'
    allow(File).to receive(:read).with(/classroom_info.md/)
      .and_return(mock_erb)
  end

  describe '#create_markdown!' do
    context 'when `classroom_info.md` does not exist' do
      it 'creates classroom_info.md' do
        allow(File).to receive(:exist?).with(output_filepath).and_return(false)
        expect(File).to receive(:open).with(output_filepath, 'w')
        run_create_markdown_file
      end
    end

    context 'when `classroom_info.md` exists' do
      it 'does not create classroom_info.md' do
        allow(File).to receive(:exist?).with(output_filepath).and_return(true)
        expect(File).not_to receive(:open).with(output_filepath, 'w')
        run_create_markdown_file
      end
    end
  end
end
# rubocop:enable BlockLength
