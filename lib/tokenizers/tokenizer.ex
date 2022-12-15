defmodule Tokenizers.Tokenizer do
  @moduledoc """
  The struct and associated functions for a tokenizer.

  A `Tokenizers.Tokenizer.t()` is a container that holds the constituent parts of the tokenization pipeline.

  When you call `Tokenizers.Tokenizer.encode/3`, the input text goes through the following pipeline:

  - normalization
  - pre-tokenization
  - model
  - post-processing

  This returns a `Tokenizers.Encoding.t()`, which can then give you the token ids for each token in the input text. These token ids are usually used as the input for natural language processing machine learning models.
  """

  @type t :: %__MODULE__{resource: binary(), reference: reference()}
  defstruct resource: nil, reference: nil

  alias Tokenizers.Model
  alias Tokenizers.Native
  alias Tokenizers.Shared

  @typedoc """
  An input being a subject to tokenization.

  Can be either a single sequence, or a pair of sequences.
  """
  @type encode_input :: String.t() | {String.t(), String.t()}

  @doc """
  Instantiate a new tokenizer from an existing file on the Hugging Face Hub.

  This is going to download a tokenizer file, save it to disk and load that file.

  ## Options

    * `:http_client` - A tuple with a module and options. This module should implement
      the `request/1` function, accepting a keyword list with the options for a request.
      This is inspired by `Req.request/1`: https://hexdocs.pm/req/Req.html#request/1

      The default HTTP client config is: `{Tokenizers.HTTPClient, []}`.
      Since it's inspired by `Req`, it's possible to use that client without any adjustments.

      When making request, the options `:url` and `:method` are going to be overridden.
      `:headers` contains the "user-agent" set by default.

    * `:revision` - The revision name that should be used for fetching the tokenizers
      from Hugging Face.

    * `:use_cache` - Tells if it should read from cache when the file already exists.
      Defaults to `true`.

    * `:cache_dir` - The directory where cache is saved. Files are written to cache
      even if `:use_cache` is false. By default it uses `:filename.basedir/3` to get
      a cache dir based in the "tokenizers_elixir" application name.

    * `:additional_special_tokens` - A list of special tokens to append to the tokenizer.
      Defaults to `[]`.
  """
  @spec from_pretrained(String.t(), Keyword.t()) :: {:ok, Tokenizer.t()} | {:error, term()}
  def from_pretrained(identifier, opts \\ []) do
    opts =
      Keyword.validate!(opts,
        revision: "main",
        use_cache: true,
        cache_dir: :filename.basedir(:user_cache, "tokenizers_elixir"),
        http_client: {Tokenizers.HTTPClient, []},
        additional_special_tokens: []
      )

    {http_client, http_opts} = opts[:http_client]

    {:ok, app_version} = :application.get_key(:tokenizers, :vsn)
    app_version = List.to_string(app_version)

    headers = [{"user-agent", "tokenizers-elixir/#{app_version}"}]
    url = "/#{identifier}/resolve/#{opts[:revision]}/tokenizer.json"

    http_opts =
      http_opts
      |> Keyword.put_new(:base_url, "https://huggingface.co")
      |> Keyword.put(:url, url)
      |> Keyword.put(:method, :get)
      |> Keyword.update(:headers, headers, fn existing -> existing ++ headers end)

    cache_dir = opts[:cache_dir]

    file_path_fun = fn etag ->
      Path.join(cache_dir, entry_filename(url, etag))
    end

    if opts[:use_cache] do
      with {:ok, response} <- request(http_client, Keyword.put(http_opts, :method, :head)) do
        etag = fetch_etag(response.headers)
        file_path = file_path_fun.(etag)

        if File.exists?(file_path) do
          from_file(file_path, opts[:additional_special_tokens])
        else
          with {:ok, response} <- request(http_client, http_opts) do
            File.mkdir_p!(cache_dir)
            File.write!(file_path, response.body)

            from_file(file_path, opts[:additional_special_tokens])
          end
        end
      end
    else
      with {:ok, response} <- request(http_client, http_opts) do
        etag = fetch_etag(response.headers)
        file_path = file_path_fun.(etag)

        File.mkdir_p!(cache_dir)
        File.write!(file_path, response.body)

        from_file(file_path, opts[:additional_special_tokens])
      end
    end
  end

  defp fetch_etag(headers) do
    {_, etag} = List.keyfind!(headers, "etag", 0)

    etag
  end

  defp request(http_client, http_opts) do
    case http_client.request(http_opts) do
      {:ok, response} ->
        case response.status do
          status when status in 200..299 ->
            {:ok, response}

          404 ->
            {:error, :not_found}

          other ->
            {:error,
             "download of pretrained file failed with status #{other}. Response: #{inspect(response.body)}"}
        end

      {:error, _} = error ->
        error
    end
  end

  defp entry_filename(url, etag) do
    encode_url(url) <> "." <> encode_etag(etag)
  end

  defp encode_url(url) do
    url |> :erlang.md5() |> Base.encode32(case: :lower, padding: false)
  end

  defp encode_etag(etag) do
    Base.encode32(etag, case: :lower, padding: false)
  end

  @doc """
  Instantiate a new tokenizer from the file at the given path.
  """
  @spec from_file(String.t(), List.t()) :: {:ok, Tokenizer.t()} | {:error, term()}
  def from_file(path, additional_special_tokens \\ []), do: Native.from_file(path, additional_special_tokens)

  @doc """
  Save the tokenizer to the provided path.
  """
  @spec save(Tokenizer.t(), String.t()) :: {:ok, String.t()} | {:error, term()}
  def save(tokenizer, path) do
    case Native.save(tokenizer, path, true) do
      {:ok, _} -> {:ok, path}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Encode the given sequence or batch of sequences to a `Tokenizers.Encoding.t()`.

  ## Options

    * `:add_special_tokens` - whether to add special tokens to the encoding. Defaults to `true`.

  """
  @spec encode(Tokenizer.t(), encode_input() | [encode_input()], Keyword.t()) ::
          {:ok, Encoding.t() | [Encoding.t()]} | {:error, term()}
  def encode(tokenizer, input, opts \\ []) do
    add_special_tokens = Keyword.get(opts, :add_special_tokens, true)
    do_encode(tokenizer, input, add_special_tokens)
  end

  defp do_encode(tokenizer, input, add_special_tokens) when is_list(input) do
    Native.encode_batch(tokenizer, input, add_special_tokens)
  end

  defp do_encode(tokenizer, input, add_special_tokens) do
    Native.encode(tokenizer, input, add_special_tokens)
  end

  @doc """
  Decode the given list of ids or list of lists of ids back to strings.

  ## Options

    * `:skip_special_tokens` - whether the special tokens should be removed from the decoded string. Defaults to `true`.
  """
  @spec decode(Tokenizer.t(), non_neg_integer() | [non_neg_integer()], Keyword.t()) ::
          {:ok, String.t() | [String.t()]} | {:error, term()}
  def decode(tokenizer, ids, opts \\ []) do
    skip_special_tokens = Keyword.get(opts, :skip_special_tokens, true)
    do_decode(tokenizer, ids, skip_special_tokens)
  end

  defp do_decode(tokenizer, [first | _] = ids, skip_special_tokens) when is_integer(first),
    do: Native.decode(tokenizer, ids, skip_special_tokens)

  defp do_decode(tokenizer, [first | _] = ids, skip_special_tokens) when is_list(first),
    do: Native.decode_batch(tokenizer, ids, skip_special_tokens)

  @doc """
  Get the tokenizer's vocabulary as a map of token to id.
  """
  @spec get_vocab(Tokenizer.t()) :: %{binary() => integer()}
  def get_vocab(tokenizer), do: tokenizer |> Native.get_vocab(false) |> Shared.unwrap()

  @doc """
  Get the number of tokens in the vocabulary.
  """
  @spec get_vocab_size(Tokenizer.t()) :: non_neg_integer()
  def get_vocab_size(tokenizer), do: tokenizer |> Native.get_vocab_size(true) |> Shared.unwrap()

  @doc """
  Convert a given id to its token.
  """
  @spec id_to_token(Tokenizer.t(), integer()) :: String.t()
  def id_to_token(tokenizer, id), do: tokenizer |> Native.id_to_token(id) |> Shared.unwrap()

  @doc """
  Convert a given token to its id.
  """
  @spec token_to_id(Tokenizer.t(), binary()) :: non_neg_integer()
  def token_to_id(tokenizer, token), do: tokenizer |> Native.token_to_id(token) |> Shared.unwrap()

  @doc """
  Get the `Tokenizer`'s `Model`.
  """
  @spec get_model(Tokenizer.t()) :: Model.t()
  def get_model(tokenizer), do: tokenizer |> Native.get_model() |> Shared.unwrap()
end

defimpl Inspect, for: Tokenizers.Tokenizer do
  import Inspect.Algebra

  alias Tokenizers.Model
  alias Tokenizers.Tokenizer

  def inspect(tokenizer, opts) do
    model_details =
      tokenizer
      |> Tokenizer.get_model()
      |> Model.get_model_details()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    attrs =
      Keyword.merge(
        [
          vocab_size: Tokenizer.get_vocab_size(tokenizer)
        ],
        model_details
      )

    concat(["#Tokenizers.Tokenizer<", to_doc(attrs, opts), ">"])
  end
end
