//=========================================================================================================================================//
//| |//
//=========================================================================================================================================//
#property copyright "Copyright 2013, www.trading-go.ru Project."
#property link "http://www.trading-go.ru"
#property version "1.00"
#property description " Principle trade with Martingale: Received TakeProfit opened an initial lot in that direction"
#property description " Received a stop loss opened reverse order with increased lot"
#property description" ========================================================================="
#property description " the Principle of trade in AntiMartingale: Received TakeProfit opened with increased lot in that direction"
#property description " Received a stop loss opened reverse order with an initial lot"
//=========================================================================================================================================//
//| |//
//=========================================================================================================================================//
#property strict
#define BUY 0 // create предопределенню variable with a value of 0
#define SEL 1 // create a variable предопределенню with a value of 1
enum sp { Buy,Sell }; // create the select using the enum type of the first order
enum tip{ Martingale,AntiMartingale};// create the select using the enum type of trade
                                     // the type of trade-Martingale, AntiMartingale
input tip TypTrade=Martingale;
// start position Buy or Sell
input sp StartPoz=Buy;
// set the value of TakeProfit
input int TakeProfit=300;
// set the value of stop loss
input int StopLoss=300;
// set the base lot
input double StartLot=0.01;
// set the value of the multiplier lots
input double MultiplierLot=2;
// set the value MagicNumber -1 if all MagicNumber
input int MagicNumber=227;
// set the value of slippage
input int Slippage=30;
int Typ=0,tik=-2; // initialize global variables
double Lot=0,Pro=0,MLot=0,ALot=0;// initialize global variables
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                                 //=========================================================================================================================================//
//| |//
//=========================================================================================================================================//
int OnInit()
  {
   Comment(""); // will be emptied technical comment
   if(TypTrade==0) //If the Advisor works in a mode Мартенгейл
     {
      MLot=MultiplierLot; // MLot assign the value of the multiplier lot
      ALot=1; // АLot assign a value of 1
     }
   else
     {
      MLot=1; // МLot assign a value 1
      ALot=MultiplierLot; // АLot assign the value of the multiplier lot
     }
   return(INIT_SUCCEEDED);
  }
//=========================================================================================================================================//
//| |//
//=========================================================================================================================================//
void OnTick()
  {
   if(!counter(BUY) && !counter(SEL)) // Check if is there оредра Advisor ,if not Baev and no Selonians
     {
      // Fetch data from the orders history of the last closed order and refund us the values required
      // order type, a lot of the order, and his profit
      history(Typ,Lot,Pro);

      if(Pro>0 && TypTrade==0)Lot=StartLot; // if the Advisor works in a mode of martingale and profit greater than zero
                                            // then the lot will equal start for a position in the same direction

      if(Pro<0 && TypTrade==1)Lot=StartLot; // if the Advisor works in mode антимартингейл and profit is less than zero
                                            // then the lot will equal start for a position in the same direction

      // For the first order
      if(Typ==0 && Lot==0 && Pro==0) // if the us of the history of orders in our magic number returned zeros
         // then you need to pen the first order
         if(openorders(StartPoz,StartLot)) // if the first order is opened
            if(modify())return; // modify it and in case of a successful modification will give management terminal

      if(Typ==BUY && Lot!=0 && Pro>0) // if the last closed order was a buy and its profit is greater than zero
         if(openorders(BUY,Lot*ALot)) // open an order to buy a lot depending on the type of TypTrade
            if(modify())return; // modify it and in case of a successful modification will give management terminal

      if(Typ==BUY && Lot!=0 && Pro<0) // if the last closed order was a buy and its profit is less than zero
         if(openorders(SEL,Lot*MLot)) // open a warrant etc одажу lot depending on the type of TypTrade
            if(modify())return; // modify it and in case of a successful modification will give management terminal

      if(Typ==SEL && Lot!=0 && Pro>0) // if the last closed order was to sell and its profit is greater than zero
         if(openorders(SEL,Lot*ALot)) // open a warrant etc одажу lot depending on the type of TypTrade
            if(modify())return; // modify it and in case of a successful modification will give management terminal

      if(Typ==SEL && Lot!=0 && Pro<0) // if the last closed order was for sale and profit less than zero
         if(openorders(BUY,Lot*MLot)) // open an order to buy a lot depending on the type of TypTrade
            if(modify())return; // modify it and in case of a successful modification will give management terminal
     }
   else return; // if the orders are then pass control to the terminal
  }
//=========================================================================================================================================//
//| Function query the state of the trade Advisor |//
//=========================================================================================================================================//
bool counter(int typ) // function takes the type of the requested order
  {
   for(int i=OrdersTotal()-1; i>=0; i--) // start the cycle of searching in the orders in reverse order
      if(OrderSelect(i,SELECT_BY_POS)) // parse the order on the part of
         if(OrderMagicNumber()==MagicNumber || MagicNumber==-1)// Check the part of the order MagicNumber if it is our MagicNumber or MagicNumber is -1
            if(OrderSymbol()==Symbol()) // check the order symbol if our then continue on
               if(OrderType()==typ)return true;//check the part of the order-order type if it is requested us to quit the function successfully
   return false; // if we didn't find the desired order to quit the function with a failure
  }
//=========================================================================================================================================//
//| Function to query the data of the last closed orders in time |//
//=========================================================================================================================================//
void history(int &typ,double &lot,double &pro) // function takes the link type, lot, and profit for their processing
  {
   datetime tim=0; // time value will be emptied
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)// start the loop through history orders in reverse order
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) // parse the order on the part of
         if(OrderSymbol()==Symbol()) // check the order symbol if our then continue on
            if(OrderMagicNumber()==MagicNumber || MagicNumber==-1)// Check the part of the order MagicNumber if it is our MagicNumber or MagicNumber is -1
               if(OrderCloseTime()>tim) // if the time of closing more of our variable tim
                 {
                  tim=OrderCloseTime(); // store the time of closing orders
                  typ=OrderType(); // store the type of the order
                  lot=OrderLots(); // store a lot orders
                  pro=OrderProfit(); // store profit orders
                 }
  }
//=========================================================================================================================================//
//| A function to open the order |//
//=========================================================================================================================================//
bool openorders(int typ,double lot) // Function takes the type of order and the desired lot
  {
   double price=0; int p=0; // will be emptied variables for rates and counter attempts of opening orders
   if(typ==BUY) // if we want to open a buy order
      price=NormalizeDouble(Ask,_Digits); // fetch a price for its opening and immediately notifies its normalize under 4 or 5 characters automatically
   else // if we want to open a sell order
   price=NormalizeDouble(Bid,_Digits); // fetch a price for its opening and immediately notifies its normalize under 4 or 5 characters automatically
   if(IsTradeAllowed()) // check whether the quotes flow and can we open the order
      while(p<5) // start the cycle attempts to open the order of 5 attempts
        { // send the malformed request to the server broker
         tik=OrderSend(Symbol(),typ,NormalizeDouble(lot,2),NormalizeDouble(price,_Digits),Slippage,0,0,WindowExpertName()+" "+(string)MagicNumber,MagicNumber,0,clrBlue);
         if(tik>=0) // if our order approved remember his ticket in a variable tik
            return true; // leave functions successfully
         else // if the server did not accept our order
           {
            p++; // increment the counter by 1
            Print(__FUNCTION__,"_Error_",GetLastError()); // output the log function name and the number of errors
            Sleep(500); // wait half a second to repeat a request
           }
        }
   return false; // if the 5 attempts, the order is not opened emerge from a function fails
  }
//=========================================================================================================================================//
//| function to modify orders |//
//=========================================================================================================================================//
bool modify() // function takes no values and processes ticket order that we remember in function openorders()
  {
   int p=0; // Will be emptied counter attempts to modify an order
   double sl=0,tp=0; // will be emptied variables for stop loss and take profit

   if(tik>=0) // ticket which we received from the function openorders() if it is more or equal to zero
      if(OrderSelect(tik,SELECT_BY_TICKET)) // parse the order on the part of
         if(OrderType()==BUY) // if the order type buying
           {
            tp=NormalizeDouble(Ask+TakeProfit*_Point,_Digits); // 'll calculate the price of take profit and normalize it for 4 or 5 nakova automatically
            sl=NormalizeDouble(Ask-StopLoss *_Point,_Digits); // 'll calculate the price of stop loss and normalize it for 4 or 5 nakova automatically
           }
   else // if the type of the order sale
     {
      tp=NormalizeDouble(Bid-TakeProfit*_Point,_Digits); // 'll calculate the price of take profit and normalize it for 4 or 5 nakova automatically
      sl=NormalizeDouble(Bid+StopLoss *_Point,_Digits); // 'll calculate the price of stop loss and normalize it for 4 or 5 nakova automatically
     }
   if(IsTradeAllowed()) // check whether quotations and whether we can open order
      while(p<5) // start the cycle attempts to modify an order on 5 attempts
        {
         if(OrderModify(tik,OrderOpenPrice(),sl,tp,0)==true)// if successful
            return true; // return result of the success
         else // if not good luck
           {
            p++; // increment the counter by 1
            Print(__FUNCTION__,"_Error_",GetLastError()); // output the log function name and the number of errors
            Sleep(500); // wait half a second to repeat a request
           }
        }
   return false; // if the 5 attempts, the order is not opened emerge from a function fails
  }
//=========================================================================================================================================//
//| |//
//=========================================================================================================================================//
