defmodule BlueStarTest do
  use ExUnit.Case

  @merchant_id "MS14612657"
  @hash_key "ni87APTA0GoSYAZkfdCbkBwnb7wAdMR3"
  @hash_iv "UhKpzRHYILdDAKVm"

  @blue_star BlueStar.new(@hash_key, @hash_iv)

  test "to_html/2" do
    merchant_order_no = "201406010001"
    amount = 1000
    description = "Good item!"

    request =
      BlueStar.Request.new(%{
        "MerchantID" => @merchant_id,
        "MerchantOrderNo" => merchant_order_no,
        "Amt" => amount,
        "ItemDesc" => description
      })

    html = BlueStar.to_html(@blue_star, request)

    document = Floki.parse_document!(html)
    form = Floki.find(document, ~s(form[name="newebpay"]))
    assert form != []
    assert Floki.find(form, ~s(input[name="MerchantID"][value="#{@merchant_id}"])) != []
    assert Floki.find(form, ~s(input[name="Version"][value="2.0"])) != []
    assert Floki.find(form, ~s(input[name="TradeInfo"])) != []
    assert Floki.find(form, ~s(input[name="TradeSha"])) != []

    trade_info =
      Floki.find(form, ~s(input[name="TradeInfo"]))
      |> Floki.attribute("value")
      |> List.first("")

    trade_sha =
      Floki.find(form, ~s(input[name="TradeSha"]))
      |> Floki.attribute("value")
      |> List.first("")

    assert trade_sha == BlueStar.Crypto.hash(trade_info, @hash_key, @hash_iv)

    request_data =
      BlueStar.Crypto.decrypt(trade_info, @hash_key, @hash_iv)
      |> URI.decode_query()

    assert request_data["Version"] == "2.0"
    assert request_data["RespondType"] == "JSON"
    assert request_data["TimeStamp"]

    assert request_data["MerchantID"] == @merchant_id
    assert request_data["MerchantOrderNo"] == merchant_order_no
    assert request_data["Amt"] == to_string(amount)
    assert request_data["ItemDesc"] == description
  end

  test "parse/2" do
    response = %{
      "Status" => "SUCCESS",
      "MerchantID" => @merchant_id,
      "TradeInfo" =>
        "587ddee832de01ebe1eea7fb85582b5022cf32ea77586e05e88554e18251b9fd518de4ca197702a50f39c3f398bab0d784a214d3aca8a6af6211ab5257ec711cf8022251bece63bf40f4e5268b31cc769861a8875ec5333ccf040ea693e0533ee8af71c8fbf68c22088bd102fcb03734b55903332563504e4c6197ac89a4230b3ff455ed9ba6c071721678f832f6b00073c871a95ba4fde5eaa3f1c1c46e469250df0d433f5f4a3fd2b598124fe5909420d9221054bb63304c9d55b4908d1acd75945a56b73ea71973441ae38ff30ed09af1c922fec6d0902e28d8745291d13a997ed383caaf0682d298e1f0d2ca12988187f300e044e828c033fc4e1ef6e313df0f45f6eababafa0e05afeef278c92beb39e569dc339109a778f68a9cb6c0092c1a8b1b25af4cad5a6172a87ba6e9ce87f02b52991aa578108cb79f8a199a1b72caf7bf6d4a140c3b3067de99292a05c9d02574fc1b86876711f9125c930422f3eb326d474e0bb4c7e4bf4d00385f6b94bae75e45ea5d74ba13bf5efec7039610396b3def96d38aa964931b6fa18e47bf0247719caef6edf4951f30832aa542cf399b79ffa25cc1bea78da6af327e5bc172583cf969fe42e0d29e346d959037",
      "TradeSha" => "F6F822E16FA563DEC8A98677C3611D2C72CFAC07EA5CE7D392C5F6D8A07EF376",
      "Version" => 2.0
    }

    {:ok, data} = BlueStar.parse(@blue_star, response)

    result = Map.fetch!(data, "Result")

    assert result["MerchantID"] == @merchant_id
    assert result["Amt"] == 123
    assert result["TradeNo"] == "12345678901234567890"
    assert result["MerchantOrderNo"] == "Order_12345"
    assert result["PaymentType"] == "CREDIT"
    assert result["RespondType"] == "JSON"
    assert result["PayTime"] == "2012-12-12 12:12:12"
    assert result["IP"] == "127.0.0.1"
  end
end
