defmodule BlueStar.Crypto do
  def encrypt(data, key, iv) do
    :crypto.crypto_one_time(:aes_256_cbc, key, iv, pad(data), true)
    |> Base.encode16(case: :lower)
  end

  def decrypt(data, key, iv) do
    with {:ok, decoded} <- Base.decode16(data, case: :lower) do
      :crypto.crypto_one_time(:aes_256_cbc, key, iv, decoded, false)
      |> unpad()
    end
  end

  def hash(data, key, iv) do
    :crypto.hash(:sha256, "HashKey=#{key}&#{data}&HashIV=#{iv}")
    |> Base.encode16(case: :upper)
  end

  def pad(data, block_size \\ 32) do
    to_pad = block_size - rem(byte_size(data), block_size)
    data <> :binary.copy(<<to_pad>>, to_pad)
  end

  def unpad(data) do
    to_unpad = :binary.last(data)
    :binary.part(data, {0, byte_size(data) - to_unpad})
  end
end
