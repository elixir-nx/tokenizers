defmodule Tokenizers.Model.WordLevelTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.Model.WordLevel

  describe "initialized from memory" do
    test "returns loaded model" do
      assert {:ok, %Tokenizers.Model{}} =
               Tokenizers.Model.WordLevel.init(%{"a" => 0, "b" => 1, "ab" => 2})
    end

    test "accepts keyword params" do
      assert {:ok, %Tokenizers.Model{}} =
               Tokenizers.Model.WordLevel.init(%{"a" => 0, "b" => 1, "ab" => 2},
                 unk_token: "asdf"
               )
    end

    test "rejects bad keyword params" do
      assert_raise ErlangError, fn ->
        Tokenizers.Model.WordLevel.init(%{"a" => 0, "b" => 1, "ab" => 2},
          weird_value: :something
        )
      end
    end
  end

  describe "loaded from file" do
    test "good initialization with valid paths" do
      assert {:ok, %Tokenizers.Model{}} =
               Tokenizers.Model.WordLevel.from_file("test/fixtures/vocab.json")
    end

    test "bad initialization with invalid paths" do
      assert {:error, _} =
               Tokenizers.Model.WordLevel.from_file("test/fixtures/not_found_vocab.json")
    end
  end
end
