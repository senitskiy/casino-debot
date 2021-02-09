# casino-debot


../solc CasinoDebot.sol 
../tvm_linker compile CasinoDebot.code --abi-json ./CasinoDebot.abi.json -o ./CasinoDebot.tvc --lib ../stdlib_sol.tvm
../tonos-cli genaddr CasinoDebot.tvc CasinoDebot.abi.json --genkey CasinoDebot.keys.json

Seed phrase: "unknown diesel rain lumber kit nuclear icon erosion spice vocal corn gadget"

Raw address: 0:b816823c87d3159ba7114aa01af8b6250c8dfe819db64019b5908d1a3326c0ca

../tonos-cli call 0:9c89d6ad4649ed289f858c5fd24adbff65b22587275c93f348f93b7663ecd569 sendTransaction '{"dest":"0:fa29986308d451b37cf7c568967c45e9dbdeca066f32d107641107b08a206478", "value":1000000000, "bounce":false}' --abi Wallet.abi.json --sign key.json



smc_abi=$(cat CasinoClient.abi.json | xxd -ps -c 20000)
<!-- smc_abi=$(cat Casino.abi.json | xxd -ps -c 20000) -->
debot_abi=$(cat CasinoDebot.abi.json | xxd -ps -c 20000)
zero_address=0:0000000000000000000000000000000000000000000000000000000000000000


../tonos-cli deploy CasinoDebot.tvc "{\"casino\":\"0:3c8045f1b815bebe42e4531c5e0585dfe675e4bee9b2822be7f36ccc83ba4ec1\",\"options\":0,\"debotAbi\":\"\",\"targetAddr\":\"$zero_address\",\"targetAbi\":\"\"}" --sign CasinoDebot.keys.json --abi CasinoDebot.abi.json


../tonos-cli call 0:b816823c87d3159ba7114aa01af8b6250c8dfe819db64019b5908d1a3326c0ca setTargetABI "{\"tabi\":\"$smc_abi\"}" --sign CasinoDebot.keys.json --abi CasinoDebot.abi.json

../tonos-cli call 0:b816823c87d3159ba7114aa01af8b6250c8dfe819db64019b5908d1a3326c0ca setABI "{\"dabi\":\"$debot_abi\"}" --sign CasinoDebot.keys.json --abi CasinoDebot.abi.json

../tonos-cli debot fetch 0:b816823c87d3159ba7114aa01af8b6250c8dfe819db64019b5908d1a3326c0ca
