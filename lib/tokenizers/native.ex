defmodule Tokenizers.Native do
  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:package][:links]["GitHub"]

  use RustlerPrecompiled,
    otp_app: :tokenizers,
    crate: "ex_tokenizers",
    version: version,
    base_url: "#{github_url}/releases/download/v#{version}",
    force_build: System.get_env("TOKENIZERS_BUILD") in ["1", "true"]

  # Added tokens
  def added_token_new(_token, _special), do: err()
  #
  def added_token_info(_added_token), do: err()
  #
  def added_token_single_word(_added_token, _single_word), do: err()
  def added_token_lstrip(_added_token, _lstrip), do: err()
  def added_token_rstrip(_added_token, _rstrip), do: err()
  def added_token_normalized(_added_token, _normalized), do: err()

  # Models
  def models_save(_model, _folder, _opts), do: err()
  #
  def models_info(_model), do: err()
  #
  def models_bpe_init(_vocab, _merges, _options), do: err()
  def models_bpe_empty(), do: err()
  def models_bpe_from_file(_vocab, _merges, _options), do: err()
  #
  def models_wordpiece_init(_vocab, _options), do: err()
  def models_wordpiece_empty(), do: err()
  def models_wordpiece_from_file(_vocab, _options), do: err()
  #
  def models_wordlevel_init(_vocab, _options), do: err()
  def models_wordlevel_empty(), do: err()
  def models_wordlevel_from_file(_vocab, _options), do: err()
  #
  def models_unigram_init(_vocab, _options), do: err()
  def models_unigram_empty(), do: err()

  # Trainers
  def trainers_info(_trainer), do: err()
  #
  def trainers_train(_trainer, _model), do: err()
  #
  def trainers_bpe_trainer(_options), do: err()
  def trainers_wordpiece_trainer(_options), do: err()
  def trainers_wordlevel_trainer(_options), do: err()
  def trainers_unigram_trainer(_options), do: err()

  def decode(_tokenizer, _ids, _skip_special_tokens), do: err()
  def decode_batch(_tokenizer, _ids, _skip_special_tokens), do: err()
  def encode(_tokenizer, _input, _add_special_tokens), do: err()
  def encode_batch(_tokenizer, _input, _add_special_tokens), do: err()
  def from_file(_path, _additional_special_tokens), do: err()
  def get_attention_mask(_encoding), do: err()
  def get_u32_attention_mask(_encoding), do: err()
  def get_type_ids(_encoding), do: err()
  def get_u32_type_ids(_encoding), do: err()
  def get_ids(_encoding), do: err()
  def get_u32_ids(_encoding), do: err()
  def get_tokens(_encoding), do: err()
  def get_special_tokens_mask(_encoding), do: err()
  def get_u32_special_tokens_mask(_encoding), do: err()
  def get_offsets(_encoding), do: err()
  def get_vocab(_tokenizer, _with_added_tokens), do: err()
  def get_vocab_size(_tokenizer, _with_added_tokens), do: err()
  def id_to_token(_tokenizer, _id), do: err()
  def save(_tokenizer, _path, _pretty), do: err()
  def token_to_id(_tokenizer, _token), do: err()
  def truncate(_encoding, _max_len, _stride, _direction), do: err()
  def pad(_encoding, _target_length, _pad_id, _pad_type_id, _pad_token, _direction), do: err()
  def get_model(_tokenizer), do: err()
  def get_model_details(_model), do: err()
  def n_tokens(_encoding), do: err()

  defp err(), do: :erlang.nif_error(:nif_not_loaded)
end
