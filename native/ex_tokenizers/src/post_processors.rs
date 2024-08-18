use rustler::NifTaggedEnum;
use serde::{Deserialize, Serialize};
use tokenizers::{Encoding, PostProcessorWrapper};

use crate::{new_info, util::Info};

pub struct ExTokenizersPostProcessorRef(pub PostProcessorWrapper);

#[derive(rustler::NifStruct)]
#[module = "Tokenizers.PostProcessor"]
pub struct ExTokenizersPostProcessor {
    pub resource: rustler::ResourceArc<ExTokenizersPostProcessorRef>,
}

impl ExTokenizersPostProcessorRef {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<PostProcessorWrapper>,
    {
        Self(data.into())
    }
}

impl ExTokenizersPostProcessor {
    pub fn new<T>(data: T) -> Self
    where
        T: Into<PostProcessorWrapper>,
    {
        Self {
            resource: rustler::ResourceArc::new(ExTokenizersPostProcessorRef::new(data)),
        }
    }
}

impl tokenizers::PostProcessor for ExTokenizersPostProcessor {
    fn added_tokens(&self, is_pair: bool) -> usize {
        self.resource.0.added_tokens(is_pair)
    }

    fn process_encodings(
        &self,
        encodings: Vec<Encoding>,
        add_special_tokens: bool,
    ) -> tokenizers::Result<Vec<Encoding>> {
        self.resource
            .0
            .process_encodings(encodings, add_special_tokens)
    }
}

impl Serialize for ExTokenizersPostProcessor {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        self.resource.0.serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for ExTokenizersPostProcessor {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        Ok(ExTokenizersPostProcessor::new(
            PostProcessorWrapper::deserialize(deserializer)?,
        ))
    }
}

impl Clone for ExTokenizersPostProcessor {
    fn clone(&self) -> Self {
        Self {
            resource: self.resource.clone(),
        }
    }
}

type ProcessorPair = (String, u32);

// /////////////////////////////////////////////////////////////////////////////
// / Inspection
// /////////////////////////////////////////////////////////////////////////////
#[rustler::nif]
fn post_processors_info(post_processor: ExTokenizersPostProcessor) -> Info {
    match &post_processor.resource.0 {
        PostProcessorWrapper::Roberta(_) => new_info![post_processor_type: "roberta"],
        PostProcessorWrapper::Bert(_) => new_info![post_processor_type: "bert"],
        PostProcessorWrapper::ByteLevel(_) => new_info![post_processor_type: "byte_level"],
        PostProcessorWrapper::Template(_) => new_info![post_processor_type: "template"],
        PostProcessorWrapper::Sequence(_) => new_info![post_processor_type: "sequence"],
    }
}

// /////////////////////////////////////////////////////////////////////////////
// / Implementation
// /////////////////////////////////////////////////////////////////////////////
#[rustler::nif]
pub fn post_processors_bert(sep: ProcessorPair, cls: ProcessorPair) -> ExTokenizersPostProcessor {
    ExTokenizersPostProcessor::new(tokenizers::processors::bert::BertProcessing::new(sep, cls))
}

#[derive(NifTaggedEnum)]
pub enum RobertaOption {
    TrimOffsets(bool),
    AddPrefixSpace(bool),
}

#[rustler::nif]
pub fn post_processors_roberta(
    sep: ProcessorPair,
    cls: ProcessorPair,
    opts: Vec<RobertaOption>,
) -> ExTokenizersPostProcessor {
    let mut proc = tokenizers::processors::roberta::RobertaProcessing::new(sep, cls);
    for opt in opts {
        match opt {
            RobertaOption::TrimOffsets(v) => proc = proc.trim_offsets(v),
            RobertaOption::AddPrefixSpace(v) => proc = proc.add_prefix_space(v),
        }
    }
    ExTokenizersPostProcessor::new(proc)
}

#[derive(NifTaggedEnum)]
pub enum ByteLevelOption {
    TrimOffsets(bool),
}

#[rustler::nif]
pub fn post_processors_byte_level(opts: Vec<ByteLevelOption>) -> ExTokenizersPostProcessor {
    let mut proc = tokenizers::processors::byte_level::ByteLevel::default();
    for opt in opts {
        match opt {
            ByteLevelOption::TrimOffsets(v) => proc = proc.trim_offsets(v),
        }
    }
    ExTokenizersPostProcessor::new(proc)
}

#[derive(NifTaggedEnum)]
pub enum TemplateOption {
    Single(String),
    Pair(String),
    SpecialTokens(Vec<(String, u32)>),
}

#[rustler::nif]
pub fn post_processors_template(
    opts: Vec<TemplateOption>,
) -> Result<ExTokenizersPostProcessor, rustler::Error> {
    let mut builder = tokenizers::processors::template::TemplateProcessing::builder();
    for opt in opts {
        match opt {
            TemplateOption::Single(v) => {
                builder.try_single(v).map_err(|_| rustler::Error::BadArg)?
            }
            TemplateOption::Pair(v) => builder.try_pair(v).map_err(|_| rustler::Error::BadArg)?,
            TemplateOption::SpecialTokens(v) => builder.special_tokens(v),
        };
    }
    Ok(ExTokenizersPostProcessor::new(
        builder.build().map_err(|_| rustler::Error::BadArg)?,
    ))
}

#[rustler::nif]
pub fn post_processors_sequence(
    post_processors: Vec<ExTokenizersPostProcessor>,
) -> ExTokenizersPostProcessor {
    ExTokenizersPostProcessor::new(tokenizers::processors::sequence::Sequence::new(
        post_processors
            .iter()
            .map(|pp| pp.resource.0.clone())
            .collect(),
    ))
}
