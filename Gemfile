source 'https://rubygems.org'

# Specify your gem's dependencies in hydra-access-controls.gemspec
gemspec

group :development do
  gem 'jettywrapper'
  gem 'debugger', :platform => :mri_19
end

group :test do
  gem 'cucumber-rails', '>=1.2.0', :require=>false
  gem 'rcov', :platform => :mri_18
  gem 'simplecov', :platform => :mri_19
  gem 'simplecov-rcov', :platform => :mri_19
  gem 'factory_girl', '< 3.0.0' # factory girl 3+ doesn't work with ruby 1.8
end
