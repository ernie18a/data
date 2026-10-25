//+------------------------------------------------------------------+
//|                                                                  |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property description "Buys or sells when current MA goes above or below previous MA."
#property description "This will only buy, sell, or close at the beginning of a new bar."
#property description "Try it on Daily bars with the default settings, for a trendy pair."
#property strict
#include <Schedule\Schedule.mqh>
//----

enum ENUM_ALLOWED_TRADE_DIRECTION
  {
   TRADE_LONG_ONLY=0,
   TRADE_SHORT_ONLY=1,
   TRADE_LONG_AND_SHORT=2
  };

extern ENUM_ALLOWED_TRADE_DIRECTION Allowed_Trade_Direction=2;
extern bool HedgingAllowed=false;
extern bool Hidden_Tp_Sl=false;
extern double Leverage_Per_Position=10;
extern double StopLoss_Percent=0;
extern double Trailing_StopLoss_Percent=0;
extern double TakeProfit_Percent=0;
extern int Slippage=10;
extern int Minimum_Free_Equity_Percent=50;
extern bool Close_All_At_Minimum_Free_Equity_Reached=true;
extern bool Average_Up=false;
extern bool Average_Down=false;
extern double Averaging_Step_Size_Percent=0;
extern double Averaging_Down_Step_Multiplier=1;
extern bool Close_All_At_MA_Crossover=true;
extern ENUM_TIMEFRAMES MA_Timeframe_Previous=1440;
extern ENUM_TIMEFRAMES MA_Timeframe_Current=1440;
extern int MA_Period_Previous_Add=10;
extern int MA_Period_Current=42;
extern int MA_Shift_Previous=2;
extern int MA_Shift_Current=0;
extern ENUM_MA_METHOD MA_Method=0;
extern ENUM_APPLIED_PRICE MA_Applied_Price=1;
extern ENUM_DAY_OF_WEEK Start_Day=1;//Start Day
extern ENUM_DAY_OF_WEEK End_Day=5;//End Day
extern string   Start_Time="12:30";//Start Time
extern string   End_Time="14:30";//End Time

Schedule schedule(Start_Day,Start_Time,End_Day,End_Time);
bool Kill_Test_On_Validation_Error=true;
double effectiveLeverage=Leverage_Per_Position;
double Lots=0;
double StopLoss=0;
double TrailingStopLoss=0;
double TakeProfit=0;
double scaledSl=0;
double scaledTSl= 0;
double scaledTp = 0;
double sl=0;
double tsl= 0;
double tp = 0;
double freeEquityFactor=100;
double minMargin=0;
datetime lastBarTime=Time[0];
int MA_Period_Previous=1440;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   MA_Period_Previous=MA_Period_Current+MA_Period_Previous_Add;
   if(StopLoss_Percent>0)
     {
      StopLoss=StopLoss_Percent/100;
     }
   if(Trailing_StopLoss_Percent>0)
     {
      TrailingStopLoss=Trailing_StopLoss_Percent/100;
     }
   if(TakeProfit_Percent>0)
     {
      TakeProfit=TakeProfit_Percent/100;
     }
   if(Minimum_Free_Equity_Percent>0)
     {
      freeEquityFactor=NormalizeDouble(Minimum_Free_Equity_Percent,2)/100;
     }
  }
//+------------------------------------------------------------------+
//|Determines whether any of the settings is in an invalid state.    |
//+------------------------------------------------------------------+
bool ValidateSettings()
  {
   bool out=true;
   string message="";

   if(Leverage_Per_Position<=0)
     {
      message=("Your Leverage_Per_Position is set to an invalid amount. It must be greater than 0.");
      out=false;
     }
   else if(StopLoss_Percent<0)
     {
      message=("The StopLoss_Percent must be 0 or greater. Set it to 0 to disable the stop loss.");
      out=false;
     }
   else if(Trailing_StopLoss_Percent<0)
     {
      message=("The Trailing_StopLoss_Percent must be 0 or greater. Set it to 0 to disable the trailing stop loss.");
      out=false;
     }
   else if(TakeProfit_Percent<0)
     {
      message=("The TakeProfit_Percent must be 0 or greater. Set it to 0 to disable the take profit.");
      out=false;
     }
   else if(Slippage<0)
     {
      message=("The Slippage must be 0 or greater.");
      out=false;
     }
   else if(Minimum_Free_Equity_Percent<0)
     {
      message=("The Minimum_Free_Equity_Percent must be 0 or greater. Set it to zero to disable guards against excessive leverage and drawdown.");
      out=false;
     }
   else if(Averaging_Step_Size_Percent<0)
     {
      message=("The Averaging_Step_Size_Percent must be 0 or greater. This only applies when using one of the averaging options.");
      out=false;
     }
   else if(Averaging_Down_Step_Multiplier<=0)
     {
      message=("The Averaging_Down_Step_Multiplier must be greater than zero. This only applies when using one of the averaging options.");
      out=false;
     }
   else if(MA_Timeframe_Previous<=0)
     {
      message=("The MA_Timeframe_Previous must be one of ENUM_TIMEFRAMES.");
      out=false;
     }
   else if(MA_Timeframe_Current<=0)
     {
      message=("The MA_Timeframe_Current must be one of ENUM_TIMEFRAMES.");
      out=false;
     }
//else if(MA_Period_Previous_Add<0)
//  {
//   message=("The MA_Period_Previous_Add must be 0 or greater.");
//   out=false;
//  }
   else if(MA_Period_Current<=0)
     {
      message=("The MA_Period_Current must be greater than zero.");
      out=false;
     }
   else if(MA_Shift_Previous<0)
     {
      message=("The MA_Shift_Previous must be 0 or greater.");
      out=false;
     }
   else if(MA_Shift_Current<0)
     {
      message=("The MA_Shift_Current must be 0 or greater.");
      out=false;
     }
   else if(MA_Method<0)
     {
      message=("The MA_Method must be a valid value in ENUM_MA_METHOD.");
      out=false;
     }
   else if(MA_Applied_Price<0)
     {
      message=("The MA_Applied_Price must be a valid value in ENUM_APPLIED_PRICE.");
      out=false;
     }

   if(out==false)
     {
      Print("");
      Print("!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~");
      Print("");
      Print("User Settings validation failed.");
      Print(message);
      Print("");
      Print("!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~");
      Print("");
      ExpertRemove();
     }

   return out;
  }
//+------------------------------------------------------------------+
//|Validates internally calculated settings.                         |
//+------------------------------------------------------------------+
bool ValidateCalculatedSettings()
  {
   bool out=true;
   string message="";

   if(effectiveLeverage<=0)
     {
      message=("The effectiveLeverage must be greater than zero.");
      out=false;
     }
   else if(Lots<=0)
     {
      message=("The Lots must be greater than zero.");
      out=false;
     }
   else if(StopLoss<0)
     {
      message=("The StopLoss must be 0 or greater.");
      out=false;
     }
   else if(TrailingStopLoss<0)
     {
      message=("The TrailingStopLoss must be 0 or greater.");
      out=false;
     }
   else if(TakeProfit<0)
     {
      message=("The TakeProfit must be 0 or greater.");
      out=false;
     }
   else if(scaledSl<0)
     {
      message=("The scaledSl must be 0 or greater.");
      out=false;
     }
   else if(scaledTp<0)
     {
      message=("The scaledTp must be 0 or greater.");
      out=false;
     }
   else if(sl<0)
     {
      message=("The sl must be 0 or greater.");
      out=false;
     }
   else if(tp<0)
     {
      message=("The tp must be 0 or greater.");
      out=false;
     }
   else if(freeEquityFactor<0)
     {
      message=("The freeEquityFactor must be 0 or greater.");
      out=false;
     }
   else if(minMargin<0)
     {
      message=("The minMargin must be 0 or greater.");
      out=false;
     }
   else if(lastBarTime<=0)
     {
      message=("The lastBarTime must be greater than zero.");
      out=false;
     }
   else if(MA_Period_Previous<=0)
     {
      message=("The MA_Period_Previous must be greater than zero.");
      out=false;
     }

   if(out==false)
     {
      Print("");
      Print("!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~");
      Print("");
      Print("Calculated Settings validation failed.");
      Print(message);
      Print("");
      Print("!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~!~");
      Print("");
      if(Kill_Test_On_Validation_Error==true)
        {
         ExpertRemove();
        }
     }

   return out;
  }
//+------------------------------------------------------------------+
//|Rules to stop the bot from even trying to trade                   |
//+------------------------------------------------------------------+
bool CanTrade()
  {
   bool out=true;
   string message="";

   if(!IsTradeAllowed())
     {
      return false;
     }

   if(!IsNewBar())
     {
      return false;
     }

   if(!schedule.IsActive(Time[0]))
     {
      return false;
     }
     
   if(Bars<MA_Period_Current)
     {
      message=("bars less than MA_Period_Current. Waiting for more history.");
      out=false;
     }
   else if(Bars<MA_Period_Previous)
     {
      message=("bars less than MA_Period_Previous. Waiting for more history.");
      out=false;
     }

   if(out==false)
     {
      Print(message);
     }

   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateMinMargin()
  {
   minMargin=AccountEquity()*freeEquityFactor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void NormalizeExits(string symbol,ENUM_ORDER_TYPE orderType)
  {
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(OrderStopLoss()!=sl || OrderTakeProfit()!=tp)
           {
            bool ret=OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0);
            if(!ret)
              {
               Print(GetLastError());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateSlTp(string symbol,ENUM_ORDER_TYPE orderType,bool whatIfOrder)
  {
   double stopLevel=MarketInfo(symbol,MODE_STOPLEVEL)*Point;
   double avgPrice=0;
   if(whatIfOrder==true)
     {
      avgPrice=PairAveragePriceWithAdditonalOrder(symbol,orderType,Lots);
     }
   else
     {
      avgPrice=PairAveragePrice(symbol,orderType);
     }

   sl=0;
   tsl=0;
   tp=0;
   scaledSl=0;
   scaledTSl= 0;
   scaledTp = 0;

   CalculateEffectiveLeverage(symbol,orderType);

   if(StopLoss>0)
     {
      scaledSl=(StopLoss/effectiveLeverage);
     }

   if(TrailingStopLoss>0)
     {
      scaledTSl=(TrailingStopLoss/effectiveLeverage);
     }

   if(TakeProfit>0)
     {
      scaledTp=(TakeProfit/effectiveLeverage);
     }

   if(orderType==OP_BUY)
     {
      sl=PairHighestStopLoss(symbol,orderType);
      tsl=sl;
      tp=PairHighestTakeProfit(symbol,orderType);

      calculateSlBuy(symbol,avgPrice,stopLevel);
      calculateTSlBuy(symbol,stopLevel);
      if((tsl!=0) && (tsl>sl || sl==0))
        {
         sl=tsl;
        }
      calculateTpBuy(symbol,avgPrice,stopLevel);
     }

   if(orderType==OP_SELL)
     {
      sl=PairLowestStopLoss(symbol,orderType);
      tsl=sl;
      tp=PairLowestTakeProfit(symbol,orderType);

      calculateSlSell(symbol,avgPrice,stopLevel);
      calculateTSlSell(symbol,stopLevel);
      if((tsl!=0) && (tsl<sl || sl==0))
        {
         sl=tsl;
        }
      calculateTpSell(symbol,avgPrice,stopLevel);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateSlBuy(string symbol,double avgPrice,double stopLevel)
  {
   double tmpDbl=0;
   if(avgPrice==0)
     {
      avgPrice=Ask;
     }

   if(StopLoss>0 && (sl==0 || Average_Up || Average_Down))
     {
      tmpDbl=NormalizeDouble(Bid-(Bid*scaledSl),Digits);
      if(tmpDbl>avgPrice)
        {
         tmpDbl=avgPrice;
        }
      else
        {
         tmpDbl=NormalizeDouble(avgPrice-(avgPrice*scaledSl),Digits);
        }
      if(tmpDbl>sl || sl==0)
        {
         sl=tmpDbl;
        }
      if((avgPrice*scaledSl)<stopLevel)
        {
         sl=NormalizeDouble(Bid-stopLevel,Digits);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateTSlBuy(string symbol,double stopLevel)
  {
   double tmpDbl=0;
   if(TrailingStopLoss>0)
     {
      tmpDbl=NormalizeDouble(Bid-(Bid*scaledTSl),Digits);
      if(tmpDbl>tsl || tsl==0)
        {
         tsl=tmpDbl;
        }
      if((Bid*scaledTSl)<stopLevel)
        {
         tsl=NormalizeDouble(Bid-stopLevel,Digits);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateSlSell(string symbol,double avgPrice,double stopLevel)
  {
   double tmpDbl=0;
   if(avgPrice==0)
     {
      avgPrice=Bid;
     }
   if(StopLoss>0 && (sl==0 || Average_Up || Average_Down))
     {
      tmpDbl=NormalizeDouble(Ask+(Ask*scaledSl),Digits);
      if(tmpDbl<avgPrice)
        {
         tmpDbl=avgPrice;
        }
      else
        {
         tmpDbl=NormalizeDouble(avgPrice+(avgPrice*scaledSl),Digits);
        }
      if(tmpDbl<sl || sl==0)
        {
         sl=tmpDbl;
        }
      if((avgPrice*scaledSl)<stopLevel)
        {
         sl=NormalizeDouble(Ask+stopLevel,Digits);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateTSlSell(string symbol,double stopLevel)
  {
   double tmpDbl=0;
   if(TrailingStopLoss>0)
     {
      tmpDbl=NormalizeDouble(Ask+(Ask*scaledTSl),Digits);
      if(tmpDbl<tsl || tsl==0)
        {
         tsl=tmpDbl;
        }
      if((Ask*scaledTSl)<stopLevel)
        {
         tsl=NormalizeDouble(Ask+stopLevel,Digits);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateTpBuy(string symbol,double avgPrice,double stopLevel)
  {
   double tmpDbl=0;
   if(avgPrice==0)
     {
      avgPrice=Ask;
     }
   if(TakeProfit>0 && (tp==0 || Average_Up || Average_Down))
     {
      tmpDbl=NormalizeDouble(avgPrice+(avgPrice*scaledTp),Digits);
      if(avgPrice<=tmpDbl && (tmpDbl<tp || tp==0))
        {
         tp=tmpDbl;
        }
      if((avgPrice*scaledTp)<stopLevel)
        {
         double x=NormalizeDouble(avgPrice+stopLevel,Digits);
         if(avgPrice<x)
           {
            tp=x;
           }
        }
     }
   if(tp<0)
     {
      tp=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateTpSell(string symbol,double avgPrice,double stopLevel)
  {
   double tmpDbl=0;
   if(avgPrice==0)
     {
      avgPrice=Bid;
     }
   if(TakeProfit>0 && (tp==0 || Average_Up || Average_Down))
     {
      tmpDbl=NormalizeDouble(avgPrice-(avgPrice*scaledTp),Digits);
      if(avgPrice>=tmpDbl && (tmpDbl>tp || tp==0))
        {
         tp=tmpDbl;
        }
      if((avgPrice*scaledTp)<stopLevel)
        {
         double x=NormalizeDouble(avgPrice-stopLevel,Digits);
         if(avgPrice>x)
           {
            tp=x;
           }
        }
     }
   if(tp<0)
     {
      tp=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrders(string symbol,ENUM_ORDER_TYPE orderType)
  {
   int ticket,i;
//----
   while(PairHighestPricePaid(symbol,orderType)>0)
     {
      for(i=0;i<OrdersTotal();i++)
        {
         ticket=OrderSelect(i,SELECT_BY_POS);
         if(OrderType()==OP_BUY && OrderSymbol()==symbol)
           {
            if(OrderClose(OrderTicket(),OrderLots(),Bid,Slippage)==false)
              {
               Print(GetLastError());
              }
           }
         if(OrderType()==OP_SELL && OrderSymbol()==symbol)
           {
            if(OrderClose(OrderTicket(),OrderLots(),Ask,Slippage)==false)
              {
               Print(GetLastError());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|Returns true when there are no open positions or when all open    |
//|positions are of the given orderType                              |
//+------------------------------------------------------------------+
bool CanMarketOrderForOp(string symbol,ENUM_ORDER_TYPE orderType)
  {
   bool result;

   result=True;
   if(HedgingAllowed==True)
     {
      return true;
     }
   if(orderType==OP_BUY && PairHighestPricePaid(symbol,OP_SELL)>0)
     {
      result=false;
     }
   if(orderType==OP_SELL && PairHighestPricePaid(symbol,OP_BUY)>0)
     {
      result=false;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   bool output=false;
   if(lastBarTime!=Time[0])
     {
      lastBarTime=Time[0];
      output=true;
     }
   return output;
  }
//+------------------------------------------------------------------+
//|Gets the highest stop loss for any order on the given pair.       |
//+------------------------------------------------------------------+
double PairHighestStopLoss(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || OrderStopLoss()>num)
           {
            num=OrderStopLoss();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the lowest stop loss for any order on the given pair.        |
//+------------------------------------------------------------------+
double PairLowestStopLoss(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || OrderStopLoss()<num)
           {
            num=OrderStopLoss();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the highest take profit for any order on the given pair.     |
//+------------------------------------------------------------------+
double PairHighestTakeProfit(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || OrderTakeProfit()>num)
           {
            num=OrderTakeProfit();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the lowest take profit for any order on the given pair.      |
//+------------------------------------------------------------------+
double PairLowestTakeProfit(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || OrderTakeProfit()<num)
           {
            num=OrderTakeProfit();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the highest price paid for any order on the given pair.      |
//+------------------------------------------------------------------+
double PairHighestPricePaid(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || OrderOpenPrice()>num)
           {
            num=OrderOpenPrice();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|Gets the lowest price paid for any order on the given pair.       |
//+------------------------------------------------------------------+
double PairLowestPricePaid(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         if(num==0 || OrderOpenPrice()<num)
           {
            num=OrderOpenPrice();
           }
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PairProfit(string symbol)
  {
   double output=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol)
        {
         output+=OrderProfit();
        }
     }
   return output;
  }
//+------------------------------------------------------------------+
//|Gets the current average price paid for the given currency pair.  |
//+------------------------------------------------------------------+
double PairAveragePrice(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   double sum=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         sum=sum+OrderOpenPrice() * OrderLots();
         num=num+OrderLots();
        }
     }
   if(num>0 && sum>0)
     {
      return (sum / num);
     }
   else
     {
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|Gets the current average price paid for the given currency pair.  |
//+------------------------------------------------------------------+
double PairAveragePriceWithAdditonalOrder(string symbol,ENUM_ORDER_TYPE orderType,double size)
  {
   double num=0;
   double sum=0;
   if(orderType==OP_BUY)
     {
      num=size * 100000;
      sum=Ask * size * 100000;
     }
   if(orderType==OP_SELL)
     {
      num=size * 100000;
      sum=Bid * size * 100000;
     }

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         sum=sum+OrderOpenPrice() * (OrderLots() * 100000);
         num=num+(OrderLots() * 100000);
        }
     }

   if(num>0 && sum>0)
     {
      return (sum / num);
     }
   else
     {
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetHighStep(string symbol,double multiplier,ENUM_ORDER_TYPE orderType)
  {
   double highPrice=PairHighestPricePaid(symbol,orderType);
   double highStep=highPrice;
   if(Averaging_Step_Size_Percent>0)
     {
      highStep=highPrice+(((Averaging_Step_Size_Percent*multiplier)/100)*highPrice);
     }
   return highStep;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLowStep(string symbol,double multiplier,ENUM_ORDER_TYPE orderType)
  {
   double lowPrice=PairLowestPricePaid(symbol,orderType);
   double lowStep=lowPrice;
   if(Averaging_Step_Size_Percent>0)
     {
      lowStep=lowPrice -(((Averaging_Step_Size_Percent*multiplier)/100)*lowPrice);
     }
   return lowStep;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateLots(string symbol)
  {
   double minLots = MarketInfo(symbol,MODE_MINLOT);
   double maxLots = MarketInfo(symbol,MODE_MAXLOT);
   double lotStep = MarketInfo(symbol,MODE_LOTSTEP);
   Lots=NormalizeDouble(AccountBalance()/100000,2)*Leverage_Per_Position;
   double modLots=NormalizeDouble(Lots-MathMod(Lots,lotStep),2);
   if(modLots>0)
     {
      Lots=modLots;
     }
   if(Lots<minLots)
     {
      Lots=minLots;
      //Print("Lot size is too small. Using broker specified minimum lot size ",minLots);
     }
   if(Lots>maxLots)
     {
      Lots=maxLots;
      //Print("Lot size is too large. Using broker specified maximum lot size ",maxLots);
     }
  }
//+------------------------------------------------------------------+
//|Gets the total size on the given currency pair.                   |
//+------------------------------------------------------------------+
double PairLotsTotal(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double num=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==symbol && OrderType()==orderType)
        {
         num=num+OrderLots();
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateEffectiveLeverage(string symbol,ENUM_ORDER_TYPE orderType)
  {
   double currentSize=NormalizeDouble((PairLotsTotal(symbol,orderType)*100000),0);
   double num=0;
   if(currentSize>0)
     {
      num=(currentSize/AccountBalance());
     }

   if(num>0)
     {
      effectiveLeverage=num;
     }
   else
     {
      effectiveLeverage=Leverage_Per_Position;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarginGuard(string symbol)
  {
   CalculateMinMargin();
   if(AccountFreeMargin()<=minMargin)
     {
      Print("Closing all open positons, minimum margin reached or exceeded.");
      CloseOrders(symbol,OP_BUY);
      CloseOrders(symbol,OP_SELL);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!ValidateSettings())
     {
      return;
     }

   if(!IsTradeAllowed())
     {
      return;
     }

   string symbol=Symbol();

   if(Hidden_Tp_Sl==true)
     {
      if(TakeProfit>0 && (PairProfit(symbol)>=AccountBalance()*TakeProfit))
        {
         CloseOrders(symbol,OP_BUY);
         CloseOrders(symbol,OP_SELL);
        }

      if(StopLoss>0 && ((PairProfit(symbol)*-1)>=AccountBalance()*StopLoss))
        {
         CloseOrders(symbol,OP_BUY);
         CloseOrders(symbol,OP_SELL);
        }
     }
   else
     {
      CalculateSlTp(symbol,OP_BUY,false);
      CalculateEffectiveLeverage(symbol,OP_BUY);
      NormalizeExits(symbol,OP_BUY);

      CalculateSlTp(symbol,OP_SELL,false);
      CalculateEffectiveLeverage(symbol,OP_SELL);
      NormalizeExits(symbol,OP_SELL);
     }

   if(Close_All_At_Minimum_Free_Equity_Reached==true)
     {
      MarginGuard(symbol);
     }

   int ticket=0;
   double MA=iMA(symbol,MA_Timeframe_Current,MA_Period_Current,MA_Shift_Current,MA_Method,MA_Applied_Price,0);
   double MAPrev=iMA(symbol,MA_Timeframe_Previous,MA_Period_Previous,MA_Shift_Previous,MA_Method,MA_Applied_Price,0);

   CalculateMinMargin();
   CalculateLots(symbol);

   Comment("MA Previous : ",MAPrev
           ,"\r\nMA : ",MA
           ,"\r\nLots : ",Lots
           ,"\r\nAccount Balance : ",AccountBalance()
           ,"\r\nAccount Equity : ",AccountEquity()
           ,"\r\nP&L : ",AccountEquity()-AccountBalance()
           ,"\r\nFree Margin : ",AccountFreeMargin()
           ,"\r\nStopLoss : ",StopLoss
           ,"\r\nTakeProfit : ",TakeProfit
           ,"\r\nMin Margin Allowed : ",minMargin
           ,"\r\nSchedule : ",schedule.ToString());

   if(!CanTrade())
     {
      return;
     }

// Check any open BUY orders
   if(MAPrev<MA)
     {
      if(Close_All_At_MA_Crossover==true)
        {
         CloseOrders(symbol,OP_SELL);
        }
      if((Allowed_Trade_Direction==TRADE_LONG_ONLY || Allowed_Trade_Direction==TRADE_LONG_AND_SHORT) && (Average_Up || Average_Down || PairHighestPricePaid(symbol,OP_BUY)==0) && (CanMarketOrderForOp(symbol,OP_BUY)==true))
        {
         CalculateMinMargin();
         CalculateLots(symbol);
         if(AccountFreeMarginCheck(symbol,OP_BUY,Lots)<=minMargin || GetLastError()==134)
           {
            PrintFormat("Not Opening order, not enough free margin for %2.2f lots.",Lots);
           }
         else
           {
            if(
               PairHighestPricePaid(symbol,OP_BUY)==0
               || (Ask>GetHighStep(symbol,1,OP_BUY) && Average_Up)
               || (Ask<GetLowStep(symbol,Averaging_Down_Step_Multiplier,OP_BUY) && Average_Down)
               )
              {
               if(Hidden_Tp_Sl==false)
                 {
                  CalculateSlTp(symbol,OP_BUY,true);
                 }

               if(ValidateCalculatedSettings())
                 {
                  ticket=OrderSend(symbol,OP_BUY,Lots,Ask,Slippage,sl,tp);
                  if(ticket<0)
                    {
                     Print(GetLastError());
                    }
                  if(Hidden_Tp_Sl==false)
                    {
                     CalculateSlTp(symbol,OP_BUY,false);
                     NormalizeExits(symbol,OP_BUY);
                    }
                 }
              }
           }
        }
     }
// Check any open SELL orders
   if(MAPrev>MA)
     {
      if(Close_All_At_MA_Crossover==true)
        {
         CloseOrders(symbol,OP_BUY);
        }
      if((Allowed_Trade_Direction==TRADE_SHORT_ONLY || Allowed_Trade_Direction==TRADE_LONG_AND_SHORT) && (Average_Up || Average_Down || PairHighestPricePaid(symbol,OP_SELL)==0) && (CanMarketOrderForOp(symbol,OP_SELL)==true))
        {
         CalculateMinMargin();
         CalculateLots(symbol);
         if(AccountFreeMarginCheck(symbol,OP_SELL,Lots)<=minMargin || GetLastError()==134)
           {
            PrintFormat("Not Opening order, not enough free margin for %2.2f lots.",Lots);
           }
         else
           {
            if(
               PairHighestPricePaid(symbol,OP_SELL)==0
               || (Bid<GetLowStep(symbol,1,OP_SELL) && Average_Up)
               || (Bid>GetHighStep(symbol,Averaging_Down_Step_Multiplier,OP_SELL) && Average_Down)
               )
              {
               if(Hidden_Tp_Sl==false)
                 {
                  CalculateSlTp(symbol,OP_SELL,true);
                 }
               if(ValidateCalculatedSettings())
                 {
                  ticket=OrderSend(symbol,OP_SELL,Lots,Bid,Slippage,sl,tp);
                  if(ticket<0)
                    {
                     Print(GetLastError());
                    }
                  if(Hidden_Tp_Sl==false)
                    {
                     CalculateSlTp(symbol,OP_SELL,false);
                     NormalizeExits(symbol,OP_SELL);
                    }
                 }
              }
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
