require 'spec_helper'
require_relative '../../lib/garcon_de_chef_training/terraform'

# rubocop:disable BlockLength
describe GarconDeChefTraining::Terraform do
  let(:mock_config) do
    { 'class_type' => 'rspec-essentials' }
  end

  let(:safe_company_name) { 'Test-Corp' }
  let(:terraform_dir) { 'mock/dir/terraform' }

  let(:run_create_classroom) do
    GarconDeChefTraining::Terraform.create_classroom!(
      mock_config,
      safe_company_name,
      terraform_dir
    )
  end

  let(:run_terraform_output) do
    GarconDeChefTraining::Terraform.run_terraform_output(
      terraform_dir
    )
  end

  let(:output_filepath) { File.join(terraform_dir, 'classroom.tf') }

  before do
    mock_erb = '<%= template_variables[\'class_type\'] %>'
    allow(File).to receive(:read).with(/classroom.tf.erb/)
      .and_return(mock_erb)

    # Only one context assumes this is false
    # Moving this allow here reduces repitition
    allow(File).to receive(:exist?).with(output_filepath).and_return(true)

    # This allows `Dir.chdir` to run it's block even on error
    # Without this the contents of the block will not run
    allow(Dir).to receive(:chdir).with(terraform_dir) { |&block| block.call }

    allow(described_class).to receive(:system)
      .with('terraform plan -detailed-exitcode > /dev/null')
      .and_return(true)

    # This mocks the exitstatus from `terraform plan`
    # rubocop:disable SpecialGlobalVars
    allow($?).to receive(:exitstatus)
      .and_return(2)
    # rubocop:enable SpecialGlobalVars

    allow(described_class).to receive(:system)
      .with('terraform apply')
      .and_return(true)
  end

  describe '#create_classroom!' do
    context 'when `classroom.tf` does not exist' do
      it 'creates classroom.tf' do
        allow(File).to receive(:exist?).with(output_filepath).and_return(false)
        output_filepath = File.join(terraform_dir, 'classroom.tf')
        expect(File).to receive(:open).with(output_filepath, 'w')
        run_create_classroom
      end
    end

    context 'when `classroom.tf` exists' do
      it 'does not create classroom.tf' do
        expect(File).not_to receive(:open).with(output_filepath, 'w')
        run_create_classroom
      end
    end

    it 'runs `terraform plan`' do
      expect(described_class).to receive(:system)
        .with('terraform plan -detailed-exitcode > /dev/null').once
      run_create_classroom
    end

    context 'when `terraform plan` indicates changes' do
      it 'runs `terraform apply`' do
        expect(described_class).to receive(:system)
          .with('terraform apply').once
        run_create_classroom
      end
    end

    context 'when `terraform plan` does not indicate changes' do
      it 'does not run `terraform apply`' do
        # rubocop:disable SpecialGlobalVars
        allow($?).to receive(:exitstatus)
          .and_return(0)
        # rubocop:enable SpecialGlobalVars
        expect(described_class).not_to receive(:system)
          .with('terraform apply')
        run_create_classroom
      end
    end
  end

  describe '#run_terraform_output' do
    it 'runs `terraform output -json`' do
      allow(described_class).to receive(:`)
        .with('terraform output -json')
        .and_return(true)

      expect(described_class).to receive('`')
        .with('terraform output -json').once

      run_terraform_output
    end
  end

  describe '#run_terraform_destroy!' do
    context 'when `force` is not specified' do
      it 'runs `terraform destroy`' do
        allow(described_class).to receive('system')
          .with('terraform destroy')
          .and_return(true)

        expect(described_class).to receive('system')
          .with('terraform destroy').once

        GarconDeChefTraining::Terraform.run_terraform_destroy!(
          terraform_dir
        )
      end
    end
    context 'when `force` is specified' do
      it 'runs `terraform destroy -force`' do
        allow(described_class).to receive('system')
          .with('terraform destroy -force')
          .and_return(true)

        expect(described_class).to receive('system')
          .with('terraform destroy -force').once

        GarconDeChefTraining::Terraform.run_terraform_destroy!(
          terraform_dir,
          force: true
        )
      end
    end
  end
end
# rubocop:enable BlockLength
