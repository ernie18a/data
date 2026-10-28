//+------------------------------------------------------------------+
//|                              escape(barabashkakvn's edition).mq5 |
//|                                    Copyright © 2009, OGUZ BAYRAM |
//|                                            es_cape77@hotmail.com |
//+------------------------------------------------------------------+
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
input ushort InpTakeProfit_l = 25;           // TakeProfit_l
input ushort InpTakeProfit_s = 26;           // TakeProfit_s
input ushort InpStopLoss_l   = 25;           // StopLoss_l
input ushort InpStopLoss_s   = 03;           // StopLoss_s
input string Name_Expert     = "escape";
input ulong  InpSlippage=1;            // Slippage
input bool   UseSound        = false;
input string NameFileSound   = "Alert.wav";
input double Lots            = 0.2;
//---
ulong        m_magic=987568;
double       ExtTakeProfit_l = 0.0;
double       ExtTakeProfit_s = 0.0;
double       ExtStopLoss_l = 0.0;
double       ExtStopLoss_s = 0.;
ulong        ExtSlippage=1;
//---
int    handle_iMA_4;                         // variable for storing the handle of the iMA indicator 
int    handle_iMA_5;                         // variable for storing the handle of the iMA indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create handle of the indicator iMA
   handle_iMA_4=iMA(Symbol(),Period(),4,0,MODE_SMA,PRICE_OPEN);
//--- if the handle is not created 
   if(handle_iMA_4==INVALID_HANDLE)
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
   handle_iMA_5=iMA(Symbol(),Period(),5,0,MODE_SMA,PRICE_OPEN);
//--- if the handle is not created 
   if(handle_iMA_5==INVALID_HANDLE)
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

   ExtTakeProfit_l   = InpTakeProfit_l*digits_adjust;
   ExtTakeProfit_s   = InpTakeProfit_s*digits_adjust;
   ExtStopLoss_l     = InpStopLoss_l*digits_adjust;
   ExtStopLoss_s     = InpStopLoss_s*digits_adjust;
   ExtSlippage       = InpSlippage*digits_adjust;
   m_trade.SetDeviationInPoints(ExtSlippage);

   if(Bars(Symbol(),Period())<50)
     {
      Print("bars less than 50");
      return(INIT_FAILED);
     }

   if(InpTakeProfit_l<1)
     {
      Print("TakeProfit_l less than 1");
      return(INIT_FAILED);
     }
   if(InpTakeProfit_s<1)
     {
      Print("TakeProfit_s less than 1");
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
   Comment("");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime prev_time=0;
   datetime curr_time=iTime(m_symbol.Name(),Period(),0);
   if(prev_time!=curr_time)
     {
      prev_time=curr_time;
     }
   else
      return;

   if(m_account.FreeMargin()<(500*Lots))
     {
      Print("We have no money. Free Margin = ",DoubleToString(m_account.FreeMargin(),2));
      return;
     }

   if(!ExistPositions())
     {
      double diClose_M5_1=iClose(Symbol(),PERIOD_M5,1);
      double diMA5=iMAGet(handle_iMA_5,1);
      double diMA4=iMAGet(handle_iMA_4,1);

      if((diClose_M5_1<diMA5))
        {
         OpenBuy();
         return;
        }

      if((diClose_M5_1>diMA4))
        {
         OpenSell();
         return;
        }
     }

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ExistPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            return(true);

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenBuy()
  {
   double ldLot,ldStop,ldTake;
   string lsComm;

   if(!RefreshRates())
      return;

   ldLot  = GetSizeLot();
   ldStop = GetStopLossBuy();
   ldTake = GetTakeProfitBuy();
   lsComm = GetCommentForOrder();

   m_trade.Buy(ldLot,Symbol(),m_symbol.Ask(),ldStop,ldTake,lsComm);

   if(UseSound)
      PlaySound(NameFileSound);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSell()
  {
   double ldLot,ldStop,ldTake;
   string lsComm;

   if(!RefreshRates())
      return;

   ldLot=GetSizeLot();
   ldStop = GetStopLossSell();
   ldTake = GetTakeProfitSell();
   lsComm = GetCommentForOrder();

   m_trade.Sell(ldLot,Symbol(),m_symbol.Bid(),ldStop,ldTake,lsComm);

   if(UseSound)
      PlaySound(NameFileSound);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetCommentForOrder()
  {
   return(Name_Expert);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSizeLot()
  {
   return(Lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTakeProfitBuy()
  {
   return(m_symbol.Ask()+ExtTakeProfit_l*Point());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTakeProfitSell()
  {
   return(m_symbol.Bid()-ExtTakeProfit_s*Point());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStopLossBuy()
  {
   return(m_symbol.Ask()-ExtStopLoss_l*Point());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStopLossSell()
  {
   return(m_symbol.Bid()+ExtStopLoss_s*Point());
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
