defmodule Tokenizers.Native do
  use Rustler,
    otp_app: :tokenizers,
    crate: :ex_tokenizers

  def decode(_tokenizer, _ids, _skip_special_tokens), do: err()
  def decode_batch(_tokenizer, _ids, _skip_special_tokens), do: err()
  def encode(_tokenizer, _input, _add_special_tokens), do: err()
  def encode_batch(_tokenizer, _input, _add_special_tokens), do: err()
  def from_file(_path), do: err()
  def from_pretrained(_identifier), do: err()
  def get_ids(_encoding), do: err()
  def get_tokens(_encoding), do: err()
  def get_vocab(_tokenizer, _with_added_tokens), do: err()
  def get_vocab_size(_tokenizer, _with_added_tokens), do: err()
  def id_to_token(_tokenizer, _id), do: err()
  def save(_tokenizer, _path, _pretty), do: err()
  def token_to_id(_tokenizer, _token), do: err()
  defp err(), do: :erlang.nif_error(:nif_not_loaded)
end
