//+------------------------------------------------------------------+
//|                             CrossMA(barabashkakvn's edition).mq5 | 
//|                                  Copyright © 2005, George-on-Don |
//|                                       http://www.forex.aaanet.ru |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object

input ulong    Magic             = 20050610; //
input double   InpLots           = 0.1;      // ExtLots
input double   MaximumRisk       = 0.02;
input double   DecreaseFactor    = 3;
input int      MA1_Period=12;       // длинный мувинг 12
input int      MA_Shift=0;
input int      MA2_Period=4;        // короткий мувинг 4
input int      ATR_Period        = 6;
input bool     SndMl             = true;

double         ExtLots=0.0;

int    handle_iMA1;                          // variable for storing the handle of the iMA indicator 
int    handle_iMA2;                          // variable for storing the handle of the iMA indicator 
int    handle_iATR;                          // variable for storing the handle of the iATR indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(Magic);      // sets magic number
   RefreshRates();
//--- create handle of the indicator iMA
   handle_iMA1=iMA(Symbol(),Period(),MA1_Period,MA_Shift,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA2=iMA(Symbol(),Period(),MA2_Period,MA_Shift,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iATR
   handle_iATR=iATR(Symbol(),Period(),ATR_Period);
//--- if the handle is not created 
   if(handle_iATR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d",
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
//| Расчет открытия позиции                                          |
//+------------------------------------------------------------------+
int CalculateCurrentOrders()
  {
   int buys=0,sells=0;
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(m_position.Symbol()==Symbol() && m_position.Magic()==Magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               buys++;
            if(m_position.PositionType()==POSITION_TYPE_SELL)
               sells++;
           }
        }
     }
//--- return count orders
   if(buys>0 || sells>0)
      return(buys+sells);
   else
      return(0);
  }
//+------------------------------------------------------------------+
//| Расчет оптимальной величины лота                                 |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=ExtLots;
   int    losses=0;                  // number of losses deals without a break
//--- select lot size
   lot=NormalizeDouble(m_account.FreeMargin()*MaximumRisk/1000.0,1);
//--- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      //--- request trade history 
      HistorySelect(TimeCurrent()-86400,TimeCurrent()+86400);
      //--- 
      uint     total=HistoryDealsTotal();
      //--- for all deals 
      for(uint i=0;i<total;i++)
        {
         if(!m_deal.SelectByIndex(i))
           {
            Print("Error in history!");
            break;
           }
         if(m_deal.Symbol()!=Symbol() || m_deal.Entry()!=DEAL_ENTRY_OUT)
            continue;
         //---
         if(m_deal.Profit()>0)
            break;
         if(m_deal.Profit()<0)
            losses++;
        }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//--- return lot size
   if(lot<0.1)
      lot=0.1;
   return(lot);
  }
//+------------------------------------------------------------------+
//| Проверка для открытия позиции с первым тиком нового бара.        |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   double mas;
   double maf;
   double mas_p;
   double maf_p;
   double Atr;
   bool   res;
   string sHeaderLetter;
   string sBodyLetter;
//--- go trading only for first tiks of new bar
   if(iTickVolume(0)>1)
      return;
//--- get Moving Average 
   mas=iMAGet(handle_iMA1,1);       // динный мувинг 12
   maf=iMAGet(handle_iMA2,1);       // короткий мувинг 4
   mas_p=iMAGet(handle_iMA1,2);     // динный мувинг 12
   maf_p=iMAGet(handle_iMA2,2);     // короткий мувинг 4
   Atr=iATRGet(0);
//--- Условие продажи
   if(maf<mas && maf_p>=mas_p)
     {
      double lots=LotsOptimized();
      double stop_loss=NormalizeDouble(m_symbol.Bid()+Atr,Digits());
      res=m_trade.Sell(lots,Symbol(),m_symbol.Bid(),
                       m_symbol.NormalizePrice(stop_loss),0);
      if(SndMl==true && res)
        {
         sHeaderLetter="Operation SELL by"+Symbol()+"";
         sBodyLetter="Deal Sell by"+Symbol()+" at "+DoubleToString(m_symbol.Bid(),Digits())+
                     ", and set stop/loss at "+DoubleToString(stop_loss,Digits())+"";
         sndMessage(sHeaderLetter,sBodyLetter);
        }
      return;
     }
//--- Условие покупки
   if(maf>mas && maf_p<=mas_p)
     {
      double lots=LotsOptimized();
      double stop_loss=NormalizeDouble(m_symbol.Ask()-Atr,Digits());
      res=m_trade.Buy(lots,Symbol(),m_symbol.Ask(),
                      m_symbol.NormalizePrice(stop_loss),0);
      if(SndMl==true && res)
        {
         sHeaderLetter="Operation BUY at"+Symbol()+"";
         sBodyLetter="Deal Buy at"+Symbol()+" for "+DoubleToString(m_symbol.Ask(),Digits())+
                     ", and set stop/loss at "+DoubleToString(stop_loss,Digits())+"";
         sndMessage(sHeaderLetter,sBodyLetter);
        }
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| ПРоверка для закрытия открытой позиции                           |
//+------------------------------------------------------------------+
void CheckForClose()
  {
   double mas;
   double maf;
   double mas_p;
   double maf_p;
   string sHeaderLetter;
   string sBodyLetter;
   bool   rtvl=false;
//---
   if(iTickVolume(0)>1)
      return;
//---
   mas=iMAGet(handle_iMA1,1);       // динный мувинг 12
   maf=iMAGet(handle_iMA2,1);       // короткий мувинг 4
   mas_p=iMAGet(handle_iMA1,2);     // динный мувинг 12
   maf_p=iMAGet(handle_iMA2,2);     // короткий мувинг 4
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(!m_position.SelectByIndex(i))
         break;
      if(m_position.Magic()!=Magic || m_position.Symbol()!=Symbol())
         continue;
      //--- 
      if(m_position.PositionType()==POSITION_TYPE_BUY)
        {
         if(maf<mas && maf_p>=mas_p)
            rtvl=m_trade.PositionClose(m_position.Ticket());
         if(SndMl==true && rtvl)
           {
            sHeaderLetter="Operation CLOSE BUY at"+Symbol()+"";
            sBodyLetter="Close position Buy at"+Symbol()+" for "+DoubleToString(m_symbol.Bid(),Digits())+", and finish this Trade";
            sndMessage(sHeaderLetter,sBodyLetter);
           }
         break;
        }
      if(m_position.PositionType()==POSITION_TYPE_SELL)
        {
         if(maf>mas && maf_p<=mas_p)
            rtvl=m_trade.PositionClose(m_position.Ticket());
         if(SndMl==true && rtvl)
           {
            sHeaderLetter="Operation CLOSE SELL at"+Symbol()+"";
            sBodyLetter="Close position Sell at"+Symbol()+" for "+DoubleToString(m_symbol.Ask(),Digits())+", and finish this Trade";
            sndMessage(sHeaderLetter,sBodyLetter);
           }
         break;
        }
     }
//---
  }
//------------------------------------------------------------------
// функция отправки ссобщения об отрытии или закрытии позиции
//------------------------------------------------------------------
void sndMessage(string HeaderLetter,string BodyLetter)
  {
   if(!SendMail(HeaderLetter,BodyLetter))
      Print("Ошибка, сообщение не отправлено: ",GetLastError());
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- check for history and trading
   if(Bars(Symbol(),Period())<25 || !IsTradeAllowed())
      return;
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders()==0)
      CheckForOpen();
   else
      CheckForClose();
//---
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int handle,const int index)
  {
   double MA[];
   ArraySetAsSeries(MA,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,0,index+1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iATR                                |
//+------------------------------------------------------------------+
double iATRGet(const int index)
  {
   double ATR[];
   ArraySetAsSeries(ATR,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iATR array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iATR,0,0,index+1,ATR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ATR[index]);
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
   long TickVolume[];
   long tickvolume=0;
   ArraySetAsSeries(TickVolume,true);
   int copied=CopyTickVolume(symbol,timeframe,index,1,TickVolume);
   if(copied>0) tickvolume=TickVolume[0];
   return(tickvolume);
  }
//+------------------------------------------------------------------+
