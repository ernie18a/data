//+------------------------------------------------------------------+
//|              ZigZagEvgeTrofi ver. 1(barabashkakvn's edition).mq5 |
//|                               Copyright © 2008, Trofimov Evgeniy |
//|                                     http://www.fracpar.narod.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Trofimov Evgeniy"
#property link      "http://www.fracpar.narod.ru/"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input int      InpDepth          = 17;       // Depth
input int      InpDeviation      = 7;        // Deviation
input int      InpBackstep       = 5;        // Backstep
input double   InpLot            = 0.10;     // Volume position
input bool     InpSignalReverse  = false;    // Signal reverse
ulong          m_magic           = 837874578;// magic number
//----
static int prevtime=0;
int Urgency=2;
//---
ulong          m_slippage=10;                // slippage

int            handle_iCustom;               // variable for storing the handle of the iCustom indicator 

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLot,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(m_symbol.Name(),Period(),"\\Examples\\ZigZag",InpDepth,InpDeviation,InpBackstep);
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
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

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!IsTradeAllowed())
      return;
//---
   double ZigZag=0.0;
   int Signal=0;

   double arr_zigzag[];
   ArraySetAsSeries(arr_zigzag,true);
   int counter=0;
   if(iCustomGet(handle_iCustom,0,0,100,arr_zigzag))
     {
      bool find=false;
      int limit=ArraySize(arr_zigzag);
      for(int i=0;i<limit;i++)
        {
         if(arr_zigzag[i]!=0.0)
           {
            find=true;
            counter=i;
            ZigZag=arr_zigzag[i];
            break;
           }
        }
      if(!find)
         return;
     }
   else
     {
      PrevBars=iTime(m_symbol.Name(),Period(),1);
      return;
     }

   double high=iHigh(m_symbol.Name(),Period(),counter);
   double low=iLow(m_symbol.Name(),Period(),counter);
   if(high==0.0 || low==0.0)
     {
      PrevBars=iTime(m_symbol.Name(),Period(),1);
      return;
     }
   if(CompareDoubles(ZigZag,high,m_symbol.Digits()))
     {
      if(!InpSignalReverse)
         Signal=1;   // open buy
      else
         Signal=2;   // open sell
     }
   else if(CompareDoubles(ZigZag,low,m_symbol.Digits()))
     {
      if(!InpSignalReverse)
         Signal=2;   // open sell
      else
         Signal=1;   // open buy
     }
//---
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(Signal==2)
                  m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(Signal==1)
                  m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
              }
           }
//---
   if(counter<=Urgency)
     {
      if(Signal==1)
         m_trade.Buy(InpLot);
      else if(Signal==2)
         m_trade.Sell(InpLot);
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
bool iCustomGet(int handle,const int buffer,const int start_pos,const int count,double &array[])
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   int copy=CopyBuffer(handle,buffer,start_pos,count,array);
   if(copy!=count)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy (%d) data from the iCustom indicator, error code %d",copy,GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2,int digits)
  {
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
