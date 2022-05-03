use std::collections::HashMap;

use rustler::NifUntaggedEnum;
use tokenizers::ModelWrapper;

use crate::error::ExTokenizersError;

pub struct ExTokenizersModelRef(pub ModelWrapper);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.Model"]
pub struct ExTokenizersModel {
    pub resource: rustler::resource::ResourceArc<ExTokenizersModelRef>,
}

impl ExTokenizersModelRef {
    pub fn new(data: ModelWrapper) -> Self {
        Self(data)
    }
}

impl ExTokenizersModel {
    pub fn new(data: ModelWrapper) -> Self {
        Self {
            resource: rustler::resource::ResourceArc::new(ExTokenizersModelRef::new(data)),
        }
    }
}

#[derive(NifUntaggedEnum)]
pub enum ModelDetailValue {
    String(String),
    OptionString(Option<String>),
    OptionNumber(Option<f32>),
    Bool(bool),
    F64(f64),
    USize(usize),
}

#[rustler::nif]
pub fn get_model_details(
    model: ExTokenizersModel,
) -> Result<HashMap<String, ModelDetailValue>, ExTokenizersError> {
    Ok(match &model.resource.0 {
        ModelWrapper::BPE(model) => HashMap::from([
            (
                String::from("model_type"),
                ModelDetailValue::String(String::from("bpe")),
            ),
            (
                String::from("dropout"),
                ModelDetailValue::OptionNumber(model.dropout),
            ),
            (
                String::from("unk_token"),
                ModelDetailValue::OptionString(model.unk_token.clone()),
            ),
            (
                String::from("continuing_subword_prefix"),
                ModelDetailValue::OptionString(model.continuing_subword_prefix.clone()),
            ),
            (
                String::from("end_of_word_suffix"),
                ModelDetailValue::OptionString(model.end_of_word_suffix.clone()),
            ),
            (
                String::from("fuse_unk"),
                ModelDetailValue::Bool(model.fuse_unk),
            ),
        ]),
        ModelWrapper::WordPiece(model) => HashMap::from([
            (
                String::from("model_type"),
                ModelDetailValue::String(String::from("bpe")),
            ),
            (
                String::from("unk_token"),
                ModelDetailValue::String(model.unk_token.clone()),
            ),
            (
                String::from("continuing_subword_prefix"),
                ModelDetailValue::String(model.continuing_subword_prefix.clone()),
            ),
            (
                String::from("max_input_chars_per_word"),
                ModelDetailValue::USize(model.max_input_chars_per_word),
            ),
        ]),
        ModelWrapper::WordLevel(model) => HashMap::from([
            (
                String::from("model_type"),
                ModelDetailValue::String(String::from("bpe")),
            ),
            (
                String::from("unk_token"),
                ModelDetailValue::String(model.unk_token.clone()),
            ),
        ]),
        ModelWrapper::Unigram(model) => HashMap::from([
            (
                String::from("model_type"),
                ModelDetailValue::String(String::from("bpe")),
            ),
            (
                String::from("min_score"),
                ModelDetailValue::F64(model.min_score),
            ),
        ]),
    })
}
