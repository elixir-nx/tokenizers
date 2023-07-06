defmodule Tokenizers.TrainerTest do
  use ExUnit.Case, async: true
  doctest Tokenizers.Trainer

  describe "BPE trainer" do
    test "it successfully initializes with empty params" do
      assert {:ok, %Tokenizers.Trainer{}} = Tokenizers.Trainer.bpe()
    end

    test "it successfully initializes with params" do
      assert {:ok, %Tokenizers.Trainer{} = trainer} =
               Tokenizers.Trainer.bpe(
                 vocab_size: 1000,
                 min_frequency: 2,
                 special_tokens: ["[UNK]", "[CLS]", "[SEP]", "[PAD]", "[MASK]"],
                 limit_alphabet: 1000,
                 initial_alphabet: [?a, ?b, ?c],
                 show_progress: true,
                 continuing_subword_prefix: "##",
                 end_of_word_suffix: "##"
               )

      assert %{
               "continuing_subword_prefix" => "##",
               "end_of_word_suffix" => "##",
               "initial_alphabet" => 3,
               "limit_alphabet" => 1000,
               "min_frequency" => 2,
               "show_progress" => true,
               "special_tokens" => 5,
               "trainer_type" => "bpe",
               "vocab_size" => 1000
             } == Tokenizers.Trainer.info(trainer)
    end

    test "it fails to initialize with invalid params" do
      assert {:error, _} =
               Tokenizers.Trainer.bpe(
                 vocab_size: 1000,
                 min_frequency: 2,
                 special_tokens: ["[UNK]", "[CLS]", "[SEP]", "[PAD]", "[MASK]"],
                 limit_alphabet: 1000,
                 initial_alphabet: [1_234_123_451, ?b, ?c],
                 show_progress: true,
                 continuing_subword_prefix: "##",
                 end_of_word_suffix: "##"
               )
    end

    test "it accepts added tokens as special tokens" do
      assert {:ok, %Tokenizers.Trainer{}} =
               Tokenizers.Trainer.bpe(
                 special_tokens: [
                   Tokenizers.AddedToken.new("[UNK]", true),
                   Tokenizers.AddedToken.new("[CLS]", true),
                   Tokenizers.AddedToken.new("[SEP]", true),
                   Tokenizers.AddedToken.new("[PAD]", true),
                   Tokenizers.AddedToken.new("[MASK]", true)
                 ]
               )
    end
  end

  describe "WordPiece trainer" do
    test "it successfully initializes with empty params" do
      assert {:ok, %Tokenizers.Trainer{}} = Tokenizers.Trainer.wordpiece()
    end

    test "it successfully initializes with params" do
      assert {:ok, %Tokenizers.Trainer{}} =
               Tokenizers.Trainer.wordpiece(
                 vocab_size: 1000,
                 min_frequency: 2,
                 special_tokens: ["[UNK]", "[CLS]", "[SEP]", "[PAD]", "[MASK]"],
                 limit_alphabet: 1000,
                 initial_alphabet: [?a, ?b, ?c],
                 show_progress: true,
                 continuing_subword_prefix: "##",
                 end_of_word_suffix: "##"
               )
    end
  end

  describe "WordLevel trainer" do
    test "it successfully initializes with empty params" do
      assert {:ok, %Tokenizers.Trainer{}} = Tokenizers.Trainer.wordlevel()
    end

    test "it successfully initializes with params" do
      assert {:ok, %Tokenizers.Trainer{}} =
               Tokenizers.Trainer.wordlevel(
                 vocab_size: 1000,
                 min_frequency: 2,
                 special_tokens: ["[UNK]", "[CLS]", "[SEP]", "[PAD]", "[MASK]"],
                 show_progress: true
               )
    end
  end

  describe "Unigram trainer" do
    test "it successfully initializes with empty params" do
      assert {:ok, %Tokenizers.Trainer{}} = Tokenizers.Trainer.unigram()
    end

    test "it successfully initializes with params" do
      assert {:ok, %Tokenizers.Trainer{}} =
               Tokenizers.Trainer.unigram(
                 vocab_size: 1000,
                 n_sub_iterations: 2,
                 shrinking_factor: 0.75,
                 special_tokens: ["[UNK]", "[CLS]", "[SEP]", "[PAD]", "[MASK]"],
                 initial_alphabet: [?a, ?b, ?c],
                 uni_token: "##",
                 max_piece_length: 4,
                 seed_size: 100,
                 show_progress: true
               )
    end
  end
end
