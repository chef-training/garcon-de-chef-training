require 'spec_helper'

# rubocop:disable BlockLength
describe GarconDeChefTraining do
  let(:garcon) { GarconDeChefTraining.new }
  let(:terraform) { GarconDeChefTraining::Terraform }
  let(:markdown) { GarconDeChefTraining::Markdown }

  before(:each) do
    @mock_config = <<-EOY
      class_type: 'rspec-essentials'
      company_name: 'mycorp'
    EOY
    allow(File).to receive(:read).with('config.yml').and_return(@mock_config)
    allow(Time).to receive_message_chain(:now, :strftime)
      .with('%Y-%m-%d')
      .and_return('2017-05-20')
    allow(terraform).to receive(:create_classroom!)
      .and_return(true)
    allow(terraform).to receive(:run_terraform_output)
      .and_return(true)
    allow(markdown).to receive(:create_markdown!)
      .and_return(true)

    # This prevents directories from being created in testing
    allow(FileUtils).to receive(:mkdir_p).and_return(true)
  end

  describe '#initialize' do
    it 'should load a YAML config' do
      expect(garcon.config).not_to be_nil
    end
    it 'should set `company_name` to `mycorp`' do
      expect(garcon.config['company_name']).to eql('mycorp')
    end
    it 'should build an output path containing a date' do
      expect(garcon.output_path).to match(/2017-05-20/)
    end
    it 'should build an output path containing a company name' do
      expect(garcon.output_path).to match(/mycorp/)
    end
    it 'should build an output path containing the class type' do
      expect(garcon.output_path).to match(/rspec-essentials/)
    end
    it 'should build a path containing a terraform directory' do
      expect(garcon.terraform_dir).to match(/terraform/)
    end
  end

  describe '#create_classroom!' do
    context 'when output path does not exist' do
      before do
        allow(File).to receive(:exist?)
          .with(garcon.output_path).and_return(false)
        allow(File).to receive(:exist?)
          .with(garcon.terraform_dir).and_return(false)
      end
      it 'should recursively create directories for output and terraform' do
        expect(FileUtils).to receive(:mkdir_p).with(garcon.output_path).once
        expect(FileUtils).to receive(:mkdir_p).with(garcon.terraform_dir).once
        garcon.create_classroom!
      end
    end
    context 'when output path does exist' do
      before do
        allow(File).to receive(:exist?)
          .with(garcon.output_path).and_return(true)
        allow(File).to receive(:exist?)
          .with(garcon.terraform_dir).and_return(true)
      end
      it 'should not recursively create directories for output and terraform' do
        expect(FileUtils).not_to receive(:mkdir_p).with(garcon.output_path)
        expect(FileUtils).not_to receive(:mkdir_p).with(garcon.terraform_dir)
        garcon.create_classroom!
      end
    end
    it 'should call ::Terraform.create_classroom!' do
      expect(terraform).to receive('create_classroom!')
        .with(garcon.config, garcon.safe_company_name, garcon.terraform_dir)
      garcon.create_classroom!
    end
  end

  describe '#destroy_classroom!' do
    it 'should call ::Terraform.run_terraform_destroy!' do
      expect(terraform).to receive('run_terraform_destroy!')
        .with(garcon.terraform_dir)
      garcon.destroy_classroom!
    end
    context 'when `force: true` is specified' do
      it 'should call ::Terraform.run_terraform_destroy! with `force: true`' do
        expect(terraform).to receive('run_terraform_destroy!')
          .with(garcon.terraform_dir, force: true)
        garcon.destroy_classroom!(force: true)
      end
    end
  end
end
# rubocop:enable BlockLength
