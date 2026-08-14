require "yard"
desc "Generate YARD documentation"
YARD::Rake::YardocTask.new do |yard|
  yard.files = ["lib/**/*.rb"]
end

desc "Generate API documentation"
task docs: :yard