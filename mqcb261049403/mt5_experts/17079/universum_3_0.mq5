//+------------------------------------------------------------------+
//|                       Universum 3.0(barabashkakvn's edition).mq5 |
//|                               Copyright © 2008, Yury V. Reshetov |
//|                               http://bigforex.biz/load/2-1-0-170 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Yury V. Reshetov http://bigforex.biz/load/2-1-0-170"
#property link      "http://bigforex.biz/load/2-1-0-170"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
//---- input parameters
input int         ma_period=10;
input ushort      InpTakeProfit=50;
input ushort      InpStopLoss=50;
input double      InpLots=0.01;
input int         losseslimit=1000000;
input int         m_magic=888;
static datetime   prevtime=0;
static int        losses=0;
//---
double            ExtTakeProfit=0.0;
double            ExtStopLoss=0.0;
int               handle_iDeMarker;                     // variable for storing the handle of the iDeMarker indicator 
double            GetLots=0.0;
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
   GetLots=0.0;
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtTakeProfit  = InpTakeProfit   * digits_adjust;
   ExtStopLoss    = InpStopLoss     * digits_adjust;

//--- create handle of the indicator iDeMarker
   handle_iDeMarker=iDeMarker(Symbol(),Period(),ma_period);
//--- if the handle is not created 
   if(handle_iDeMarker==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iDeMarker indicator for the symbol %s/%s, error code %d",
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
      prevtime=0;
      MathSrand((int)TimeCurrent());
      Sleep(30000+MathRand());
     }
//---
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            return; // если есть позиция, то выходим

   double lt=0.0;
   if(GetLots==0)
      lt=InpLots;
   else
      lt=GetLots;
   if(losses>=losseslimit)
     {
      SendMail(MQLInfoString(MQL_PROGRAM_NAME)+" Too many losses","Chart "+Symbol());
      return;
     }

   if(!RefreshRates())
      return;

   if(iDeMarkerGet(0)>0.5)
     {
      if(!m_trade.Buy(lt,Symbol(),m_symbol.Ask(),m_symbol.Ask()-ExtStopLoss*Point(),
         m_symbol.Ask()+ExtTakeProfit*Point(),MQLInfoString(MQL_PROGRAM_NAME)))
        {
         Sleep(30000);
         prevtime=0;
        }
     }
   else
     {
      if(!m_trade.Sell(lt,Symbol(),m_symbol.Bid(),m_symbol.Bid()+ExtStopLoss*Point(),
         m_symbol.Bid()-ExtTakeProfit*Point(),MQLInfoString(MQL_PROGRAM_NAME)))
        {
         Sleep(30000);
         prevtime=0;
        }
     }
//--- Exit ---
   return;
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   double res=0.0;
   losses=0.0;

   double spread=m_symbol.Spread();
   double k=(ExtTakeProfit+ExtStopLoss)/(ExtTakeProfit-spread);
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_entry        =0;
      double   deal_profit       =0.0;
      double   deal_volume       =0.0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_volume=HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==Symbol() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            if(deal_profit>0)
              {
               res=InpLots;
               losses=0;
              }
            else
              {
               res=deal_volume*k;
               losses++;
              }

            GetLots=LotCheck(res);
           }
     }
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
//| Get value of buffers for the iDeMarker                           |
//+------------------------------------------------------------------+
double iDeMarkerGet(const int index)
  {
   double DeMarker[];
   ArraySetAsSeries(DeMarker,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iDeMarker array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iDeMarker,0,0,index+1,DeMarker)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iDeMarker indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(DeMarker[index]);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
