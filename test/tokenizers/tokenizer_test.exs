defmodule Tokenizers.TokenizerTest do
  use ExUnit.Case
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

  describe "encode/decode" do
    test "can encode a single string", %{tokenizer: tokenizer} do
      assert match?({:ok, %Tokenizers.Encoding{}}, Tokenizer.encode(tokenizer, "This is a test"))
    end

    test "can encode a batch of strings", %{tokenizer: tokenizer} do
      assert match?(
               {:ok, [%Tokenizers.Encoding{} | _]},
               Tokenizer.encode(tokenizer, ["This is a test", "And so is this"])
             )
    end

    test "can decode a single encoding", %{tokenizer: tokenizer} do
      text = "This is a test"
      {:ok, encoding} = Tokenizer.encode(tokenizer, text)
      ids = Encoding.get_ids(encoding)
      {:ok, decoded} = Tokenizer.decode(tokenizer, ids)
      assert decoded == text
    end

    test "can decode a batch of encodings", %{tokenizer: tokenizer} do
      text = ["This is a test", "And so is this"]
      {:ok, encodings} = Tokenizer.encode(tokenizer, text)
      ids = Enum.map(encodings, &Encoding.get_ids/1)
      {:ok, decoded} = Tokenizer.decode(tokenizer, ids)
      assert decoded == text
    end
  end
end
