# casino-debot


../solc CasinoDebot.sol 
../tvm_linker compile CasinoDebot.code --abi-json ./CasinoDebot.abi.json --lib ../stdlib_sol.tvm
../tonos-cli genaddr CasinoDebot.tvc CasinoDebot.abi.json --genkey CasinoDebot.keys.json

Seed phrase: "casual book napkin horse drastic polar gold fever anger brave romance orchard"
Raw address: 0:ffe416f77aa2664b26e657827c02fefd6367635a7a7ab4049dbfaf7cf91377a8

./tonos-cli call 0:9c89d6ad4649ed289f858c5fd24adbff65b22587275c93f348f93b7663ecd569 sendTransaction '{"dest":"0:54d6f30e1a734033024c15d6072a136c85e225707653004f5137f81a6f087f77", "value":1000000000, "bounce":false}' --abi Wallet.abi.json --sign key.json

./tonos-cli genaddr CasinoDebot.tvc CasinoDebot.abi.json --genkey botkey.keys.json


smc_abi=$(cat Casino.abi.json | xxd -ps -c 20000)
debot_abi=$(cat CasinoDebot.abi.json | xxd -ps -c 20000)
zero_address=0:0000000000000000000000000000000000000000000000000000000000000000


./tonos-cli deploy CasinoDebot.tvc "{\"casino\":\"0:3c8045f1b815bebe42e4531c5e0585dfe675e4bee9b2822be7f36ccc83ba4ec1\",\"options\":0,\"debotAbi\":\"\",\"targetAddr\":\"$zero_address\",\"targetAbi\":\"\"}" --sign botkey.keys.json --abi CasinoDebot.abi.json


./tonos-cli call 0:b63f16620d17fec4bbea35d5f438885f05ee0f5c6ed1aaf7514a054a87c42ca9 setTargetABI "{\"tabi\":\"$smc_abi\"}" --sign botkey.keys.json --abi CasinoDebot.abi.json

./tonos-cli call 0:b63f16620d17fec4bbea35d5f438885f05ee0f5c6ed1aaf7514a054a87c42ca9 setABI "{\"dabi\":\"$debot_abi\"}" --sign botkey.keys.json --abi CasinoDebot.abi.json

./tonos-cli debot fetch 0:54d6f30e1a734033024c15d6072a136c85e225707653004f5137f81a6f087f77
