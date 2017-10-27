# Querrel

Querrel makes it easy to query multiple databases in parallel (threads) using ActiveRecord, as if you were querying one database.

## Installation

Add this line to your application's Gemfile:

    gem 'querrel'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install querrel

## Usage

### Basic

You can use with Querrel directly via it's top level namespace, or by creating an instance:

```ruby
all_brands = Querrel.query(Brand.all, on: ['db1', 'db2', 'db3'])
# is the same as
all_brands = Querrel.new(['db1', 'db2', 'db3']).query(Brand.all)
```

Either of the above will give you an array of all the Brand objects from all the given databases. The records will be marked as readonly.

### Advanced

`query` will yield a block with the passed in `ActiveRecord::Relation`, this allows you to do additional operations on the results before they are merged, for example you could use pluck:

```ruby
all_brand_names = q.query(Brand.all) do |s|
  s.pluck(:name)
end
```

There is also a `run` method which instead of running a preprescribed scope and merging, will take a block which allows you do anything you want with the specified database connection, for instance:

```ruby
require 'thread'
all_brands = []
b_s = Mutex.new
all_products = []
p_s = Mutex.new

Querrel.run(on: dbs) do |db|
  b_s.synchronize { all_brands += Brand.all.to_a }
  p_s.synchronize { all_products += Product.all.to_a }
end
```

### Databases

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

### Configuration

By default Querrel will use a maximum of 20 threads, but you can adjust this using the `:threads` option:

```ruby
q = Querrel.new(dbs, threads: 50)
```

## Contributing

1. Fork it ( https://github.com/meritec/querrel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
