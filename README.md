# casino-debot


../solc CasinoDebot.sol 
../tvm_linker compile CasinoDebot.code --abi-json ./CasinoDebot.abi.json -o ./CasinoDebot.tvc --lib ../stdlib_sol.tvm
../tonos-cli genaddr CasinoDebot.tvc CasinoDebot.abi.json --genkey CasinoDebot.keys.json

Seed phrase: "month lyrics outside govern maze weekend jazz carbon denial debris crime tomato"

Raw address: 0:e960363afd4ffffba2c426ed2766a7f799419c14d86e201d7f0902576722f487

<!-- ../tonos-cli call 0:9c89d6ad4649ed289f858c5fd24adbff65b22587275c93f348f93b7663ecd569 sendTransaction '{"dest":"0:fa29986308d451b37cf7c568967c45e9dbdeca066f32d107641107b08a206478", "value":1000000000, "bounce":false}' --abi Wallet.abi.json --sign key.json -->



smc_abi=$(cat CasinoClient.abi.json | xxd -ps -c 20000)
<!-- smc_abi=$(cat Casino.abi.json | xxd -ps -c 20000) -->
debot_abi=$(cat CasinoDebot.abi.json | xxd -ps -c 20000)
zero_address=0:0000000000000000000000000000000000000000000000000000000000000000


../tonos-cli deploy CasinoDebot.tvc "{\"casino\":\"0:9a00bf5de1311dfb4f10e01766874606430cf0ca8b34038719991e917be9b5d8\",\"options\":0,\"debotAbi\":\"\",\"targetAddr\":\"$zero_address\",\"targetAbi\":\"\"}" --sign CasinoDebot.keys.json --abi CasinoDebot.abi.json


../tonos-cli call 0:e960363afd4ffffba2c426ed2766a7f799419c14d86e201d7f0902576722f487 setTargetABI "{\"tabi\":\"$smc_abi\"}" --sign CasinoDebot.keys.json --abi CasinoDebot.abi.json

../tonos-cli call 0:e960363afd4ffffba2c426ed2766a7f799419c14d86e201d7f0902576722f487 setABI "{\"dabi\":\"$debot_abi\"}" --sign CasinoDebot.keys.json --abi CasinoDebot.abi.json
## ========== debot run ================
../tonos-cli debot fetch 0:e960363afd4ffffba2c426ed2766a7f799419c14d86e201d7f0902576722f487


#### =================CasinoClient==============================
Seed phrase: "motor explain mirror heart script arrange brief radar fancy excite put great"
Raw address: 0:d94cd40b995b238104f8c748f4d3795b8a332cc3f17d07a24fcc6beeacea7338

#### ===========Casino.abi.json============
Seed phrase: "burger actor unusual live curtain penalty pet image cup crew easily capital"
Raw address: 0:9a00bf5de1311dfb4f10e01766874606430cf0ca8b34038719991e917be9b5d8

#### CasinoOwner.abi.json
#### =============================================
Seed phrase: "drip crop gap glad eager cry alarm shaft bridge guide body fish"
Raw address: 0:3b19ac2fccb1c6823be554ec8d8f7afbf776bb3b6dcdf543de30e4dd6ec8199e
