pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
import "./Debot.sol";

contract CasinoDebot is Debot {
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
    uint8 constant STATE_BET_SINGLE = 2;
    uint8 constant STATE_BET_SINGLE2 = 3;
    uint8 constant STATE_BET_SINGLE3 = 4;

    uint8 constant STATE_BET_DOZEN = 5;
    uint8 constant STATE_BET_DOZEN2 = 6;
    uint8 constant STATE_BET_DOZEN3 = 7;

    uint8 constant STATE_BET_COLUMN = 8;
    uint8 constant STATE_BET_COLUMN2 = 9;
    uint8 constant STATE_BET_COLUMN3 = 10;

    uint8 constant STATE_BET_COLOR = 11;
    uint8 constant STATE_BET_COLOR2 = 12;
    uint8 constant STATE_BET_COLOR3 = 13;

    uint8 constant STATE_BET_GS = 14;
    uint8 constant STATE_BET_GS2 = 15;
    uint8 constant STATE_BET_GS3 = 16;
    uint8 constant STATE_BET_PARITY = 17;
    uint8 constant STATE_BET_PARITY2 = 18;
    uint8 constant STATE_BET_PARITY3 = 19;
    uint8 constant STATE_CHECK = 20;


    modifier accept() {
        tvm.accept();
        _;
    }

    uint64 m_numberBetSing;
    uint64 m_numberBetDoz;
    uint64 m_numberBetColumn;
    uint64 m_numberBetColor;
    uint64 m_numberBetGS;
    uint64 m_numberBetPar;

    uint64 m_numberBetSingValue;
    uint64 m_numberBetDozValue;
    uint64 m_numberBetColumnValue;
    uint64 m_numberBetColorValue;
    uint64 m_numberBetGSValue;
    uint64 m_numberBetParValue;

    function fetch() public override accept returns (Context[] contexts){
        contexts.push(Context(STATE_ZERO,
            "", [
            ActionRun("Hello, please enter the storage address ", "enterStorageAddress", STATE_MAIN),
            ActionPrint("Quit", "quit", STATE_EXIT)
            ]));

        contexts.push(Context(STATE_PRE_MAIN,
            "", [
            ActionRun("Hello, please enter the casino address ", "setCasino", STATE_MAIN),
            ActionPrint("Quit", "quit", STATE_EXIT)
            ]));

        optional(string) args;
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
            "", [
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
    function receiveAnswer(uint8 code, uint128 comment) public override {
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

    function enterNumBetSingle(uint256 numb) private accept {
        m_numberBetSing = numb;
    }

    function sendSubmitMsgBetSingle() public accept view returns (address dest, TvmCell body) {
        dest = m_target.get();
        body = tvm.encodeBody(Casino.singleBet, m_numberBetSing, m_numberBetSingValue);
    }

    function enterNumBetSingleValue(uint256 numb) private accept {
        m_numberBetSingValue = numb;
    }

}
