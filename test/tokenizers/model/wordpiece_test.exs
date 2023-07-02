defmodule Tokenizers.Model.WordPieceTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.Model.WordPiece

  describe "initialized from memory" do
    test "returns loaded model" do
      assert {:ok, %Tokenizers.Model{}} =
               Tokenizers.Model.WordPiece.init(%{"a" => 0, "b" => 1, "ab" => 2})
    end

    test "accepts keyword params" do
      assert {:ok, %Tokenizers.Model{}} =
               Tokenizers.Model.WordPiece.init(%{"a" => 0, "b" => 1, "ab" => 2},
                 max_input_chars_per_word: 50
               )
    end

    test "rejects bad keyword params" do
      assert_raise ErlangError, fn ->
        Tokenizers.Model.WordPiece.init(%{"a" => 0, "b" => 1, "ab" => 2},
          weird_value: :something
        )
      end
    end
  end

  describe "loaded from file" do
    test "good initialized with valid pathes" do
      assert {:ok, %Tokenizers.Model{}} =
               Tokenizers.Model.WordPiece.from_file("test/fixtures/vocab.txt")
    end

    test "bad initialized with invalid pathes" do
      assert {:error, _} =
               Tokenizers.Model.WordPiece.from_file("test/fixtures/not_found_vocab.json")
    end
  end
end
