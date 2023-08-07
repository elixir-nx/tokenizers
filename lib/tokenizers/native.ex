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
  def decoders_wordpiece(_options), do: err()
  def decoders_byte_fallback(), do: err()
  def decoders_fuse(), do: err()
  def decoders_strip(_content, _left, _right), do: err()
  def decoders_metaspace(_options), do: err()
  def decoders_bpe(_options), do: err()
  def decoders_ctc(_options), do: err()
  def decoders_sequence(_decoders), do: err()

  # Encoding
  def encoding_get_length(_encoding), do: err()
  def encoding_get_n_sequences(_encoding), do: err()
  def encoding_set_sequence_id(_encoding, _seq_id), do: err()
  def encoding_get_ids(_encoding), do: err()
  def encoding_get_u32_ids(_encoding), do: err()
  def encoding_get_type_ids(_encoding), do: err()
  def encoding_get_u32_type_ids(_encoding), do: err()
  def encoding_get_attention_mask(_encoding), do: err()
  def encoding_get_u32_attention_mask(_encoding), do: err()
  def encoding_get_special_tokens_mask(_encoding), do: err()
  def encoding_get_u32_special_tokens_mask(_encoding), do: err()
  def encoding_get_tokens(_encoding), do: err()
  def encoding_get_word_ids(_encoding), do: err()
  def encoding_get_sequence_ids(_encoding), do: err()
  def encoding_get_offsets(_encoding), do: err()
  def encoding_get_overflowing(_encoding), do: err()
  def encoding_word_to_tokens(_encoding, _word, _seq_id), do: err()
  def encoding_word_to_chars(_encoding, _word, _seq_id), do: err()
  def encoding_token_to_sequence(_encoding, _token), do: err()
  def encoding_token_to_chars(_encoding, _token), do: err()
  def encoding_token_to_word(_encoding, _token), do: err()
  def encoding_char_to_token(_encoding, _position, _seq_id), do: err()
  def encoding_char_to_word(_encoding, _position, _seq_id), do: err()
  def encoding_pad(_encoding, _target_length, _opts), do: err()
  def encoding_truncate(_encoding, _max_length, _opts), do: err()

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
  def pre_tokenizers_split(_pattern, _behavior, _options), do: err()
  def pre_tokenizers_punctuation(_behavior), do: err()
  def pre_tokenizers_sequence(_pre_tokenizers), do: err()
  def pre_tokenizers_digits(_options), do: err()

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
  def trainers_bpe_trainer(_options), do: err()
  def trainers_wordpiece_trainer(_options), do: err()
  def trainers_wordlevel_trainer(_options), do: err()
  def trainers_unigram_trainer(_options), do: err()

  # Tokenizer
  def tokenizer_init(_model), do: err()
  def tokenizer_from_file(_path, _options), do: err()
  def tokenizer_from_buffer(_buffer, _options), do: err()
  def tokenizer_save(_tokenizer, _folder, _options), do: err()
  #
  def tokenizer_get_model(_tokenizer), do: err()
  def tokenizer_set_model(_tokenizer, _model), do: err()
  def tokenizer_get_normalizer(_tokenizer), do: err()
  def tokenizer_set_normalizer(_tokenizer, _normalizer), do: err()
  def tokenizer_get_pre_tokenizer(_tokenizer), do: err()
  def tokenizer_set_pre_tokenizer(_tokenizer, _pre_tokenizer), do: err()
  def tokenizer_get_post_processor(_tokenizer), do: err()
  def tokenizer_set_post_processor(_tokenizer, _post_processor), do: err()
  def tokenizer_get_decoder(_tokenizer), do: err()
  def tokenizer_set_decoder(_tokenizer, _decoder), do: err()
  def tokenizer_get_vocab(_tokenizer, _with_added_tokens), do: err()
  def tokenizer_get_vocab_size(_tokenizer, _with_added_tokens), do: err()
  def tokenizer_add_tokens(_tokenizer, _tokens), do: err()
  def tokenizer_add_special_tokens(_tokenizer, _tokens), do: err()
  def tokenizer_set_truncation(_tokenizer, _opts), do: err()
  def tokenizer_disable_truncation(_tokenizer), do: err()
  def tokenizer_set_padding(_tokenizer, _opts), do: err()
  def tokenizer_disable_padding(_tokenizer), do: err()
  #
  def tokenizer_encode(_tokenizer, _input, _options), do: err()
  def tokenizer_encode_batch(_tokenizer, _inputs, _options), do: err()
  def tokenizer_decode(_tokenizer, _ids, _options), do: err()
  def tokenizer_decode_batch(_tokenizer, _ids, _options), do: err()
  def tokenizer_token_to_id(_tokenizer, _token), do: err()
  def tokenizer_id_to_token(_tokenizer, _id), do: err()
  def tokenizer_post_processing(_tokenizer, _encoding, _pair, _add_special_tokens), do: err()
  #
  def tokenizer_train_from_files(_tokenizer, _files, _trainer), do: err()

  defp err(), do: :erlang.nif_error(:nif_not_loaded)
end
