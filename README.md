
My Discord: ogidev

<details>
    <summary><b>What is this resource?</b></summary>
        <p>
            This is a <b>FIVEM</b> vehicle radio script which keeps the original gta 5 radio look with the ability to change stations name, sound (as radios for example) and picture (hud.ytd -> change textures using open iv for example)
            Changing the radios sound and name is easily done through fxmanifest.lua
            Vehicle radios are synced between players and can be heard outside of the vehicles (distance is based on volume)
        </p>
</details>

# Installation steps

## General Setup

1. SHOWCASE: https://streamable.com/xo5yu6
2. Huge inspiration: https://forum.cfx.re/t/release-js-radio/52121

## Dependencies

1. qb-core (https://github.com/search?q=qbcore&type=repositories)
2. ox_lib - for the options menu (https://github.com/overextended/ox_lib)
3. xsound (https://github.com/Xogy/xsound)

## Installation

1. Download the resource, put it in your resources folder, ensure it and then do the following:
2. Locate config.lua > availableRadios, this list provides a complete list of radios that are available in GTA 5
3. Locate fxmanifest.lua
4. Add / Remove radios like shown in the examples. (Do not remove the radio with url = "options", you will lose the options menu on the radio wheel)
5. NOTE: URLs must be https://...

## Features

1. Fully synced radios between players
2. Radios can be heard outside of the vehicles that have their engines on
3. 0.00 - 0.01 CPU usage
4. Multi-Language Support using QBCore Locales
5. 24/7 Support on discord

![Screenshot](https://cdn.discordapp.com/attachments/1173699009806860308/1173699010482151454/image.png?ex=6564e762&is=65527262&hm=3581b96296c25881a8c668c6c528f5f5ffe977d2aca730bfc762661a4546fea7&)

## Bugs

If you encounter any bug, please feel free to reach out to me on discord (ogidev)

## TODO

1. ~~Add support for ESX~~
2. ~~Add support for different inputs~~
3. ~~Refactoring / Optimisations~~

## YOUR PART

1. Feel free to do PRs
### CONTRIBUTIONS

Big thanks to tsfs (discord) for rewritting the lang and adding support for ESX 