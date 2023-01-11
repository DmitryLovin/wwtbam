source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"
gem "rails", "~> 7.0.4"

gem "cssbundling-rails"
gem "devise"
gem "devise-i18n"
gem "font-awesome-rails"
gem "jsbundling-rails"
gem "puma", "~> 5.0"
gem "rails_admin", '~> 3.1', git: 'https://github.com/sferik/rails_admin.git'
gem "russian"
gem "sassc-rails"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "sqlite3", "~> 1.4"
end

group :development do
  gem "web-console"
end

group :production do
  gem "pg", "~> 1.1"
end
