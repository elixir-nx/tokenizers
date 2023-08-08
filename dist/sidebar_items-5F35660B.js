sidebarNodes={"extras":[{"group":"","headers":[{"anchor":"modules","id":"Modules"}],"id":"api-reference","title":"API Reference"},{"group":"","headers":[{"anchor":"setup","id":"Setup"},{"anchor":"get-a-tokenizer","id":"Get a tokenizer"},{"anchor":"save-and-load","id":"Save and load"},{"anchor":"check-the-tokenizer","id":"Check the tokenizer"},{"anchor":"encode-and-decode","id":"Encode and decode"},{"anchor":"get-a-tensor","id":"Get a tensor"}],"id":"pretrained","title":"Pretrained tokenizers"},{"group":"","headers":[{"anchor":"intro","id":"Intro"},{"anchor":"downloading-the-data","id":"Downloading the data"},{"anchor":"training-the-tokenizer-from-scratch","id":"Training the tokenizer from scratch"},{"anchor":"using-the-tokenizer","id":"Using the tokenizer"},{"anchor":"post-processing","id":"Post-processing"},{"anchor":"encoding-multiple-sentences-in-a-batch","id":"Encoding multiple sentences in a batch"}],"id":"training","title":"Training custom tokenizer"},{"group":"","headers":[],"id":"license","title":"LICENSE"}],"modules":[{"deprecated":false,"group":"","id":"Tokenizers","sections":[],"title":"Tokenizers"},{"deprecated":false,"group":"Tokenization","id":"Tokenizers.Decoder","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"bpe/1","deprecated":false,"id":"bpe/1","title":"bpe(opts \\\\ [])"},{"anchor":"byte_fallback/0","deprecated":false,"id":"byte_fallback/0","title":"byte_fallback()"},{"anchor":"byte_level/0","deprecated":false,"id":"byte_level/0","title":"byte_level()"},{"anchor":"ctc/1","deprecated":false,"id":"ctc/1","title":"ctc(opts \\\\ [])"},{"anchor":"decode/2","deprecated":false,"id":"decode/2","title":"decode(decoder, tokens)"},{"anchor":"fuse/0","deprecated":false,"id":"fuse/0","title":"fuse()"},{"anchor":"metaspace/1","deprecated":false,"id":"metaspace/1","title":"metaspace(opts \\\\ [])"},{"anchor":"replace/2","deprecated":false,"id":"replace/2","title":"replace(pattern, content)"},{"anchor":"sequence/1","deprecated":false,"id":"sequence/1","title":"sequence(decoders)"},{"anchor":"strip/3","deprecated":false,"id":"strip/3","title":"strip(content, left, right)"},{"anchor":"word_piece/1","deprecated":false,"id":"word_piece/1","title":"word_piece(opts \\\\ [])"}]}],"sections":[],"title":"Tokenizers.Decoder"},{"deprecated":false,"group":"Tokenization","id":"Tokenizers.Encoding","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"char_to_token/3","deprecated":false,"id":"char_to_token/3","title":"char_to_token(encoding, position, seq_id)"},{"anchor":"char_to_word/3","deprecated":false,"id":"char_to_word/3","title":"char_to_word(encoding, position, seq_id)"},{"anchor":"get_attention_mask/1","deprecated":false,"id":"get_attention_mask/1","title":"get_attention_mask(encoding)"},{"anchor":"get_ids/1","deprecated":false,"id":"get_ids/1","title":"get_ids(encoding)"},{"anchor":"get_length/1","deprecated":false,"id":"get_length/1","title":"get_length(encoding)"},{"anchor":"get_n_sequences/1","deprecated":false,"id":"get_n_sequences/1","title":"get_n_sequences(encoding)"},{"anchor":"get_offsets/1","deprecated":false,"id":"get_offsets/1","title":"get_offsets(encoding)"},{"anchor":"get_overflowing/1","deprecated":false,"id":"get_overflowing/1","title":"get_overflowing(encoding)"},{"anchor":"get_sequence_ids/1","deprecated":false,"id":"get_sequence_ids/1","title":"get_sequence_ids(encoding)"},{"anchor":"get_special_tokens_mask/1","deprecated":false,"id":"get_special_tokens_mask/1","title":"get_special_tokens_mask(encoding)"},{"anchor":"get_tokens/1","deprecated":false,"id":"get_tokens/1","title":"get_tokens(encoding)"},{"anchor":"get_type_ids/1","deprecated":false,"id":"get_type_ids/1","title":"get_type_ids(encoding)"},{"anchor":"get_u32_attention_mask/1","deprecated":false,"id":"get_u32_attention_mask/1","title":"get_u32_attention_mask(encoding)"},{"anchor":"get_u32_ids/1","deprecated":false,"id":"get_u32_ids/1","title":"get_u32_ids(encoding)"},{"anchor":"get_u32_special_tokens_mask/1","deprecated":false,"id":"get_u32_special_tokens_mask/1","title":"get_u32_special_tokens_mask(encoding)"},{"anchor":"get_u32_type_ids/1","deprecated":false,"id":"get_u32_type_ids/1","title":"get_u32_type_ids(encoding)"},{"anchor":"get_word_ids/1","deprecated":false,"id":"get_word_ids/1","title":"get_word_ids(encoding)"},{"anchor":"n_tokens/1","deprecated":false,"id":"n_tokens/1","title":"n_tokens(encoding)"},{"anchor":"pad/3","deprecated":false,"id":"pad/3","title":"pad(encoding, target_length, opts \\\\ [])"},{"anchor":"set_sequence_id/2","deprecated":false,"id":"set_sequence_id/2","title":"set_sequence_id(encoding, id)"},{"anchor":"token_to_chars/2","deprecated":false,"id":"token_to_chars/2","title":"token_to_chars(encoding, token)"},{"anchor":"token_to_sequence/2","deprecated":false,"id":"token_to_sequence/2","title":"token_to_sequence(encoding, token)"},{"anchor":"token_to_word/2","deprecated":false,"id":"token_to_word/2","title":"token_to_word(encoding, token)"},{"anchor":"truncate/3","deprecated":false,"id":"truncate/3","title":"truncate(encoding, max_length, opts \\\\ [])"},{"anchor":"word_to_chars/3","deprecated":false,"id":"word_to_chars/3","title":"word_to_chars(encoding, word, seq_id)"},{"anchor":"word_to_tokens/3","deprecated":false,"id":"word_to_tokens/3","title":"word_to_tokens(encoding, word, seq_id)"}]}],"sections":[],"title":"Tokenizers.Encoding"},{"deprecated":false,"group":"Tokenization","id":"Tokenizers.Tokenizer","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:encode_input/0","deprecated":false,"id":"encode_input/0","title":"encode_input()"},{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"loading","name":"Loading","nodes":[{"anchor":"from_buffer/2","deprecated":false,"id":"from_buffer/2","title":"from_buffer(data, opts \\\\ [])"},{"anchor":"from_file/2","deprecated":false,"id":"from_file/2","title":"from_file(path, opts \\\\ [])"},{"anchor":"from_pretrained/2","deprecated":false,"id":"from_pretrained/2","title":"from_pretrained(identifier, opts \\\\ [])"},{"anchor":"save/3","deprecated":false,"id":"save/3","title":"save(tokenizer, path, opts \\\\ [])"}]},{"key":"inference","name":"Inference","nodes":[{"anchor":"decode/3","deprecated":false,"id":"decode/3","title":"decode(tokenizer, ids, opts \\\\ [])"},{"anchor":"decode_batch/3","deprecated":false,"id":"decode_batch/3","title":"decode_batch(tokenizer, sentences, opts \\\\ [])"},{"anchor":"encode/3","deprecated":false,"id":"encode/3","title":"encode(tokenizer, input, opts \\\\ [])"},{"anchor":"encode_batch/3","deprecated":false,"id":"encode_batch/3","title":"encode_batch(tokenizer, input, opts \\\\ [])"},{"anchor":"id_to_token/2","deprecated":false,"id":"id_to_token/2","title":"id_to_token(tokenizer, id)"},{"anchor":"token_to_id/2","deprecated":false,"id":"token_to_id/2","title":"token_to_id(tokenizer, token)"}]},{"key":"configuration","name":"Configuration","nodes":[{"anchor":"add_special_tokens/2","deprecated":false,"id":"add_special_tokens/2","title":"add_special_tokens(tokenizer, tokens)"},{"anchor":"add_tokens/2","deprecated":false,"id":"add_tokens/2","title":"add_tokens(tokenizer, tokens)"},{"anchor":"disable_padding/1","deprecated":false,"id":"disable_padding/1","title":"disable_padding(tokenizer)"},{"anchor":"disable_truncation/1","deprecated":false,"id":"disable_truncation/1","title":"disable_truncation(tokenizer)"},{"anchor":"get_decoder/1","deprecated":false,"id":"get_decoder/1","title":"get_decoder(tokenizer)"},{"anchor":"get_model/1","deprecated":false,"id":"get_model/1","title":"get_model(tokenizer)"},{"anchor":"get_normalizer/1","deprecated":false,"id":"get_normalizer/1","title":"get_normalizer(tokenizer)"},{"anchor":"get_post_processor/1","deprecated":false,"id":"get_post_processor/1","title":"get_post_processor(tokenizer)"},{"anchor":"get_pre_tokenizer/1","deprecated":false,"id":"get_pre_tokenizer/1","title":"get_pre_tokenizer(tokenizer)"},{"anchor":"get_vocab/2","deprecated":false,"id":"get_vocab/2","title":"get_vocab(tokenizer, opts \\\\ [])"},{"anchor":"get_vocab_size/2","deprecated":false,"id":"get_vocab_size/2","title":"get_vocab_size(tokenizer, opts \\\\ [])"},{"anchor":"init/1","deprecated":false,"id":"init/1","title":"init(model)"},{"anchor":"set_decoder/2","deprecated":false,"id":"set_decoder/2","title":"set_decoder(tokenizer, decoder)"},{"anchor":"set_model/2","deprecated":false,"id":"set_model/2","title":"set_model(tokenizer, model)"},{"anchor":"set_normalizer/2","deprecated":false,"id":"set_normalizer/2","title":"set_normalizer(tokenizer, normalizer)"},{"anchor":"set_padding/2","deprecated":false,"id":"set_padding/2","title":"set_padding(tokenizer, opts)"},{"anchor":"set_post_processor/2","deprecated":false,"id":"set_post_processor/2","title":"set_post_processor(tokenizer, post_processor)"},{"anchor":"set_pre_tokenizer/2","deprecated":false,"id":"set_pre_tokenizer/2","title":"set_pre_tokenizer(tokenizer, pre_tokenizer)"},{"anchor":"set_truncation/2","deprecated":false,"id":"set_truncation/2","title":"set_truncation(tokenizer, opts \\\\ [])"}]},{"key":"training","name":"Training","nodes":[{"anchor":"train_from_files/3","deprecated":false,"id":"train_from_files/3","title":"train_from_files(tokenizer, paths, opts \\\\ [])"}]}],"sections":[],"title":"Tokenizers.Tokenizer"},{"deprecated":false,"group":"Pipeline","id":"Tokenizers.Normalizer","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"bert_normalizer/1","deprecated":false,"id":"bert_normalizer/1","title":"bert_normalizer(opts \\\\ [])"},{"anchor":"lowercase/0","deprecated":false,"id":"lowercase/0","title":"lowercase()"},{"anchor":"nfc/0","deprecated":false,"id":"nfc/0","title":"nfc()"},{"anchor":"nfd/0","deprecated":false,"id":"nfd/0","title":"nfd()"},{"anchor":"nfkc/0","deprecated":false,"id":"nfkc/0","title":"nfkc()"},{"anchor":"nfkd/0","deprecated":false,"id":"nfkd/0","title":"nfkd()"},{"anchor":"nmt/0","deprecated":false,"id":"nmt/0","title":"nmt()"},{"anchor":"normalize/2","deprecated":false,"id":"normalize/2","title":"normalize(normalizer, input)"},{"anchor":"precompiled/1","deprecated":false,"id":"precompiled/1","title":"precompiled(data)"},{"anchor":"prepend/1","deprecated":false,"id":"prepend/1","title":"prepend(prepend)"},{"anchor":"replace/2","deprecated":false,"id":"replace/2","title":"replace(pattern, content)"},{"anchor":"sequence/1","deprecated":false,"id":"sequence/1","title":"sequence(normalizers)"},{"anchor":"strip/1","deprecated":false,"id":"strip/1","title":"strip(opts \\\\ [])"},{"anchor":"strip_accents/0","deprecated":false,"id":"strip_accents/0","title":"strip_accents()"}]}],"sections":[],"title":"Tokenizers.Normalizer"},{"deprecated":false,"group":"Pipeline","id":"Tokenizers.PostProcessor","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"bert/2","deprecated":false,"id":"bert/2","title":"bert(sep, cls)"},{"anchor":"byte_level/1","deprecated":false,"id":"byte_level/1","title":"byte_level(opts \\\\ [])"},{"anchor":"roberta/3","deprecated":false,"id":"roberta/3","title":"roberta(sep, cls, opts \\\\ [])"},{"anchor":"sequence/1","deprecated":false,"id":"sequence/1","title":"sequence(post_processors)"},{"anchor":"template/1","deprecated":false,"id":"template/1","title":"template(opts \\\\ [])"}]}],"sections":[],"title":"Tokenizers.PostProcessor"},{"deprecated":false,"group":"Pipeline","id":"Tokenizers.PreTokenizer","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:split_delimiter_behaviour/0","deprecated":false,"id":"split_delimiter_behaviour/0","title":"split_delimiter_behaviour()"},{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"bert_pre_tokenizer/0","deprecated":false,"id":"bert_pre_tokenizer/0","title":"bert_pre_tokenizer()"},{"anchor":"byte_level/1","deprecated":false,"id":"byte_level/1","title":"byte_level(opts \\\\ [])"},{"anchor":"byte_level_alphabet/0","deprecated":false,"id":"byte_level_alphabet/0","title":"byte_level_alphabet()"},{"anchor":"char_delimiter_split/1","deprecated":false,"id":"char_delimiter_split/1","title":"char_delimiter_split(delimiter)"},{"anchor":"digits/1","deprecated":false,"id":"digits/1","title":"digits(opts \\\\ [])"},{"anchor":"metaspace/1","deprecated":false,"id":"metaspace/1","title":"metaspace(opts \\\\ [])"},{"anchor":"pre_tokenize/2","deprecated":false,"id":"pre_tokenize/2","title":"pre_tokenize(pre_tokenizer, input)"},{"anchor":"punctuation/1","deprecated":false,"id":"punctuation/1","title":"punctuation(behaviour)"},{"anchor":"sequence/1","deprecated":false,"id":"sequence/1","title":"sequence(pre_tokenizers)"},{"anchor":"split/3","deprecated":false,"id":"split/3","title":"split(pattern, behavior, opts \\\\ [])"},{"anchor":"whitespace/0","deprecated":false,"id":"whitespace/0","title":"whitespace()"},{"anchor":"whitespace_split/0","deprecated":false,"id":"whitespace_split/0","title":"whitespace_split()"}]}],"sections":[],"title":"Tokenizers.PreTokenizer"},{"deprecated":false,"group":"Training","id":"Tokenizers.AddedToken","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"info/1","deprecated":false,"id":"info/1","title":"info(model)"},{"anchor":"new/2","deprecated":false,"id":"new/2","title":"new(token, opts \\\\ [])"}]}],"sections":[],"title":"Tokenizers.AddedToken"},{"deprecated":false,"group":"Training","id":"Tokenizers.Model","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"info/1","deprecated":false,"id":"info/1","title":"info(model)"},{"anchor":"save/3","deprecated":false,"id":"save/3","title":"save(model, directory, opts \\\\ [])"}]}],"sections":[],"title":"Tokenizers.Model"},{"deprecated":false,"group":"Training","id":"Tokenizers.Model.BPE","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:options/0","deprecated":false,"id":"options/0","title":"options()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"empty/0","deprecated":false,"id":"empty/0","title":"empty()"},{"anchor":"from_file/3","deprecated":false,"id":"from_file/3","title":"from_file(vocab_path, merges_path, options \\\\ [])"},{"anchor":"init/3","deprecated":false,"id":"init/3","title":"init(vocab, merges, options \\\\ [])"}]}],"sections":[],"title":"Tokenizers.Model.BPE"},{"deprecated":false,"group":"Training","id":"Tokenizers.Model.Unigram","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:options/0","deprecated":false,"id":"options/0","title":"options()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"empty/0","deprecated":false,"id":"empty/0","title":"empty()"},{"anchor":"init/2","deprecated":false,"id":"init/2","title":"init(vocab, options \\\\ [])"}]}],"sections":[],"title":"Tokenizers.Model.Unigram"},{"deprecated":false,"group":"Training","id":"Tokenizers.Model.WordLevel","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:options/0","deprecated":false,"id":"options/0","title":"options()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"empty/0","deprecated":false,"id":"empty/0","title":"empty()"},{"anchor":"from_file/2","deprecated":false,"id":"from_file/2","title":"from_file(vocab_path, options \\\\ [])"},{"anchor":"init/2","deprecated":false,"id":"init/2","title":"init(vocab, options \\\\ [])"}]}],"sections":[],"title":"Tokenizers.Model.WordLevel"},{"deprecated":false,"group":"Training","id":"Tokenizers.Model.WordPiece","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:options/0","deprecated":false,"id":"options/0","title":"options()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"empty/0","deprecated":false,"id":"empty/0","title":"empty()"},{"anchor":"from_file/2","deprecated":false,"id":"from_file/2","title":"from_file(vocab_path, options \\\\ [])"},{"anchor":"init/2","deprecated":false,"id":"init/2","title":"init(vocab, options \\\\ [])"}]}],"sections":[],"title":"Tokenizers.Model.WordPiece"},{"deprecated":false,"group":"Training","id":"Tokenizers.Trainer","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:bpe_options/0","deprecated":false,"id":"bpe_options/0","title":"bpe_options()"},{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"},{"anchor":"t:unigram_options/0","deprecated":false,"id":"unigram_options/0","title":"unigram_options()"},{"anchor":"t:wordlevel_options/0","deprecated":false,"id":"wordlevel_options/0","title":"wordlevel_options()"},{"anchor":"t:wordpiece_options/0","deprecated":false,"id":"wordpiece_options/0","title":"wordpiece_options()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"bpe/1","deprecated":false,"id":"bpe/1","title":"bpe(options \\\\ [])"},{"anchor":"info/1","deprecated":false,"id":"info/1","title":"info(trainer)"},{"anchor":"unigram/1","deprecated":false,"id":"unigram/1","title":"unigram(options \\\\ [])"},{"anchor":"wordlevel/1","deprecated":false,"id":"wordlevel/1","title":"wordlevel(options \\\\ [])"},{"anchor":"wordpiece/1","deprecated":false,"id":"wordpiece/1","title":"wordpiece(options \\\\ [])"}]}],"sections":[],"title":"Tokenizers.Trainer"},{"deprecated":false,"group":"Other","id":"Tokenizers.HTTPClient","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"request/1","deprecated":false,"id":"request/1","title":"request(opts)"}]}],"sections":[],"title":"Tokenizers.HTTPClient"}],"tasks":[]}