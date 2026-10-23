//+------------------------------------------------------------------+
//|                           20PRExp-3(barabashkakvn's edition).mq5 |
//|                     Copyright © 2005-2007, Сергей (Sergey2005TR) |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedRisk m_money;
//--- Внешние параметры советника
sinput string _Parameters_Trade  = "----- Параметры торговли";
input ushort   TakeProfit        = 20;       // Take Profit
input ushort   TrailingStop      = 10;       // TrailingStop
input ushort   TrailingStep      = 10;       // TrailingStep
input double   Risk              = 5;        // Risk in percent for a deal from a free margin
sinput string _Parameters_Expert = "----- Параметры советника";
input ushort   Gap               = 50;
//--- Глобальные переменные советника
bool ft=true;
double MidL=0,MLP=0,MLM=0;
double canal;
//---
ulong          m_magic=20051214;             // magic number
ulong          m_slippage=30;                // slippage
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
int            handle_iSAR;                  // variable for storing the handle of the iSAR indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//SetMarginMode();
//if(!IsHedging())
//  {
//   Print("Hedging only!");
//   return(INIT_FAILED);
//  }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(m_symbol.Name(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(Risk);
//--- create handle of the indicator iSAR
   handle_iSAR=iSAR(m_symbol.Name(),PERIOD_M5,0.005,0.01);
//--- if the handle is not created 
   if(handle_iSAR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
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
// ObjectsDeleteAll(WindowOnDropped());
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
//---
   if(str1.hour>6)
     {
      MLP = iHigh(0,m_symbol.Name(),PERIOD_D1);
      MLM = iLow(0,m_symbol.Name(),PERIOD_D1);
      MidL= NormalizeDouble((MLP+MLM)/2,4);
      datetime time_0=iTime(0);
      MoveHLine("MidL",time_0,MidL,clrGold,1,STYLE_DOT);
      MoveHLine("MLP",time_0,MLP,clrLime,1,STYLE_DOT);
      MoveHLine("MLM",time_0,MLM,clrMagenta,1,STYLE_DOT);
      canal=MLP-MLM;
      ft=true;
     }
//Comment(TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES),"\n",
//        " Min=",DoubleToString(MLM,m_symbol.Digits()),
//        ", Max=",DoubleToString(MLP,m_symbol.Digits()),
//        ", Pivot=",DoubleToString(MidL,4));

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(iSARGet(0)>iClose(1))
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
               if(TrailingStop>0)
                 {
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>TrailingStop*m_adjusted_point)
                    {
                     if(m_position.StopLoss()<m_symbol.Bid()-(TrailingStop+TrailingStep)*m_adjusted_point)
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_symbol.Bid()-TrailingStop*m_adjusted_point),
                           m_symbol.NormalizePrice(m_symbol.Bid()+TrailingStop*m_adjusted_point)))
                           //OrderModify(OrderTicket(),OrderOpenPrice(),
                           //            Bid-Point*TrailingStop,
                           //            Bid+Point*TrailingStop,0,Green);
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        return;
                       }
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(iSARGet(0)<iClose(1))
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
               if(TrailingStop>0)
                 {
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>TrailingStop*m_adjusted_point)
                    {
                     if(m_position.StopLoss()>m_symbol.Ask()+(TrailingStop+TrailingStep)*m_adjusted_point ||
                        m_position.StopLoss()==0)
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_symbol.Ask()+TrailingStop*m_adjusted_point),
                           m_symbol.NormalizePrice(m_symbol.Ask()-TrailingStop*m_adjusted_point)))
                           //OrderModify(OrderTicket(),OrderOpenPrice(),
                           //         Ask+Point*TrailingStop,
                           //         Ask-Point*TrailingStop,0,Red);
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        return;
                       }
                    }
                 }
              }
           }

   OpenPosition();
//---
  }
//+------------------------------------------------------------------+
//| Функции                                                          |
//+------------------------------------------------------------------+
bool MoveHLine(string name,datetime time,double price,color clr,int width,int style)
  {
   if(ObjectFind(0,name)<0)
     {
      //--- сбросим значение ошибки
      ResetLastError();
      //--- создадим горизонтальную линию
      if(!ObjectCreate(0,name,OBJ_HLINE,0,time,price))
        {
         Print(__FUNCTION__,
               ": не удалось создать горизонтальную линию! Код ошибки = ",GetLastError());
         return(false);
        }
      //--- установим цвет линии
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      //--- установим толщину линии
      ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
      //--- установим стиль отображения линии
      ObjectSetInteger(0,name,OBJPROP_STYLE,style);
     }
   else
     {
      //--- сбросим значение ошибки
      ResetLastError();
      //--- переместим горизонтальную линию
      if(!ObjectMove(0,name,0,time,price))
        {
         Print(__FUNCTION__,
               ": не удалось переместить горизонтальную линию! Код ошибки = ",GetLastError());
         return(false);
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Открытие позиции                                                 |
//+------------------------------------------------------------------+
void OpenPosition()
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   if(total>0)
      return;

   double ldStop=0.0,ldTake=0.0;
   if(!RefreshRates())
      return;
   int    bs=GetTradeSignal();

   if(bs>0)
     {
      if(TakeProfit!=0)
         ldTake=m_symbol.Ask()+TakeProfit*m_adjusted_point;
      OpenBuy(MLM,ldTake);
      //OrderSend(Symbol(),OP_BUY,Lots(),Ask,3,MLM,ldTake,
      //          "Pipsover",888,0,Blue);
     }
   if(bs<0)
     {
      if(TakeProfit!=0)
         ldTake=m_symbol.Bid()-TakeProfit*m_adjusted_point;
      OpenSell(MLP,ldTake);
      //OrderSend(Symbol(),OP_SELL,Lots(),Bid,3,MLP,ldTake,
      //          "Pipsover",888,0,Red);
     }
  }
//+------------------------------------------------------------------+
//| Возвращает торговый сигнал:                                      |
//|    1 - покупай                                                   |
//|    0 - сиди, кури бамбук                                         |
//|   -1 - продавай                                                  |
//+------------------------------------------------------------------+
int GetTradeSignal()
  {
   double spread=m_symbol.Ask()-m_symbol.Bid();
   long vVolume = iTickVolume(0,m_symbol.Name(),PERIOD_M30);
   long pVolume = iTickVolume(1,m_symbol.Name(),PERIOD_M30);

   double test_bid=m_symbol.Bid();
   if(m_symbol.Bid() -(spread)<MLM && (vVolume/pVolume)>1.5 && canal>Gap*m_adjusted_point)
      return(-1);

   if(m_symbol.Ask()>MLP && (vVolume/pVolume)>1.5 && canal>Gap*m_adjusted_point)
      return(1);

   return(0);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+ 
//| Get the High for specified bar index                             | 
//+------------------------------------------------------------------+ 
double iHigh(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double High[1];
   double high=0;
   int copied=CopyHigh(symbol,timeframe,index,1,High);
   if(copied>0) high=High[0];
   return(high);
  }
//+------------------------------------------------------------------+ 
//| Get Low for specified bar index                                  | 
//+------------------------------------------------------------------+ 
double iLow(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Low[1];
   double low=0;
   int copied=CopyLow(symbol,timeframe,index,1,Low);
   if(copied>0) low=Low[0];
   return(low);
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+ 
//| Get TickVolume for specified bar index                           | 
//+------------------------------------------------------------------+ 
long iTickVolume(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   long TickVolume[1];
   long tickvolume=0;
   int copied=CopyTickVolume(symbol,timeframe,index,1,TickVolume);
   if(copied>0) tickvolume=TickVolume[0];
   return(tickvolume);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_long_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=check_open_long_lot)
        {
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_short_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iSAR                                |
//+------------------------------------------------------------------+
double iSARGet(const int index)
  {
   double SAR[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iSARBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iSAR,0,index,1,SAR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iSAR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(SAR[0]);
  }
//+------------------------------------------------------------------+
