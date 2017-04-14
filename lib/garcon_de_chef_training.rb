# Creates Classrooms for Chef Courses via Terraform
class GarconDeChefTraining
  require 'fileutils'
  require 'yaml'

  require_relative 'garcon_de_chef_training/terraform'
  require_relative 'garcon_de_chef_training/markdown'

  attr_reader :config, :output_path, :terraform_dir, :safe_company_name

  def initialize
    @config = YAML.safe_load(File.read('config.yml'))
    # This replaces non-alphanumeric characters with `-`
    # It is used in making directory path and prefixing Terraform variables
    @safe_company_name = config['company_name'].tr('^A-Za-z0-9', '-')
    @output_path = build_output_path
    @terraform_dir = File.join(output_path, 'terraform')
  end

  # Performs all the steps needed to create a classroom
  def create_classroom!
    if class_exist?
      prompt_for_continue
    else
      create_directory!(@output_path)
      create_directory!(@terraform_dir)
      create_machines!
      create_markdown!
    end
  end

  # Performs all the steps needed to destroy a classroom
  def destroy_classroom!(args = {})
    if args['force'] || args[:force]
      GarconDeChefTraining::Terraform.run_terraform_destroy!(
        @terraform_dir,
        force: true
      )
    else
      GarconDeChefTraining::Terraform.run_terraform_destroy!(
        @terraform_dir
      )
    end
  end

  private

  # Build output directory path (Example: `output/170403-MyCorp-essentials`)
  def build_output_path
    File.join(
      'output',
      [
        Time.now.strftime('%Y-%m-%d'),
        @safe_company_name,
        @config['class_type']
      ].join('-')
    )
  end

  # Recursively create a path if it doesn't exist
  def create_directory!(path)
    return if File.exist?(path)
    puts "Creating directory `#{path}`"
    FileUtils.mkdir_p(path)
  end

  def create_machines!
    GarconDeChefTraining::Terraform.create_classroom!(
      @config,
      @safe_company_name,
      @terraform_dir
    )
  end

  def create_markdown!
    GarconDeChefTraining::Markdown.create_markdown!(
      @config,
      GarconDeChefTraining::Terraform.run_terraform_output(@terraform_dir),
      @output_path
    )
  end

  def class_exist?
    File.exist?(@output_path)
  end

  def prompt_for_continue
    class_name = @output_path.gsub('output/', '')
    # `STDOUT` is explicity called here for RSPEC matcher
    STDOUT.puts "WARNING: Class #{class_name} already exists"
    STDOUT.puts 'WARNING: Continuing could cause unexpected results'
    STDOUT.puts 'Are you sure you want to continue? (Y/N)'
    exit 0 if $stdin.gets.chomp.casecmp('N').zero?
  end
end
