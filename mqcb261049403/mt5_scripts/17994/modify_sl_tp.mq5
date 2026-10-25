//+------------------------------------------------------------------+
//|                                                 Modify SL TP.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, fxMeter"
#property link      "https://www.mql5.com/en/users/fxmeter"
#property version   "1.00"

#property script_show_inputs
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh> 
CPositionInfo  posi;    
CTrade         trade; 
CSymbolInfo    symb;
input double InpStoploss=0.0; //StopLoss Pips
input double InpTakeProfit=0.0;//TakeProfit Pips
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
double stoploss=0.0;
double takeprofit=0.0;
ulong  slippage=3;
int    pt=1;

   symb.Name(Symbol());   
   if(!symb.RefreshRates())return;
   if(symb.Digits()==5 || symb.Digits()==3) pt=10;

   stoploss=InpStoploss*pt;   
   slippage    = slippage * pt;
   takeprofit  = InpTakeProfit * pt;
   trade.SetDeviationInPoints(slippage);  
   
   //---
   double curBid = symb.Bid();   
   double slbuy=0.0,slsell=0.0,tpbuy=0.0,tpsell=0.0;
   if(stoploss>0)
   {
    slbuy =   curBid  - stoploss*symb.Point();
    slsell =  curBid + stoploss*symb.Point();
    slbuy = symb.NormalizePrice(slbuy);
    slsell =symb.NormalizePrice(slsell);    
   }
   
   if(takeprofit>0)
   { 
    tpbuy =   curBid  + takeprofit*symb.Point();    
    tpsell =  curBid - takeprofit*symb.Point();
    tpbuy = symb.NormalizePrice(tpbuy);
    tpsell = symb.NormalizePrice(tpsell);    
   }
   
   ModifySLTP(slbuy,tpbuy,slsell,tpsell);
   
  }
//+------------------------------------------------------------------+  
void ModifySLTP(double slPriceBuy,double tpPriceBuy,double slPriceSell,double tpPriceSell)
{
//---     
      double sl=0.0 ,tp=0.0;      
      bool bslbuy = false,btpbuy = false, bslsell = false, btpsell = false;
      if(slPriceBuy>0)bslbuy=true;
      if(tpPriceBuy>0)btpbuy=true;
      if(slPriceSell>0)bslsell=true;
      if(tpPriceSell>0)btpsell=true;
      
      if(!bslbuy && !btpbuy && !bslsell && !btpsell )
      {
          Print(__FUNCTION__,",No SL/TP need to be modified");
          return;
      }
      
      
      for(int i=PositionsTotal()-1;i>=0;i--)
      {
         if(posi.SelectByIndex(i))
         {
            if(posi.Symbol()==Symbol() )
            {                
               if(posi.PositionType()==POSITION_TYPE_BUY)
                 {
                     if(bslbuy)sl=slPriceBuy;else sl = posi.StopLoss();  
                     if(btpbuy)tp=tpPriceBuy;else tp = posi.TakeProfit();               
                     trade.PositionModify(posi.Ticket(),sl,tp);
                 }

               if(posi.PositionType()==POSITION_TYPE_SELL)
                 {
                     if(bslsell)sl=slPriceSell;else sl = posi.StopLoss();
                     if(btpsell)tp=tpPriceSell;else tp = posi.TakeProfit(); 
                     trade.PositionModify(posi.Ticket(),sl,tp);
                 }
              }
             }
          } 
//---
}  