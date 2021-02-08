# casino-debot


../solc CasinoDebot.sol 
../tvm_linker compile CasinoDebot.code --abi-json ./CasinoDebot.abi.json --lib ../stdlib_sol.tvm
../tonos-cli genaddr CasinoDebot.tvc CasinoDebot.abi.json --genkey CasinoDebot.keys.json

Seed phrase: "casual book napkin horse drastic polar gold fever anger brave romance orchard"
Raw address: 0:ffe416f77aa2664b26e657827c02fefd6367635a7a7ab4049dbfaf7cf91377a8