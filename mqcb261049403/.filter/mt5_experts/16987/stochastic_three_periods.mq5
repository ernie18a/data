//+------------------------------------------------------------------+
//|            Stochastic Three Periods(barabashkakvn's edition).mq5 |
//|                                            Rafael Maia de Amorim |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Rafael Maia de Amorim"
#property link      "https://www.metaquotes.net"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---- input parameters
input ushort    InpTP=30;  // TP
input ushort    InpSL=10;  // SL
input double    Lots=0.1;
input int       ShiftEntrance=3;
int lastorder=0;
input ENUM_TIMEFRAMES  period_stochactic1 = PERIOD_M5;
input ENUM_TIMEFRAMES  period_stochactic2 = PERIOD_M15;
input ENUM_TIMEFRAMES  period_stochactic3 = PERIOD_M30;
input int KEntrance1 = 5; // K-period stochactic 1
input int KEntrance2 = 5; // K-period stochactic 2
input int KEntrance3 = 5; // K-period stochactic 3
input int KExit1     = 5; // K-period stochactic 1 - Exit
//---
ulong     m_magic=1152789;                   // magic number
double    ExtTP      = 0.0;
double    ExSL       = 0.0;
int    handle_iStochastic1;                  // variable for storing the handle of the iStochastic indicator 
int    handle_iStochastic2;                  // variable for storing the handle of the iStochastic indicator 
int    handle_iStochastic3;                  // variable for storing the handle of the iStochastic indicator 
int    handle_iStochastic1Exit;              // variable for storing the handle of the iStochastic indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   lastorder=0;
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   ExtTP =InpTP*digits_adjust;
   ExSL  =InpSL*digits_adjust;
//--- create handle of the indicator iStochastic
   handle_iStochastic1=iStochastic(Symbol(),period_stochactic1,KEntrance1,3,3,MODE_SMA,STO_CLOSECLOSE);
//--- if the handle is not created 
   if(handle_iStochastic1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic2=iStochastic(Symbol(),period_stochactic2,KEntrance2,3,3,MODE_SMA,STO_CLOSECLOSE);
//--- if the handle is not created 
   if(handle_iStochastic2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic3=iStochastic(Symbol(),period_stochactic3,KEntrance3,3,3,MODE_SMA,STO_CLOSECLOSE);
//--- if the handle is not created 
   if(handle_iStochastic3==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic1Exit=iStochastic(Symbol(),period_stochactic1,KExit1,3,3,MODE_SMA,STO_CLOSECLOSE);
//--- if the handle is not created 
   if(handle_iStochastic1Exit==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
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
   double  p=Point();
   int     PositionsPerSymbol=0;
   if(m_account.FreeMargin()<(1000*Lots))
     {
      Print("Недостаточно денег");
      return;
     }
   if(Bars(Symbol(),Period())<100)
     {
      Print("-----NO BARS ");
      return;
     }

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            PositionsPerSymbol++;
//Abre as ordens apenas se nгo possuir nenhuma ordem aberta por Simbolo
   if(PositionsPerSymbol==0)
     {
      int sinal=Sinal();
      if(sinal==1 && lastorder!=1)
        {
         if(!RefreshRates())
            return;
         m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),
                     m_symbol.Ask()-(ExSL*p),m_symbol.Ask()+(ExtTP*p),"Buy  "+TimeToString(TimeCurrent()));
         lastorder=1;
         return;
        }

      if(sinal==2 && lastorder!=2)
        {
         m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),
                      m_symbol.Bid()+(ExSL*p),m_symbol.Bid()-(ExtTP*p),"Sell "+TimeToString(TimeCurrent()));
         lastorder=2;
         return;
        }
     }
//---  close positions
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               //--- Check if reverse occurred
               if(SignalExit()==2)
                  m_trade.PositionClose(m_position.Ticket());
              } // if BUY

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(SignalExit()==1)
                  m_trade.PositionClose(m_position.Ticket());
              } //if SELL

           } // if(OrderSymbol)

//} // for
   return;
  }
//+------------------------------------------------------------------+
//| Gerador de sinais                                          |
//+------------------------------------------------------------------+  
int Sinal()
  {
   double STOM5ValueS0,STOM5SignalS0,STOM5ValueS1,STOM5SignalS1;
   double STOM15Value,STOM15Signal,STOM30Value,STOM30Signal;

   int direction=0; // 1 - Buy, 2 - Sell

   STOM5ValueS0  = iStochasticGet(handle_iStochastic1,MAIN_LINE,0);
   STOM5SignalS0 = iStochasticGet(handle_iStochastic1,SIGNAL_LINE,0);
   STOM5ValueS1  = iStochasticGet(handle_iStochastic1,MAIN_LINE,ShiftEntrance);
   STOM5SignalS1 = iStochasticGet(handle_iStochastic1,SIGNAL_LINE,ShiftEntrance);

   STOM15Value   = iStochasticGet(handle_iStochastic2,MAIN_LINE,0);
   STOM15Signal  = iStochasticGet(handle_iStochastic2,SIGNAL_LINE,0);
   STOM30Value   = iStochasticGet(handle_iStochastic3,MAIN_LINE,0);
   STOM30Signal  = iStochasticGet(handle_iStochastic3,SIGNAL_LINE,0);

   double close_0=iClose(m_symbol.Name(),Period(),0);
   double close_1=iClose(m_symbol.Name(),Period(),1);

   if(STOM5ValueS0>STOM5SignalS0 && STOM5ValueS1<STOM5SignalS1 && 
      STOM15Value>STOM15Signal && STOM30Value>STOM30Signal && 
      close_0>close_1)
     {
      direction=1;
     }
   else if(STOM5ValueS0<STOM5SignalS0 && STOM5ValueS1>STOM5SignalS1 && STOM15Value<STOM15Signal && STOM30Value<STOM30Signal && close_0<close_1)
     {
      direction=2;
     }
   else
     {
      direction=0;
     }
   return (direction);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SignalExit()
  {
   double STOM5ValueS0=0.0,STOM5SignalS0=0.0;
   int direction=0;

   STOM5ValueS0=iStochasticGet(handle_iStochastic1Exit,MAIN_LINE,1);
   STOM5SignalS0=iStochasticGet(handle_iStochastic1Exit,SIGNAL_LINE,1);
   if(STOM5ValueS0>STOM5SignalS0)
     {
      direction=1;
     }
   else if(STOM5ValueS0<STOM5SignalS0)
     {
      direction=2;
     }
   else
     {
      direction=0;
     }
   return (direction);
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
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(const int handle,const int buffer,const int index)
  {
   double Stochastic[];
   ArraySetAsSeries(Stochastic,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,buffer,0,index+1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[index]);
  }
//+------------------------------------------------------------------+
