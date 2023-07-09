defmodule Tokenizers.PreTokenizerTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.PreTokenizer

  describe "Byte Level pretokenizer" do
    test "accepts no parameters" do
      assert %Tokenizers.PreTokenizer{} = Tokenizers.PreTokenizer.byte_level()
    end

    test "accepts options" do
      assert %Tokenizers.PreTokenizer{} =
               Tokenizers.PreTokenizer.byte_level(add_prefix_space: false)
    end
  end

  describe "Split pretokenizer" do
    test "accepts no parameters" do
      assert %Tokenizers.PreTokenizer{} = Tokenizers.PreTokenizer.split(" ", :removed)
    end

    test "accepts options" do
      assert %Tokenizers.PreTokenizer{} =
               Tokenizers.PreTokenizer.split(" ", :removed, invert: true)
    end
  end

  describe "WhitespaceSplit pretokenizer" do
    test "accepts no parameters" do
      assert %Tokenizers.PreTokenizer{} = Tokenizers.PreTokenizer.whitespace_split()
    end
  end

  describe "BertPreTokenizer pretokenizer" do
    test "accepts no parameters" do
      assert %Tokenizers.PreTokenizer{} = Tokenizers.PreTokenizer.bert_pre_tokenizer()
    end
  end

  describe "Metaspace pretokenizer" do
    test "accepts no parameters" do
      assert %Tokenizers.PreTokenizer{} = Tokenizers.PreTokenizer.metaspace()
    end

    test "accepts options" do
      assert %Tokenizers.PreTokenizer{} =
               Tokenizers.PreTokenizer.metaspace(replacement: ?_, add_prefix_space: false)
    end
  end

  describe "CharDelimiterSplit pretokenizer" do
    test "accepts no parameters" do
      assert %Tokenizers.PreTokenizer{} = Tokenizers.PreTokenizer.char_delimiter_split(?_)
    end
  end

  describe "Sequence pretokenizer" do
    test "accepts no parameters but chain of tokenizers" do
      assert %Tokenizers.PreTokenizer{} =
               Tokenizers.PreTokenizer.sequence([
                 Tokenizers.PreTokenizer.whitespace_split(),
                 Tokenizers.PreTokenizer.bert_pre_tokenizer()
               ])
    end
  end
end
