defmodule Tokenizers.DecoderTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.Decoder

  describe "WordPiece Decoder" do
    test "accepts no parameters" do
      assert %Tokenizers.Decoder{} = Tokenizers.Decoder.word_piece()
    end

    test "accepts all params" do
      assert %Tokenizers.Decoder{} = Tokenizers.Decoder.word_piece(prefix: "test", cleanup: false)
    end

    test "can decode array of strings" do
      assert Tokenizers.Decoder.word_piece()
             |> Tokenizers.Decoder.decode(["Hel", "##lo", "there", "my", "fr", "##iend"]) ==
               {:ok, "Hello there my friend"}
    end
  end

  describe "ByteFallback Decoder" do
    test "accepts no parameters" do
      assert %Tokenizers.Decoder{} = Tokenizers.Decoder.byte_fallback()
    end

    test "can decode array of strings" do
      [
        {["Hel", "lo"], "Hello"},
        {["<0x61>"], "a"},
        {["<0x61>"], "a"},
        {["My", " na", "me"], "My name"},
        {["<0x61>"], "a"},
        {["<0xE5>"], "�"},
        {["<0xE5>", "<0x8f>"], "��"},
        {["<0xE5>", "<0x8f>", "<0xab>"], "叫"},
        {["<0xE5>", "<0x8f>", "a"], "��a"},
        {["<0xE5>", "<0x8f>", "<0xab>", "a"], "叫a"}
      ]
      |> Enum.each(fn {tokens, result} ->
        assert Tokenizers.Decoder.decode(Tokenizers.Decoder.byte_fallback(), tokens) ==
                 {:ok, result}
      end)
    end
  end

  describe "Replace Decoder" do
    test "can decode array of strings" do
      assert Tokenizers.Decoder.decode(Tokenizers.Decoder.replace("_", " "), ["Hello", "_Hello"]) ==
               {:ok, "Hello Hello"}
    end
  end

  describe "Fuse Decoder" do
    test "accepts no parameters" do
      %Tokenizers.Decoder{} = Tokenizers.Decoder.fuse()
    end

    test "can decode array of strings" do
      assert Tokenizers.Decoder.fuse()
             |> Tokenizers.Decoder.decode(["Hel", "lo"]) ==
               {:ok, "Hello"}
    end
  end

  describe "Strip Decoder" do
    test "can be initialized" do
      assert %Tokenizers.Decoder{} = Tokenizers.Decoder.strip(?_, 0, 0)
    end

    test "cant be initialized with invalid char" do
      assert_raise ArgumentError, fn ->
        Tokenizers.Decoder.strip(61_126_999, 0, 0)
      end
    end

    test "can decode array of strings" do
      assert Tokenizers.Decoder.strip(?_, 1, 0)
             |> Tokenizers.Decoder.decode(["_Hel", "lo", "__there"]) ==
               {:ok, "Hello_there"}
    end
  end

  describe "Metaspace Decoder" do
    test "accepts no parameters" do
      assert %Tokenizers.Decoder{} = Tokenizers.Decoder.metaspace()
    end

    test "accepts all params" do
      assert %Tokenizers.Decoder{} =
               Tokenizers.Decoder.metaspace(replacement: ?t, add_prefix_space: true)
    end
  end

  describe "BPE Decoder" do
    test "accepts no parameters" do
      assert %Tokenizers.Decoder{} = Tokenizers.Decoder.bpe()
    end
  end

  describe "CTC Decoder" do
    test "accepts no parameters" do
      assert %Tokenizers.Decoder{} = Tokenizers.Decoder.ctc()
    end

    test "accepts all parameters" do
      assert %Tokenizers.Decoder{} =
               Tokenizers.Decoder.ctc(
                 pad_token: "<pad>",
                 word_delimiter_token: "!!",
                 cleanup: false
               )
    end

    test "can decode array of strings" do
      assert Tokenizers.Decoder.ctc()
             |> Tokenizers.Decoder.decode([
               "<pad>",
               "h",
               "h",
               "e",
               "e",
               "l",
               "l",
               "<pad>",
               "l",
               "l",
               "o"
             ]) ==
               {:ok, "hello"}
    end
  end

  describe "Sequence Decoder" do
    test "accepts empty list as parameter" do
      assert %Tokenizers.Decoder{} = Tokenizers.Decoder.sequence([])
    end

    test "can decode array of strings correctly" do
      assert Tokenizers.Decoder.sequence([
               Tokenizers.Decoder.ctc(),
               Tokenizers.Decoder.metaspace()
             ])
             |> Tokenizers.Decoder.decode(["▁", "▁", "H", "H", "i", "i", "▁", "y", "o", "u"]) ==
               {:ok, "Hi you"}
    end
  end
end
