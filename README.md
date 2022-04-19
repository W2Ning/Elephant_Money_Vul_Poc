# Elephant_Money_Vul_Poc
Elephant.Money 攻击事件的复现


```
git clone https://github.com/W2Ning/Elephant_Money_Vul_Poc.git  && cd Elephant_Money_Vul_Poc
```


```
forge test --fork-url https://speedy-nodes-nyc.moralis.io/your_api_key/bsc/mainnet/archive  --fork-block-number  16886438  -vvv
```


<img width="582" alt="image" src="https://user-images.githubusercontent.com/33406415/163914696-89e251b3-4c6b-4fef-b412-7c73e2643bec.png">



### 攻击步骤分析

1. 从`BUSDT-WBNB`交易对, 通过闪电贷借出`130162`个`WBNB`， 从`Cake-WBNB交易对`, 借出`1000`个`WBNB`

2. 从`BUSDT-BUSD`交易对, 通过闪电贷借出`91035000`个`BUSD`

3. 把全部`WBNB`换成`BNB`

4. 调用`PancakeRouter`的`swapExactETHForTokensSupportingFeeOnTransferTokens`函数, 把全部`BNB` 换成`37972517886502219499494`个`ELEPHANT`

5. 把`BUSD` 授权给未开源合约

6. 调用未开源合约的`mint`函数
    这一步里面, 未开源合约会：
    1. 转走攻击合约的全部`BUSD`
    2. 给攻击合约`mint`相应数量的`TRUNK`
    3. 用一部分`BUSD`在`BUSD-WBNB`交易对上换`WBNB`
    4. 用`WBNB`在`WBNB-Elephant`交易对上换`Elephant`
    5. 剩余的`BUSD`转给`0xcb5a-Treasury`
    6. 换来的`Elephant`转给`0xaf09-Treasury`
    7. 0x8655-ElephantDollarDistributor . credit ( collateralAmount = 910,350,000,000,000,000,000,000 )
    8. 0xdb2c-ElephantDollarDistributor . credit ( collateralAmount = 9,103,500,000,000,000,000,000,000 )
    9. TRUNK . mint ( _to = 0xd520a3b47e42a1063617a9b6273b206a07bdf834,  _amount = 910,407,327,522,499,746,863,942)
    10. 去给`TRUNK-BUSD`交易对 添加流动性

7.  攻击合约把`Elephant`授权给`PancakeRouter`

8.  用`Elephant`换了`96715`个`WBNB`

9.  把`TRUNK`授权给`未开源合约`

10. 调用未开源合约的`redeem`
    这一步， 攻击者失去了全部的`TRUNK`， 获得了`32669771`个`BUSD`, `140806`个`ELEPHANT`

11. 用`140806`个`ELEPHANT`换`36987`个`BNB`

------------------------------  下面是第二次攻击循环  --------------------------------------------

12. 用大部分`BNB`换`24,106,703`个`BUSD`

13. 用小部分`BNB`换`Elephant`

14. mint

15. 用`Elephant`换`WBNB`

16. redeem

------------------------------- 善后工作 ------------------

17. 用`BNB`换`BUSD`

18. 偿还`BUSDT-BUSD`交易对的闪电贷

19. 偿还`BUSDT-WBNB`交易对的闪电贷

20. 把剩余`27416`个`BNB`转回给攻击者自己的EOA地址, 结束攻击
