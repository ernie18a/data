//+------------------------------------------------------------------+
//|                      TrendMeLeaveMe(barabashkakvn's edition).mq5 | 
//|                              Copyright © 2006, Eng. Waddah Attar |
//|                                          waddahattar@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007,Eng Waddah Attar"
#property link      "waddahattar@hotmail.com"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include<Trade\OrderInfo.mqh>                // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // pending orders object
//---
input string BuyStop_Trend_Info= "_______________________";
input string BuyStop_TrendName = "buystop";
input int    BuyStop_TakeProfit= 500;
input int    BuyStop_StopLoss=300;
input double BuyStop_Lot=0.1;
input int    BuyStop_StepUpper = 100;
input int    BuyStop_StepLower = 500;
input string SellStop_Trend_Info= "_______________________";
input string SellStop_TrendName = "sellstop";
input int    SellStop_TakeProfit= 500;
input int    SellStop_StopLoss=300;
input double SellStop_Lot=0.1;
input int    SellStop_StepUpper = 500;
input int    SellStop_StepLower = 100;
//------
ulong MagicBuyStop=1101;
ulong MagicSellStop=1102;
ENUM_ORDER_TYPE glbOrderType;
ulong glbOrderTicket;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_symbol.Name(Symbol());                  // sets symbol name

   if(!RefreshRates())
     {
      Print("Error RefreshRates.",
            " Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   Comment("TrendMeLeaveMe by Waddah Attar");

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
   double vH,vL,vM,sl,tp;
   if(ObjectFind(0,BuyStop_TrendName)==0)
     {
      SetObject("High"+BuyStop_TrendName,
                ObjectGetInteger(0,BuyStop_TrendName,OBJPROP_TIME,0),
                ObjectGetDouble(0,BuyStop_TrendName,OBJPROP_PRICE,0)+BuyStop_StepUpper*Point(),
                ObjectGetInteger(0,BuyStop_TrendName,OBJPROP_TIME,1),
                ObjectGetDouble(0,BuyStop_TrendName,OBJPROP_PRICE,1)+BuyStop_StepUpper*Point(),
                (color)ObjectGetInteger(0,BuyStop_TrendName,OBJPROP_COLOR));
                
      SetObject("Low"+BuyStop_TrendName,
                ObjectGetInteger(0,BuyStop_TrendName,OBJPROP_TIME,0),
                ObjectGetDouble(0,BuyStop_TrendName,OBJPROP_PRICE,0)-BuyStop_StepLower*Point(),
                ObjectGetInteger(0,BuyStop_TrendName,OBJPROP_TIME,1),
                ObjectGetDouble(0,BuyStop_TrendName,OBJPROP_PRICE,1)-BuyStop_StepLower*Point(),
                (color)ObjectGetInteger(0,BuyStop_TrendName,OBJPROP_COLOR));
                
      vH = NormalizeDouble(ObjectGetValueByTime(0,"High"+BuyStop_TrendName,TimeCurrent(),0), Digits());
      vM = NormalizeDouble(ObjectGetValueByTime(0,BuyStop_TrendName,TimeCurrent(),0), Digits());
      vL = NormalizeDouble(ObjectGetValueByTime(0,"Low"+BuyStop_TrendName,TimeCurrent(),0), Digits());
      sl = vH - BuyStop_StopLoss*Point();
      tp = vH + BuyStop_TakeProfit*Point();

      if(!RefreshRates())
         return;

      if(m_symbol.Ask()<=vM && m_symbol.Ask()>=vL && OrderFind(MagicBuyStop)==false)
        {
         m_trade.SetExpertMagicNumber(MagicBuyStop);
         if(!m_trade.BuyStop(BuyStop_Lot,vH,Symbol(),sl,tp,0,0,""))
           {
            Print("Err BuyStop (",m_trade.ResultRetcodeDescription(),") Price= ",
                  DoubleToString(vH,Digits())," SL= ",
                  DoubleToString(sl,Digits())," TP= ",
                  DoubleToString(tp,Digits()));
           }
        }
      if(m_symbol.Ask()<=vM && m_symbol.Ask()>=vL && OrderFind(MagicBuyStop)==true && glbOrderType==ORDER_TYPE_BUY_STOP)
        {
         if(m_order.Select(glbOrderTicket))
            if(vH!=m_order.PriceOpen())
               if(!m_trade.OrderModify(glbOrderTicket,vH,sl,tp,0,0))
                 {
                  Print("Err Modify BuyStop (",m_trade.ResultRetcodeDescription(),") Price= ",
                        DoubleToString(vH,Digits())," SL= ",
                        DoubleToString(sl,Digits())," TP= ",
                        DoubleToString(tp,Digits()));
                 }
        }
     }
   if(ObjectFind(0,SellStop_TrendName)==0)
     {
      SetObject("High"+SellStop_TrendName,
                ObjectGetInteger(0,SellStop_TrendName,OBJPROP_TIME,0),
                ObjectGetDouble(0,SellStop_TrendName,OBJPROP_PRICE,0)+SellStop_StepUpper*Point(),
                ObjectGetInteger(0,SellStop_TrendName,OBJPROP_TIME,1),
                ObjectGetDouble(0,SellStop_TrendName,OBJPROP_PRICE,1)+SellStop_StepUpper*Point(),
                (color)ObjectGetInteger(0,SellStop_TrendName,OBJPROP_COLOR));
                
      SetObject("Low"+SellStop_TrendName,
                ObjectGetInteger(0,SellStop_TrendName,OBJPROP_TIME,0),
                ObjectGetDouble(0,SellStop_TrendName,OBJPROP_PRICE,0)-SellStop_StepLower*Point(),
                ObjectGetInteger(0,SellStop_TrendName,OBJPROP_TIME,1),
                ObjectGetDouble(0,SellStop_TrendName,OBJPROP_PRICE,1)-SellStop_StepLower*Point(),
                (color)ObjectGetInteger(0,SellStop_TrendName,OBJPROP_COLOR));
                
      vH = NormalizeDouble(ObjectGetValueByTime(0,"High" + SellStop_TrendName,TimeCurrent(),0), Digits());
      vM = NormalizeDouble(ObjectGetValueByTime(0,SellStop_TrendName,TimeCurrent(),0), Digits());
      vL = NormalizeDouble(ObjectGetValueByTime(0,"Low" +SellStop_TrendName,TimeCurrent(),0), Digits());
      sl = vL + SellStop_StopLoss*Point();
      tp = vL - SellStop_TakeProfit*Point();

      if(m_symbol.Bid()>=vM && m_symbol.Bid()<=vH && OrderFind(MagicSellStop)==false)
        {
         m_trade.SetExpertMagicNumber(MagicSellStop);
         if(!m_trade.SellStop(SellStop_Lot,vL,Symbol(),sl,tp,0,0,""))
           {
            Print("Err SellStop (",m_trade.ResultRetcodeDescription(),") Price= ",
                  DoubleToString(vL,Digits())," SL= ",
                  DoubleToString(sl,Digits())," TP= ",
                  DoubleToString(tp,Digits()));
           }
        }

      if(m_symbol.Bid()>=vM && m_symbol.Bid()<=vH && OrderFind(MagicSellStop)==true && glbOrderType==ORDER_TYPE_SELL_STOP)
        {
         if(m_order.Select(glbOrderTicket))
            if(vL!=m_order.PriceOpen())
               if(!m_trade.OrderModify(glbOrderTicket,vL,sl,tp,0,0))
                 {
                  Print("Err Modify SellStop (",m_trade.ResultRetcodeDescription(),") Price= ",
                        DoubleToString(vL,Digits())," SL= ",
                        DoubleToString(sl,Digits())," TP= ",
                        DoubleToString(tp,Digits()));
                 }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderFind(ulong Magic)
  {
   glbOrderType=ORDER_TYPE_CLOSE_BY;
   glbOrderTicket=18446744073709551;
   int total= OrdersTotal();
   bool res = false;
   for(int cnt=total-1;cnt>=0;cnt--)
     {
      if(m_order.SelectByIndex(cnt))
        {
         if(m_order.Magic()==Magic && m_order.Symbol()==Symbol())
           {
            glbOrderType=m_order.OrderType();
            glbOrderTicket=m_order.Ticket();
            res=true;
           }
        }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetObject(string name,datetime T1,double P1,datetime T2,double P2,color clr)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TREND,0,T1,P1,T2,P2);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
     }
   else
     {
      ObjectMove(0,name,0,T1,P1);
      ObjectMove(0,name,1,T2,P2);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
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
