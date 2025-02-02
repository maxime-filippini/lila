import gleam/int
import lila/language.{type Language, Croatian, English, French}

pub fn lila_s_baby_list(lang: Language) -> String {
  case lang {
    English -> "Lila's baby list"
    Croatian -> "Popis za Lilu"
    French -> "La liste de naissance de Lila"
  }
}

pub fn thank_you(lang: Language) -> String {
  case lang {
    English -> "Thank you very much for helping us!"
    Croatian -> "Hvala ti puno što nam pomažeš!"
    French -> "Merci beaucoup pour votre aide!"
  }
}

pub fn i_am_interested(lang: Language) -> String {
  case lang {
    English -> "Interested"
    Croatian -> "Zainteresiran(a)"
    French -> "Intéressé(e)"
  }
}

pub fn i_am_no_longer_interested(lang: Language) -> String {
  case lang {
    English -> "No longer interested"
    Croatian -> "Nisam zainteresiran(a)"
    French -> "Plus intéressé(e)"
  }
}

pub fn i_will_buy(lang: Language) -> String {
  case lang {
    English -> "Will buy"
    Croatian -> "Kupit ću"
    French -> "Va acheter"
  }
}

pub fn i_need_more_info(lang: Language) -> String {
  case lang {
    English -> "Need more information"
    Croatian -> "Treba mi više informacija"
    French -> "Besoin d'informations"
  }
}

pub fn if_problem_contact_me(lang: Language) -> String {
  case lang {
    English -> "For support, please contact "
    French -> "Besoin d'aide? Contactez "
    Croatian -> "Trebate pomoć? Kontaktirajte "
  }
}

pub fn name(lang: Language) -> String {
  case lang {
    English -> "Name"
    French -> "Nom"
    Croatian -> "Ime"
  }
}

pub fn email(lang: Language) -> String {
  case lang {
    English -> "Email address"
    French -> "Adresse email"
    Croatian -> "Email adresa"
  }
}

pub fn confirm(lang: Language) -> String {
  case lang {
    English -> "Confirm"
    French -> "Confirmer"
    Croatian -> "Potvrdi"
  }
}

pub fn we_need_your_info(lang: Language) -> String {
  case lang {
    French -> "Nous avons besoin de votre nom avant de continuer"
    Croatian -> "Pogledajte opcije"
    English -> "Provide your info before continuing"
  }
}

pub fn i_need_more_info_on_item(lang: Language) -> String {
  case lang {
    English -> "I need information for item "
    Croatian -> "Trebam informacije o "
    French -> "J'ai besoin de plus amples informations sur "
  }
}

pub fn people_in_waitlist(lang: Language, multiple multiple: Bool) -> String {
  let people = case lang, multiple {
    English, True -> "people"
    English, False -> "person"
    French, True -> "personnes"
    French, False -> "personne"
    Croatian, True -> "osobe"
    Croatian, False -> "osoba"
  }

  case lang {
    Croatian -> people <> " na listi čekanja"
    English -> people <> " in the waiting list"
    French -> people <> " dans la liste d'attente"
  }
}

pub fn position_in_waitlist(lang: Language, n: Int) -> String {
  let n_str = int.to_string(n)

  case lang {
    Croatian -> "Vi ste br. " <> n_str
    English -> "You are #" <> n_str
    French -> "Vous êtes n°" <> n_str
  }
}

pub fn put_me_on_waitlist(lang: Language) -> String {
  case lang {
    Croatian -> "Dodaj me na listu čekanja"
    English -> "Add me to the waiting list"
    French -> "Mettez moi sur la liste d'attente"
  }
}

pub fn cancel_my_participation(lang: Language) -> String {
  case lang {
    Croatian -> "Otkaži moje sudjelovanje"
    English -> "Cancel my participation"
    French -> "Annuler ma participation"
  }
}
