defmodule BlueStar do
  defstruct [:key, :iv, :test_mode]

  def new(key, iv, test_mode \\ false) do
    %__MODULE__{
      key: key,
      iv: iv,
      test_mode: test_mode
    }
  end

  def to_html(%__MODULE__{} = t, request) do
    action =
      if t.test_mode,
        do: "https://ccore.newebpay.com/MPG/mpg_gateway",
        else: "https://core.newebpay.com/MPG/mpg_gateway"

    trade_info =
      request
      |> Map.filter(fn {_k, v} -> v end)
      |> URI.encode_query()
      |> BlueStar.Crypto.encrypt(t.key, t.iv)

    trade_sha = BlueStar.Crypto.hash(trade_info, t.key, t.iv)

    """
    <form name="newebpay" method="post" action="#{action}">
      <input type="hidden" name="MerchantID" value="#{request["MerchantID"]}" />
      <input type="hidden" name="TradeInfo" value="#{trade_info}" />
      <input type="hidden" name="TradeSha" value="#{trade_sha}" />
      <input type="hidden" name="Version" value="2.0" />
      <input type="submit" value="導向至藍新金流中..." />
    </form>
    <script>document.forms.newebpay.submit()</script>
    """
  end

  def parse(%__MODULE__{} = t, response) do
    trade_info = response["TradeInfo"]
    trade_sha = response["TradeSha"]

    if trade_info && trade_sha && BlueStar.Crypto.hash(trade_info, t.key, t.iv) == trade_sha do
      trade_info
      |> BlueStar.Crypto.decrypt(t.key, t.iv)
      |> Jason.decode()
    else
      {:error, :bad_response}
    end
  end
end
