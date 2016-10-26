require 'minitest/autorun'
require 'key_value_parser'

class TestKeyValueParser < Minitest::Test

  def setup
    @parser = KeyValueParser.new
  end

  def test_parses_kvs
    kvs = ['user:mig', 'machine:coconut']
    expected = {user: 'mig', machine: 'coconut'}
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_equal_works_as_separator
    kvs = ['user=mig', 'machine=coconut']
    expected = {user: 'mig', machine: 'coconut'}
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_spaces_work_in_separator
    kvs = ['user=  mig', 'machine = coconut']
    expected = {user: 'mig', machine: 'coconut'}
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_booleans_are_typecasted
    kvs = ['dead:false', 'running:true']
    expected = {dead: false, running: true}
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_integers_are_typecasted
    kvs = ['machine:1coconut', 'size:11', 'negative:-5']
    expected = {machine: '1coconut', size: 11, negative: -5}
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_floats_are_typecasted
    kvs = [
      'machine:5.0coconut', 
      'float1:99.99', 'float2:-5.0', 'float3:.4'
    ]
    expected = {
      machine: '5.0coconut', 
      float1: 99.99, float2: -5.0, float3: 0.4
    }
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_nil_value_typecasted_to_true
    kvs = ['running']
    expected = {running: true}
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_parser_can_have_defaults
    kvs = ['user:mig']
    expected = {user: 'mig', role: 'dev'}
    parser = KeyValueParser.new user: 'marty', role: 'dev'
    assert_equal expected, parser.parse(kvs) 
  end

  def test_separator_can_be_changed
    kvs = ['user|mig', 'machine|coconut']
    expected = {user: 'mig', machine: 'coconut'}
    wrong_parser = KeyValueParser.new
    refute_equal expected, wrong_parser.parse(kvs) 
    parser = KeyValueParser.new({}, separator: '|')
    assert_equal expected, parser.parse(kvs) 
  end

  def test_keys_are_normalized
    kvs = ['user-name=mig', 'machine_name=coconut', 'why not=yes']
    expected = {user_name: 'mig', machine_name: 'coconut', why_not: 'yes'}
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_unix_double_dash_keys_are_normalized
    kvs = ['--user-name=mig', '--running']
    expected = {user_name: 'mig', running: true}
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_value_is_updated_if_key_is_referenced_multiple_times
    kvs = ['user:bad', 'user:mig']
    expected = {user: 'mig'}
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_arrays
    kvs = ['users:mig:why', 'numbers:3:5', 'request:false:POST:500']
    expected = {
      users: ['mig', 'why'], 
      numbers: [3,5], 
      request: [false, 'POST', 500]
    }
    assert_equal expected, @parser.parse(kvs) 
  end

  def test_normalize_key_can_be_skipped
    kvs = ['--user-name=mig', '--running']
    expected = {'--user-name' => 'mig', '--running' => true}
    parser = KeyValueParser.new({}, {normalize_keys: false})
    assert_equal expected, parser.parse(kvs) 
  end

  def test_typecast_can_be_skipped
    kvs = ['user:mig', 'size:5', 'crazy:false:maybe', 'dev']
    expected = {user: 'mig', size: '5', crazy: ['false','maybe'], dev: nil}
    parser = KeyValueParser.new({}, {typecast_values: false})
    assert_equal expected, parser.parse(kvs) 
  end

  def test_arrays_can_be_avoided
    kvs = ['users:mig=why', 'size:5:6', 'running']
    expected = {users: 'mig=why', size: '5:6', running: true}
    parser = KeyValueParser.new({}, {array_values: false})
    assert_equal expected, parser.parse(kvs) 
  end

end

