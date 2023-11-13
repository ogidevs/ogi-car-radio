local Translations = {
    options = {
        name = 'Radio Options',
        volume_label = "Volume",
        volume_help = "Change the volume of the radio",
        volume_icon = "volume-high",
        custom_url_label = "Custom URL",
        custom_url_help = "Enter a custom youtube URL to play in the radio",
        custom_url_icon = "youtube",
    },
}


Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
