class GarconDeChefTraining
  # Creates Markdown of information for students
  module Markdown
    require 'json'

    def self.create_markdown!(config, terraform_output, markdown_dir)
      create_markdown_file!(
        template_data: read_template(config['class_type']),
        company_name: config['company_name'],
        terraform_output: terraform_output,
        markdown_dir: markdown_dir
      )
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
          'classroom_info.md.erb'
        )
        File.read(path)
      end

      def create_markdown_file!(data)
        terraform_data = JSON.parse(data[:terraform_output])

        # This is used to feed the `info` and `company_name` variable in the ERB
        info = terraform_data['classroom_info']['value']
        company_name = data[:company_name]

        # The `nil` argument renders the ERB using the current process
        # The `>` argument renders the ERB without newlines after tags
        # See: http://www.stuartellis.name/articles/erb/
        markdown_file = ERB.new(data[:template_data], nil, '>').result(binding)
        write_markdown_file!(markdown_file, data[:markdown_dir])
      end

      def write_markdown_file!(markdown_file, output_path)
        # Create markdown file if it doesn't already exist
        # Uses `output_path` minus the `output/` as an identifier
        output_filepath = File.join(
          output_path,
          "#{output_path.gsub(/output./, '')}_classroom_info.md"
        )
        return if File.exist?(output_filepath)
        puts "Creating Markdown file `#{output_filepath}`"
        File.open(output_filepath, 'w') { |f| f.write(markdown_file) }
      end
    end
  end
end
