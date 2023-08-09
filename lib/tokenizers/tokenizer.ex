defmodule Tokenizers.Tokenizer do
  @moduledoc """
  Functions to load, apply and train tokenizers.

  The `t:Tokenizers.Tokenizer.t/0` struct represents the tokenization
  pipeline. When you call `Tokenizers.Tokenizer.encode/3`, the input
  text goes through the following steps:

    * normalization
    * pre-tokenization
    * model
    * post-processing

  This pipeline returns a `t:Tokenizers.Encoding.t/0`, which can then
  give you the token ids representing the input text. These token ids
  are usually used as the input for natural language processing (NLP)
  machine learning models.
  """

  defstruct [:resource]

  alias Tokenizers.Model
  alias Tokenizers.Encoding
  alias Tokenizers.PostProcessor
  alias Tokenizers.PreTokenizer
  alias Tokenizers.Normalizer
  alias Tokenizers.Decoder

  @type t :: %__MODULE__{resource: reference()}

  @typedoc """
  An input being a subject to tokenization.

  Can be either a single sequence, or a pair of sequences.
  """
  @type encode_input :: String.t() | {String.t(), String.t()}

  @doc """
  Loads a new tokenizer from a repository on Hugging Face Hub.

  This is going to download a tokenizer file, save it to disk and load
  that file.

  ## Options

    * `:http_client` - a tuple with a module and options. This module
      should implement the `request/1` function, accepting a keyword
      list with the options for a request. This is inspired by
      `Req.request/1`: https://hexdocs.pm/req/Req.html#request/1

      The default HTTP client config is: `{Tokenizers.HTTPClient, []}`.
      Since it's inspired by `Req`, it's possible to use that client
      without any adjustments.

      When making request, the options `:url` and `:method` are going
      to be overridden. `:headers` contains the "user-agent" set by
      default.

    * `:revision` - the revision name that should be used for fetching
      the tokenizers from the Hugging Face repository

    * `:use_cache` - tells if it should read from cache when the file
      already exists. Defaults to `true`

    * `:cache_dir` - the directory where cache is saved. Files are
      written to cache even if `:use_cache` is `false`. By default
      it uses `:filename.basedir/3` to get a cache dir based in the
      "tokenizers_elixir" application name

  """
  @spec from_pretrained(String.t(), Keyword.t()) :: {:ok, t()} | {:error, term()}
  @doc type: :loading
  def from_pretrained(identifier, opts \\ []) do
    opts =
      Keyword.validate!(
        opts,
        [
          :additional_special_tokens,
          revision: "main",
          use_cache: true,
          cache_dir: :filename.basedir(:user_cache, "tokenizers_elixir"),
          http_client: {Tokenizers.HTTPClient, []}
        ]
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

    load_opts = Keyword.take(opts, [:additional_special_tokens])

    if opts[:use_cache] do
      with {:ok, response} <- request(http_client, Keyword.put(http_opts, :method, :head)) do
        etag = fetch_etag(response.headers)
        file_path = file_path_fun.(etag)

        if File.exists?(file_path) do
          from_file(file_path, load_opts)
        else
          with {:ok, response} <- request(http_client, http_opts) do
            File.mkdir_p!(cache_dir)
            File.write!(file_path, response.body)

            from_file(file_path, load_opts)
          end
        end
      end
    else
      with {:ok, response} <- request(http_client, http_opts) do
        etag = fetch_etag(response.headers)
        file_path = file_path_fun.(etag)

        File.mkdir_p!(cache_dir)
        File.write!(file_path, response.body)

        from_file(file_path, load_opts)
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
  @doc type: :loading
  @spec from_file(path :: String.t(), keyword()) :: {:ok, t()} | {:error, term()}
  def from_file(path, opts \\ []) do
    if Keyword.has_key?(opts, :additional_special_tokens) do
      IO.warn(
        "passing :additional_special_tokens as an option is deprecated. Use add_special_tokens/2 instead"
      )
    end

    Tokenizers.Native.tokenizer_from_file(path, opts)
  end

  @doc """
  Instantiate a new tokenizer from the buffer.
  """
  @doc type: :loading
  @spec from_buffer(data :: String.t(), keyword()) :: {:ok, t()} | {:error, term()}
  def from_buffer(data, opts \\ []) do
    if Keyword.has_key?(opts, :additional_special_tokens) do
      IO.warn(
        "passing :additional_special_tokens as an option is deprecated. Use add_special_tokens/2 instead"
      )
    end

    Tokenizers.Native.tokenizer_from_buffer(data, opts)
  end

  @doc """
  Save the tokenizer to the provided path.

  ## Options

    * `:pretty` - whether to pretty print the JSON file. Defaults to `true`

  """
  @doc type: :loading
  @spec save(t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  defdelegate save(tokenizer, path, opts \\ []), to: Tokenizers.Native, as: :tokenizer_save

  @doc """
  Instantiate a new tokenizer from an existing model.
  """
  @doc type: :configuration
  @spec init(Model.t()) :: {:ok, t()} | {:error, any()}
  defdelegate init(model), to: Tokenizers.Native, as: :tokenizer_init

  @doc """
  Returns the model currently used by `tokenizer`.
  """
  @doc type: :configuration
  @spec get_model(t()) :: Model.t()
  defdelegate get_model(tokenizer), to: Tokenizers.Native, as: :tokenizer_get_model

  @doc """
  Sets `tokenizer`'s model.
  """
  @doc type: :configuration
  @spec set_model(t(), Model.t()) :: t()
  defdelegate set_model(tokenizer, model), to: Tokenizers.Native, as: :tokenizer_set_model

  @doc """
  Returns the normalizer currently used by `tokenizer`.
  """
  @doc type: :configuration
  @spec get_normalizer(t()) :: Normalizer.t() | nil
  defdelegate get_normalizer(tokenizer), to: Tokenizers.Native, as: :tokenizer_get_normalizer

  @doc """
  Sets `tokenizer`'s normalizer.
  """
  @doc type: :configuration
  @spec set_normalizer(t(), Normalizer.t()) :: t()
  defdelegate set_normalizer(tokenizer, normalizer),
    to: Tokenizers.Native,
    as: :tokenizer_set_normalizer

  @doc """
  Returns the pre-tokenizer currently used by `tokenizer`.
  """
  @doc type: :configuration
  @spec get_pre_tokenizer(t()) :: PreTokenizer.t() | nil
  defdelegate get_pre_tokenizer(tokenizer),
    to: Tokenizers.Native,
    as: :tokenizer_get_pre_tokenizer

  @doc """
  Sets `tokenizer`'s pre-tokenizer.
  """
  @doc type: :configuration
  @spec set_pre_tokenizer(t(), PreTokenizer.t()) :: t()
  defdelegate set_pre_tokenizer(tokenizer, pre_tokenizer),
    to: Tokenizers.Native,
    as: :tokenizer_set_pre_tokenizer

  @doc """
  Returns the post-processor currently used by `tokenizer`.
  """
  @doc type: :configuration
  @spec get_post_processor(t()) :: PostProcessor.t() | nil
  defdelegate get_post_processor(tokenizer),
    to: Tokenizers.Native,
    as: :tokenizer_get_post_processor

  @doc """
  Sets `tokenizer`'s post-processor.
  """
  @doc type: :configuration
  @spec set_post_processor(t(), PostProcessor.t()) :: t()
  defdelegate set_post_processor(tokenizer, post_processor),
    to: Tokenizers.Native,
    as: :tokenizer_set_post_processor

  @doc """
  Returns the decoder currently used by `tokenizer`.
  """
  @doc type: :configuration
  @spec get_decoder(t()) :: Decoder.t() | nil
  defdelegate get_decoder(tokenizer), to: Tokenizers.Native, as: :tokenizer_get_decoder

  @doc """
  Sets `tokenizer`'s decoder.
  """
  @doc type: :configuration
  @spec set_decoder(t(), Decoder.t()) :: t()
  defdelegate set_decoder(tokenizer, decoder), to: Tokenizers.Native, as: :tokenizer_set_decoder

  @doc """
  Get the tokenizer's vocabulary as a map of token to id.

  ## Options

    * `:with_added_tokens` - whether to include the tokens explicitly
      added to the tokenizer. Defaults to `true`

  """
  @spec get_vocab(t(), keyword()) :: %{String.t() => integer()}
  @doc type: :configuration
  def get_vocab(tokenizer, opts \\ []) do
    opts = Keyword.validate!(opts, with_added_tokens: true)
    Tokenizers.Native.tokenizer_get_vocab(tokenizer, opts[:with_added_tokens])
  end

  @doc """
  Get the number of tokens in the vocabulary.

  ## Options

    * `:with_added_tokens` - whether to include the tokens explicitly
      added to the tokenizer. Defaults to `true`

  """
  @spec get_vocab_size(t(), keyword()) :: non_neg_integer()
  @doc type: :configuration
  def get_vocab_size(tokenizer, opts \\ []) do
    opts = Keyword.validate!(opts, with_added_tokens: true)
    Tokenizers.Native.tokenizer_get_vocab_size(tokenizer, opts[:with_added_tokens])
  end

  @doc """
  Adds tokens to `tokenizer`'s vocabulary.

  These tokens **are not special**. To add special tokens use
  `add_special_tokens/2`.
  """
  @doc type: :configuration
  @spec add_tokens(tokenizer :: t(), tokens :: [String.t()]) :: non_neg_integer()
  defdelegate add_tokens(tokenizer, tokens),
    to: Tokenizers.Native,
    as: :tokenizer_add_tokens

  @doc """
  Adds special tokens to `tokenizer`'s vocabulary.

  These tokens **are special**. To add regular tokens use `add_tokens/2`.
  """
  @doc type: :configuration
  @spec add_special_tokens(tokenizer :: t(), tokens :: [String.t()]) :: non_neg_integer()
  defdelegate add_special_tokens(tokenizer, tokens),
    to: Tokenizers.Native,
    as: :tokenizer_add_special_tokens

  @doc """
  Configures `tokenizer` with truncation.

  To disable truncation use `disable_truncation/1`.

  ## Options

    * `:max_length` (default: `512`) - the maximum length to truncate
      the model's input to

    * `:stride` (default: `0`) - the stride to use when overflowing
      the model's input

    * `:strategy` (default: `:longest_first`) - the strategy to use
      when overflowing the model's input

    * `:direction` (default: `:right`) - the direction to use when
      overflowing the model's input

  """
  @doc type: :configuration
  @spec set_truncation(t(), opts) :: t()
        when opts: [
               max_length: non_neg_integer(),
               stride: non_neg_integer(),
               strategy: :longest_first | :only_first | :only_second,
               direction: :left | :right
             ]
  defdelegate set_truncation(tokenizer, opts \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_set_truncation

  @doc """
  Disable truncation on `tokenizer`.
  """
  @doc type: :configuration
  @spec disable_truncation(t()) :: t()
  defdelegate disable_truncation(tokenizer),
    to: Tokenizers.Native,
    as: :tokenizer_disable_truncation

  @doc """
  Configures `tokenizer` with padding.

  To disable padding use `disable_padding/1`.

  ## Options

    * `:strategy` (default: `:batch_longest`) - the strategy to use
      when padding

    * `:direction` (default: `:right`) - the direction to use when
      padding

    * `:pad_to_multiple_of` (default: `0`) - the multiple to pad to

    * `:pad_id` (default: `0`) - the id of the token to use for padding

    * `:pad_type_id` (default: `0`) - the id of the token type to use
      for padding

    * `:pad_token` (default: `"[PAD]"`) - the token to use for padding

  """
  @doc type: :configuration
  @spec set_padding(tokenizer :: t(), opts) :: t()
        when opts: [
               strategy: :batch_longest | {:fixed, non_neg_integer()},
               direction: :left | :right,
               pad_to_multiple_of: non_neg_integer(),
               pad_id: non_neg_integer(),
               pad_type_id: non_neg_integer(),
               pad_token: String.t()
             ]
  defdelegate set_padding(tokenizer, opts),
    to: Tokenizers.Native,
    as: :tokenizer_set_padding

  @doc """
  Disable padding on `tokenizer`.
  """
  @doc type: :configuration
  @spec disable_padding(tokenizer :: t()) :: t()
  defdelegate disable_padding(tokenizer),
    to: Tokenizers.Native,
    as: :tokenizer_disable_padding

  @doc """
  Encode the given sequence to a `Tokenizers.Encoding.t()`.

  ## Options

    * `:add_special_tokens` - whether to add special tokens to the
      sequence. Defaults to `true`

    * `:encoding_transformations` - a list of `t:Tokenizers.Encoding.Transformation.t/0`
      to apply to the encoding. Check `Tokenizers.Encoding.transform/2`
      for more information. Defaults to `[]`

  """
  @doc type: :inference
  @spec encode(t(), encode_input(), keyword()) :: {:ok, Encoding.t()} | {:error, term()}
  defdelegate encode(tokenizer, input, opts \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_encode

  @doc """
  Batched version of `encode/3`.
  """
  @doc type: :inference
  @spec encode_batch(t(), [encode_input()], keyword()) :: {:ok, [Encoding.t()]} | {:error, term()}
  defdelegate encode_batch(tokenizer, input, opts \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_encode_batch

  @doc """
  Decodes the given list of ids back to a string.

  ## Options

    * `:skip_special_tokens` - whether to exclude special tokens from
      the decoded string. Defaults to `true`

  """
  @doc type: :inference
  @spec decode(t(), [non_neg_integer()], keyword()) :: {:ok, String.t()} | {:error, term()}
  defdelegate decode(tokenizer, ids, opts \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_decode

  @doc """
  Batched version of `decode/3`.
  """
  @doc type: :inference
  @spec decode_batch(t(), [[non_neg_integer()]], keyword()) ::
          {:ok, [String.t()]} | {:error, term()}
  defdelegate decode_batch(tokenizer, sentences, opts \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_decode_batch

  @doc """
  Convert a given id to its token.
  """
  @doc type: :inference
  @spec id_to_token(t(), integer()) :: String.t() | nil
  defdelegate id_to_token(tokenizer, id),
    to: Tokenizers.Native,
    as: :tokenizer_id_to_token

  @doc """
  Convert a given token to its id.
  """
  @doc type: :inference
  @spec token_to_id(t(), String.t()) :: non_neg_integer() | nil
  defdelegate token_to_id(tokenizer, token),
    to: Tokenizers.Native,
    as: :tokenizer_token_to_id

  @doc """
  Train the tokenizer on the given files.

  ## Options

    * `:trainer` - the trainer to use. Defaults to the default trainer
      corresponding to `tokenizers`'s model

  """
  @doc type: :training
  @spec train_from_files(t(), [String.t()], keyword()) :: {:ok, t()} | {:error, term()}
  def train_from_files(tokenizer, paths, opts \\ []) do
    opts = Keyword.validate!(opts, trainer: nil)
    Tokenizers.Native.tokenizer_train_from_files(tokenizer, paths, opts[:trainer])
  end
end

defimpl Inspect, for: Tokenizers.Tokenizer do
  import Inspect.Algebra

  @spec inspect(Tokenizers.Tokenizer.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(tokenizer, opts) do
    model_details =
      tokenizer
      |> Tokenizers.Tokenizer.get_model()
      |> Tokenizers.Model.info()
      |> Keyword.new(fn {k, v} -> {String.to_atom(k), v} end)

    attrs =
      Keyword.merge(
        [
          vocab_size: Tokenizers.Tokenizer.get_vocab_size(tokenizer)
        ],
        model_details
      )

    concat(["#Tokenizers.Tokenizer<", to_doc(attrs, opts), ">"])
  end
end
