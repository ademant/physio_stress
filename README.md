[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
# Physio stress modpack

## Short description
Providing following mods:
- physio_stress, using xpfs to provide hunger, thirst, exhaustion, sunburn and nyctophoby
- ph_integrate, integration of physio_stress with several other mods

## Not so short description
### physio_stress
Using the storage mechanism of mod XPFW, new attributes for each player are registered, providing hunger, thirst, exhaustion, sunburn and nyctophoby.

While working, walking, swimming etc. the hunger and thirst level decrease. Mining harder nodes decrease hunger faster than digging soft materials. The coefficients are choosen so that the player should drink more often than to eat.

The eating function is overridden to enable thirst mechanism. Food, which have also water content stored, can be used to recreate thirst level.

Sunburn can occur in full daylight without protection or by hard change of light level. Teleporting from a dark mine into full daylight will hurt you till you adjust to the new level.
Any kind of armor helps to protect against sunburn.

Same for nyctophoby, which is not testet fully, so it is disabled by default.

### ph_integrate
Extend items of other mods for usage with physio_stress. Mainly add water content to some food.

## Authors of source code

ademant (MIT)


## Authors of media (textures)
---------------------------
