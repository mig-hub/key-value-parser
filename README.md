Key Value Parser
================

The primary purpose of `KeyValueParser` is to have a
simple class to be able to parse command line arguments
which are all formated as `key=value`.

For example you could call a script like this:

```
$ ruby my-script.rb port=3000 host=localhost user=bob
```

Then in your script you would do:

```ruby
# my-script.rb

require 'key_value_parser'

options = KeyValueParser.new.parse(ARGV)
options[:port] == 3000
options[:host] == 'localhost'
options[:user] == 'bob'
```

Since `KeyValueParser` is quite opinionated, it is absolutely
not a replacement for `OptionParser` which aim is to be able to
parse Unix style arguments.

Also `KeyValueParser` is not limited to command line arguments.
It can potentially parse any array which is a list of Key/Value
strings. For example you can parse a list of HTTP header lines.

The following sections are list of features in order to understand
what `KeyValueParser` can and cannot do.

Default Values
--------------

When you create the parser instance, you can pass a `Hash` with
default values.

```ruby
# $ ruby my-script.rb host=www.domain.com
parser = KeyValueParser.new host: 'localhost', port: 3000
options = parser.parse(ARGV)
options[:port] == 3000
options[:host] == 'www.domain.com'
```

Typecasted Values
-----------------

As you may have noticed in previous examples, values are
typecasted. So far it does typecast integers, floats and booleans.
Also if you don't give a value, the parser will interpret
it as a flag and set it to `true`.

```ruby
# $ ruby myscript.rb port=3000 broadcast=false running
options = KeyValueParser.new.parse(ARGV)
options[:port] == 3000
options[:broadcast] == false
options[:running] == true
```

If you don't want to cast values, you can use the second argument of
`KeyValueParse#parse` which is a list of options. Just set 
`typecast_values` to `false`.

```ruby
parser = KeyValueParser.new({}, {typecast_values: false})
```

Typecasting is still very basic and will most likely evolve,
but it will move in this direction.

Normalized Keys
---------------

Keys of the resulting `Hash` are normalized. Dash in the middle
of words are replaced by underscores. Double dash in front of a 
word are also removed. It allows you to have unix style double dash 
arguments.

```ruby
# $ ruby my-script.rb --user-name="bob mould"
options = KeyValueParser.new.parse(ARGV)
options[:user_name] == 'bob'
```

Because of the way command line arguments are created for `ARGV`
you can even surround an argument with quotes in order to have
spaces in the argument's value.

There is nothing yet for unix style single dash arguments.
I could remove the dash and treat it like a single letter key,
but the true purpose of single letter arguments is to be an 
alternative to a longer argument name. If you have a simple idea
to implement this without too much hassle, please send me a pull
request.

If you don't want the keys to be normalized, there is an option
for this.

```ruby
# $ ruby my-script.rb --user-name=bob
parser = KeyValueParser.new({}, {normalize_keys: false})
options = parser.parse(ARGV)
options['--user-name'] == 'bob'
```

Array Arguments
---------------

You can have array values if you chain more than one `=<value>` 
after the key. And the values are still typecasted unless you
disable it.

```ruby
# $ ruby my-script.rb heroes=batman=robin ids=1=2
options = KeyValueParser.new.parse(ARGV)
options[:heroes] == ['batman', 'robin']
options[:ids] == [1, 2]
```

You can also disable this option:

```ruby
# $ ruby my-script.rb heroes=batman=robin
parser = KeyValueParser.new({}, {array_values: false})
options = parser.parse(ARGV)
options[:heroes] == 'batman=robin'
```

Please note that so far this is the only way to make an array.
Setting multiple times the same value would just result 
in the key being set to the last value.

```ruby
# $ ruby my-script.rb heroes=batman heroes=robin
options = KeyValueParser.new.parse(ARGV)
options[:heroes] == 'robin'
```

Parsing More Than ARGV 
----------------------

By default, the separator allows you to have an equal sign `=` 
or a colon `:`. And the regexp allows spaces around the separator.
The surrounded spaces are if you want to parse a list of keys/values
from a file for example. Let say you have a file containing a 
key/value per line.

```
user: Bob Mould
number: 42
```

Which looks like a subset of YAML.
Then you can parse the file for settings.

```ruby
parser = KeyValueParser.new
settings = parser.parse File.readlines('settings.conf')
```
Everything works the same, typecasting, normalizing keys, defaults, arrays...
You can also set another separator. Anything which works with
`String#split` will do.

```ruby
# settings.conf:
# author | Kevin Smith
# characters | Jay | Silent Bob

parser = KeyValueParser.new({stars: 5}, {separator: /\s*\|\s*/})
settings = parser.parse File.readlines('settings.conf')
settings[:author] == 'Kevin Smith'
settings[:characters] == ['Jay', 'Silent Bob']
settings[:stars] == 5
```

