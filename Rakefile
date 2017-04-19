require_relative 'lib/garcon_de_chef_training'

task :default do
  system('rake --tasks')
end

desc 'Create classroom using `./config.yml`'
task :create do
  GarconDeChefTraining.new.create_classroom!
end

namespace :destroy do
  desc 'Run `terraform destroy -f` in classroom\'s Terraform directory'
  task :force do
    GarconDeChefTraining.new.destroy_classroom!(force: true)
  end
end

desc 'Run `terraform destroy` in classroom\'s Terraform directory'
task :destroy do
  GarconDeChefTraining.new.destroy_classroom!
end

namespace :test do
  desc 'Run RuboCop'
  task :lint do
    system('rubocop')
  end

  desc 'Run RSpec'
  task :unit do
    system('rspec')
  end

  task all: [:lint, :unit]
end

# Define common aliases
task rubocop: 'test:lint'
task rspec: 'test:unit'
task spec: 'test:unit'

desc 'Run RSpec and RuboCop'
task test: 'test:all'
