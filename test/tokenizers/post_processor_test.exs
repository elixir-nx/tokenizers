defmodule Tokenizers.PostProcessorTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.PostProcessor

  describe "bertProcessing" do
    test "instantiates correctly with only two parameters" do
      assert %Tokenizers.PostProcessor{} =
               Tokenizers.PostProcessor.bert({"[SEP]", 0}, {"[CLS]", 1})
    end

    test "successfully processes data" do
      {:ok, tokenizer} = Tokenizers.Tokenizer.init(Tokenizers.Model.BPE.empty() |> elem(1))

      tokenizer =
        tokenizer
        |> Tokenizers.Tokenizer.add_special_tokens(["[SEP]", "[CLS]"])
        |> Tokenizers.Tokenizer.add_tokens(["my", "name", "is", "john", "pair"])
        |> Tokenizers.Tokenizer.set_post_processor(
          Tokenizers.PostProcessor.bert({"[SEP]", 0}, {"[CLS]", 1})
        )

      {:ok, output} =
        Tokenizers.Tokenizer.encode(tokenizer, {"my name", "pair"})

      assert Tokenizers.Encoding.get_tokens(output) == [
               "[CLS]",
               "my",
               "name",
               "[SEP]",
               "pair",
               "[SEP]"
             ]

      assert Tokenizers.Encoding.get_ids(output) == [1, 2, 3, 0, 6, 0]
    end
  end

  describe "robertaProcessing" do
    test "instantiates correctly with only two parameters" do
      assert %Tokenizers.PostProcessor{} =
               Tokenizers.PostProcessor.roberta({"</s>", 0}, {"<s>", 1})
    end

    test "successfully processes data" do
      {:ok, tokenizer} = Tokenizers.Tokenizer.init(Tokenizers.Model.BPE.empty() |> elem(1))

      tokenizer =
        tokenizer
        |> Tokenizers.Tokenizer.add_special_tokens(["</s>", "<s>"])
        |> Tokenizers.Tokenizer.add_tokens(["my", "name", "is", "john", "pair"])
        |> Tokenizers.Tokenizer.set_post_processor(
          Tokenizers.PostProcessor.roberta({"</s>", 1}, {"<s>", 0})
        )

      {:ok, output} =
        Tokenizers.Tokenizer.encode(tokenizer, {"my name", "pair"})

      assert Tokenizers.Encoding.get_tokens(output) == [
               "<s>",
               "my",
               "name",
               "</s>",
               "</s>",
               "pair",
               "</s>"
             ]

      assert Tokenizers.Encoding.get_ids(output) == [0, 2, 3, 1, 1, 6, 1]
    end
  end

  describe "byteLevelProcessing" do
    test "instantiates correctly with only two parameters" do
      assert %Tokenizers.PostProcessor{} =
               Tokenizers.PostProcessor.byte_level(trim_offsets: false)

      assert %Tokenizers.PostProcessor{} = Tokenizers.PostProcessor.byte_level()
    end
  end
end
