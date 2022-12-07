defmodule Tokenizers.TokenizerTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.Tokenizer

  alias Tokenizers.Encoding
  alias Tokenizers.Tokenizer

  setup do
    {:ok, tokenizer} = Tokenizer.from_file("test/fixtures/bert-base-cased.json")
    {:ok, tokenizer: tokenizer}
  end

  describe "IO" do
    test "can read from file" do
      {:ok, tokenizer} = Tokenizer.from_file("test/fixtures/bert-base-cased.json")
      assert Tokenizer.get_vocab_size(tokenizer) == 28996
    end

    @tag :tmp_dir
    test "can write to file", config do
      {:ok, tokenizer} = Tokenizer.from_file("test/fixtures/bert-base-cased.json")
      {:ok, path} = Tokenizer.save(tokenizer, config.tmp_dir <> "test.json")
      {:ok, tokenizer} = Tokenizer.from_file(path)
      assert Tokenizer.get_vocab_size(tokenizer) == 28996
    end
  end

  describe "from_pretrained/2" do
    defmodule SuccessHTTPClient do
      def request(opts) do
        send(self(), {:request, opts})

        body =
          case opts[:method] do
            :get ->
              File.read!("test/fixtures/bert-base-cased.json")

            :head ->
              ""
          end

        {:ok,
         %{
           body: body,
           headers: [{"etag", "test-etag"}],
           status: opts[:test_status]
         }}
      end
    end

    defmodule ErrorHTTPClient do
      def request(opts) do
        send(self(), {:request, opts})
        {:error, "internal error"}
      end
    end

    @tag :tmp_dir
    test "load from pretrained successfully", %{tmp_dir: tmp_dir} do
      {:ok, tokenizer} =
        Tokenizer.from_pretrained("bert-base-cased",
          use_cache: false,
          cache_dir: tmp_dir,
          http_client: {SuccessHTTPClient, [test_status: 200, headers: [{"test-header", "42"}]]}
        )

      assert Tokenizer.get_vocab_size(tokenizer) == 28996

      assert_received {:request, opts}

      assert opts[:method] == :get
      assert opts[:base_url] == "https://huggingface.co"
      assert opts[:url] == "/bert-base-cased/resolve/main/tokenizer.json"

      assert [{"test-header", "42"}, {"user-agent", "tokenizers-elixir/" <> _app_version}] =
               opts[:headers]

      {:ok, tokenizer} =
        Tokenizer.from_pretrained("bert-base-cased",
          use_cache: true,
          cache_dir: tmp_dir,
          http_client: {SuccessHTTPClient, [test_status: 200]}
        )

      assert Tokenizer.get_vocab_size(tokenizer) == 28996

      assert_received {:request, opts}
      assert opts[:method] == :head
    end

    @tag :tmp_dir
    test "returns error when status is not found", %{tmp_dir: tmp_dir} do
      assert {:error, :not_found} =
               Tokenizer.from_pretrained("bert-base-cased",
                 use_cache: false,
                 cache_dir: tmp_dir,
                 http_client: {SuccessHTTPClient, [test_status: 404]}
               )
    end

    @tag :tmp_dir
    test "returns error when request is not successful", %{tmp_dir: tmp_dir} do
      assert {:error, error} =
               Tokenizer.from_pretrained("bert-base-cased",
                 use_cache: false,
                 cache_dir: tmp_dir,
                 http_client: {ErrorHTTPClient, []}
               )

      assert error == "internal error"
    end
  end

  describe "encode/decode" do
    test "can encode a single string", %{tokenizer: tokenizer} do
      assert {:ok, %Tokenizers.Encoding{}} = Tokenizer.encode(tokenizer, "This is a test")
    end

    test "can encode a single string with special characters", %{tokenizer: tokenizer} do
      seq = "This is a test"
      {:ok, encoding_clean} = Tokenizer.encode(tokenizer, seq, add_special_tokens: false)
      {:ok, encoding_special} = Tokenizer.encode(tokenizer, seq)

      refute Encoding.n_tokens(encoding_clean) == Encoding.n_tokens(encoding_special)
    end

    test "can encode a pair of strings", %{tokenizer: tokenizer} do
      assert {:ok, %Tokenizers.Encoding{}} = Tokenizer.encode(tokenizer, {"Question?", "Answer"})
    end

    test "can encode a batch of strings", %{tokenizer: tokenizer} do
      assert {:ok, [%Tokenizers.Encoding{}, %Tokenizers.Encoding{}]} =
               Tokenizer.encode(tokenizer, ["This is a test", "And so is this"])
    end

    test "can encode a batch of strings and pairs", %{tokenizer: tokenizer} do
      assert {:ok, [%Tokenizers.Encoding{}, %Tokenizers.Encoding{}]} =
               Tokenizer.encode(tokenizer, ["This is a test", {"Question?", "Answer"}])
    end

    test "can decode a single encoding", %{tokenizer: tokenizer} do
      text = "This is a test"
      {:ok, encoding} = Tokenizer.encode(tokenizer, text)
      ids = Encoding.get_ids(encoding)
      {:ok, decoded} = Tokenizer.decode(tokenizer, ids)
      assert decoded == text
    end

    test "can decode a single encoding skipping special characters", %{tokenizer: tokenizer} do
      seq = "This is a test"
      {:ok, encoding} = Tokenizer.encode(tokenizer, seq)
      ids = Encoding.get_ids(encoding)

      {:ok, seq_clean} = Tokenizer.decode(tokenizer, ids)
      {:ok, seq_special} = Tokenizer.decode(tokenizer, ids, skip_special_tokens: false)

      refute seq_special == seq
      assert seq_clean == seq
    end

    test "can decode a batch of encodings", %{tokenizer: tokenizer} do
      text = ["This is a test", "And so is this"]
      {:ok, encodings} = Tokenizer.encode(tokenizer, text)
      ids = Enum.map(encodings, &Encoding.get_ids/1)
      {:ok, decoded} = Tokenizer.decode(tokenizer, ids)
      assert decoded == text
    end
  end

  describe "encode metadata" do
    test "can return special tokens mask", %{tokenizer: tokenizer} do
      text = ["This is a test", "And so is this"]
      {:ok, encodings} = Tokenizer.encode(tokenizer, text)
      special_tokens_mask = Enum.map(encodings, &Encoding.get_special_tokens_mask/1)
      assert [[1, 0, 0, 0, 0, 1], [1, 0, 0, 0, 0, 1]] == special_tokens_mask
    end

    test "can return offsets", %{tokenizer: tokenizer} do
      text = ["This is a test", "And so is this"]
      {:ok, encodings} = Tokenizer.encode(tokenizer, text)
      offsets = Enum.map(encodings, &Encoding.get_offsets/1)

      assert [
               [{0, 0}, {0, 4}, {5, 7}, {8, 9}, {10, 14}, {0, 0}],
               [{0, 0}, {0, 3}, {4, 6}, {7, 9}, {10, 14}, {0, 0}]
             ] == offsets
    end
  end
end
