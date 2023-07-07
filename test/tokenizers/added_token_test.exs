defmodule Tokenizers.AddedTokenTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.AddedToken

  describe "Added token" do
    test "successfully initializes with empty params" do
      assert token = %Tokenizers.AddedToken{} = Tokenizers.AddedToken.new("[MASK]")

      assert %{
               "content" => "[MASK]",
               "lstrip" => false,
               "normalized" => true,
               "rstrip" => false,
               "single_word" => false,
               "special" => false
             } = Tokenizers.AddedToken.info(token)
    end

    test "successfully initializes with params" do
      assert token =
               %Tokenizers.AddedToken{} =
               Tokenizers.AddedToken.new(
                 "[MASK]",
                 lstrip: true,
                 rstrip: true,
                 single_word: true,
                 normalized: false,
                 special: true
               )

      assert %{
               "content" => "[MASK]",
               "lstrip" => true,
               "normalized" => false,
               "rstrip" => true,
               "single_word" => true,
               "special" => true
             } = Tokenizers.AddedToken.info(token)
    end
  end
end
