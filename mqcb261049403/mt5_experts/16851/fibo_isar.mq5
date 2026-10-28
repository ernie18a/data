//+---------------------------------------------------------------------------0+|
//|                                      Fibo iSAR(barabashkakvn's edition).mq5 |
//|                            Разработано для 39 выпуска журнала  FORTRADER.RU |
//|                                                                             |
//| Описание стратегии:         http://www.forexsystems.ru/showthread.php?t=5495|
//| Описание некоторых функций: http://fxnow.ru/blog/programming_mql4/          |
//| Контакты:                   yuriy@fortrader.ru                              |
//+----------------------------------------------------------------------------+|
//|4-150
#property copyright "FORTRADER.RU"
#property link      "http://FORTRADER.RU"
#property version   "1.001"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include<Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object

#define MODE_LOW 1
#define MODE_HIGH 2

input int      InpControlTime       =false;  // Control Time
input uchar    IntStartTime         =7;      // Start Time (hour)
input uchar    IntStopTime          =17;     // Stop Time (hour)
input ushort   InpBBUSize           =0;      // Breakeven
input ushort   InpTrailingStop      =10;     // Trailing Stop
input ushort   InpTrailingStep      =5;      // Trailing Step
input double   InpStepFast          =0.02;   // Step Fast_SAR
input double   InpMaximumFast       =0.2;    // Maximum Fast_SAR
input double   InpStepSlow          =0.01;   // Step Slow_SAR
input double   InpMaximumSlow       =0.1;    // Maximum Slow_SAR
input int      InpCountBarSearch    =3;      // Count Bar Search
input int      InpIndentStopLoss    =30;     // Indent Stop Loss
input double   InpFiboEntranceLevel =50;     // Fibo Entrance Level
input double   InpFiboProfitLevel   =161;    // Fibo Profit Level

int nummodb,nummods;
int bars=0;
int err1;
int countbars,countbarv;

double ExtTrailingStop=0.0;
double ExtTrailingStep=0.0;
double ExtIndentStopLoss=0.0;

int    handle_iFastSAR;                      // variable for storing the handle of the iSAR indicator 
int    handle_iSlowSAR;                      // variable for storing the handle of the iSAR indicator 

string fibo_name="FiboLevels";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(IntStartTime>24 || IntStopTime>24)
     {
      Print("Start Time or Stop Time can't be more than 24");
      return(INIT_FAILED);
     }

   m_symbol.Name(Symbol());
   if(!RefreshRates())
     {
      Print("Ask: ",DoubleToString(m_symbol.Ask(),Digits()),
            ",Bid: ",DoubleToString(m_symbol.Bid(),Digits()));
      return(INIT_FAILED);
     }

//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtTrailingStop=InpTrailingStop*digits_adjust;
   ExtTrailingStep=InpTrailingStep*digits_adjust;
   ExtIndentStopLoss=InpIndentStopLoss*digits_adjust;

//--- create handle of the indicator iSAR
   handle_iFastSAR=iSAR(Symbol(),Period(),InpStepFast,InpMaximumFast);
//--- if the handle is not created 
   if(handle_iFastSAR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

//--- create handle of the indicator iSAR
   handle_iSlowSAR=iSAR(Symbol(),Period(),InpStepSlow,InpMaximumSlow);
//--- if the handle is not created 
   if(handle_iSlowSAR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//if(bars!=Bars(Symbol(),Period()) && ((!TimeControl(IntStartTime,IntStopTime) && InpControlTime) || !InpControlTime))
   if((!TimeControl(IntStartTime,IntStopTime) && InpControlTime) || !InpControlTime)
     {
      //bars=Bars(Symbol(),Period());
      err1=ScalpParabolicPattern();
     }

   if(ExtTrailingStop>0)
     {
      err1=Trailing();
     }
   if(InpBBUSize>0)
     {
      err1=BBU();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ScalpParabolicPattern()
  {
   bool err;
   double op,sl,tp,max,min,FiboLevel50,FiboLevel116;
   int sarmax=0,sarmin=0;

   if(!RefreshRates())
      return(-1);

   double SarSlow=iSARGet(handle_iSlowSAR,1);
   double SarFast=iSARGet(handle_iFastSAR,1);

//--- в самом низу SarSlow, выше её находится SarFast и цена m_symbol.Bid() выше SarFast
   if(SarSlow<SarFast && SarFast<m_symbol.Bid())
     {
      sarmax=0;
      min=MaximumMinimum(0);   //найдем текущий минимум
      max=iHigh(m_symbol.Name(),Period(),1);

      FiboLevel50=GetFiboUr(max,min,InpFiboEntranceLevel/100.0);//получим 50% значение фибо
      FiboLevel116=GetFiboUr(max,min,InpFiboProfitLevel/100.0); //получим 116% значение фибо

      op=FiboLevel50;
      sl=min-ExtIndentStopLoss*Point();
      tp=FiboLevel116;
      if((m_symbol.Ask()-op)<5*Point() || (m_symbol.Ask()-sl)<5*Point() || (tp-m_symbol.Ask())<5*Point())
        {
         return(0);
        }
      if(ChLimitOrder(1)==0 && ChPositions(1)==0)
        {
         err=m_trade.BuyLimit(0.1,NormalizeDouble(op,Digits()),Symbol(),sl,tp,
                              ORDER_TIME_SPECIFIED,TimeCurrent()+3*60,"FORTRADER.RU");
         if(!err)
           {
            Print("ScalpParabolicPattern()-  Ошибка установки отложенных ордеров OP_BUYLIMIT.  op ",
                  DoubleToString(op,Digits())," sl ",
                  DoubleToString(sl,Digits())," tp ",
                  DoubleToString(tp,Digits())," ",GetLastError());
            return(-1);
           }
         nummodb=0;
        }
     }
//--- в самом верху SarSlow, ниже её находится SarFast и цена m_symbol.Bid() ниже SarFast
   if(SarSlow>SarFast && SarFast>m_symbol.Bid())
     {
      sarmin=0;
      max=MaximumMinimum(1);   //найдем текущий максимум
      min=iLow(m_symbol.Name(),Period(),1);

      FiboLevel50=GetFiboUr(min,max,InpFiboEntranceLevel/100);//получим 50% значение фибо
      FiboLevel116=GetFiboUr(min,max,InpFiboProfitLevel/100); //получим 116% значение фибо

      op=FiboLevel50;
      sl=max+ExtIndentStopLoss*Point();
      tp=FiboLevel116;
      if((op-m_symbol.Ask())<5*Point() || (sl-m_symbol.Ask())<5*Point() || (m_symbol.Ask()-tp)<5*Point())
        {
         return(0);
        }
      if(ChLimitOrder(0)==0 && ChPositions(0)==0)
        {
         err=m_trade.SellLimit(0.1,NormalizeDouble(op,Digits()),Symbol(),sl,tp,
                               ORDER_TIME_SPECIFIED,TimeCurrent()+3*60,"FORTRADER.RU");
         if(!err)
           {
            Print("ScalpParabolicPattern()-  Ошибка установки отложенных ордеров OP_SELLLIMIT.  op ",
                  DoubleToString(op,Digits())," sl ",
                  DoubleToString(sl,Digits())," tp ",
                  DoubleToString(tp,Digits())," ",GetLastError());
            return(-1);
           }
         nummods=0;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DeleteLimitOrder(int type)
  {
   bool err=false;
   for(int i=OrdersTotal()-1; i>=0;i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT && m_order.Symbol()==Symbol() && type==1)
           {
            err=m_trade.OrderDelete(m_order.Ticket());
           }
         if(m_order.OrderType()==ORDER_TYPE_SELL_LIMIT && m_order.Symbol()==Symbol() && type==0)
           {
            err=m_trade.OrderDelete(m_order.Ticket());
           }
        }
     }
   return(err);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChLimitOrder(int type)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(m_order.SelectByIndex(i))
        {
         if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT && m_order.Symbol()==Symbol() && type==1)
           {
            return(1);
           }
         if(m_order.OrderType()==ORDER_TYPE_SELL_LIMIT && m_order.Symbol()==Symbol() && type==0)
           {
            return(1);
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChPositions(int type)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(m_position.PositionType()==POSITION_TYPE_BUY && m_position.Symbol()==Symbol() && type==1)
           {
            return(1);
           }
         if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.Symbol()==Symbol() && type==0)
           {
            return(1);
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MaximumMinimum(int type)
  {//описание функции http://fxnow.ru/blog/programming_mql4/3.html
   int x=0,stop=0;
   double minmax=0.0;

   if(type==0)
     {
      while(stop==0)
        {
         minmax=iLow(m_symbol.Name(),Period(),iLowest(Symbol(),Period(),MODE_LOW,InpCountBarSearch,x));
         if(minmax>iLow(m_symbol.Name(),Period(),iLowest(Symbol(),Period(),MODE_LOW,InpCountBarSearch,x+InpCountBarSearch)))
           {
            minmax=iLow(m_symbol.Name(),Period(),iLowest(Symbol(),Period(),MODE_LOW,InpCountBarSearch,x+InpCountBarSearch));
            x=x+InpCountBarSearch;
           }
         else
           {
            stop=1;
            return(minmax);
           }
        }
     }

   if(type==1)
     {
      while(stop==0)
        {
         minmax=iHigh(m_symbol.Name(),Period(),iHighest(Symbol(),Period(),MODE_HIGH,InpCountBarSearch,x));
         if(minmax<iHigh(m_symbol.Name(),Period(),iHighest(Symbol(),Period(),MODE_HIGH,InpCountBarSearch,x+InpCountBarSearch)))
           {
            minmax=iHigh(m_symbol.Name(),Period(),iHighest(Symbol(),Period(),MODE_HIGH,InpCountBarSearch,x+InpCountBarSearch));
            x=x+InpCountBarSearch;
           }
         else{stop=1;return(minmax);}
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetFiboUr(double high,double low,double ur)
  {//описание функции http://fxnow.ru/blog/programming_mql4/4.html
   double Fibo=NormalizeDouble(low+(high-low)*ur,Digits());
   return(Fibo);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  Trailing()
  {//описание функции http://fxnow.ru/blog/programming_mql4/1.html
   bool err=false;
   if(ExtTrailingStop<=0)
      return(0);
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(m_position.PositionType()==POSITION_TYPE_BUY && m_position.Symbol()==Symbol())
           {
            if((m_symbol.Bid()-m_position.PriceOpen())>=ExtTrailingStop*Point() && 
               (m_symbol.Bid()-Point()*ExtTrailingStop)>m_position.StopLoss())
              {
               if(((m_symbol.Bid()-Point()*ExtTrailingStop)-m_position.StopLoss())>=ExtTrailingStep*Point())
                 {
                  Print("ТРЕЙЛИМ BUY");
                  err=m_trade.PositionModify(m_position.Ticket(),
                                             m_symbol.Bid()-Point()*ExtTrailingStop,m_position.TakeProfit());
                  if(!err)
                    {
                     return(-1);
                    }
                 }
              }
           }
         if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.Symbol()==Symbol())
           {
            if((m_position.PriceOpen()-m_symbol.Ask())>=ExtTrailingStop*Point() && 
               m_position.StopLoss()>(m_symbol.Ask()+ExtTrailingStop*Point()))
              {
               if((m_position.StopLoss()-(m_symbol.Ask()+ExtTrailingStop*Point()))>ExtTrailingStep*Point())
                 {
                  Print("ТРЕЙЛИМ SELL");
                  err=m_trade.PositionModify(m_position.Ticket(),
                                             m_symbol.Ask()+ExtTrailingStop*Point(),m_position.TakeProfit());
                  if(!err)
                    {
                     return(-1);
                    }
                 }
              }
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  BBU()
  {//описание функции http://fxnow.ru/blog/programming_mql4/2.html
   bool err=false;
   if(InpBBUSize<=0)
      return(0);
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(m_position.PositionType()==POSITION_TYPE_BUY && m_position.Symbol()==Symbol() && 
            m_position.StopLoss()<m_position.PriceOpen())
           {
            if(m_symbol.Bid()-m_position.PriceOpen()>=InpBBUSize*Point())
              {
               Print("ПОРА Buy В БезуБыток");
               err=m_trade.PositionModify(m_position.Ticket(),
                                          m_position.PriceOpen()+1*Point(),m_position.TakeProfit());
               if(err==false)
                 {
                  return(-1);
                 }
              }
           }

         if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.Symbol()==Symbol() && 
            m_position.StopLoss()>m_position.PriceOpen())
           {
            if(m_position.PriceOpen()-m_symbol.Ask()>=InpBBUSize*Point())
              {
               Print("ПОРА Sell В БезуБыток");
               err=m_trade.PositionModify(m_position.Ticket(),
                                          m_position.PriceOpen()-1*Point(),m_position.TakeProfit());
               if(err==false)
                 {
                  return(-1);
                 }
              }
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Time Control                                                     |
//+------------------------------------------------------------------+
bool TimeControl(uchar Start,uchar Stop)
  {//описание функции http://fxnow.ru/blog/programming_mql4/5.html
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
   if(str1.hour>=Start && str1.hour<=Stop)
     {
      return(false);
     }
   return(true);
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
//| Get value of buffers for the iSAR                                |
//+------------------------------------------------------------------+
double iSARGet(const int handle,const int index)
  {
   double SAR[];
   ArraySetAsSeries(SAR,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iSARBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,0,index+1,SAR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iSAR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(SAR[index]);
  }
//+------------------------------------------------------------------+
