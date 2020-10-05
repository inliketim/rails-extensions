class ToQueryTest < ActiveSupport::TestCase

  def test_hash_with_namespace_option
    hash = { name: "Tim", nationality: "USA" }
    assert_equal "user%5Bname%5D=Tim&user%5Bnationality%5D=USA", hash.to_query(namespace: "user")
  end

  def test_hash_not_sorted_lexicographically_if_option_specified
    hash={type: "human", name: "Tim"}
    assert_equal "type=human&name=Tim", hash.to_query(preserve_order: true)
  end

  def test_hash_sorted_lexicographically_if_option_specified
    hash = { type: "human", name: "Tim" }
    assert_equal "name=Tim&type=human", hash.to_query(preserve_order: false)
  end

  def test_hash_with_all_options_provided
    hash={type: "human", name: "Tim"}
    expected = "earth[type]=human&earth[name]=Tim"
    actual = hash.to_query(preserve_order: true, namespace: "earth")
    assert_equal expected, URI.decode_www_form_component(actual)
  end

end