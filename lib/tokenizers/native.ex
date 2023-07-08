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
  def added_token_new(_token, _opts), do: err()
  #
  def added_token_info(_added_token), do: err()

  # Decoders
  def decoders_decode(_decoder, _tokens), do: err()
  #
  def decoders_info(_decoder), do: err()
  #
  def decoders_byte_level(), do: err()
  def decoders_replace(_pattern, _content), do: err()
  def decoders_wordpiece(_prefix, _cleanup), do: err()
  def decoders_byte_fallback(), do: err()
  def decoders_fuse(), do: err()
  def decoders_strip(_content, _left, _right), do: err()
  def decoders_metaspace(_replacement, _add_prefix_space), do: err()
  def decoders_bpe(_suffix), do: err()
  def decoders_ctc(_pad_token, _word_delimiter_token, _cleanup), do: err()
  def decoders_sequence(_decoders), do: err()

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

  # Normalizers
  def normalizers_normalize(_normalizer, _input), do: err()
  #
  def normalizers_info(_normalizer), do: err()
  #
  def normalizers_bert_normalizer(_opts), do: err()
  def normalizers_nfd(), do: err()
  def normalizers_nfkd(), do: err()
  def normalizers_nfc(), do: err()
  def normalizers_nfkc(), do: err()
  def normalizers_strip(_opts), do: err()
  def normalizers_prepend(_prepend), do: err()
  def normalizers_strip_accents(), do: err()
  def normalizers_sequence(_normalizers), do: err()
  def normalizers_lowercase(), do: err()
  def normalizers_replace(_pattern, _content), do: err()
  def normalizers_nmt(), do: err()
  def normalizers_precompiled(_data), do: err()

  # PreTokenizers
  def pre_tokenizers_pre_tokenize(_pre_tokenizer, _input), do: err()
  #
  def pre_tokenizers_info(_pre_tokenizer), do: err()
  #
  def pre_tokenizers_byte_level(_opts), do: err()
  def pre_tokenizers_byte_level_alphabet(), do: err()
  def pre_tokenizers_whitespace(), do: err()
  def pre_tokenizers_whitespace_split(), do: err()
  def pre_tokenizers_bert(), do: err()
  def pre_tokenizers_metaspace(_opts), do: err()
  def pre_tokenizers_char_delimiter_split(_delimiter), do: err()
  def pre_tokenizers_split(_pattern, _behavior, _invert), do: err()
  def pre_tokenizers_punctuation(_behavior), do: err()
  def pre_tokenizers_sequence(_pre_tokenizers), do: err()
  def pre_tokenizers_digits(_individual_digits), do: err()

  # PostProcessors
  def post_processors_info(_post_processor), do: err()
  #
  def post_processors_bert(_sep, _cls), do: err()
  def post_processors_roberta(_sep, _cls, _opts), do: err()
  def post_processors_byte_level(_opts), do: err()
  def post_processors_template(_opts), do: err()
  def post_processors_sequence(_post_processors), do: err()

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
