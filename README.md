# Emiler

Naïve distance calculation for emails. Returns “similar” basing on artificial
name and domain comparison.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'emiler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install emiler

## Usage

```ruby
require 'emiler'

Emiler.similarity('abc.zzzzzz@example.com', 'abc@example.ru')
#⇒ {:jw=>0.6897546897546897, :full=>0.8000000000000002, :name=>0.8, :domain=>0.8, :result=>true}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/emiler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
