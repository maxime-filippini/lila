pub type Language {
  English
  Croatian
  French
}

pub fn to_iso(lang: Language) -> String {
  case lang {
    English -> "en"
    Croatian -> "hr"
    French -> "fr"
  }
}

pub fn from_iso(s: String) -> Result(Language, Nil) {
  case s {
    "en" -> Ok(English)
    "hr" -> Ok(Croatian)
    "fr" -> Ok(French)
    _ -> Error(Nil)
  }
}
