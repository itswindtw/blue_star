defmodule BlueStar.Request do
  @required_keys ~w(MerchantID RespondType TimeStamp Version MerchantOrderNo Amt ItemDesc)
  @optional_keys ~w(LangType TradeLimit ExpireDate ReturnURL NotifyURL CustomerURL ClientBackURL Email EmailModify LoginType OrderComment CREDIT ANDROIDPAY SAMSUNGPAY LINEPAY ImageUrl InstFlag CreditRed UNIONPAY WEBATM VACC BankType CVS BARCODE ESUNWALLET TAIWANPAY CVSCOM EZPAY EZPWECHAT EZPALIPAY LgsType)
  @keys @required_keys ++ @optional_keys

  def new(params) do
    data = Map.take(params, @keys)

    defaults = %{
      "RespondType" => "JSON",
      "TimeStamp" => DateTime.to_unix(DateTime.utc_now()),
      "Version" => "2.0"
    }

    Map.merge(defaults, data)
  end
end
