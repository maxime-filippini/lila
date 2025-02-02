import gleam/io
import gleam/string
import youid/uuid

pub fn main() {
  uuid.v4_string() |> string.lowercase |> io.println
}
