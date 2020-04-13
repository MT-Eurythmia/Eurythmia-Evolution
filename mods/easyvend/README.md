# Easy Vending Machines [`easyvend`]
Version: 1.0.1

Adds vending and depositing machines which allow to buy and sell items from
other players, using a currency item.

## Requirements
Runs natively in Minetest Game.

May also run in other games if they have the `default` mod and locked chest
(`default:chest_locked`).

Locked chests from other mods are not supported, but mods can choose
to add support for Easyvend on their own (see developer information below).

You can optionally add the `select_item` mod. This adds a button to select
an item from a list of items.
This feature is very useful for depositing machines because you can select
any item, not just those you have already in your inventory.

## How to use
Help is also included as help entry for Item Documentation [`doc_items`].

### Summary
Vending machines TAKE currency (gold ingots by default) and GIVE items
of the owner's choice.
Depositing machines GIVE currency and TAKE items of the owner's choice.

To operate your own machine, place a locked chest above or below and fill
it with items to exchange. If the green status LED (the upper one) lights
up, the machine is operational. You can stack these locked chests for
extended storage.

### Currency item
The currency of all machines is gold ingots by default.
But it can be changed via the setting `easyvend_currency`.



## Appendix
### Developer information
If you want to a container node compatible with vending/depositing machines,
use the Easyvend API, see the file `API.md`.

### Converting machines from `vendor` mod (experimental)
This mod is able to automatically transform the vending and depositing
machines from Bad\_Command\_'s Vending machines [`vendor`] mod on loading
and turn them into the new machines from `easyvend`. This is useful if
you want to switch a world from `vendor` to `easyvend`.

**WARNING**: This feature is experimental! It is advised to backup your world
before doing this. This feature is also incomplete; items are currently
**not** transformed in the process.

#### Conversion process
To transform all nodes from the `vendor` mod, disable the `vendor` mod (if
it is not already disabled), enable the setting `easyvend_convert_vendor`
and start or restart the game.

Now all nodes from the `vendor` mod will be replaced  with `easyvend` ones.

If you run a server, you should inform players of this change because a few
machines might need a reconfiguration.

#### Details
The machine configuration will be kept in the process and the machines will
stay in operation provided their configuration is valid. The mod tries to
keep as many machines in operation as possible. Machines with very high values
(item count or price) might be disabled because they exceed limits and must
be reconfigured by their owners. Most machines which worked before will likely
stay in operation afterwards.

### Credits and licenses
- Code
    - License: [LGPL 2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)
    - Source: Forked from mod “Vending Machines” [vendor] by Bad\_Command\_.
    - Authors: Bad\_Command\_ and Wuzzy
- Textures
    - License: MIT License
    - Author: Wuzzy
- Sounds
    - Any of the following licenses apply:
        - [CC-BY 3.0](https://creativecommons.org/licenses/by/3.0/)
        - [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/)
        - [GPL 3.0](https://www.gnu.org/licenses/gpl-3.0.html)
        - [GPL 2.0](https://www.gnu.org/licenses/old-licenses/gpl-2.0)
    - Original title of the work: “Inventory Sound Effects”
    - Source: [OpenGameArt](http://opengameart.org/content/inventory-sound-effects)
    - Authors: [OpenGameArt](http://opengameart.org/) user artisticdude, edited by Bad\_Command\_
