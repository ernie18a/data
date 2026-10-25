//+------------------------------------------------------------------+
//|                                  Expert Advisor Count_Orders.mq4 |
//|                                                  Francisco Rayol |
//|                                      https://twitter.com/mql4all |
//+------------------------------------------------------------------+
#property copyright "EA's and Indicators for Funds and Prop Desks (Risk Management EAs). Click here for more content. Francisco Rayol."
#property link      "https://twitter.com/mql4all"
#property description "Expert Advisor Count Orders"
#property version   "1.00"
#property strict

extern  int    MAGICMA = 2556;       // MagicNumber defined by the user
extern  double stoploss = 100;       // Stop Loss points defined by the user
extern  double takeprofit = 400;     // Take Profit points defined by the user
extern double lot = 0.01;           // Lot size defined by the user
extern  int    slippage = 7;         // Slippage allowed defined by the user
extern  int    wait_time = 2000;     // Time in milisseconds between the orders opening

int buys,sells; // these two interger variables must be Global so that they don't keep having "zero" value everytime the OrdersCount() function is triggered by the OnTick()
                // they are the variables that will be used to show the amount of each type of order
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  int ticket;
   
  string symb=Symbol();
  
  double sl = stoploss*Point; 
  double tp = takeprofit*Point; 
  
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
//--- minimal allowed volume of trade operations   
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot<min_volume)
     {
      lot=min_volume;
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lot>max_volume)
     {
      lot=max_volume;
     }
   
  //+---------------------------------------------------------------------------------------------------------------------------------------------------+
  //| At the start of the Expert Advisor's running, I set this EA to open three sample orders to make it visible the "Counting Orders" function working |
  //| After the two first orders being sent successfully I set the Sleep() function to make the EA wait some seconds before opening a new trade         |
  //+---------------------------------------------------------------------------------------------------------------------------------------------------+
   if(CheckMoneyForTrade(symb,lot,0))
   {
   
   ticket=OrderSend(symb,0,lot,Ask,slippage,Bid-sl,Ask+tp,"",MAGICMA,0,Blue);
   if(ticket>0)Sleep(wait_time);
   
   }
   
   if(CheckMoneyForTrade(symb,lot,0))
   {
   
   ticket=OrderSend(symb,0,lot,Ask,slippage,Bid-sl,Ask+tp,"",MAGICMA,0,Blue);
   if(ticket>0)Sleep(wait_time);
   
   }
   
   if(CheckMoneyForTrade(symb,lot,1))
   {
   ticket=OrderSend(symb,1,lot,Bid,slippage,Ask+sl,Bid-tp,"",MAGICMA,0,Red);
   if(ticket>0)Print("Samples orders sent.");
   }
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

  //+----------------------------------------------------------------------------------------------------------------------------+
  //| Way to make the counting of the running orders visible                                                                     |
  //| I chose the Comment() function, but you can choose any other way you prefer                                                |
  //| It must be placed on the "OnTick()" function in order to be running every tick, checking the total amount of opened orders |
  //+----------------------------------------------------------------------------------------------------------------------------+
  
  Comment("Orders total now: "+(string)OrdersCount()+". Buys: "+(string)buys+". Sells: "+(string)sells); 
   
  }

  //+----------------------------------+
  //| OrdersCount() Int Function Code  |
  //+----------------------------------+

int OrdersCount()
{
      
      int buy = 0,sell = 0; // these are Local Variables used by the OrdersCount()'s function in it's loop triggered by the OnTick() looking for opened orders
      
      for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA)break;
        {
         if(OrderType()==OP_BUY)  buy++;   // if an OP_BUY order is found running, it adds one unit to this Local Variable
         if(OrderType()==OP_SELL) sell++;  // if an OP_SELL order is found running, it adds one unit to this Local Variable
        }
     }
     
     buys=buy;    // Here the OrdersCount() function attributes to the Global Variables the amount of each type of order running at that moment
     sells=sell;
     
return(buy+sell); // The function returns the total amount of orders running which is called by the OnTick() function in the "Comment()" above

}

bool CheckMoneyForTrade(string symb, double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
   //-- if there is not enough money
   if(free_margin<0)
     {
      return(false);
     }
   //--- checking successful
   return(true);
  }