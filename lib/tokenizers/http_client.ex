defmodule Tokenizers.HTTPClient do
  @moduledoc """
  A simple implementation of an HTTP client.

  This is using the built-in `:httpc` module, configured to use SSL.
  The `request/1` function is similar to `Req.request/1`.
  """

  @base_url "https://huggingface.io"

  @doc """
  Make an HTTP(s) requests.


  ## Options

    * `:method` - An HTTP method. By default it uses the `:get` method.

    * `:base_url` - The base URL to make requests. By default is #{inspect(@base_url)}. 

    * `:url` - A path to a resource. By default is "".

    * `:headers` - A list of tuples representing HTTP headers. By default it's empty.
  """
  def request(opts) when is_list(opts) do
    opts = Keyword.validate!(opts, base_url: @base_url, headers: [], method: :get, url: "")

    url = Path.join([opts[:base_url], opts[:url]]) |> String.to_charlist()
    headers = Enum.map(opts[:headers], fn {key, value} -> {String.to_charlist(key), value} end)

    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)

    if proxy = System.get_env("HTTP_PROXY") || System.get_env("http_proxy") do
      %{host: host, port: port} = URI.parse(proxy)

      :httpc.set_options([{:proxy, {{String.to_charlist(host), port}, []}}])
    end

    proxy = System.get_env("HTTPS_PROXY") || System.get_env("https_proxy")

    with true <- is_binary(proxy),
         %{host: host, port: port} when is_binary(host) and is_integer(port) <- URI.parse(proxy) do
      :httpc.set_options([{:https_proxy, {{String.to_charlist(host), port}, []}}])
    end

    # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/inets
    cacertfile = CAStore.file_path() |> String.to_charlist()

    http_options = [
      ssl: [
        verify: :verify_peer,
        cacertfile: cacertfile,
        depth: 3,
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]

    options = [body_format: :binary]

    case :httpc.request(opts[:method], {url, headers}, http_options, options) do
      {:ok, {{_, status, _}, headers, body}} ->
        {:ok, %{status: status, headers: headers, body: body}}

      {:ok, {status, body}} ->
        {:ok, %{status: status, body: body, headers: []}}

      {:error, reason} ->
        {:error, "could not make request #{url}: #{inspect(reason)}"}
    end
  end
end
