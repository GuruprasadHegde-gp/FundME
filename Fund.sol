//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";


contract fundME{
    using PriceConverter for uint256;
     uint256 public minAmount=50 * 10 ** 18;
     
     address[]  public funders;
     mapping(address=>uint256) amountSent;
     address  public contractDeployer;


    constructor(){          //A constructor is a special type of method which will execute first when contract is deployed
            contractDeployer=msg.sender;
    }
 
    function donate() public payable{   
         //since anyone can donate us we make this function public
         //since the user is paying money we make this function payable
         //similarly how wallets can hold fund/currencies our smart contracts can also hold funds
       // require(msg.value > 1e18,"SORRY THE MIN AMOUNT IS 1 ETH");      //msg keyword allows to read the input given by the user in value field
        require(msg.value.getConversionRate() >= minAmount,"SORRY THE MIN AMOUNT IS 1 usd");                                // require is like a condtion checker in solidity it checks wether value is greater than 1e18
        funders.push(msg.sender);          // msg.sender gives the adress of the sender
        amountSent[msg.sender]=msg.value;                                //if the first condition is not met then transaction is reverted and any prior work done before the transaction will be undone (gas fees is also returned)
                                        //require has two parameters one is the condtion and other is the error message to be displayed if condition is not met
                                        //1e18=1*10^18= 1000000000000000000 value of 1 eth in wei
                                        //transaction is done in terms of wei in solidity
                                        //our smart contract doesnt know whats the price of eth in USD hence we need to interact with external chains to know the real time data
                                         //this can be done by chainLink dataFeeds

    }


   function withdraw() public deployerOnly {        //deployerOnly is a modifier ,Before exxecuting the inner codes of the function it checks the condition at the deployerOnly modifier
        for(uint256 fundIndex=0;fundIndex<funders.length;fundIndex++){
            address fundersAddress=funders[fundIndex];
            amountSent[fundersAddress]=0;
          
        }

         funders= new address[](0);// this wil reset the array since the amount has been withdrawn from the contract


         //now we have to transfer the amount the smart contract is holding to the address
         // we are using payabale
        
        // Ethereum can be transffered uisng three methods
        //Transfer
        //Send
        //call
        // payable(msg.sender).transfer(address(this).balance);// this.balance gives the amount balance smart contract is holding
        //if transfer is used then it uses 2100 gas and if more than 2100 gas is used and deployed then it is reverted automatically
        // bool transferStatus= payable(msg.sender).send(address(this).balance);//using the send keyword it returns an false if gas more than 2100 is used we have to use the return type to explicitly revert thee transaction                    
        // require(transferStatus,"Transaction Failed");

       (bool callStatus,)=  payable(msg.sender).call{value:address(this).balance}("");//call function has no gas cap it forwards all amount of gas set
        require(callStatus,"Transffered Failed");
                                                                                    //("") is used to call a function 
                                                                                    //call function returns two parameter
                                                                                    //1)If the transaction has succeded or not,it returns a bool value
                                                                                    //2)The function we have called using ("") if the function returns data than it is stored in the form of the byte array
                                                                                    //as per now it is recommended to use the call function
        }


        modifier deployerOnly{ 
            require(msg.sender==contractDeployer,"Only Contract owners  can Withdraw the Amount");
            _;// "_" Means continue to execute rest of the code
        }
}
