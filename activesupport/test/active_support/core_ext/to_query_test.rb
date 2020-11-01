class ToQueryTest < ActiveSupport::TestCase

  def test_hash_with_namespace_option
    hash = { name: "Nakshay", nationality: "Indian" }
    assert_equal "user%5Bname%5D=Nakshay&user%5Bnationality%5D=Indian", hash.to_query(namespace: "user")
  end

  def test_hash_not_sorted_lexicographically_for_nested_structure
    params = {
      "foo" => {
        "contents" => [
          { "name" => "gorby", "id" => "123" },
          { "name" => "puff", "d" => "true" }
        ]
      }
    }
    expected = "foo[contents][][name]=gorby&foo[contents][][id]=123&foo[contents][][name]=puff&foo[contents][][d]=true"
    assert_equal expected, URI.decode_www_form_component(params.to_query)
  end

  def test_hash_not_sorted_lexicographically_if_option_specified
    hash = { type: "human", name: "Nakshay" }
    assert_equal "type=human&name=Nakshay", hash.to_query(preserve_order: true)
  end

  def test_hash_sorted_lexicographically_if_option_specified
    hash = { type: "human", name: "Nakshay" }
    assert_equal "name=Nakshay&type=human", hash.to_query(preserve_order: false)
  end

  def test_hash_with_namespace_and_preserve_order_options_provided
    hash = { type: "human", name: "Nakshay" }
    expected = "earth[type]=human&earth[name]=Nakshay"
    actual = hash.to_query(preserve_order: true, namespace: "earth")
    assert_equal expected, URI.decode_www_form_component(actual)
  end

  def test_hash_as_a_namespace
    hash = { type: "human", name: "Nakshay" }
    hash_namespace = { weird_namespace: "yes" }
    actual = hash.to_query(hash_namespace)
    expected = '{:weird_namespace=>"yes"}[name]=Nakshay&{:weird_namespace=>"yes"}[type]=human'
    assert_equal expected, CGI.unescape(actual)
  end

  def test_hash_with_hash_key
    hash_as_key = { weird_key: "yes" }
    main_hash = { hash_as_key => "myvalue" }
    actual = main_hash.to_query()
    expected = "weird_key%3Dyes=myvalue"
    assert_equal expected, actual
  end

end