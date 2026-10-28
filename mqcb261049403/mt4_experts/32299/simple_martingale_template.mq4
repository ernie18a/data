//+------------------------------------------------------------------+
//|                                   Simple Martingale Template.mq4 |
//|                           Copyright © 2015, Joel Tagle Protusada |
//|                     https://www.facebook.com/groups/FXFledgling/ |
//+------------------------------------------------------------------+
#property copyright  "Copyright © 2015 by Joel Tagle Protusada"
#property link       "https://www.facebook.com/groups/FXFledgling/"
#property version    "1.00"
#property strict

/*===================================================================//
A simple but fully functional program that demonstrate how a martingale 
can work for you. Just change the entry analyis using your own scalping 
strategy and your personal money management style, then optimize. 
If your goal is a consistent profit, NOT a high-percentage one and 
willing to use a big capital. This script maybe for you. Optimize it 
first with a capital that gives a maximum drawdown of not more than 50%. 
To be conservative, less than 30% is ideal.

If you are looking for an EA with a profit of 100% per year or more, 
this is not for you. Just don't be greedy and just aim for reasonable 
profit percentage (e.g. 5% to 50% per year)  

FULL DISCUSSION: Details of this script and the logic behind it is discussed
in the ebook; Uncharted Stratagems: Unknown Depths of Forex Trading. This book
tackles the entry-level learning of Maneuver Analysis. This strategy is just one 
of the in-depth topics you can get from the book. Latest edition will be
released in October 2021. You can pre-order now.

HOW TO PRE-ORDER UNCHARTED STRATAGEMS
Step 1: Buy Grid-Averaging Bot at https://www.mql5.com/en/market/product/45236
Step 2: Give it a 5-Star Review
Step 3: Wait for 7-day Payment Grace Period in MQL5 site. After 7 days, you will 
receive initial draft of the e-book. Then the complete version in October 2021.

BONUS if you pre-order on or before January 31, 2021: You will get the Source Code
of Grid-Averaging Bot so you can review topics discussed in the ebook, 
Uncharted Stratagems. 


===============================================================================
ADVANCED LEARNING E-BOOK: 

1) FOREX OVERLORD: Mastering Control in Forex Trading with Advanced Maneuver 
   Analysis and More Strategies for Higher Profitability.
   To be released: in 2023 - You can pre-order now.
   
2) FOREX VAULT: A Treasure Collection of Successful Forex Robot Source Codes 
   Covered in FOREX OVERLORD. 
   To be released: in 2023 - You can pre-order now.
===============================================================================   


DISCLAIMER: This script is for educational purposes only. If you decided 
to use this script on live trading, please pratice due diligence on
what entry analysis and indicators that you are going to use with
thorough optimization, and long-term demo forward testing. Forex is 
a high-risk endeavour and you should not invest money that you can not 
afford to lose.  
//===================================================================*/

//=========Default Parameters is for EURUSD H1 chart=================//
//Optimize it with the pair and timeframe that you like to test.

//-----------Trade Parameters
extern double StopLoss   = 650;
extern double TakeProfit = 650;
extern double LS         = 0.01;
//-----------Martingale Parameter
extern double Multiplier=2.5;

//-----------Indicator & Entry Analysis Parameters
//=================================================
//Put here the parameters of your own analysis
extern int    TimeFrame  = 60;
extern int    fastperiod = 50;
extern int    slowperiod = 200;
//=================================================

//-----------Variables
double Lot         = 0.01;
double AcctBalance = 0.0;
bool   Go          = true;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   AcctBalance=AccountBalance();
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   if(OrdersTotal()==0 && AcctBalance!=AccountBalance())
     {
      if(AcctBalance>AccountBalance())
        {
         Lot=Multiplier*Lot;
         Go = true;
        }
      else if(AcctBalance<AccountBalance())
        {
         Lot=LS;
         Go = true;
        }
     }
   //else if(OrdersTotal()==0 && AcctBalance==AccountBalance())
   //  {
   //   Go=true;
   //  }

   if(OrdersTotal()==0 && Go)
     {
      AcctBalance=AccountBalance();
      int order;
      
      //=================Change this with your own entry analysis=============================
      double fast = iMA(Symbol(),TimeFrame,fastperiod,0,MODE_SMA,PRICE_CLOSE,1);
      double slow = iMA(Symbol(),TimeFrame,slowperiod,0,MODE_SMA,PRICE_CLOSE,1);
      double c    = iClose(Symbol(),TimeFrame,1);

      double fast2 = iMA(Symbol(),TimeFrame,fastperiod,0,MODE_SMA,PRICE_CLOSE,2);
      double slow2 = iMA(Symbol(),TimeFrame,slowperiod,0,MODE_SMA,PRICE_CLOSE,2);
      double H     = iHigh(Symbol(),TimeFrame,2);
      double L     = iLow(Symbol(),TimeFrame,2);
      //======================================================================================

      if(c>fast && fast>slow && fast2<slow2 && c>H) //Change this with your buy condition
        {
         order=OrderSend(Symbol(),OP_BUY,Lot,Ask,0,Bid-StopLoss*Point,Ask+TakeProfit*Point);
         Go=false;
        }
      else if(c<fast && fast<slow && fast2>slow2 && c<L) //Change this with your sell condition
        {
         order=OrderSend(Symbol(),OP_SELL,Lot,Bid,0,Ask+StopLoss*Point,Bid-TakeProfit*Point);
         Go=false;
        }
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+
