//+------------------------------------------------------------------+
//|                        MTC Сombo v2(barabashkakvn's edition).mq5 |
//|                               Copyright © 2008, Yury V. Reshetov |
//|                               http://bigforex.biz/load/2-1-0-171 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Yury V. Reshetov"
#property link      "http://bigforex.biz/load/2-1-0-171"
#property version   "2.002"
#property description "Тетсирование разных индикаторов, смещений..."

#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh> 
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
CAccountInfo   m_account;                    // account info wrapper
CSymbolInfo    m_symbol;                     // symbol info object
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
//---- input parameters
input uchar              bar=0;
input int                ma_period = 2;               // averaging period 
input int                ma_shift=0;                  // horizontal shift 
input ENUM_MA_METHOD     ma_method=MODE_SMA;          // smoothing type 
input ENUM_APPLIED_PRICE applied_price=PRICE_CLOSE;   // type of price or handle 
input double      tp1 = 50;
input double      sl1 = 50;
//input int         p1=10;
input int         x12 = 100;
input int         x22 = 100;
input int         x32 = 100;
input int         x42 = 100;
input double      tp2 = 50;
input double      sl2 = 50;
input int         p2=20;
input int         x13 = 100;
input int         x23 = 100;
input int         x33 = 100;
input int         x43 = 100;
input double      tp3 = 50;
input double      sl3 = 50;
input int         p3=20;
input int         x14 = 100;
input int         x24 = 100;
input int         x34 = 100;
input int         x44 = 100;
input int         p4=20;
input int         pass=10;
input double      m_lots=0.01;
input ulong       mn=888;
static datetime   prevtime=0;
static double     m_sl = 100;
static double     m_tp = 100;
//---
int    handle_iCCI;                          // variable for storing the handle of the iCCI indicator 
int    handle_iMA;                           // variable for storing the handle of the iMA indicator 
string WindowExpertName="";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(m_lots<=0.0)
     {
      Print("The \"volume transaction\" can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
////--- create handle of the indicator iCCI
//   handle_iCCI=iCCI(Symbol(),Period(),p1,PRICE_OPEN);
////--- if the handle is not created 
//   if(handle_iCCI==INVALID_HANDLE)
//     {
//      //--- tell about the failure and output the error code 
//      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
//                  Symbol(),
//                  EnumToString(Period()),
//                  GetLastError());
//      //--- the indicator is stopped early 
//      return(INIT_FAILED);
//     }
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),ma_period,ma_shift,ma_method,applied_price);
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

   m_trade.SetExpertMagicNumber(mn);               // sets magic number
   m_trade.SetDeviationInPoints(10);               // sets deviation
   m_symbol.Name(Symbol());                        // sets symbol name
   RefreshRates();

   WindowExpertName=MQLInfoString(MQL_PROGRAM_NAME);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(iTime(Symbol(),Period(),0)==prevtime)
      return;
   prevtime=iTime(Symbol(),Period(),0);

   if(!IsTradeAllowed())
     {
      again();
      return;
     }
//---
   int total=PositionsTotal();
   for(int i=total-1; i>=0; i--)
     {
      if(!m_position.SelectByIndex(i))
         return;
      if(m_position.Symbol()==Symbol() && m_position.Magic()==mn)
        {
         return;
        }
     }

   m_sl = sl1;
   m_tp = tp1;

   ulong m_ticket=0;

   if(!RefreshRates())
      return;

   if(Supervisor()>0)
     {
      if(m_trade.Buy(m_lots,Symbol(),m_symbol.Ask(),
         m_symbol.Ask()-m_sl*Point(),m_symbol.Ask()+m_tp*Point(),WindowExpertName))
        {
         m_ticket=m_trade.ResultDeal();
        }
      if(m_ticket==0)
        {
         again();
        }
     }
   else
     {
      if(m_trade.Sell(m_lots,Symbol(),m_symbol.Bid(),
         m_symbol.Bid()+m_sl*Point(),m_symbol.Bid()-m_tp*Point(),WindowExpertName))
        {
         m_ticket=m_trade.ResultDeal();
        }
      if(m_ticket==0)
        {
         again();
        }
     }
//--- exit ---
   return;
  }
//+------------------------------------------------------------------+
//| getLots                                                          |
//+------------------------------------------------------------------+                            
double Supervisor()
  {
   if(pass==4)
     {
      if(perceptron3()>0)
        {
         if(perceptron2()>0)
           {
            m_sl = sl3;
            m_tp = tp3;
            return(1.0);
           }
        }
      else
        {
         if(perceptron1()<0)
           {
            m_sl = sl2;
            m_tp = tp2;
            return(-1.0);
           }
        }
      return(basicTradingSystem());
     }

   if(pass==3)
     {
      if(perceptron2()>0)
        {
         m_sl = sl3;
         m_tp = tp3;
         return(1.0);
        }
      else
        {
         return(basicTradingSystem());
        }
     }

   if(pass==2)
     {
      if(perceptron1()<0)
        {
         m_sl = sl2;
         m_tp = tp2;
         return(-1.0);
        }
      else
        {
         return(basicTradingSystem());
        }

     }
   return(basicTradingSystem());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double perceptron1()
  {
   double       w1 = x12 - 100;
   double       w2 = x22 - 100;
   double       w3 = x32 - 100;
   double       w4 = x42 - 100;
   double a1 = iClose(Symbol(),Period(),0) - iOpen(Symbol(),Period(),p2);
   double a2 = iOpen(Symbol(),Period(),p2) - iOpen(Symbol(),Period(),p2 * 2);
   double a3 = iOpen(Symbol(),Period(),p2 * 2) - iOpen(Symbol(),Period(),p2 * 3);
   double a4 = iOpen(Symbol(),Period(),p2 * 3) - iOpen(Symbol(),Period(),p2 * 4);
   return(w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double perceptron2()
  {
   double       w1 = x13 - 100;
   double       w2 = x23 - 100;
   double       w3 = x33 - 100;
   double       w4 = x43 - 100;
   double a1 = iClose(Symbol(),Period(),0) - iOpen(Symbol(),Period(),p3);
   double a2 = iOpen(Symbol(),Period(),p3) - iOpen(Symbol(),Period(),p3 * 2);
   double a3 = iOpen(Symbol(),Period(),p3 * 2) - iOpen(Symbol(),Period(),p3 * 3);
   double a4 = iOpen(Symbol(),Period(),p3 * 3) - iOpen(Symbol(),Period(),p3 * 4);
   return(w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double perceptron3()
  {
   double       w1 = x14 - 100;
   double       w2 = x24 - 100;
   double       w3 = x34 - 100;
   double       w4 = x44 - 100;
   double a1 = iClose(Symbol(),Period(),0) - iOpen(Symbol(),Period(),p4);
   double a2 = iOpen(Symbol(),Period(),p4) - iOpen(Symbol(),Period(),p4 * 2);
   double a3 = iOpen(Symbol(),Period(),p4 * 2) - iOpen(Symbol(),Period(),p4 * 3);
   double a4 = iOpen(Symbol(),Period(),p4 * 3) - iOpen(Symbol(),Period(),p4 * 4);
   return(w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double basicTradingSystem()
  {
//return(iCCIGet(0));
   return(iMAGet(bar));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void again()
  {
   prevtime=iTime(Symbol(),Period(),1);
   Sleep(30000);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCCI                                |
//+------------------------------------------------------------------+
double iCCIGet(const int index)
  {
   double CCI[];
   ArraySetAsSeries(CCI,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCCI,0,0,index+1,CCI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCCI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(CCI[index]);
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[];
   ArraySetAsSeries(MA,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,0,index+2,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   double right=MA[index];
   double left=MA[index+1];
   return(right-left);
  }
//+------------------------------------------------------------------+
