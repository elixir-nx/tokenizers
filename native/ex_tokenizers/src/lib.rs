mod added_token;
mod decoders;
mod encoding;
mod error;
mod models;
mod normalizers;
mod post_processors;
mod pre_tokenizers;
mod tokenizer;
mod trainers;
mod util;

use added_token::*;
use decoders::*;
use encoding::*;
use models::*;
use normalizers::*;
use post_processors::*;
use pre_tokenizers::*;
use rustler::{Env, Term};
use tokenizer::*;
use trainers::*;

pub use error::ExTokenizersError;

fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(ExTokenizersAddedTokenRef, env);
    rustler::resource!(ExTokenizersDecoderRef, env);
    rustler::resource!(ExTokenizersTokenizerRef, env);
    rustler::resource!(ExTokenizersEncodingRef, env);
    rustler::resource!(ExTokenizersTrainerRef, env);
    rustler::resource!(ExTokenizersModelRef, env);
    rustler::resource!(ExTokenizersNormalizerRef, env);
    rustler::resource!(ExTokenizersPostProcessorRef, env);
    rustler::resource!(ExTokenizersPreTokenizerRef, env);
    true
}

rustler::init!(
    "Elixir.Tokenizers.Native",
    [
        // AddedToken
        added_token_new,
        //
        added_token_info,
        // Decoders
        decoders_decode,
        //
        decoders_info,
        //
        decoders_byte_level,
        decoders_replace,
        decoders_wordpiece,
        decoders_byte_fallback,
        decoders_fuse,
        decoders_strip,
        decoders_metaspace,
        decoders_bpe,
        decoders_ctc,
        decoders_sequence,
        // Encoding
        encoding_get_length,
        encoding_get_n_sequences,
        encoding_set_sequence_id,
        encoding_get_ids,
        encoding_get_type_ids,
        encoding_get_attention_mask,
        encoding_get_special_tokens_mask,
        encoding_get_tokens,
        encoding_get_word_ids,
        encoding_get_sequence_ids,
        encoding_get_offsets,
        encoding_get_overflowing,
        encoding_word_to_tokens,
        encoding_word_to_chars,
        encoding_token_to_sequence,
        encoding_token_to_chars,
        encoding_token_to_word,
        encoding_char_to_token,
        encoding_char_to_word,
        encoding_pad,
        encoding_truncate,
        // Models
        models_save,
        //
        models_info,
        //
        models_bpe_init,
        models_bpe_empty,
        models_bpe_from_file,
        //
        models_wordpiece_init,
        models_wordpiece_empty,
        models_wordpiece_from_file,
        //
        models_wordlevel_init,
        models_wordlevel_empty,
        models_wordlevel_from_file,
        //
        models_unigram_init,
        models_unigram_empty,
        // Normalizers
        normalizers_normalize,
        //
        normalizers_info,
        //
        normalizers_bert_normalizer,
        normalizers_nfd,
        normalizers_nfkd,
        normalizers_nfc,
        normalizers_nfkc,
        normalizers_strip,
        normalizers_prepend,
        normalizers_strip_accents,
        normalizers_sequence,
        normalizers_lowercase,
        normalizers_replace,
        normalizers_nmt,
        normalizers_precompiled,
        // PreTokenizers
        pre_tokenizers_pre_tokenize,
        //
        pre_tokenizers_info,
        //
        pre_tokenizers_byte_level,
        pre_tokenizers_byte_level_alphabet,
        pre_tokenizers_whitespace,
        pre_tokenizers_whitespace_split,
        pre_tokenizers_bert,
        pre_tokenizers_metaspace,
        pre_tokenizers_char_delimiter_split,
        pre_tokenizers_split,
        pre_tokenizers_punctuation,
        pre_tokenizers_sequence,
        pre_tokenizers_digits,
        // PostProcessors
        post_processors_info,
        //
        post_processors_bert,
        post_processors_roberta,
        post_processors_byte_level,
        post_processors_template,
        post_processors_sequence,
        // Trainers
        trainers_info,
        //
        trainers_train,
        //
        trainers_bpe_trainer,
        trainers_wordpiece_trainer,
        trainers_wordlevel_trainer,
        trainers_unigram_trainer,
        // Tokenizer
        tokenizer_init,
        tokenizer_from_file,
        tokenizer_from_buffer,
        tokenizer_save,
        //
        tokenizer_get_model,
        tokenizer_set_model,
        tokenizer_get_normalizer,
        tokenizer_set_normalizer,
        tokenizer_get_pre_tokenizer,
        tokenizer_set_pre_tokenizer,
        tokenizer_get_post_processor,
        tokenizer_set_post_processor,
        tokenizer_get_decoder,
        tokenizer_set_decoder,
        tokenizer_get_vocab,
        tokenizer_get_vocab_size,
        tokenizer_add_tokens,
        tokenizer_add_special_tokens,
        tokenizer_set_truncation,
        tokenizer_disable_truncation,
        tokenizer_set_padding,
        tokenizer_disable_padding,
        //
        tokenizer_encode,
        tokenizer_encode_batch,
        tokenizer_decode,
        tokenizer_decode_batch,
        tokenizer_token_to_id,
        tokenizer_id_to_token,
        tokenizer_post_processing,
        //
        tokenizer_train_from_files,
    ],
    load = on_load
);
