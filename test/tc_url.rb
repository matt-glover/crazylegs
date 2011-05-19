require 'crazylegs'
require 'test/unit'

include Crazylegs

class TC_testURL < Test::Unit::TestCase

  def setup
    @cred = Credentials.new('dpf43f3p2l4k3l03',
                            'kd94hf93k423kf44',
                            :http,
                            AccessToken.new('nnch734d00sl2jdk','pfkkdhi9sl3r4s00'))
    @signed_url = SignedURL.new(@cred,
                               'http://photos.example.net/photos',
                               'GET')
    class << @signed_url
      def [](param); @params[param]; end
    end
  end

  def NOtest_encode_parts
    url = "/this/is/easy"
    assert_equal url,SignedURL::encode_parts(url)
    url = "this/has some spaces/and stuff"
    assert_equal "this/has%20some%20spaces/and%20stuff",SignedURL::encode_parts(url)

    url = "this/$account/has spaces/$username"
    assert_equal "this/$account/has%20spaces/$username",SignedURL::encode_parts(url)
  end

  def NOtest_bad_param_override
    SignedURL::READ_ONLY_PARAMS.keys.each do |param|
      assert_raises(ArgumentError) do 
        @signed_url[param] = 'asdfasdfasdf'
      end
    end
  end

  def NOtest_simple
    @signed_url['file'] = 'vacation.jpg'
    @signed_url['size'] = 'original'
    do_simple_assert
  end

  def test_simple_bulk_params_set
    params = {
      'file' => 'vacation.jpg',
      'size' => 'original',
    }
    @signed_url.params=params
    do_simple_assert
  end

  def NOtest_assign_param
    @signed_url['blah'] = :foo
    @signed_url['crud'] = 'foo'
    assert_equal('foo',@signed_url['blah'])
    assert_equal('foo',@signed_url['crud'])
  end

  def NOtest_nil_param_assign
    @signed_url['blah'] = 'foo'
    assert_raises(ArgumentError) { @signed_url.params = nil }
  end

  private
  def do_simple_assert
    signature = 'tR3+Ty81lMeYAr/Fid0kMTYa/WM='
    signature_encoded = 'tR3%2BTy81lMeYAr%2FFid0kMTYa%2FWM%3D'
    expected_url_with_query_string = 'http://photos.example.net/photos?file=vacation.jpg&oauth_consumer_key=dpf43f3p2l4k3l03&oauth_nonce=kllo9940pd9333jh&oauth_signature=' + signature_encoded + '&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1191242096&oauth_token=nnch734d00sl2jdk&oauth_version=1.0&size=original'
    assert_equal(expected_url_with_query_string,@signed_url.full_url(1191242096,'kllo9940pd9333jh'))

    expected_url_for_headers = 'http://photos.example.net/photos?file=vacation.jpg&size=original'
    result = @signed_url.full_url_using_headers(1191242096,'kllo9940pd9333jh')
    assert_equal(expected_url_for_headers,result[0])
    expected_headers = {
      'Authorization' => 'OAuth oauth_consumer_key="dpf43f3p2l4k3l03",oauth_nonce="kllo9940pd9333jh",oauth_signature="' + signature + '",oauth_signature_method="HMAC-SHA1",oauth_timestamp="1191242096",oauth_token="nnch734d00sl2jdk",oauth_version="1.0"'
    }
    assert_equal(expected_headers,result[1])
  end

end
