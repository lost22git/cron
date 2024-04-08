import gleam/string_builder

/// remove all whitespaces in string
///
/// whitespaces include: [" ", "\t"]
///
pub fn remove_whitespaces(s: String) -> String {
  string_builder.from_string(s)
  |> string_builder.replace(" ", "")
  |> string_builder.replace("\t", "")
  |> string_builder.to_string()
}
