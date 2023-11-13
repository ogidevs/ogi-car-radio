local Translations = {
    options = {
        name = 'Radio Podesavanja',
        volume_label = "Zvuk",
        volume_help = "Promeni zvuk radija",
        volume_icon = "volume-high",
        custom_url_label = "Youtube URL",
        custom_url_help = "Unesi youtube URL da pustis na radiju",
        custom_url_icon = "youtube",
    },
}


Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
