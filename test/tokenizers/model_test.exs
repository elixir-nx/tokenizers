defmodule Tokenizers.ModelTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.Trainer

  describe "model common functionality" do
    test "it successfully saves the model" do
      {:ok, original_model} = Tokenizers.Model.BPE.empty()
      assert {:ok, [vocab, merges]} = Tokenizers.Model.save(original_model, System.tmp_dir!)
      assert File.exists?(vocab)
      assert File.exists?(merges)

      assert {:ok, loaded_model} = Tokenizers.Model.BPE.from_file(vocab, merges)
      assert Tokenizers.Model.info(original_model) == Tokenizers.Model.info(loaded_model)
    end

    test "it successfully saves the model to a directory with prefix" do
      {:ok, original_model} = Tokenizers.Model.BPE.empty()
      assert {:ok, [vocab, merges]} = Tokenizers.Model.save(original_model, System.tmp_dir!, prefix: "MODEL_PREFIX")
      assert File.exists?(vocab)
      assert File.exists?(merges)

      assert String.contains?(vocab, "MODEL_PREFIX")
      assert String.contains?(merges, "MODEL_PREFIX")

      assert {:ok, loaded_model} = Tokenizers.Model.BPE.from_file(vocab, merges)
      assert Tokenizers.Model.info(original_model) == Tokenizers.Model.info(loaded_model)
    end
  end
end
