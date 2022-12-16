# BlueStar

BlueStar provides utilities to build requests and parse response for Newebpay (藍新金流).

## Usage

1. Add blue_star to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:blue_star, github: "itswindtw/blue_star"}
  ]
end
```

2. Construct a `BlueStar` struct from your environment.

```elixir
# For example, you have api key configured in your runtime.exs.
config :my_app, BlueStar,
  merchant_id: System.get_env("NEWEBPAY_MERCHANT_ID"),
  hash_key: System.get_env("NEWEBPAY_HASH_KEY"),
  hash_iv: System.get_env("NEWEBPAY_HASH_IV")

# So we can construct `BlueStar` struct like this
config = Application.get_env(:my_app, BlueStar)
blue_star = BlueStar.new(config[:hash_key], config[:hash_iv])
```

3. build a `BlueStar.Request` struct for your request and then use `BlueStar.to_html/2` generate html to render:

```elixir
request =
  BlueStar.Request.new(%{
    "MerchantID" => "MS123456789",
    "MerchantOrderNo" => "Order_123",
    "Amt" => amount,
    "ItemDesc" => "Item description",
    ...
  })

html(conn, BlueStar.to_html(blue_star, request))
```


4. parse callback response with `BlueStar.parse/2`:

```elixir

{:ok, data} = BlueStar.parse(blue_star, response)

data["Status"] # SUCCESS
```