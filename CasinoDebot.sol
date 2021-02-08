pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import "./Debot.sol";


interface Casino {
    function singleBet(uint8 number) external view;
    function dozenBet(uint8 number) external view;
    function columnBet(uint8 number) external view;
    function greatSmallBet(bool isGreat) external view;
    function parityBet(bool isEven) external view;
    function colorBet(bool isRed) external view;
    function getSeed() external view;
    function withdrawBenefits() external view;
    function receiveFunds() external pure;
}

interface CasinoClient {
    function receiveAnswer(uint8 code, uint128 comment) external;
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

    uint8 m_numberBetSing;
    uint8 m_numberBetDoz;
    uint64 m_numberBetColumn;
    uint64 m_numberBetColor;
    uint64 m_numberBetGS;
    uint64 m_numberBetPar;

    uint8 m_numberBetSingValue;
    uint64 m_numberBetDozValue;
    uint64 m_numberBetColumnValue;
    uint64 m_numberBetColorValue;
    uint64 m_numberBetGSValue;
    uint64 m_numberBetParValue;

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
            ActionRun("Hello, please enter the storage address ", "enterStorageAddress", STATE_MAIN),
            ActionPrint("Quit", "quit", STATE_EXIT)
            ]));

        // optional(string) args;
        optional(string) fargs;
        contexts.push(Context(STATE_MAIN,
            "Bet menu:", [
            ActionGoto("Single - bet on the single number from 0 to 36", STATE_BET_SINGLE),
            ActionGoto("Dozen - bet on the dozen of numbers: from 1 to 12, 13-...-24, 25-...-36", STATE_BET_DOZEN),
            ActionGoto("Column - bet on the column of numbers: 1-4-...-34, 2-5-...-35, 3-6-...-36", STATE_BET_COLUMN),
            ActionGoto("Great/Small - bet on righteen numbers: from 1 to 18 or from 19 to 36", STATE_BET_GS),
            ActionGoto("Even/Odd - bet on all even or odd numbers", STATE_BET_PARITY),
            ActionGoto("Red/Black - bet on all red or black numbers", STATE_BET_COLOR),
            ActionGoto("Return to set address", STATE_ZERO),
            ActionGoto("Check last result", STATE_CHECK),
            ActionPrint("Quit", "quit", STATE_EXIT) ] ));
        contexts.push(Context(STATE_BET_SINGLE,
            "", [
            ActionRun("Enter bet value", "enterNumBetSingleValue", STATE_BET_SINGLE2),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));
        contexts.push(Context(STATE_BET_SINGLE2,
            "", [
            ActionRun("Enter number for bet", "enterNumBetSingle", STATE_BET_SINGLE3),
            ActionGoto("Return to bet menu", STATE_MAIN),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));
            
        contexts.push(Context(STATE_BET_SINGLE3,
            "Are you sure?", [
            ActionSendMsg("Yes", "sendSubmitMsgBetSingle", "sign=by_user", STATE_MENU),
            ActionGoto("Return to main menu", STATE_MAIN),
            ActionGoto("Return to set address", STATE_ZERO),
            ActionPrint("Quit", "Bye!", STATE_EXIT) ] ));

        fargs.set("getVal");

        contexts.push(Context(STATE_CHECK,
            "Exit or not?", [
            // ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", STATE_CURRENT),
            ActionPrintEx("", "Code: {}\nComment: {}\nCasino: {}", true, fargs, STATE_CURRENT),
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

    function getVal() public view returns (uint8 number0, uint128 number1, address casino) {
        number0 = m_lastCode;
        number1 = m_lastComment;
        casino = m_casino;
    }

    receive() external pure {}

    function enterNumBetSingle(uint8 numb) public accept {
        m_numberBetSing = numb;
    }

    function sendSubmitMsgBetSingle() public accept view returns (address dest, TvmCell body) {
        // dest = m_target.get();
        dest = m_casino;

        // body = tvm.encodeBody(Casino.singleBet, m_casino, m_numberBetSing,  m_numberBetSingValue);//Casino.singleBet m_casino, 
        // CasinoClient(msg.sender).singleBet{value: m_numberBetSingValue}(m_numberBetSing);
        
        // первый вариант транзакции
        body = tvm.encodeBody(Casino.singleBet, m_numberBetSing);        
        dest.transfer({value:m_numberBetSingValue, body:body});

        // второй вариант транзакции
        // CasinoClient(msg.sender).singleBet{value: m_numberBetSingValue}(m_numberBetSing);
    }        


    function enterNumBetSingleValue(uint8 numb) public accept {
        m_numberBetSingValue = numb;
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
