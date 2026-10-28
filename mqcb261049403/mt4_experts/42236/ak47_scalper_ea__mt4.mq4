//+------------------------------------------------------------------+
//|                                                     AK-47 EA.mq4 |
//|                           Copyright 2022, Hung_tthanh@yahoo.com. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Hung_tthanh@yahoo.com."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict

#define ExtBotName "AK-47 EA" //Bot Name
#define  Version "1.00"

//--- input parameters
extern string  EASettings        = "---------------------------------------------"; //-------- <EA Settings> --------
input int      InpMagicNumber    = 124656;   //Magic Number
extern string  MoneySettings     = "---------------------------------------------"; //-------- <Money Settings> --------
input bool     isVolume_Percent  = true;     //Allow Volume Percent
input double   InpRisk           = 3;        //Risk Percentage of Balance (%)
extern string  TradingSettings   = "---------------------------------------------"; //-------- <Trading Settings> --------
input double   Inpuser_lot       = 0.01;     //Lots
input double   InpSL_Pips        = 3.5;      //Stoploss (in Pips)
input double   InpTP_Pips        = 7;       //TP (in Pips) (0 = No TP)
int      InpMax_slippage   = 3;              //Maximum slippage allow_Pips.
input double   InpMax_spread     = 5;      //Maximum allowed spread (in Point) (0 = floating)
extern double  InpProfit_lock    = 50;       //Trailing stop Trigger (in %) (0 = Inactive)
//extern double  InpProfitStep     = 1.2;      //Trailing Step (in %)
extern string   TimeSettings     = "---------------------------------------------"; //-------- <Trading Time Settings> --------
input bool     InpTimeFilter     = true;     //Trading Time Filter
input int      InpStartHour      = 2;        //Start Hour
input int      InpStartMinute    = 30;       //Start Minute
input int      InpEndHour        = 21;       //End Hour
input int      InpEndMinute      = 0;        //End Minute

//input int InpPeriodKelner = 20;
//--- Variables
int      Pips2Points;    // slippage  3 pips    3=points    30=points
double   Pips2Double;    // Stoploss 15 pips    0.015      0.0150
bool     isOrder = false;
int      slippage;
double acSpread;
double mprofit_lock = InpProfit_lock;
double order_profit1 = 0;
double close_profit1 = 0;
double max_profit1 = 0;
string strComment = "";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---   
   //Kiem tra sàn 3 số hay 5 số
   //Pip and point
   if (Digits % 2 == 1)
   {
      Pips2Double  = _Point*10; 
      Pips2Points  = 10;
      slippage = 10* InpMax_slippage;
   } 
   else
   {    
      Pips2Double  = _Point;
      Pips2Points  =  1;
      slippage = InpMax_slippage;
   }
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
     if(IsTradeAllowed() == false)
     {
      Comment("AK-47 EA\nTrade not allowed.");
      return;
     }
     
       MqlDateTime structTime;
       TimeCurrent(structTime);
       structTime.sec = 0;
       
       //Set starting time
       structTime.hour = InpStartHour;
       structTime.min = InpStartMinute;       
       datetime timeStart = StructToTime(structTime);
       
       //Set Ending time
       structTime.hour = InpEndHour;
       structTime.min = InpEndMinute;
       datetime timeEnd = StructToTime(structTime);
       
       acSpread = MarketInfo(Symbol(), MODE_SPREAD);
       
      
      strComment = "\n" + ExtBotName + " - v." + (string)Version;
      strComment += "\nSever time = " + TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS) + " day of week " + DayOfWeekDescription(structTime.day_of_week);
      strComment += "\nTrading time = [" + (string)InpStartHour + "h" + (string)InpStartMinute + " --> " +  (string)InpEndHour + "h" + (string)InpEndMinute + "]";
      
      strComment += "\nCurrent Spread = " + (string)acSpread + " Points";
      strComment += "\nCurrent Profit = " + (string)order_profit1 + " Pips";
      Comment(strComment);
   
      //Update Values
      UpdateOrders();
      
      TrailingStop();
      
      //Dieu kien giao dich theo phien My
      if(InpTimeFilter)
      {
         if(TimeCurrent() >= timeStart && TimeCurrent() < timeEnd)
         {
            if(!isOrder) OpenOrder();
         }
      }
      else
      {
         if(!isOrder) OpenOrder();
      }
      

     
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CALCULATE SIGNAL AND SEND ORDER                                  |
//+------------------------------------------------------------------+
void OpenOrder(){
   
   // 1) Build signals
   //int TF = PERIOD_H1;
   ////double sar1 = iSAR(NULL, TF, 0.02, 0.2, 1);
   //double sar2 = iSAR(NULL, TF, 0.02, 0.2, 0);
   //bool buySignal  = sar2 > iOpen(_Symbol, TF, 1);// && sar2 < iOpen(_Symbol, TF, 0);
   //bool sellSignal = sar2 < iOpen(_Symbol, TF, 1);// && sar2 > iOpen(_Symbol, TF, 0);
   
   int OrdType = OP_SELL;//-1;
   
   //Specify Order Type

   // 3) Open trades on signal
   //if (sellSignal) OrdType = OP_SELL;
   //if (buySignal) OrdType = OP_BUY;
   
   double TP = 0;
   double SL = 0;
   string comment = ExtBotName;
   
   //Calculate Lots
   double lot1 = CalculateVolume();
   
   if(OrdType == OP_SELL){
      double OpenPrice = Bid - NormalizeDouble(InpSL_Pips/2 * Pips2Double, Digits);
      
      TP = OpenPrice - NormalizeDouble(InpTP_Pips * Pips2Double, Digits);
      SL = Ask + NormalizeDouble(InpSL_Pips/2 * Pips2Double, Digits);//OpenPrice + NormalizeDouble(InpSL_Pips * Pips2Double, Digits);
         
      if(CheckSpreadAllow()                                    //Check Spread
         && CheckVolumeValue(lot1)                             //Check volume
         && CheckOrderForFREEZE_LEVEL(OP_SELLSTOP, OpenPrice)  //Check Dist from openPrice to Bid
         && CheckStopLoss(OpenPrice,  SL, TP)                  //Check Dist from SL, TP to OpenPrice
         && CheckMoneyForTrade(_Symbol, lot1, OP_SELL))        //Check Balance khi lenh cho duoc Hit
      {
         if(!OrderSend(_Symbol, OP_SELLSTOP, lot1, OpenPrice, slippage, SL, TP, comment, InpMagicNumber, 0, clrRed))
         Print(__FUNCTION__,"--> OrderSend error ",GetLastError());
      }
   }
   else if(OrdType == OP_BUY){
      double OpenPrice = Ask + NormalizeDouble(InpSL_Pips/2 * Pips2Double, Digits);
      SL = Bid - NormalizeDouble(InpSL_Pips/2 * Pips2Double, Digits);//OpenPrice - NormalizeDouble(InpSL_Pips * Pips2Double, Digits);
      
      if(CheckSpreadAllow()                                    //Check Spread
         && CheckVolumeValue(lot1)                             //Check volume
         && CheckOrderForFREEZE_LEVEL(OP_BUYSTOP, OpenPrice)  //Check Dist from openPrice to Bid
         && CheckStopLoss(OpenPrice,  SL, TP)                  //Check Dist from SL, TP to OpenPrice         
         && CheckMoneyForTrade(_Symbol, lot1, OP_BUY))        //Check Balance khi lenh cho duoc Hit
      {
         if(!OrderSend(_Symbol, OP_BUYSTOP, lot1, OpenPrice, slippage, SL, TP, comment, InpMagicNumber, 0, clrBlue))
         Print(__FUNCTION__,"--> OrderSend error ",GetLastError());
      }
   }
   
}
//+------------------------------------------------------------------+
//| TRAILING STOP                                                    |
//+------------------------------------------------------------------+
void TrailingStop()
  {
   double SL_in_Pip = 0;


   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if((OrderMagicNumber() == InpMagicNumber) && (OrderSymbol() == Symbol()))   //_Symbol))
           {
            // For Buy oder
            if(OrderType() == OP_BUY)
              {
                  //--Calculate SL when price changed
                  SL_in_Pip = NormalizeDouble(Bid - OrderStopLoss(),Digits) / Pips2Double;
                  if(SL_in_Pip > InpSL_Pips)
                    {
                        double newSL = NormalizeDouble(Bid - InpSL_Pips * Pips2Double, Digits);
                        if(!OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue))
                           {
                              Print(__FUNCTION__,"--> OrderModify error ",GetLastError());
                              continue;  
                           }
                    }

              }

            //For Sell Order
            else if(OrderType() == OP_SELL)
              {
                  //--Calculate SL when price changed
                  SL_in_Pip = NormalizeDouble(OrderStopLoss() - Bid, Digits) / Pips2Double;
                  if(SL_in_Pip > InpSL_Pips){
                        double newSL = NormalizeDouble(Bid + (InpSL_Pips) * Pips2Double, Digits);
                        if(!OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrRed))
                        {
                           Print(__FUNCTION__,"--> OrderModify error ",GetLastError());
                           continue;  
                        }
                    }
              }
            
            //For BuyStop Order
            else if(OrderType() == OP_BUYSTOP)
              {
                  SL_in_Pip = NormalizeDouble(Bid - OrderStopLoss(), Digits) / Pips2Double;
                  
                  if(SL_in_Pip < InpSL_Pips/2){
                     double newOP = NormalizeDouble(Bid + (InpSL_Pips/2) * Pips2Double, Digits);
                     double newTP =  NormalizeDouble(newOP + InpTP_Pips * Pips2Double, Digits);
                     double newSL = NormalizeDouble(Bid - (InpSL_Pips/2) * Pips2Double, Digits);
                     
                     if(!OrderModify(OrderTicket(), newOP, newSL, newTP, 0, clrRed))
                     {
                        Print(__FUNCTION__,"--> Modify PendingOrder error!", GetLastError());
                        continue;  
                     }
                  
                  }
              }
              
            //For SellStop Order
            else if(OrderType() == OP_SELLSTOP)
              {
                  SL_in_Pip = NormalizeDouble(OrderStopLoss() - Ask, Digits) / Pips2Double;
                  
                  if(SL_in_Pip < InpSL_Pips/2){
                     double newOP = NormalizeDouble(Ask - (InpSL_Pips/2) * Pips2Double, Digits);
                     double newTP =  NormalizeDouble(newOP - InpTP_Pips * Pips2Double, Digits);
                     double newSL = NormalizeDouble(Ask + (InpSL_Pips/2) * Pips2Double, Digits);
                     
                     if(!OrderModify(OrderTicket(), newOP, newSL, newTP, 0, clrRed))
                     {
                        Print(__FUNCTION__,"--> Modify PendingOrder error!", GetLastError());
                        continue;  
                     }
                  
                  }
              }
              
           }
        }
     }
  }

// ------------------------------------------------------------------------------------------------
// UPDATE ORDERS
// ------------------------------------------------------------------------------------------------
void UpdateOrders()
  {
   isOrder = false;
  
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS, MODE_TRADES)) continue;

      if(OrderSymbol() == _Symbol && OrderMagicNumber() == InpMagicNumber){
            if(OrderType() == OP_BUY || OrderType() == OP_SELL){
               isOrder = true;
            }

            
            //Check lenh cho va xoa gia cho cua TSL_Price
            if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP){
               isOrder = true;
               max_profit1 = 0;
                  //Delete All of Objects
                  
               for(int n = ObjectsTotal()-1; n>=0; n--)
                 {
                  string objectName = ObjectName(n);
                  //Delete All Arrows
                  if(ObjectType(objectName)==OBJ_ARROW)
                     ObjectDelete(objectName);
                 }
            }
         }
       
      }
   }

//+------------------------------------------------------------------+
//| CALCULATE VOLUME                                                 |
//+------------------------------------------------------------------+
// We define the function to calculate the position size and return the lot to order.
double CalculateVolume()
  {
   double LotSize = 0;

   if(isVolume_Percent == false)
     {
      LotSize = Inpuser_lot;
     }
   else
     {

      LotSize = (InpRisk) * AccountFreeMargin();
      LotSize = LotSize /100000;
      double n = MathFloor(LotSize/Inpuser_lot);
      //Comment((string)n);
      LotSize = n * Inpuser_lot;

      if(LotSize < Inpuser_lot)
         LotSize = Inpuser_lot;

      if(LotSize > MarketInfo(Symbol(),MODE_MAXLOT))
         LotSize = MarketInfo(Symbol(),MODE_MAXLOT);

      if(LotSize < MarketInfo(Symbol(),MODE_MINLOT))
         LotSize = MarketInfo(Symbol(),MODE_MINLOT);
     }

   return(LotSize);
  }

 
//+------------------------------------------------------------------+
//| CHECK ST AND TP                                                  |
//+------------------------------------------------------------------+
bool CheckStopLoss_Takeprofit(ENUM_ORDER_TYPE type,double price, double SL)
{
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
   int stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(stops_level!=0)
     {
         PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must"+
            " not be nearer than %d points from the closing price",stops_level,stops_level);
     }
     
     int freeze_level = (int)SymbolInfoInteger(_Symbol,  SYMBOL_TRADE_FREEZE_LEVEL);
//---
   bool SL_check=false,TP_check=false, check = false;
//--- check only two order types
   switch(type)
     {
         //--- Buy operation
         case ORDER_TYPE_BUY_STOP:
         {
         //--- check the StopLoss
         //   SL_check=(Bid-SL>stops_level*_Point);
         //if(!SL_check)
         //   PrintFormat("For order %s StopLoss=%.5f must be less than %.5f"+
         //               " (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
         //               EnumToString(type),SL,Bid-stops_level*_Point,Bid,stops_level);
                        
        //--- check the distance from the opening price to the activation price
        check = ((price-Ask) > freeze_level*_Point);
            //--- return the result of checking
         return(check);
         }
      //--- Sell operation
      case ORDER_TYPE_SELL_STOP:
         {
         //--- check the StopLoss
      //   SL_check = (SL-Ask>stops_level*_Point);
      //if(!SL_check)
      //      PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f "+
      //      " (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
      //         EnumToString(type),SL,Ask+stops_level*_Point,Ask,stops_level);
         //--- check the distance from the opening price to the activation price
            check = ((Bid-price)>freeze_level*_Point);

         //--- return the result of checking
         return(check);
}
         break;
     }
//--- a slightly different function is required for pending orders
   return false;
   } 
   
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume)//,string &description)
{
//--- minimal allowed volume for trade operations
  double min_volume=SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if(volume < min_volume)
     {
      //description = StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      //description = StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   int ratio = (int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      //description = StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f", volume_step,ratio*volume_step);
      return(false);
     }
     
//--- check volume limit
//   double limit_volume= SymbolInfoDouble (_Symbol, SYMBOL_VOLUME_LIMIT);
//
//   if (limit_volume> 0 && limit_volume - AllVolumes - volume <= 0)
//      {
//         //PrintFormat("%.2f - %.2f",max_volume , dlot);
//         return false ;
//      }
      
   //description="Correct volume value";
   return(true);
}


//+------------------------------------------------------------------+
//| CHECK ST AND TP                                                  |
//+------------------------------------------------------------------+
bool CheckOrderForFREEZE_LEVEL(int type, double price)
{
   int freeze_level = (int)SymbolInfoInteger(_Symbol,  SYMBOL_TRADE_FREEZE_LEVEL);//MarketInfo(Symbol(),MODE_FREEZELEVEL);
   int stop_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   
   bool check = false;
   
//--- check only two order types
   switch(type)
     {
      //--- Buy operation
      case OP_BUYSTOP:
      {
         //--- check the distance from the opening price to the activation price
         check = ((price-Ask) > MathMax(freeze_level, stop_level) *_Point);
         //--- return the result of checking
         return(check);
      }
      //--- Sell operation
      case OP_SELLSTOP:
      {
         //--- check the distance from the opening price to the activation price
         check = ((Bid-price) > MathMax(freeze_level, stop_level) * _Point);

         //--- return the result of checking
         return(check);
      }
      break;
     }
//--- a slightly different function is required for pending orders
   return false;
}
   
bool CheckMoneyForTrade(string symb, double lots, int type)
{
   double free_margin = AccountFreeMarginCheck(symb, type, lots);
   //-- if there is not enough money
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Will not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
   //--- checking successful
   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSpreadAllow(){
   //double acSpread = NormalizeDouble(MarketInfo(_Symbol, MODE_SPREAD), _Digits) / Pips2Points;
   acSpread = MarketInfo(Symbol(), MODE_SPREAD);// / Pips2Points;
   if(InpMax_spread != 0){
      if(acSpread > InpMax_spread){
         Print(__FUNCTION__," > current Spread = " + (string)acSpread + " > greater than user Spread!...");
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//|CHECK SL AND TP FOR PENDING ORDER                                 |
//+------------------------------------------------------------------+

bool CheckStopLoss(double price, double SL, double TP)
{
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
   int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   if(stops_level != 0)
     {
      PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must"+
                  " not be nearer than %d points from the closing price", stops_level, stops_level);
     }
//---
   bool SL_check = true;
   bool TP_check = true;
   
   if(SL != 0)
   {
      //--- check the StopLoss
      SL_check = MathAbs(price - SL) > (stops_level * _Point);
   }
   
   if(TP != 0)
   {
      //--- check the Takeprofit
      TP_check = MathAbs(price - TP) > (stops_level * _Point);
   }
      //--- return the result of checking
      return(TP_check&&SL_check);  
}

//+------------------------------------------------------------------+
//| Day Of Week Description                                          |
//+------------------------------------------------------------------+
string DayOfWeekDescription(const int day_of_week)
  {
   string text="";
   switch(day_of_week)
     {
      case  0:
         text="Sunday";
         break;
      case  1:
         text="Monday";
         break;
      case  2:
         text="Tuesday";
         break;
      case  3:
         text="Wednesday";
         break;
      case  4:
         text="Thursday";
         break;
      case  5:
         text="Friday";
         break;
      case  6:
         text="Saturday";
         break;
      default:
         text="Another day";
         break;
     }
//---
   return(text);
  }