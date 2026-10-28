//+------------------------------------------------------------------+
//|                          MA Reverse(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
int            handle_iMA;                   // variable for storing the handle of the iMA indicator 
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),14,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
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

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static int count=0;
   static datetime prev_time=0;

   if(!RefreshRates())
      return;

   double MA=iMAGet(0);

   if(m_symbol.Bid()==MA)
      count=0;

   if(m_symbol.Bid()-MA>0)
      count++;

   if(count>150 && m_symbol.Bid()>MA)
     {
      if(iTime(0)>prev_time)
        {
         //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
         double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),1.0,m_symbol.Bid(),ORDER_TYPE_SELL);
         if(chek_volime_lot==1.0)
           {
            Print("CheckVolume Sell = ",chek_volime_lot," lot");
            if(m_trade.Sell(1.0,NULL,m_symbol.Bid(),0.0,m_symbol.NormalizePrice(m_symbol.Bid()-30*m_adjusted_point)))
              {
               if(m_trade.ResultDeal()!=0)
                 {
                  count=0;
                  prev_time=iTime(0);
                 }
               else
                  prev_time=iTime(1);
              }
            else
               prev_time=iTime(1);
           }
        }
     }

   if(count>0 && m_symbol.Bid()-MA<0)
      count=0;

   if(count<0 && m_symbol.Bid()-MA>0)
      count=0;

   if(m_symbol.Bid()-MA<0)
      count--;

   if(count<-150 && m_symbol.Bid()<MA)
     {
      if(iTime(0)>prev_time)
        {
         //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
         double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),1.0,m_symbol.Ask(),ORDER_TYPE_BUY);
         if(chek_volime_lot==1.0)
           {
            Print("CheckVolume Buy = ",chek_volime_lot," lot");
            if(m_trade.Buy(1.0,NULL,m_symbol.Ask(),0.0,m_symbol.NormalizePrice(m_symbol.Ask()+30*m_adjusted_point)))
              {
               if(m_trade.ResultDeal()!=0)
                 {
                  count=0;
                  prev_time=iTime(0);
                 }
               else
                  prev_time=iTime(1);
              }
            else
               prev_time=iTime(1);
           }
        }
     }

   return;
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
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
