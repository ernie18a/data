//+------------------------------------------------------------------+
//|        MTC Neural network plus MACD(barabashkakvn's edition).mq5 |
//|                             Copyright © 2008, Henadiy E. Batohov |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Henadiy E. Batohov"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters for Neuro part
input int          x11 = 100;
input int          x12 = 100;
input int          x13 = 100;
input int          x14 = 100;
input double       tp1 = 100;
input double       sl1 = 50;
input int          p1=10;
input int          x21 = 100;
input int          x22 = 100;
input int          x23 = 100;
input int          x24 = 100;
input double       tp2 = 100;
input double       sl2 = 50;
input int          p2=10;
input int          x31 = 100;
input int          x32 = 100;
input int          x33 = 100;
input int          x34 = 100;
input int          p3=10;
//--- input parameters
input int          pass=3;
input double       m_lots = 0.1;
input ulong        m_magic=555;

static datetime    prevtime=0;
static double      take_profit=100;
static double      stop_loss=50;
//---
int    digits_adjust=0;    // tuning for 3 or 5 digits
int    handle_iMACD;       // variable for storing the handle of the iMACD indicator 
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
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- create handle of the indicator iMACD;
   handle_iMACD=iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(iTime(m_symbol.Name(),Period(),0)==prevtime)
      return;
   prevtime=iTime(m_symbol.Name(),Period(),0);

   if(!IsTradeAllowed())
     {
      again();
      return;
     }

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            return;

   int MACD       = getMACD();
   int perceptron = Supervisor();

   if(MACD>0 && perceptron>0)
     {
      if(!RefreshRates())
         return;

      if(!m_trade.Buy(m_lots,Symbol(),m_symbol.Ask(),
         m_symbol.Ask()-stop_loss*Point()*digits_adjust,
         m_symbol.Ask()+take_profit*Point()*digits_adjust,MQLInfoString(MQL_PROGRAM_NAME)))
        {
         again();
        }
     }

   if(MACD<0 && perceptron<0)
     {
      if(!RefreshRates())
         return;

      if(!m_trade.Sell(m_lots,Symbol(),m_symbol.Bid(),
         m_symbol.Bid()+stop_loss*Point()*digits_adjust,
         m_symbol.Bid()-take_profit*Point()*digits_adjust,MQLInfoString(MQL_PROGRAM_NAME)))
        {
         again();
        }
     }

   return;
  }
//+------------------------------------------------------------------+
//| calculate perciptrons value                                      |
//+------------------------------------------------------------------+
int Supervisor()
  {
   if(pass>=3)
     {
      if(perceptron3()>0)
        {
         if(perceptron2()>0)
           {
            stop_loss=sl2;
            take_profit=tp2;
            return(1);
           }
        }
      else
        {
         if(perceptron1()<0)
           {
            stop_loss=sl1;
            take_profit=tp1;
            return(-1);
           }
        }
      return(0);
     }

   if(pass==2)
     {
      if(perceptron2()>0)
        {
         stop_loss=sl2;
         take_profit=tp2;
         return(1);
        }
      else
        {
         return(0);
        }
     }

   if(pass==1)
     {
      if(perceptron1()<0)
        {
         stop_loss=sl1;
         take_profit=tp1;
         return(-1);
        }
      else
        {
         return(0);
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double perceptron1()
  {
   double       w1 = x11 - 100;
   double       w2 = x12 - 100;
   double       w3 = x12 - 100;
   double       w4 = x12 - 100;
   double a1 = iClose(m_symbol.Name(),Period(),0) - iOpen(m_symbol.Name(),Period(),p1);
   double a2 = iOpen(m_symbol.Name(),Period(),p1) - iOpen(m_symbol.Name(),Period(),p1 * 2);
   double a3 = iOpen(m_symbol.Name(),Period(),p1 * 2) - iOpen(m_symbol.Name(),Period(),p1 * 3);
   double a4 = iOpen(m_symbol.Name(),Period(),p1 * 3) - iOpen(m_symbol.Name(),Period(),p1 * 4);
   return(w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double perceptron2()
  {
   double       w1 = x21 - 100;
   double       w2 = x22 - 100;
   double       w3 = x23 - 100;
   double       w4 = x24 - 100;
   double a1 = iClose(m_symbol.Name(),Period(),0) - iOpen(m_symbol.Name(),Period(),p2);
   double a2 = iOpen(m_symbol.Name(),Period(),p2) - iOpen(m_symbol.Name(),Period(),p2 * 2);
   double a3 = iOpen(m_symbol.Name(),Period(),p2 * 2) - iOpen(m_symbol.Name(),Period(),p2 * 3);
   double a4 = iOpen(m_symbol.Name(),Period(),p2 * 3) - iOpen(m_symbol.Name(),Period(),p2 * 4);
   return(w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double perceptron3()
  {
   double       w1 = x31 - 100;
   double       w2 = x32 - 100;
   double       w3 = x33 - 100;
   double       w4 = x34 - 100;
   double a1 = iClose(m_symbol.Name(),Period(),0) - iOpen(m_symbol.Name(),Period(),p3);
   double a2 = iOpen(m_symbol.Name(),Period(),p3) - iOpen(m_symbol.Name(),Period(),p3 * 2);
   double a3 = iOpen(m_symbol.Name(),Period(),p3 * 2) - iOpen(m_symbol.Name(),Period(),p3 * 3);
   double a4 = iOpen(m_symbol.Name(),Period(),p3 * 3) - iOpen(m_symbol.Name(),Period(),p3 * 4);
   return(w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4);
  }
//+------------------------------------------------------------------+
//| Calculate MACD value                                             |
//+------------------------------------------------------------------+
int getMACD()
  {
   double MacdCurrent,MacdPrevious,SignalCurrent,SignalPrevious;

   MacdCurrent=iMACDGet(MAIN_LINE,0);
   MacdPrevious=iMACDGet(MAIN_LINE,2);
   SignalCurrent=iMACDGet(SIGNAL_LINE,0);
   SignalPrevious=iMACDGet(SIGNAL_LINE,2);

   if(MacdCurrent<0 && MacdCurrent>=SignalCurrent && MacdPrevious<=SignalPrevious)
      return(1);

   if(MacdCurrent>0 && MacdCurrent<=SignalCurrent && MacdPrevious>=SignalPrevious)
      return(-1);

   return(0);
  }
//+------------------------------------------------------------------+
//| pause and try to do expert again                                 |
//+------------------------------------------------------------------+
void again()
  {
   prevtime=0;
   Sleep(30000);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iMACDGet(const int buffer,const int index)
  {
   double MACD[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMACD,buffer,index,1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[0]);
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
