# Easy Vending Machines [`easyvend`]
Version: 0.4.3

Adds vending and depositing machines which allow to buy and sell items from other players.

Help is included as help entry for Item Documentation [`doc_items`].

## Converting machines from `vendor` mod (experimental)
This mod is able to automatically transform the vending and depositing
machines from Bad\_Command\_'s Vending machines [`vendor`] mod on loading
and turn them into the new machines from `easyvend`. This is useful if
you want to switch a world from `vendor` to `easyvend`.

**WARNING**: This feature is experimental! It is advised to backup your world
before doing this. This feature is also incomplete; items are currently
**not** transformed in the process.

### Conversion process
To transform all nodes from the `vendor` mod, disable the `vendor` mod (if
it is not already disabled), enable the setting `easyvend_convert_vendor`
and start or restart the game.

Now all nodes from the `vendor` mod will be replaced  with `easyvend` ones.

If you run a server, you should inform players of this change because a few
machines might need a reconfiguration.

### Details
The machine configuration will be kept in the process and the machines will
stay in operation provided their configuration is valid. The mod tries to
keep as many machines in operation as possible. Machines with very high values
(item count or price) might be disabled because they exceed limits and must
be reconfigured by their owners. Most machines which worked before will likely
stay in operation afterwards.

## Credits and licenses
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
