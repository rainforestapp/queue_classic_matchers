# QueueClassicMatchers

Test helpers and RSpec matchers to [QueueClassicPlus](https://github.com/rainforestapp/queue_classic_plus).

## Compatibility

This version of the matchers are compatible with queue_classic 3.1+ which includes built-in scheduling. See other branches for other compatible versions.

## Installation

Add this line to your application's Gemfile:

    gem 'queue_classic_matchers'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install queue_classic_matchers

## Usage

TODO: Write usage instructions here

### Matchers

```ruby
expect(MyQueueClassicPlusJob).to have_queued(*my_args)
```

Other matchers are `have_queue_size_of`, `change_queue_size_of` and `have_scheduled`.


### Test Helper

Run a subset of the jobs in a queue. Delete the others.

```ruby
run_queue q_name, [MyQueueClassicPlusJob]
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/queue_classic_matchers/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
