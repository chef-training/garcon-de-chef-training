class GarconDeChefTraining
  # Helper module for Terraform related actions
  module Terraform
    require 'erb'

    def self.create_classroom!(config, safe_company_name, terraform_dir)
      template_data = read_template(config['class_type'])
      template_variables = config
      # This is used as a prefix for Terraform resources
      template_variables['safe_company_name'] = safe_company_name
      create_terraform_file!(template_data, template_variables, terraform_dir)
      run_terraform_init!(terraform_dir)
      run_terraform_apply!(terraform_dir)
    end

    def self.run_terraform_output(terraform_dir)
      Dir.chdir(terraform_dir) do
        `terraform output -json`
      end
    end

    def self.run_terraform_destroy!(terraform_dir, args = {})
      Dir.chdir(terraform_dir) do
        if args['force'] || args[:force]
          puts "Running `terraform destroy -force` in #{terraform_dir}"
          system('terraform destroy -force')
        else
          puts "Running `terraform destroy` in #{terraform_dir}"
          system('terraform destroy')
        end
      end
    end

    def self.installed?
      system('terraform version > /dev/null') ? true : false
    end

    def self.awscli_installed?
      system('aws --version &> /dev/null') ? true : false
    end

    # This allows for private methods in a module without needing a class
    class << self
      private

      def read_template(class_type)
        # Using `_dir_` evaluates to parent directory of this module
        path = File.join(
          __dir__,
          'templates',
          class_type,
          'terraform',
          'classroom.tf.erb'
        )
        File.read(path)
      end

      def create_terraform_file!(template_data, template_variables, output_path)
        # The `nil` argument renders the ERB using the current process
        # The `>` argument renders the ERB without newlines after tags
        # See: http://www.stuartellis.name/articles/erb/
        terraform_file = ERB.new(template_data, nil, '>').result(binding)

        # Create terraform file if it doesn't already exist
        output_filepath = File.join(output_path, 'classroom.tf')
        return if File.exist?(output_filepath)
        puts "Creating Terraform file `#{output_filepath}`"
        File.open(output_filepath, 'w') { |f| f.write(terraform_file) }
      end

      def run_terraform_apply!(terraform_dir)
        Dir.chdir(terraform_dir) do
          puts "Running `terraform plan` silently in `#{terraform_dir}`"
          system('terraform plan -detailed-exitcode > /dev/null')
          if $?.exitstatus == 2 # rubocop:disable SpecialGlobalVars
            puts "Running `terraform apply` in #{terraform_dir}..."
            system('terraform apply')
          else
            puts "No changes detected in #{terraform_dir} with `terraform plan`"
          end
        end
      end

      def run_terraform_init!(terraform_dir)
        Dir.chdir(terraform_dir) do
          puts "Running `terraform init` silently in `#{terraform_dir}`"
          system('terraform init > /dev/null')
        end
      end
    end
  end
end
