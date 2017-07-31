# Creates Classrooms for Chef Courses via Terraform
class GarconDeChefTraining
  require 'fileutils'
  require 'yaml'

  require_relative 'garcon_de_chef_training/terraform'
  require_relative 'garcon_de_chef_training/markdown'

  attr_reader :config, :output_path, :terraform_dir, :safe_company_name

  def initialize(path_to_config_yaml = 'config.yml')
    # rubocop:disable Security/YAMLLoad
    @config = YAML.load(File.read(path_to_config_yaml))
    # rubocop:enable Security/YAMLLoad

    # This replaces non-alphanumeric characters with `-`
    # It is used in making directory path and prefixing Terraform variables
    @safe_company_name = config['company_name'].tr('^A-Za-z0-9', '-')
    @output_path = build_output_path
    @terraform_dir = File.join(output_path, 'terraform')
  end

  # Performs all the steps needed to create a classroom
  def create_classroom!
    prompt_for_continue if class_exist?
    create_directory!(@output_path)
    create_directory!(@terraform_dir)
    create_machines!
    create_markdown!
  end

  # Performs all the steps needed to destroy a classroom
  def destroy_classroom!(args = {})
    if args['force'] || args[:force]
      GarconDeChefTraining::Terraform.run_terraform_destroy!(
        select_terraform_dir,
        force: true
      )
    else
      GarconDeChefTraining::Terraform.run_terraform_destroy!(
        select_terraform_dir
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
    # `$stdout` is explicity called here for RSPEC matcher
    $stdout.puts "WARNING: Class #{class_name} already exists"
    $stdout.puts 'WARNING: Continuing could cause unexpected results'
    $stdout.puts 'Are you sure you want to continue? (Y/N)'
    exit 0 if $stdin.gets.chomp.casecmp('N').zero?
  end

  # The `@terraform_dir` always has the current date in it
  # This method selects one class based on matching everything but the date
  def select_terraform_dir
    # Select all terraform directories in `output/`
    terraform_dirs = Dir.glob('output/**/terraform')
    class_selector = [@safe_company_name, @config['class_type']].join('-')
    # Build list of Terraform directories that match the class selector
    selected_dirs = terraform_dirs.select { |d| d.match(class_selector) } || []
    num_classes = selected_dirs.length
    return selected_dirs.first if num_classes == 1
    raise "ERROR: Multiple classes match #{class_selector}" if num_classes > 1
    raise "ERROR: No classes match #{class_selector}" if num_classes.zero?
  end
end
