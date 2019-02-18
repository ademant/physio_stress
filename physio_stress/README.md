[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
# Minetest Mod: Physio_Stress

See license.txt for license information.

Works only with Minetest >= 5.0

Minetest <= 0.4.17 does not support the mechanism for handling player related meta data.

## Short Description
Physio-Stress is a mod providing following physiological enhancements:
- Sunburn
- Nyctophoby (Angst of darkness)
- hunger
- thirst
- exhaustion due to fast working

A main feature compared with other mods is the storage of relevant information in the player metadata not in mod space. For this the API of the mod xpfw is used, providing functions to handle player relevant data.

## Sunburn/Nyctophoby:
Each player can adjust to the actual light. Too fast changes in light leads to a kind of shock.
With the actual light amount a rolling mean value is calculated. Is the actual light level too high or too low compared with the rolling mean value, a shock is produced, leading to decreasing hit points.
The threshold is bigger if the player has at least one armor (from 3d_armor) as sun protection.
New player joining the game has a delay time, where sunburn/nyctophoby has no harm. In this time the rolling mean value establish.

## hunger/thirst:
Similar to other mods hunger (saturation) and thirst is implemented using the player metadata for storing.
The item_eat routine is rewritten to give the hp to field saturation instead HP.
If an item has the definition value "drink_hp" this value will be added to the thirst value.
An item like an apple can increase saturation and thirst level at the same time.
Saturation and thirst will decrease by time, walking, swimming, digging, crafting and building. For this the statistics from xpfw is used. Per time step the changes are used to calculate a decreasing of saturation and thirst.
For digging a correction is applied: A kind of hardness of the node is estimated from the value of the groups "choppy", "crumbly", "snappy" and "cracky". Digging harder nodes (higher values) lead to higher drain of saturation and thirst. Also digging a cracky node lead to highest drain, while digging other nodes lead to less drain.

## Exhaustion:
By mod xpfw several speeds are measured: Walking, Swimming, Digging, building and crafting. Out of this speed a kind of exhaustion is calculated.

## Authors of source code

ademant (MIT)

## Authors of media (textures)
  
Created by ademant (CC BY 3.0):

## Authors of media (sound)

  eat_generic:	copied from mod hbhunger (https://github.com/creatively-survival/hbhunger)
