# Easy Vending Machines [`easyvend`]
Version: 0.1.1

Adds vending and depositing machines which allow to buy and sell items from other players.

Help is included as help entry for Item Documentation [`doc_items`].

## Converting machines from `vendor` mod (experimental)
This mod is able to automatically transform the vending and depositing
machines from Bad\_Command_'s Vending machines [`vendor`] mod on loading
and turn them into the new machines from `easyvend`. This is useful if
you want to switch a world from `vendor` to `easyvend`.

**WARNING**: This feature is experimental! It is advised to backup your world
before doing this. This feature is also incomplete;

### Conversion process
To transform all nodes from the `vendor` mod, enable the `easyvend` mod
and disable the `vendor` mod, then load the world. Now all nodes from
the vendor mod will be replaced by the new machines from `easyvend`.

If you run a server, inform players of the change after loading the world with
the new nodes.

### Details
The machine configuration will be kept in the process and the machines will
stay in operation provided their configuration is valid. The mod tries to
keep as many machines in operation as possible. Machines with very high values
(item count or price) might be disabled because they exceed limits and must
be reconfigured by their owners. Most machines which worked before will likely
stay in operation afterwards.

