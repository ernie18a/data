//+------------------------------------------------------------------+
//|                                T3MA(barabashkakvn's edition).mq5 |
//|                                               Безбородов Алексей |
//|                                                   AlexeiBv@ya.ru |
//+------------------------------------------------------------------+
#property copyright "Безбородов Алексей"
#property link      "AlexeiBv@ya.ru"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double   InpLots=0.1;
input ushort   InpStopLoss=20;
input ushort   InpTakeProfit=125;
input int      InpBarNumber=1;

input ulong m_magic=794356487;
input ulong m_slippage=30;                // slippage
input bool InpPlaySound=true;
//---
int            handle_iT3MA;                 // variable for storing the handle of the T3MA indicator 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
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
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator T3MA
   handle_iT3MA=iCustom(m_symbol.Name(),Period(),"T3MA-ALARM",4,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iT3MA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
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
//---
   static double LastOrder=0;
//---
   double m0=0.0,m1=0.0;
   double sl=0.0;
   double tp=0.0;
   string comment="Т3МА";

//--- buffer 1: Buy, buffer 2: Sell    
   m0=iT3MAGet(1,InpBarNumber);
   m1=iT3MAGet(2,InpBarNumber);

   Comment("m0="+DoubleToString(m0,0)+" m1="+DoubleToString(m1,0)+" LastOrder"+DoubleToString(LastOrder,0));

   if(m0!=0.0 && m0!=LastOrder)
     {
      if(!RefreshRates())
         return;

      sl=0.0;
      if(InpStopLoss>0)
         sl=m_symbol.NormalizePrice(m_symbol.Ask()-InpStopLoss*m_adjusted_point);
      tp=0.0;
      if(InpTakeProfit>0)
         tp=m_symbol.NormalizePrice(m_symbol.Ask()+InpTakeProfit*m_adjusted_point);
      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);

      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=InpLots)
           {
            if(m_trade.Buy(InpLots,NULL,m_symbol.Ask(),sl,tp,MQLInfoString(MQL_PROGRAM_NAME)))
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
                  LastOrder=m0;
                  if(InpPlaySound)
                     PlaySound("alert.wav");
                 }
              }
            else
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
     }

   if(m1!=0.0 && m1!=LastOrder)
     {
      if(!RefreshRates())
         return;

      sl=0.0;
      if(InpStopLoss>0)
         sl=m_symbol.NormalizePrice(m_symbol.Bid()+InpStopLoss*m_adjusted_point);
      tp=0.0;
      if(InpTakeProfit>0)
         tp=m_symbol.NormalizePrice(m_symbol.Bid()-InpTakeProfit*m_adjusted_point);
      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=InpLots)
           {
            if(m_trade.Sell(InpLots,NULL,m_symbol.Bid(),sl,tp))
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
                  LastOrder=m1;
                  if(InpPlaySound)
                     PlaySound("alert.wav");
                 }
              }
            else
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
     }

//---
   return;
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the T3MA                                |
//| buffer 1: Buy, buffer 2: Sell                                    |
//+------------------------------------------------------------------+
double iT3MAGet(int buffer,const int index)
  {
   double T3MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iT3MA,buffer,index,1,T3MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the T3MA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(T3MA[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
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
