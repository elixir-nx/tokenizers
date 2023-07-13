defmodule Tokenizers.Tokenizer do
  @moduledoc """
  The struct and associated functions for a tokenizer.

  A `Tokenizers.t()` is a container that holds the constituent parts of the tokenization pipeline.

  When you call `Tokenizers.Tokenizer.encode/3`, the input text goes through the following pipeline:

  - normalization
  - pre-tokenization
  - model
  - post-processing

  This returns a `Tokenizers.Encoding.t()`, which can then give you the token ids for each token in the input text.
  These token ids are usually used as the input for natural language processing machine learning models.
  """

  @type t :: %__MODULE__{resource: reference()}
  defstruct [:resource]

  alias Tokenizers.Model
  alias Tokenizers.Encoding
  alias Tokenizers.PostProcessor
  alias Tokenizers.PreTokenizer
  alias Tokenizers.Normalizer
  alias Tokenizers.Decoder

  @typedoc """
  An input being a subject to tokenization.

  Can be either a single sequence, or a pair of sequences.
  """
  @type encode_input :: String.t() | {String.t(), String.t()}

  @doc """
  Instantiate a new tokenizer from an existing models.
  """
  @spec init(model :: Model.t()) :: {:ok, t()} | {:error, any()}
  defdelegate init(model), to: Tokenizers.Native, as: :tokenizer_init

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
  @spec from_pretrained(String.t(), Keyword.t()) :: {:ok, t()} | {:error, term()}
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
          from_file(file_path, Keyword.take(opts, [:additional_special_tokens]))
        else
          with {:ok, response} <- request(http_client, http_opts) do
            File.mkdir_p!(cache_dir)
            File.write!(file_path, response.body)

            from_file(file_path, Keyword.take(opts, [:additional_special_tokens]))
          end
        end
      end
    else
      with {:ok, response} <- request(http_client, http_opts) do
        etag = fetch_etag(response.headers)
        file_path = file_path_fun.(etag)

        File.mkdir_p!(cache_dir)
        File.write!(file_path, response.body)

        from_file(file_path, Keyword.take(opts, [:additional_special_tokens]))
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
  You can specify a list of special tokens to append to the tokenizer.
  """
  @spec from_file(
          path :: String.t(),
          options :: [additional_special_tokens :: [String.t() | Tokenizers.AddedToken.t()]]
        ) ::
          {:ok, t()} | {:error, term()}
  defdelegate from_file(path, options \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_from_file

  @doc """
  Instantiate a new tokenizer from the buffer.
  You can specify a list of special tokens to append to the tokenizer.
  """
  @spec from_buffer(
          data :: String.t(),
          options :: [additional_special_tokens :: [String.t() | Tokenizers.AddedToken.t()]]
        ) ::
          {:ok, t()} | {:error, term()}
  defdelegate from_buffer(data, options \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_from_buffer

  @doc """
  Save the tokenizer to the provided path. Options:

  * `:pretty` - Whether to pretty print the JSON file. Defaults to `true`.
  """
  @spec save(t(), pretty: boolean()) :: {:ok, String.t()} | {:error, term()}
  defdelegate save(tokenizer, path, options \\ []), to: Tokenizers.Native, as: :tokenizer_save

  ##############################################################################
  # Setup
  ##############################################################################

  @doc """
  Get the `Tokenizer`'s `Model`.
  """
  @spec get_model(t()) :: Model.t()
  defdelegate get_model(tokenizer), to: Tokenizers.Native, as: :tokenizer_get_model

  @doc """
  Set the `Tokenizer`'s `Model`.
  """
  @spec set_model(t(), Model.t()) :: t()
  defdelegate set_model(tokenizer, model), to: Tokenizers.Native, as: :tokenizer_set_model

  @doc """
  Get the `Tokenizer`'s `Normalizer`.
  """
  @spec get_normalizer(t()) :: Normalizer.t() | nil
  defdelegate get_normalizer(tokenizer), to: Tokenizers.Native, as: :tokenizer_get_normalizer

  @doc """
  Set the `Tokenizer`'s `Normalizer`.
  """
  @spec set_normalizer(t(), Normalizer.t()) :: t()
  defdelegate set_normalizer(tokenizer, normalizer),
    to: Tokenizers.Native,
    as: :tokenizer_set_normalizer

  @doc """
  Get the `Tokenizer`'s `PreTokenizer`.
  """
  alias Tokenizers.PreTokenizer
  @spec get_pre_tokenizer(t()) :: PreTokenizer.t() | nil
  defdelegate get_pre_tokenizer(tokenizer),
    to: Tokenizers.Native,
    as: :tokenizer_get_pre_tokenizer

  @doc """
  Set the `Tokenizer`'s `PreTokenizer`.
  """
  @spec set_pre_tokenizer(t(), PreTokenizer.t()) :: t()
  defdelegate set_pre_tokenizer(tokenizer, pre_tokenizer),
    to: Tokenizers.Native,
    as: :tokenizer_set_pre_tokenizer

  @doc """
  Get the `Tokenizer`'s `PostProcessor`.
  """
  @spec get_post_processor(t()) :: PostProcessor.t() | nil
  defdelegate get_post_processor(tokenizer),
    to: Tokenizers.Native,
    as: :tokenizer_get_post_processor

  @doc """
  Set the `Tokenizer`'s `PostProcessor`.
  """
  @spec set_post_processor(t(), PostProcessor.t()) :: t()
  defdelegate set_post_processor(tokenizer, post_processor),
    to: Tokenizers.Native,
    as: :tokenizer_set_post_processor

  @doc """
  Get the `Tokenizer`'s `Decoder`.
  """
  @spec get_decoder(t()) :: Decoder.t() | nil
  defdelegate get_decoder(tokenizer), to: Tokenizers.Native, as: :tokenizer_get_decoder

  @doc """
  Set the `Tokenizer`'s `Decoder`.
  """
  @spec set_decoder(t(), Decoder.t()) :: t()
  defdelegate set_decoder(tokenizer, decoder), to: Tokenizers.Native, as: :tokenizer_set_decoder

  @doc """
  Get the tokenizer's vocabulary as a map of token to id.
  """
  @spec get_vocab(tokenizer :: t(), with_additional_tokens :: boolean()) :: %{
          String.t() => integer()
        }
  defdelegate get_vocab(tokenizer, with_additional_tokens \\ true),
    to: Tokenizers.Native,
    as: :tokenizer_get_vocab

  @doc """
  Get the number of tokens in the vocabulary.
  """
  @spec get_vocab_size(tokenizer :: t(), with_additional_tokens :: boolean()) ::
          non_neg_integer()
  defdelegate get_vocab_size(tokenizer, with_additional_tokens \\ true),
    to: Tokenizers.Native,
    as: :tokenizer_get_vocab_size

  @doc """
  Adds tokens to the vocabulary.
  These tokens **are not special**. To add special tokens - use `add_special_tokens/2`.
  """
  @spec add_tokens(tokenizer :: t(), tokens :: [String.t()]) :: non_neg_integer()
  defdelegate add_tokens(tokenizer, tokens),
    to: Tokenizers.Native,
    as: :tokenizer_add_tokens

  @doc """
  Adds special tokens to the vocabulary.
  These tokens **are special**. To add regular tokens - use `add_tokens/2`.
  """
  @spec add_special_tokens(tokenizer :: t(), tokens :: [String.t()]) :: non_neg_integer()
  defdelegate add_special_tokens(tokenizer, tokens),
    to: Tokenizers.Native,
    as: :tokenizer_add_special_tokens

  @typedoc """
  Truncation options. All options can be ommited.

  * `:max_length` (default: `512`) - the maximum length to truncate the model's input to.
  * `:stride` (default: `0`) - the stride to use when overflowing the model's input.
  * `:strategy` (default: `:longest_first) - the strategy to use when overflowing the model's input.
  * `:direction` (default: `:right`) - the direction to use when overflowing the model's input.
  """
  @type truncation_options() :: [
          max_length: non_neg_integer(),
          stride: non_neg_integer(),
          strategy: :longest_first | :only_first | :only_second,
          direction: :left | :right
        ]

  @doc """
  Set truncation for the tokenizer.
  """
  @spec set_truncation(
          tokenizer :: t(),
          opts :: truncation_options()
        ) :: t()
  defdelegate set_truncation(tokenizer, opts \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_set_truncation

  @doc """
  Disable truncation for the tokenizer.
  """
  @spec disable_truncation(tokenizer :: t()) :: t()
  defdelegate disable_truncation(tokenizer),
    to: Tokenizers.Native,
    as: :tokenizer_disable_truncation

  @typedoc """
  Padding options. All options can be ommited.

  * `:strategy` (default: `:batch_longest`) - the strategy to use when padding.
  * `:direction` (default: `:right`) - the direction to use when padding.
  * `:pad_to_multiple_of` (default: `0`) - the multiple to pad to.
  * `:pad_id` (default: `0`) - the id of the token to use for padding.
  * `:pad_type_id` (default: `0`) - the id of the token type to use for padding.
  * `:pad_token` (default: `"<pad>"`) - the token to use for padding.
  """
  @type padding_options() :: [
          strategy: :batch_longest | {:fixed, non_neg_integer()},
          direction: :left | :right,
          pad_to_multiple_of: non_neg_integer(),
          pad_id: non_neg_integer(),
          pad_type_id: non_neg_integer(),
          pad_token: String.t()
        ]

  @doc """
  Set padding for the tokenizer.
  """
  @spec set_padding(tokenizer :: t(), opts :: padding_options()) :: t()
  defdelegate set_padding(tokenizer, opts),
    to: Tokenizers.Native,
    as: :tokenizer_set_padding

  @doc """
  Disable padding for the tokenizer.
  """
  @spec disable_padding(tokenizer :: t()) :: t()
  defdelegate disable_padding(tokenizer),
    to: Tokenizers.Native,
    as: :tokenizer_disable_padding

  ##############################################################################
  # Infering
  ##############################################################################

  @doc """
  Encode the given sequence to a `Tokenizers.Encoding.t()`.

  Options:
  * `:add_special_tokens` (default: `true`) - whether to add special tokens to the sequence.
  """
  @spec encode(
          tokenizer :: t(),
          input :: encode_input(),
          options :: [add_special_tokens: boolean()]
        ) ::
          {:ok, Encoding.t()} | {:error, term()}
  defdelegate encode(tokenizer, input, options \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_encode

  @doc """
  Encode the given batch of sequences to a `Tokenizers.Encoding.t()`.

  For options check `encode/3`.
  """
  @spec encode_batch(
          tokenizer :: t(),
          input :: [encode_input()],
          options :: [add_special_tokens: boolean()]
        ) ::
          {:ok, [Encoding.t()]} | {:error, term()}
  defdelegate encode_batch(tokenizer, input, options \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_encode_batch

  @doc """
  Decodes the given list of ids back to a string.

  Options:

  * `:skip_special_tokens` (default: `true`) - whether to remove special tokens from the decoded string.
  """
  @spec decode(
          tokenizer :: t(),
          ids :: [non_neg_integer()],
          options :: [skip_special_tokens: boolean()]
        ) ::
          {:ok, String.t()} | {:error, term()}
  defdelegate decode(tokenizer, ids, options \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_decode

  @doc """
  Decode the given list of ids or list of lists of ids back to strings.
  """
  @spec decode_batch(
          tokenizer :: t(),
          sentences :: [[non_neg_integer()]],
          options :: [skip_special_tokens: boolean()]
        ) ::
          {:ok, [String.t()]} | {:error, term()}
  defdelegate decode_batch(tokenizer, sentences, options \\ []),
    to: Tokenizers.Native,
    as: :tokenizer_decode_batch

  @doc """
  Convert a given id to its token.
  """
  @spec id_to_token(t(), integer()) :: String.t() | nil
  defdelegate id_to_token(tokenizer, id),
    to: Tokenizers.Native,
    as: :tokenizer_id_to_token

  @doc """
  Convert a given token to its id.
  """
  @spec token_to_id(t(), String.t()) :: non_neg_integer() | nil
  defdelegate token_to_id(tokenizer, token),
    to: Tokenizers.Native,
    as: :tokenizer_token_to_id

  ##############################################################################
  # Training
  ##############################################################################

  @doc """
  Train the tokenizer on the given files.
  """
  @spec train_from_files(
          tokenizer :: t(),
          files :: [String.t()],
          trainer :: Tokenizers.Trainer.t() | nil
        ) ::
          {:ok, t()} | {:error, term()}
  defdelegate train_from_files(tokenizer, files, trainer \\ nil),
    to: Tokenizers.Native,
    as: :tokenizer_train_from_files
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
