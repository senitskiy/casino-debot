pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import "./Debot.sol";
// import "./CasinoDebotInterfaces.sol";

interface ICasino {
    function singleBet(uint8 number) external view;
    function dozenBet(uint8 number) external view;
    function columnBet(uint8 number) external view;
    function greatSmallBet(uint8 isGreat) external view;
    function parityBet(uint8 isEven) external view;
    function colorBet(uint8 isRed) external view;
    function getSeed() external view;
    function withdrawBenefits() external view;
    function receiveFunds() external pure;
}

interface ICasinoClient {
    // function transfer(address dest, uint128 tokens, uint128 grams) external functionID(0x000000c);

    function receiveAnswer(uint8 code, uint128 comment) external;

    function bet(uint128 value, uint8 number) external;
    function betDozen(uint128 value, uint8 number) external;
    function betColumn(uint128 value, uint8 number) external;
    function betColor(uint128 value, bool isRed) external;
    function betGreatSmall(uint128 value, bool isGreat) external;
    function betParity(uint128 value, bool isEven) external;

    
    function getVal() external returns (uint8 code, uint128 comment, address casino);
}

// interface Casino {
//     function singleBet(uint256 bet_) external;
//     function getValue() external returns (uint256 val);
// }

contract CasinoDebot is Debot, DError {
    
    address m_casino;
    uint8 public m_lastCode;
    uint128 public m_lastComment;

    constructor(address casino, uint8 options, string debotAbi, string targetAbi, address targetAddr) public {
        require(tvm.pubkey() != 0, 103);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        init(options, debotAbi, targetAbi, targetAddr);
        m_casino = casino;
    }
    uint8 constant STATE_MAIN = 1;
    uint8 constant STATE_PRE_MAIN = 12;
    uint8 constant STATE_MENU       =13;
    uint8 constant STATE_BET_SINGLE = 22;
    uint8 constant STATE_BET_SINGLE2 = 23;
    uint8 constant STATE_BET_SINGLE3 = 24;

    uint8 constant STATE_BET_DOZEN = 25;
    uint8 constant STATE_BET_DOZEN2 = 26;
    uint8 constant STATE_BET_DOZEN3 = 27;

    uint8 constant STATE_BET_COLUMN = 28;
    uint8 constant STATE_BET_COLUMN2 = 29;
    uint8 constant STATE_BET_COLUMN3 = 30;

    uint8 constant STATE_BET_COLOR = 31;
    uint8 constant STATE_BET_COLOR2 = 32;
    uint8 constant STATE_BET_COLOR3 = 33;

    uint8 constant STATE_BET_GS = 34;
    uint8 constant STATE_BET_GS2 = 35;
    uint8 constant STATE_BET_GS3 = 36;
    uint8 constant STATE_BET_PARITY = 37;
    uint8 constant STATE_BET_PARITY2 = 38;
    uint8 constant STATE_BET_PARITY3 = 39;
    uint8 constant STATE_CHECK = 50;


    modifier accept() {
        tvm.accept();
        _;
    }

    uint8   m_numberBetSing;
    uint8   m_numberBetDozen;
    uint8   m_numberBetColumn;
    uint8   m_numberBetColor;
    uint8   m_numberBetGS;
    uint8   m_numberBetParity;

    uint128 m_BetValue;
    // uint64 m_numberBetDozValue;
    // uint64 m_numberBetColumnValue;
    // uint64 m_numberBetColorValue;
    // uint64 m_numberBetGSValue;
    // uint64 m_numberBetParValue;

    function setABI(string dabi) public {
        require(tvm.pubkey() == msg.pubkey(), 100);
        tvm.accept();
        m_debotAbi.set(dabi);
        m_options |= DEBOT_ABI;
    }

    function setTargetABI(string tabi) public {
        require(tvm.pubkey() == msg.pubkey(), 100);
        tvm.accept();
        m_targetAbi.set(tabi);
        m_options |= DEBOT_TARGET_ABI;
    }

    function fetch() public override accept returns (Context[] contexts){
        contexts.push(Context(STATE_ZERO,
            "", [
            ActionRun("Hello, please enter your address for play in CASINO.", "enterStorageAddress", STATE_MAIN),
            ActionPrint("Quit", "quit", STATE_EXIT)
            ]));

        // optional(string) args;
        optional(string) fargs;
        optional(string) fargs2;
        
        fargs.set("parseCasinoAddress");
        // fargs2.set("getValInner");

        contexts.push(Context(STATE_MAIN,
            "Bet menu:", [
            ActionPrintEx("", "Address Casino: {}", true, fargs, STATE_CURRENT),
            // ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", true, fargs2, STATE_CURRENT),
            ActionGoto("Single - bet on the single number from 0 to 36", STATE_BET_SINGLE),
            ActionGoto("Dozen - bet on the dozen of numbers: from 1 to 12, 13-...-24, 25-...-36", STATE_BET_DOZEN),
            ActionGoto("Column - bet on the column of numbers: 1-4-...-34, 2-5-...-35, 3-6-...-36", STATE_BET_COLUMN),
            ActionGoto("Great/Small - bet on righteen numbers: from 1 to 18 or from 19 to 36", STATE_BET_GS),
            ActionGoto("Even/Odd - bet on all even or odd numbers", STATE_BET_PARITY),
            ActionGoto("Red/Black - bet on all red or black numbers", STATE_BET_COLOR),
            ActionGoto("Return to set address", STATE_ZERO),
            ActionGoto("Check last result", STATE_CHECK),
            ActionPrint("Quit", "quit", STATE_EXIT) ] ));

        //STATE_BET_SINGLE
        contexts.push(Context(STATE_BET_SINGLE,
            "", [
            ActionRun("Enter bet value", "enterBet", STATE_BET_SINGLE2),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));
        
        contexts.push(Context(STATE_BET_SINGLE2,
            "", [
            ActionRun("Single! Enter single number from 0 to 36", "enterNumBetSingle", STATE_BET_SINGLE3),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));

        contexts.push(Context(STATE_BET_SINGLE3,
            "Are you sure?", [
            // ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", true, fargs, STATE_CURRENT),    
            ActionSendMsg("Yes", "sendSubmitMsgBetSingle", "sign=by_user", STATE_MENU),
            ActionGoto("Return to main menu", STATE_MAIN),
            ActionGoto("Return to set address", STATE_ZERO),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));        

        //STATE_BET_DOZEN 
        contexts.push(Context(STATE_BET_DOZEN,
            "", [
            ActionRun("Enter bet value", "enterBet", STATE_BET_DOZEN2),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));    

        contexts.push(Context(STATE_BET_DOZEN2,
            "", [
            ActionRun("Dozen! Enter dozen of numbers: from 1 to 12, 13-...-24, 25-...-36 [exm:1,2,3]", "enterNumBetDozen", STATE_BET_DOZEN3),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));        

        contexts.push(Context(STATE_BET_DOZEN3,
            "Are you sure?", [
            // ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", true, fargs, STATE_CURRENT),    
            ActionSendMsg("Yes", "sendSubmitMsgBetDozen", "sign=by_user", STATE_MENU),
            ActionGoto("Return to main menu", STATE_MAIN),
            ActionGoto("Return to set address", STATE_ZERO),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));

        //STATE_BET_COLUMN
        contexts.push(Context(STATE_BET_COLUMN,
            "", [
            ActionRun("Enter bet value", "enterBet", STATE_BET_COLUMN2),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));    

        contexts.push(Context(STATE_BET_COLUMN2,
            "", [
            ActionRun("Column! Enter column of numbers: from 1 to 12, 13-...-24, 25-...-36 [exm:1,2,3]", "enterNumBetColumn", STATE_BET_COLUMN3),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));   

        contexts.push(Context(STATE_BET_COLUMN3,
            "Are you sure?", [
            // ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", true, fargs, STATE_CURRENT),    
            ActionSendMsg("Yes", "sendSubmitMsgBetColumn", "sign=by_user", STATE_MENU),
            ActionGoto("Return to main menu", STATE_MAIN),
            ActionGoto("Return to set address", STATE_ZERO),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));

        //STATE_BET_GS
        contexts.push(Context(STATE_BET_GS,
            "", [
            ActionRun("Enter bet value", "enterBet", STATE_BET_GS2),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));    

        contexts.push(Context(STATE_BET_GS2,
            "", [
            ActionRun("Great/Small! Enter righteen numbers: from 1 to 18 [Small:0] or from 19 to 36.[Great:1]", "enterNumBetGS", STATE_BET_GS3),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));   

        contexts.push(Context(STATE_BET_GS3,
            "Are you sure?", [
            // ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", true, fargs, STATE_CURRENT),    
            ActionSendMsg("Yes", "sendSubmitMsgBetGreatSmall", "sign=by_user", STATE_MENU),
            ActionGoto("Return to main menu", STATE_MAIN),
            ActionGoto("Return to set address", STATE_ZERO),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));

        //STATE_BET_PARITY
        contexts.push(Context(STATE_BET_PARITY,
            "", [
            ActionRun("Enter bet value", "enterBet", STATE_BET_PARITY2),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));    

        contexts.push(Context(STATE_BET_PARITY2,
            "", [
            ActionRun("Even/Odd! Even or odd numbers. [even = 1; odd = 0", "enterNumBetPARITY", STATE_BET_PARITY3),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));   

        contexts.push(Context(STATE_BET_PARITY3,
            "Are you sure?", [
            // ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", true, fargs, STATE_CURRENT),    
            ActionSendMsg("Yes", "sendSubmitMsgBetParity", "sign=by_user", STATE_MENU),
            ActionGoto("Return to main menu", STATE_MAIN),
            ActionGoto("Return to set address", STATE_ZERO),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));

        //STATE_BET_COLOR
        contexts.push(Context(STATE_BET_COLOR,
            "", [
            ActionRun("Enter bet value", "enterBet", STATE_BET_COLOR2),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));    

        contexts.push(Context(STATE_BET_COLOR2,
            "", [
            ActionRun("COLOR! Red or black numbers [Red:true; black:false]", "enterNumBetCOLOR", STATE_BET_COLOR3),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));   

        contexts.push(Context(STATE_BET_COLOR3,
            "Are you sure?", [
            // ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", true, fargs, STATE_CURRENT),    
            ActionSendMsg("Yes", "sendSubmitMsgBetColor", "sign=by_user", STATE_MENU),
            ActionGoto("Return to main menu", STATE_MAIN),
            ActionGoto("Return to set address", STATE_ZERO),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));

        // fargs.set("getVal");

        contexts.push(Context(STATE_CHECK,
            "Exit or not?", [
            // ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", STATE_CURRENT),
            // ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", true, fargs, STATE_CURRENT),
            ActionGoto("Return to main menu", STATE_MAIN),
            ActionGoto("Return to set address", STATE_ZERO),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));

    }

    function enterStorageAddress(address addr) public accept {
        m_target.set(addr);
        m_options |= DEBOT_TARGET_ADDR;
    }

    function setCasino(address casino) public accept {
        m_casino = casino;
    }
    // Callback function to get answer from the casino.
    function receiveAnswer(uint8 code, uint128 comment) public {    //override
        require(msg.sender == m_casino, 101);
        tvm.accept();
        m_lastCode = code;
        m_lastComment = comment;
    }

    // function getValInner() public view returns (address dest, TvmCell body) {

    //     dest = m_target;

    //     body = tvm.encodeBody(ICasinoClient.getVal,);

    // }

    receive() external pure {}


    function enterNumBetSingle(uint8 number) public accept {
        m_numberBetSing = number;
    }

    function enterNumBetDozen(uint8 number) public accept {
        m_numberBetDozen = number;
    }

    function enterNumBetColumn(uint8 number) public accept {
        m_numberBetColumn = number;
    }

    function enterNumBetGS(uint8 isGreat) public accept {
        m_numberBetGS = isGreat;
    }

    function enterNumBetPARITY(uint8 isEven) public accept {
        m_numberBetParity = isEven;
    }

    function enterNumBetCOLOR(uint8 isRed) public accept {
        m_numberBetColor = isRed;
    }                    


    function parseNumBetSingle() public view accept returns (uint8 number0) {
        number0 = m_numberBetSing;
    }

    function parseNumBetDozen() public view accept returns (uint8 number0) {
        number0 = m_numberBetDozen;
    }

    function parseNumBetColumn() public view accept returns (uint8 number0) {
        number0 = m_numberBetColumn;
    }

    function parseNumBetGS() public view accept returns (uint184 number0) {
        number0 = m_numberBetGS;
    }

    function parseNumBetParity() public view accept returns (uint8 number0) {
        number0 = m_numberBetParity;
    }

    function parseNumBetColor() public view accept returns (uint8 number0) {
        number0 = m_numberBetColor;
    }                


    function parseCasinoAddress() public view accept returns (address param0) {
        param0 = m_casino;
    }

    // function bet(uint128 value, uint8 number) public view onlyOwner {
    //     ICasino(m_casino).singleBet{value: value}(number);
    // }

    // function sendSubmitMsg() public accept view returns (address dest, TvmCell body) {
    //     dest = m_target.get();
    //     body = tvm.encodeBody(ITONTokenWallet.transfer, m_dest, m_tokens, m_grams);
    // }

//    function sendSubmitMsg() public accept view returns (address dest, TvmCell body) {
//         dest = m_target.get();
//         body = tvm.encodeBody(Storage.storeValue, m_numberFromStorage);
//     }

    // function getNumFromStorage() public view accept returns (address dest, TvmCell body) {
    //     dest = m_target.get();
    //     body = tvm.encodeBody(Storage.getNumber);
    //     Storage(dest).getNumber();
    // }

    function sendSubmitMsgBetSingle() public accept view returns (address dest, TvmCell body) {
        // dest = m_target.get();
        dest = m_target;

        body = tvm.encodeBody(ICasinoClient.bet, m_BetValue, m_numberBetSing);//Casino.singleBet m_casino, ICasino.singleBet, m_casino, m_numberBetSing,  m_BetValue
        // ICasino(msg.sender).singleBet{value: m_BetValue}(m_numberBetSing);
        // ICasino(dest).singleBet{value: m_BetValue}(m_numberBetSing);
        
        // первый вариант транзакции
        // body = tvm.encodeBody(Casino.singleBet, m_numberBetSing);        
        // dest.transfer({value:m_BetValue, body:body});

        // второй вариант транзакции
        // Casino(msg.sender).singleBet{value: m_BetValue}(m_numberBetSing);

        // третий вариант
        // ICasino(m_casino).singleBet{value: m_BetValue}(m_numberBetSing);

    }

    function sendSubmitMsgBetDozen() public accept view returns (address dest, TvmCell body) {

        // body = tvm.encodeBody(ICasino.singleBet, m_numberBetSing);
        // ICasino(m_casino).dozenBet{value: m_BetValue}(m_numberBetDozen);
        //ICasino(m_casino).dozenBet{value: value}(number); 
        ICasinoClient(m_casino).betDozen(m_BetValue, m_numberBetDozen);
    }

    function sendSubmitMsgBetColumn() public accept view returns (address dest, TvmCell body) {

        body = tvm.encodeBody(ICasino.singleBet, m_numberBetColumn);
        ICasino(m_casino).columnBet{value: m_BetValue}(m_numberBetColumn);
        // ICasino(m_casino).columnBet{value: value}(number);
    }

    function sendSubmitMsgBetGreatSmall() public accept view returns (address dest, TvmCell body) {

        // body = tvm.encodeBody(ICasino.singleBet, m_numberBetGS);
        ICasino(m_casino).greatSmallBet{value: m_BetValue}(m_numberBetGS);
        
        // ICasino(m_casino).greatSmallBet{value: value}(isGreat);
    }

    function sendSubmitMsgBetParity() public accept view returns (address dest, TvmCell body) {

        // body = tvm.encodeBody(ICasino.singleBet, m_numberBetParity);
        ICasino(m_casino).parityBet{value: m_BetValue}(m_numberBetParity);
        // ICasino(m_casino).parityBet{value: value}(isEven);
    }

    function sendSubmitMsgBetColor() public accept view returns (address dest, TvmCell body) {
        // dest = m_target.get();
        dest = m_target;

        // body = tvm.encodeBody(ICasino.singleBet, m_numberBetColor);//Casino.singleBet m_casino, ICasino.singleBet, m_casino, m_numberBetSing,  m_BetValue
        // ICasino(msg.sender).singleBet{value: m_BetValue}(m_numberBetSing);
        ICasino(dest).colorBet{value: m_BetValue}(m_numberBetColor);
        // ICasino(m_casino).colorBet{value: value}(isRed);
        // betColor(uint128 value, bool isRed) 

    }
           
    // function getNumFromStorage() public view accept returns (address dest, TvmCell body) {
    //     dest = m_target.get();
    //     body = tvm.encodeBody(Storage.getNumber);
    //     Storage(dest).getNumber();
    // }

    function enterBet(uint128 numb) public accept {
        m_BetValue = numb;
    }

    function getVersion() public override accept returns (string name, uint24 semver) {
        name = "Casino DeBot";
        semver = (1 << 8);
    }



    function start() public override accept {}

    function quit() public override accept {}

    uint32 constant ERROR_ZERO_ADDRESS = 1001;
    uint32 constant ERROR_AMOUNT_TOO_LOW = 1002;
    uint32 constant ERROR_TOO_MANY_CUSTODIANS = 1003;
    uint32 constant ERROR_INVALID_CONFIRMATIONS = 1004;
    uint32 constant ERROR_AMOUNT_TOO_BIG = 1005;

    function getErrorDescription(uint32 error) public pure override returns (string desc) {
        if (error == ERROR_ZERO_ADDRESS) {
            return "recipient address can't be zero";
        } else if (error == ERROR_AMOUNT_TOO_LOW) {
            return "amount must be greater or equal than 0.001 tons";
        } else if (error == ERROR_TOO_MANY_CUSTODIANS) {
            return "custodian count must be less than 32";
        } else if (error == ERROR_INVALID_CONFIRMATIONS) {
            return "number of confirmations must be less than number of custodians";
        } else if (error == ERROR_AMOUNT_TOO_BIG) {
            return "amount is bigger than wallet balance";
        }
        return "unknown exception";
    }

}
