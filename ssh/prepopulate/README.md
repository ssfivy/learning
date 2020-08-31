# Prepopulate

Generate SSH keys for two machines,
and configure them so that one can seamlessly connect to the other.

Pregenerating private key might sound iffy.
Here I am generating keys specifically so the two machines can perform SSH tunneling.
They aren't used for anything else.
Proof of concept, so probably still has iffyness in heaps.


# Usage

run `prepopulate.sh --generate` to pregenerate all the keys.

run `prepopulate.sh --serverinstall` to populate the server machine. **WARNING: Will overwrite ssh server keys!**
run `prepopulate.sh --clientinstall` to populate the client machine.

run `prepopulate.sh --connect` to create the ssh connection (it's a normal forward tunnel)
