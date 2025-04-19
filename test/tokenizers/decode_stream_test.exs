defmodule Tokenizers.DecodeStreamTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.Decoder

  describe "Minimal tokenizer" do
    test "Decodes with stream" do
      {:ok, bpe} = Tokenizers.Model.BPE.empty()
      {:ok, tk} = Tokenizers.Tokenizer.init(bpe)

      tk =
        tk
        |> Tokenizers.Tokenizer.add_tokens(["my", "name", "is", "john", "pair"])

      ds = Tokenizers.DecodeStream.new()

      {:ok, "my"} = Tokenizers.DecodeStream.step(ds, tk, 0)
      {:ok, " name"} = Tokenizers.DecodeStream.step(ds, tk, 1)
      {:ok, " is"} = Tokenizers.DecodeStream.step(ds, tk, 2)
      {:ok, " john"} = Tokenizers.DecodeStream.step(ds, tk, 3)
      {:ok, " pair"} = Tokenizers.DecodeStream.step(ds, tk, 4)
    end
  end

  describe "Byte fallback decode stream" do
    test "handles byte fallback decoding" do
      vocab = [
        {"<unk>", 0.0},
        {"<0x20>", -0.1},
        {"<0xC3>", -0.2},
        {"<0xA9>", -0.3}
      ]

      {:ok, model} = Tokenizers.Model.Unigram.init(vocab, byte_fallback: true, unk_id: 0)

      {:ok, tk} = Tokenizers.Tokenizer.init(model)

      tk =
        tk
        |> Tokenizers.Tokenizer.set_decoder(Tokenizers.Decoder.byte_fallback())

      ds = Tokenizers.DecodeStream.new(false)

      {:ok, " "} = Tokenizers.DecodeStream.step(ds, tk, 1)
      {:ok, :out_of_range} = Tokenizers.DecodeStream.step(ds, tk, 2)
      {:ok, "é"} = Tokenizers.DecodeStream.step(ds, tk, 3)
    end

    test "handles metaspace decoding" do
      vocab = [
        {"<unk>", 0.0},
        {"▁This", -0.1}
      ]

      {:ok, model} = Tokenizers.Model.Unigram.init(vocab, byte_fallback: false, unk_id: 0)
      {:ok, tk} = Tokenizers.Tokenizer.init(model)

      tk =
        tk
        |> Tokenizers.Tokenizer.set_decoder(Tokenizers.Decoder.metaspace())

      ds = Tokenizers.DecodeStream.new(false)

      {:ok, "This"} = Tokenizers.DecodeStream.step(ds, tk, 1)
      {:ok, " This"} = Tokenizers.DecodeStream.step(ds, tk, 1)
    end
  end

  describe "DecodeStream info" do
    test "skip_special_tokens false" do
      assert Tokenizers.DecodeStream.info(Tokenizers.DecodeStream.new(false)) == %{
               "skip_special_tokens" => false
             }
    end

    test "skip_special_tokens true" do
      assert Tokenizers.DecodeStream.info(Tokenizers.DecodeStream.new(true)) == %{
               "skip_special_tokens" => true
             }
    end

    test "default DecodeStream" do
      assert Tokenizers.DecodeStream.info(Tokenizers.DecodeStream.new()) == %{
               "skip_special_tokens" => false
             }
    end
  end
end
