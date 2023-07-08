defmodule Tokenizers.PostProcessorTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.PostProcessor

  describe "bertProcessing" do
    test "instantiates correctly with only two parameters" do
      assert %Tokenizers.PostProcessor{} =
               Tokenizers.PostProcessor.bert({"[SEP]", 0}, {"[CLS]", 1})
    end
  end

  describe "robertaProcessing" do
    test "instantiates correctly with only two parameters" do
      assert %Tokenizers.PostProcessor{} =
               Tokenizers.PostProcessor.roberta({"</s>", 0}, {"<s>", 1})
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
