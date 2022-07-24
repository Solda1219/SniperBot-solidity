// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./SafeBEP20.sol";
import "./TransferHelper.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

contract SniperBot is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeBEP20 for IBEP20;
    
    struct OrderStatus {
		bool state;
        bool deposit;
        uint256 amount0;
        uint256 amount1;
		uint256 depositAmount;
    }
    
    mapping (address => mapping(address => OrderStatus)) public status;
    
    mapping (address => bool) public _subscriptionAllowed;
    
    mapping (address => mapping(uint32 => bool)) private _subscriptionDetailAllowed;
    
    mapping (uint32 => IUniswapV2Router02) public swapRouter;
    
    mapping (uint32 => IUniswapV2Factory) pairFactory;
    
    constructor (bool isBinace) Ownable(){
    
        if(isBinace){
            //swapRouter[1] = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
            //pairFactory[1] = IUniswapV2Factory(swapRouter[1].factory());
            swapRouter[2] = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            pairFactory[2] = IUniswapV2Factory(swapRouter[2].factory());
            swapRouter[1] = IUniswapV2Router02(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
            pairFactory[1] = IUniswapV2Factory(swapRouter[1].factory());
    
        }else{
             //swapRouter[1] = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
             //pairFactory[1] = IUniswapV2Factory(swapRouter[1].factory());
               swapRouter[2] = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
               pairFactory[2] = IUniswapV2Factory(swapRouter[2].factory());
            //   swapRouter[3] = IUniswapV2Router02(0xE592427A0AEce92De3Edee1F18E0157C05861564);
            //   pairFactory[3] = IUniswapV2Factory(swapRouter[2].factory());
        }
    }
    
    function SetRouter(uint32 typeId, IUniswapV2Router02 router) public onlyOwner() {
       require(address(router) != address(0) , "Router address is not valid!");
       require(address(router.factory()) != address(0) , "Router is not valid Router!");
       swapRouter[typeId] = router;
       pairFactory[typeId] = IUniswapV2Factory(router.factory());
    }
    
    function SetSubScription(address userAddress, bool val) public onlyOwner() {
        require(userAddress != address(0) , "address is not valid!");
        _subscriptionAllowed[userAddress] =  val;
    }
    
    function SetSubScriptionDetail(address userAddress, uint32 typeId, bool val) public onlyOwner() {
        require(userAddress != address(0) , "address is not valid!");
        _subscriptionDetailAllowed[userAddress][typeId] =  val;
    }
    
    function CheckReadyToBuy(uint32 typeId, address token0, address[] calldata path) public view returns (uint32, uint112, uint112) {

        if(status[_msgSender()][token0].state == true) return (500,0,0);
        
        for (uint32 i = 0; i < path.length; i++) {
            address pairAddr = pairFactory[typeId].getPair(token0, path[i]);

            if(pairAddr != address(0)) {
                IUniswapV2Pair pair = IUniswapV2Pair(pairAddr);
                 (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
                 
                 if(reserve1 > 0 && reserve0 > 0){
                     return ( token0 == pair.token0() ? (i, reserve1, reserve0) : (i, reserve0, reserve1));
                 }
            }
        }
        return (500, 0 , 0);
    }
    
    function CheckReadyToSell(uint32 typeId, address token0, address[] calldata path, uint256 rate) public view returns (uint32, uint112, uint112) {
        if(status[_msgSender()][token0].state == true) return (500,0,0);
        uint112 baseAmount;
        uint112 tokenAmount;
        for (uint32 i = 0; i < path.length; i++) {
            address pairAddr = pairFactory[typeId].getPair(token0, path[i]);

            if(pairAddr != address(0)) {
                IUniswapV2Pair pair = IUniswapV2Pair(pairAddr);
                if(token0 == pair.token1()){
                    (baseAmount, tokenAmount,) = pair.getReserves();
                }else{
                    (tokenAmount, baseAmount,) = pair.getReserves();
                }
                
                if(status[_msgSender()][token0].deposit && checkPrice(rate, baseAmount, tokenAmount, token0)) return (i, baseAmount, tokenAmount);
            }
        }
        return (500,baseAmount, tokenAmount);
    }
    
    function checkPrice(uint256 rate, uint256 bsAmount, uint256 tkAmount , address token0) internal view returns (bool) {
        uint256 var0 = uint256(bsAmount).div(10**9).mul(status[_msgSender()][token0].amount1).div(10**9);
        uint256 var1 = uint256(tkAmount).div(10**9).mul(status[_msgSender()][token0].amount0).div(10**9).mul(rate);
        if(var0 > var1) return true;
        return false;
    }
    
    function SendAnywayBuyTransaction(uint32 typeId, address token, address[] calldata path) public payable {
        bool passed = false;
        require(address(pairFactory[typeId]) != address(0) , "Router is not initialized!");
        require(status[_msgSender()][token].state == false , "User set flag not trade!"); 
        
        if(_msgSender() != owner()){
            require(checkSubscription(_msgSender() , typeId), "You have to get subscription from admin!");
        }

        for (uint32 i = 0; i < path.length; i++) {
            
            address pairAddr = pairFactory[typeId].getPair(token, path[i]);
            if(pairAddr != address(0)) {
                IUniswapV2Pair pair = IUniswapV2Pair(pairAddr);
                 (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
                 
                 if(reserve1 > 0 && reserve0 > 0) {
                     uint baz = i + 2;
                     address[] memory swapPath = new address[](baz);
                       swapPath[0] = path[0];
                       if(i==1){
                           swapPath[1] = path[1];
                           swapPath[2] = token;
                       }else{
                           swapPath[1]= token;
                       }
                        uint256 beforeBalance = IBEP20(token).balanceOf(address(this)) ;
                        swapRouter[typeId].swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
                            0, // accept any amount of TOKEN
                            swapPath,
                            address(this),
                            block.timestamp
                        );
                        IBEP20(token).safeApprove(address(swapRouter[typeId]), IBEP20(token).balanceOf(address(this)));
                        passed = true;
                        status[_msgSender()][token].amount0 = msg.value;
                        status[_msgSender()][token].amount1 = IBEP20(token).balanceOf(address(this)).sub(beforeBalance);
                        //status[_msgSender()][token].depositAmount = IBEP20(token).balanceOf(address(this));
                        break;
                 }
            }
        }
        require(passed , "Failed!");
    }
    
    function checkPath(uint32 typeId, address token, address[] calldata path) internal view returns(uint32) {
     
        for (uint32 i = 0; i < path.length; i++) {
            
            address pairAddr = pairFactory[typeId].getPair(token, path[i]);
            if(pairAddr != address(0)) {
                IUniswapV2Pair pair = IUniswapV2Pair(pairAddr);
                 (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
                 
                 if(reserve1 > 0 && reserve0 > 0) {
                        
                         return i;
                 }
            }
        }
        return 200;
    }
    
    function SendMultiStepBuyTransaction(uint32 typeId, address token, address[] calldata path, uint256 divideCount) public payable {
        bool passed = false;
        require(address(pairFactory[typeId]) != address(0) , "Router is not initialized!");
        require(status[_msgSender()][token].state == false , "User set flag not trade!"); 
        uint256 ethVal = msg.value;
        if(_msgSender() != owner()){
            require(checkSubscription(_msgSender() , typeId), "You have to get subscription from admin!");
        }
        uint32 index = checkPath(typeId,token,path);
        
        if(index!=200){
            uint baz = index + 2;
            address[] memory swapPath = new address[](baz);
            swapPath[0] = path[0];
            if(index==1){
                swapPath[1] = path[1];
                swapPath[2] = token;
            }else{
                swapPath[1]= token;
            }
            uint256 beforeBalance = IBEP20(token).balanceOf(address(this));
            
            for(uint256 i = 0 ; i < divideCount ; i++){
                swapRouter[typeId].swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethVal.div(divideCount)}(
                    0, // accept any amount of TOKEN
                    swapPath,
                    address(this),
                    block.timestamp
                );
            }
            if(IBEP20(token).allowance(address(this), address(swapRouter[typeId]))!=0) {
                IBEP20(token).safeApprove(address(swapRouter[typeId]), 0);                
            }
            IBEP20(token).safeApprove(address(swapRouter[typeId]), IBEP20(token).balanceOf(address(this)));
            status[_msgSender()][token].amount0 = msg.value;
            status[_msgSender()][token].amount1 = IBEP20(token).balanceOf(address(this)).sub(beforeBalance);
            status[_msgSender()][token].depositAmount = IBEP20(token).balanceOf(address(this));
        }else{
            require(passed , "Failed!");
        }
    }
    
    function SendAnywaySellTransaction(uint32 typeId, address token, address[] calldata path, uint256 percent) public {
        bool passed = false;

        if(_msgSender() != owner()){
            require(checkSubscription(_msgSender() , typeId), "You have to get subscription from admin!");
        }

        for (uint32 i = 0; i < path.length; i++) {
            
            address pairAddr = pairFactory[typeId].getPair(token, path[i]);
            if(pairAddr != address(0)) {
                 (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pairAddr).getReserves();
                 
                 if(reserve1 > 0 && reserve0 > 0) {
                     uint256 swapAmount = status[_msgSender()][token].amount1.mul(percent).div(1000);
                     uint baz = i + 2;
                     address[] memory swapPath = new address[](baz);
                       swapPath[0] = token;
                       if(i==1){
                           swapPath[1] = path[1];
                           swapPath[2] = path[0];
                       }else{
                           swapPath[1]= path[0];
                       }
                        //uint256 beforeBalance = IBEP20(token).balanceOf(address(this)) ;
                        swapRouter[typeId].swapExactTokensForETHSupportingFeeOnTransferTokens(
                                swapAmount,
                                0, // accept any amount of ETH
                                swapPath,
                                _msgSender(),
                                block.timestamp
                        );
                        passed = true;
                        status[_msgSender()][token].amount1 = status[_msgSender()][token].amount1.sub(swapAmount);
                        //status[_msgSender()][token].depositAmount = IBEP20(token).balanceOf(address(this));
                        break;
                 }
            }
        }
        require(passed , "Failed!");
    }
    
    function SendLimitSellTransaction(uint32 typeId, address token, address[] calldata path, uint256 tokenamount) public {
        bool passed = false;

        if(_msgSender() != owner()){
            require(checkSubscription(_msgSender() , typeId), "You have to get subscription from admin!");
        }

        for (uint32 i = 0; i < path.length; i++) {
            
            address pairAddr = pairFactory[typeId].getPair(token, path[i]);
            if(pairAddr != address(0)) {
                 (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pairAddr).getReserves();
                 
                 if(reserve1 > 0 && reserve0 > 0) {
                     uint256 swapAmount = (status[_msgSender()][token].depositAmount > tokenamount ? tokenamount:status[_msgSender()][token].depositAmount);
                     uint baz = i + 2;
                     address[] memory swapPath = new address[](baz);
                       swapPath[0] = token;
                       if(i==1){
                           swapPath[1] = path[1];
                           swapPath[2] = path[0];
                       }else{
                           swapPath[1]= path[0];
                       }
                        //uint256 beforeBalance = IBEP20(token).balanceOf(address(this)) ;
                        swapRouter[typeId].swapExactTokensForETHSupportingFeeOnTransferTokens(
                                swapAmount,
                                0, // accept any amount of ETH
                                swapPath,
                                _msgSender(),
                                block.timestamp
                        );
                        passed = true;
                        status[_msgSender()][token].depositAmount = status[_msgSender()][token].depositAmount.sub(swapAmount);
                        break;
                 }
            }
        }
        require(passed , "Failed!");
    }
    function SendBuyTransaction(uint32 typeId, address[] calldata path) public payable {
        
        address token0 = path[path.length-1];
        
        if(_msgSender() != owner()){
            require(checkSubscription(_msgSender() , typeId), "You have to get subscription from admin!");
        }

        require(address(pairFactory[typeId]) != address(0) , "Router is not initialized!");
        require(status[_msgSender()][token0].state == false , "User set flag not trade!");
        
        uint256 beforeBalance = IBEP20(token0).balanceOf(_msgSender()) ;
        swapRouter[typeId].swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0, // accept any amount of TOKEN
            path,
            _msgSender(),
            block.timestamp
        );
        
        status[_msgSender()][token0].amount0 = msg.value;
        status[_msgSender()][token0].amount1 = IBEP20(token0).balanceOf(_msgSender()).sub(beforeBalance);
    }   

    function SendSellTransaction(uint32 typeId, address[] calldata path) public {
        address token0 = path[0];
        
        if(_msgSender() != owner()){
            require(checkSubscription(_msgSender() , typeId), "You have to get subscription from admin!");
        }
        
        require(address(pairFactory[typeId]) != address(0) , "Router is not initialized!");
        require(status[_msgSender()][token0].state == false , "User set flag not trade!");
        require(status[_msgSender()][token0].deposit == true , "No deposit now!");
        
        uint256 tokenBalance = IBEP20(token0).balanceOf(address(this));

        if(tokenBalance >= status[_msgSender()][token0].depositAmount){
            IBEP20(token0).safeApprove(address(swapRouter[typeId]), status[_msgSender()][token0].depositAmount);        
            swapRouter[typeId].swapExactTokensForETHSupportingFeeOnTransferTokens(
                status[_msgSender()][token0].depositAmount,
                0, // accept any amount of ETH
                path,
                _msgSender(),
                block.timestamp
            );
            status[_msgSender()][token0].depositAmount = 0;
            status[_msgSender()][token0].deposit = false;
        }
    }
    
    function checkSubscription(address user , uint32 typeId) internal view returns (bool checked){
        if(_subscriptionAllowed[user]) {
            checked =  true;
        }else{
            checked =  _subscriptionDetailAllowed[user][typeId];
        }
    }
    //call approve before calling
	function Deposit(address token, uint256 amount) public {
		IBEP20(token).safeTransferFrom(_msgSender(), address(this), amount);
		status[_msgSender()][token].depositAmount = status[_msgSender()][token].depositAmount.add(amount);
		status[_msgSender()][token].deposit = true;
	}
	
    function Withdraw(address token, uint256 amount) public  {
		require(amount <= status[_msgSender()][token].depositAmount, "Balance error!");
        IBEP20(token).safeTransfer(_msgSender(), amount);
		status[_msgSender()][token].depositAmount = status[_msgSender()][token].depositAmount.sub(amount);
		if(status[_msgSender()][token].depositAmount==uint256(0))
		    status[_msgSender()][token].deposit = false;
    }
	
    function WithdrawAll(address token) public  {
        IBEP20(token).safeTransfer(_msgSender(), status[_msgSender()][token].depositAmount);
		status[_msgSender()][token].state = false;
		status[_msgSender()][token].amount0 = 0;
		status[_msgSender()][token].amount1 = 0;
		status[_msgSender()][token].depositAmount = 0;
		status[_msgSender()][token].deposit = false;
    }
    
    function EmegencyWithdraw(address token) public onlyOwner {
        uint256 balance = IBEP20(token).balanceOf(address(this));
        IBEP20(token).safeTransfer(_msgSender(), balance);
		status[_msgSender()][token].state = false;
		status[_msgSender()][token].amount0 = 0;
		status[_msgSender()][token].amount1 = 0;
		status[_msgSender()][token].depositAmount = 0;
		status[_msgSender()][token].deposit = false;
    }
    
	function GetPrice(address token) public view returns(uint256,uint256) {
	    return (status[_msgSender()][token].amount0 , status[_msgSender()][token].amount1 );
	}
	
	function SetPrice(address token,  uint256 amountETH,  uint256 amount) public {
	    require(amountETH>0&&amount>0,"Price must be greater then zero!");
	    status[_msgSender()][token].amount0 = amountETH;
		status[_msgSender()][token].amount1 = amount;
	}
	
    function SetDisableTrade(address token) public {
        status[_msgSender()][token].state = true;
    }
    
    function SetEnableTrade(address token) public {
		status[_msgSender()][token].state = false;
    }
}