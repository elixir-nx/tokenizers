defmodule Tokenizers.NormalizerTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.Normalizer

  describe "Bert" do
    test "accepts no parameters" do
      assert %Tokenizers.Normalizer{} = Tokenizers.Normalizer.bert_normalizer()
    end

    test "accepts options" do
      assert %Tokenizers.Normalizer{} =
               Tokenizers.Normalizer.bert_normalizer(
                 clean_text: true,
                 handle_chinese_chars: true,
                 strip_accents: true,
                 lowercase: true
               )
    end

    test "works well with strip accents" do
      assert Tokenizers.Normalizer.bert_normalizer(strip_accents: true, lowercase: false)
             |> Tokenizers.Normalizer.normalize("Héllò") ==
               {:ok, "Hello"}
    end

    test "handles chinese chars well" do
      assert Tokenizers.Normalizer.bert_normalizer(handle_chinese_chars: true)
             |> Tokenizers.Normalizer.normalize("你好") ==
               {:ok, " 你  好 "}
    end

    test "handles clean text well" do
      assert Tokenizers.Normalizer.bert_normalizer(clean_text: true, lowercase: false)
             |> Tokenizers.Normalizer.normalize("\ufeffHello") ==
               {:ok, "Hello"}
    end

    test "handle lowercase well" do
      assert Tokenizers.Normalizer.bert_normalizer(lowercase: true)
             |> Tokenizers.Normalizer.normalize("Hello") ==
               {:ok, "hello"}
    end
  end

  describe "Sequence" do
    test "can be instantiated" do
      assert Tokenizers.Normalizer.sequence([
               Tokenizers.Normalizer.lowercase(),
               Tokenizers.Normalizer.strip()
             ])
             |> Tokenizers.Normalizer.normalize("HELLO    ") == {:ok, "hello"}
    end
  end

  describe "Lowercase" do
    test "accepts no parameters" do
      assert %Tokenizers.Normalizer{} = Tokenizers.Normalizer.lowercase()
    end

    test "can normalize strings" do
      assert Tokenizers.Normalizer.lowercase()
             |> Tokenizers.Normalizer.normalize("HELLO") == {:ok, "hello"}
    end
  end

  describe "Strip" do
    test "accepts no parameters" do
      assert %Tokenizers.Normalizer{} = Tokenizers.Normalizer.strip()
    end

    test "accepts options" do
      assert %Tokenizers.Normalizer{} = Tokenizers.Normalizer.strip(left: true, right: true)
    end

    test "can normalizer strings" do
      assert Tokenizers.Normalizer.strip()
             |> Tokenizers.Normalizer.normalize("     Hello there   ") ==
               {:ok, "Hello there"}
    end
  end

  describe "Prepend" do
    test "can be initialized" do
      assert %Tokenizers.Normalizer{} = Tokenizers.Normalizer.prepend("▁")
    end

    test "can normalize strings" do
      assert Tokenizers.Normalizer.prepend("▁")
             |> Tokenizers.Normalizer.normalize("Hello") ==
               {:ok, "▁Hello"}
    end
  end

  describe "Replace" do
    test "can be initialized" do
      assert %Tokenizers.Normalizer{} = Tokenizers.Normalizer.replace("find", "replace")
    end

    test "can normalize strings" do
      assert Tokenizers.Normalizer.replace("Hello", "World")
             |> Tokenizers.Normalizer.normalize("Hello") ==
               {:ok, "World"}
    end
  end

  describe "Replace Regex" do
    test "can be initialized" do
      assert %Tokenizers.Normalizer{} = Tokenizers.Normalizer.replace_regex("\\d*", "")
    end

    test "can normalize strings" do
      assert Tokenizers.Normalizer.replace_regex("\\d*", "")
             |> Tokenizers.Normalizer.normalize("1Hel2lo3") ==
               {:ok, "Hello"}
    end
  end
end
