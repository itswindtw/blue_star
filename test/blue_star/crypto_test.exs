defmodule BlueStar.CryptoTest do
  use ExUnit.Case

  alias BlueStar.Crypto

  @key "12345678901234567890123456789012"
  @iv "1234567890123456"

  @data URI.encode_query([
          {"MerchantID", "3430112"},
          {"RespondType", "JSON"},
          {"TimeStamp", "1485232229"},
          {"Version", 1.4},
          {"MerchantOrderNo", "S_1485232229"},
          {"Amt", 40},
          {"ItemDesc", "UnitTest"}
        ])
  @encrypted_data "ff91c8aa01379e4de621a44e5f11f72e4d25bdb1a18242db6cef9ef07d80b0165e476fd1d9acaa53170272c82d122961e1a0700a7427cfa1cf90db7f6d6593bbc93102a4d4b9b66d9974c13c31a7ab4bba1d4e0790f0cbbbd7ad64c6d3c8012a601ceaa808bff70f94a8efa5a4f984b9d41304ffd879612177c622f75f4214fa"
  @encrypted_data_hash "EA0A6CC37F40C1EA5692E7CBB8AE097653DF3E91365E6A9CD7E91312413C7BB8"

  test "encrypt/3" do
    assert Crypto.encrypt(@data, @key, @iv) == @encrypted_data
  end

  test "decrypt/3" do
    assert Crypto.decrypt(@encrypted_data, @key, @iv) == @data
  end

  test "hash/3" do
    assert Crypto.hash(@encrypted_data, @key, @iv) == @encrypted_data_hash
  end
end
