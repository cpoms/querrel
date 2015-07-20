# Querrel

Playing around with the idea of parallel queries to multiple databases with ActiveRecord, more info [on my blog post](http://www.wordofmike.net/j/shard-query-rails-querying-multiple-databases).

## Installation

Add this line to your application's Gemfile:

    gem 'querrel'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install querrel

## Usage

You can use with Querrel directly via it's top level namespace, or by creating an instance:

```ruby
all_brands = Querrel.query(Brand.all, on: ['db1', 'db2', 'db3'])
# is the same as
all_brands = Querrel.new(['db1', 'db2', 'db3']).query(Brand.all)
```

Either of the above will give you an array of all the Brand objects from all the given databases. The records will be marked as readonly.

There are three ways in which you can instruct Querrel which databases to use:

1. Pass in an array of environments, e.g. `Querrel.new([:customer1, :customer2])`
2. Pass in an array of database names, e.g. `Querrel.new(['dbs/customer1.sqlite3', 'dbs/customer2.sqlite3'], db_names: true)`
3. Pass in a hash of named connection configurations, e.g.:

    ```ruby
    Querrel.new({
      one: {
        adapter: "sqlite3",
        database: "test/dbs/test_db_1.sqlite3"
      },
      two: {
        adapter: "sqlite3",
        database: "test/dbs/test_db_2.sqlite3"
      }
    })
    ```

## Contributing

1. Fork it ( https://github.com/meritec/querrel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
