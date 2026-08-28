module SocialHelper
  # Her presence elsewhere, in the order it is worth finding: the accounts she
  # posts to most first, the separate Red Timia project after them, and the
  # personal profile last. `icon` names a glyph in shared/_social_icon.
  def social_links
    [
      { label: "Instagram",  icon: :instagram, url: "https://www.instagram.com/doc.mfdiiorio/" },
      { label: "YouTube",    icon: :youtube,   url: "https://www.youtube.com/@mariaflorenciadiiorio8" },
      { label: "Spotify",    icon: :spotify,   url: "https://open.spotify.com/show/6lzzOTVUqmSCkhlQmZMJkG" },
      { label: "Facebook",   icon: :facebook,  url: "https://www.facebook.com/doc.mfdiiorio/" },
      { label: "Red Timia",  icon: :instagram, url: "https://www.instagram.com/redtimia/" },
      { label: t("footer.facebook_personal"), icon: :facebook,
        url: "https://www.facebook.com/florencia.diiorio.7/" }
    ]
  end
end
