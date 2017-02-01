# Creates Classrooms for Chef Courses via Terraform
class GarconDeChefTraining
  require 'YAML'
  require 'erb'
  require 'json'

  attr_accessor :variables, :output_dir
  attr_accessor :classroom_terraform, :classroom_markdown

  def initialize
    @variables = YAML.load(File.read('variables.yml'))
    add_runtime_variables
    create_output_directories
  end

  def create_classroom
    create_output_directories
    generate_terraform_file
    run_terraform_apply
    generate_classroom_markdown
  end

  def render_terraform
    create_output_directories
    generate_terraform_file
  end

  def generate_terraform_file
    render_classroom_terraform
    output_terraform_file = File.join(@output_dir, 'terraform', 'classroom.tf')
    puts "Rendering Terraform template `#{output_terraform_file}`..."
    File.open(output_terraform_file, 'w') { |f| f.write(@classroom_terraform) }
  end

  def run_terraform_apply
    Dir.chdir(File.join(@output_dir, 'terraform')) do
      system('terraform plan -detailed-exitcode > /dev/null')
      if $?.exitstatus == 2 # rubocop:disable SpecialGlobalVars
        puts 'Running `terraform apply`...'
        system('terraform apply')
      else
        puts "No changes detected in #{@output_dir} via `terraform plan`"
      end
    end
  end

  def generate_classroom_markdown
    render_classroom_markdown
    classroom_markdown_file = File.join(
      @output_dir,
      "#{@output_dir.gsub(/output./, '')}_classroom_info.md"
    )
    puts "Rendering classroom info markdown `#{classroom_markdown_file}`..."
    File.open(classroom_markdown_file, 'w') { |f| f.write(@classroom_markdown) }
  end

  private

  def render_classroom_terraform
    @classroom_terraform = ERB.new(
      File.read(
        File.join(choose_classroom_templates, 'terraform', 'classroom.tf.erb')
      ),
      nil,
      '>'
    ).result(binding)
  end

  def render_classroom_markdown
    info = JSON.parse(run_terraform_output)['classroom_info']['value']
    @classroom_markdown = ERB.new(
      File.read(
        File.join(choose_classroom_templates, 'classroom_info.md.erb')
      ),
      nil,
      '>'
    ).result(binding)
  end

  def add_runtime_variables
    @variables['current_date'] = Time.now.strftime('%Y-%m-%d')
    @variables['prefix'] = @variables['company_name'].tr('^A-Za-z0-9', '-')

    @output_dir = File.join(
      'output',
      [
        @variables['current_date'],
        @variables['prefix'],
        @variables['class_type']
      ].join('-')
    )
  end

  def create_output_directories
    ['output', @output_dir, File.join(@output_dir, 'terraform')].each do |d|
      unless File.exist?(d)
        puts "Creating output directory `#{d}`"
        Dir.mkdir(d)
      end
    end
  end

  def choose_classroom_templates
    case @variables['class_type']
    when 'chef-essentials'
      'templates/essentials/linux/'
    when 'chef-essentials-windows'
      'templates/essentials/windows/'
    when 'chef-intermediate'
      'templates/intermediate/linux/'
    end
  end

  def run_terraform_output
    Dir.chdir(File.join(@output_dir, 'terraform')) do
      `terraform output -json`
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  garcon = GarconDeChefTraining.new
  args = Hash[ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/)]

  if args.key?('render-only')
    garcon.render_terraform
  else
    garcon.create_classroom
  end
end
