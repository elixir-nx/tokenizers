defmodule Tokenizers.Model.UnigramTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.Model.Unigram

  describe "initialized from memory" do
    test "returns loaded model" do
      assert {:ok, %Tokenizers.Model{}} =
               Tokenizers.Model.Unigram.init([{"<unk>", 0}, {"Hello", -1}, {"there", -2}],
                 unk_id: 0
               )
    end
  end
end
