//+------------------------------------------------------------------+
//|                      VR---SETKA---3(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
//===========================================================================================================================//
// Author VOLDEMAR227 site WWW.TRADING-GO.RU      SKYPE: TRADING-GO          e-mail: TRADING-GO@List.ru
//===========================================================================================================================//
#property copyright "Copyright © 2012, WWW.TRADING-GO.RU ."
#property link      "http://WWW.TRADING-GO.RU"
//WWW.TRADING-GO.RU  full version free
//===========================================================================================================================//
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input string  Comment_1    = "settings";
input ushort  InpPlus      = 5;
input ushort  InpTakeProfit= 30;
input ushort  InpDistanciya= 30;
input ushort  InpStepDist  = 5;
input double  Lots         = 0.00;
input double  InpPercent   = 1;
input bool    Martin       = true;
input string  Comment_4    = "signalProc";
input bool    Proc         = true;
input double  Procent      = 1.3;
input ushort  InpSlip      = 2;
input ulong   Magic        = 1;
//---
double  ExtPlus      = 0;
double  ExtTakeProfit= 0;
double  ExtDistanciya= 0;
double  ExtStepDist  = 0;
ulong    ExtSlip=0;
double  ExtPercent=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(m_account.MarginMode()!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(Magic);      // sets magic number

   if(!RefreshRates())
     {
      Print("Error RefreshRates.",
            " Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   ExtPlus        = InpPlus         *digits_adjust;
   ExtTakeProfit  = InpTakeProfit   *digits_adjust;
   ExtDistanciya  = InpDistanciya   *digits_adjust;
   ExtStepDist    = InpStepDist     *digits_adjust;
   ExtSlip        = InpSlip         *digits_adjust;
   ExtPercent     = InpPercent;

   m_trade.SetDeviationInPoints(ExtSlip);    // sets deviation
//---
   if(!LabelCreate())
      return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!RefreshRates())
      return;
   double Lots_New=0;
   double One_Lot=0.0;
   if(!OrderCalcMargin(ORDER_TYPE_BUY,m_symbol.Name(),1.0,m_symbol.Ask(),One_Lot))
     {
      Print("Error OrderCalcMargin #",GetLastError());
      return;
     }
   double Min_Lot=m_symbol.LotsMin();
   double Step   =m_symbol.LotsStep();
   double Free   =m_account.FreeMargin();
//--------------------------------------------------------------- 3 --
   if(Lots>0)
     {
      double Money=Lots*One_Lot;
      if(Money<=m_account.FreeMargin())
         Lots_New=Lots;
      else
         Lots_New=MathFloor(Free/One_Lot/Step)*Step;
     }
//--------------------------------------------------------------- 4 --
   else
     {
      if(ExtPercent>100)
         ExtPercent=100;
      if(ExtPercent==0)
         Lots_New=Min_Lot;
      else
         Lots_New=MathFloor(Free*ExtPercent/100/One_Lot/Step)*Step;//Расч
     }
//--------------------------------------------------------------- 5 --
   if(Lots_New<Min_Lot)
      Lots_New=Min_Lot;
   if(Lots_New*One_Lot>m_account.FreeMargin())
     {
      return;
     }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// set text label transferred to OnInit ()
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
   double opB=2000;           double opS=0;
   double orderProfitbuy=0;   double Sum_Profitbuy=0;

   double LotB=Lots_New;
   double LotS=Lots_New;
   int total=PositionsTotal();
   int b=0,s=0,n=0;
   for(int i=total-1; i>=0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(m_position.Symbol()==m_symbol.Name())
           {
            n++;
            //---
            if(m_position.PositionType()==POSITION_TYPE_BUY && m_position.Magic()==Magic)
              {
               b++;
               LotB=m_position.Volume();
               double ProfitB=m_position.TakeProfit();
               double openB=m_position.PriceOpen();
               if(openB<opB)
                 {
                  opB=openB;
                 }
              }
            //---
            if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.Magic()==Magic)
              {
               s++;
               LotS=m_position.Volume();
               double ProfitS=m_position.TakeProfit();
               double openS=m_position.PriceOpen();
               if(openS>opS)
                 {
                  opS=openS;
                 }
              }
           }
        }
     }
   double max = NormalizeDouble(iHigh (Symbol(),PERIOD_D1,0),m_symbol.Digits());
   double min = NormalizeDouble(iLow  (Symbol(),PERIOD_D1,0),m_symbol.Digits());
   double opp = NormalizeDouble(iOpen (Symbol(),PERIOD_D1,0),m_symbol.Digits());
   double cl  = NormalizeDouble(iClose(Symbol(),PERIOD_D1,0),m_symbol.Digits());
//   double dii = NormalizeDouble(ExtDistanciya+(ExtDistanciya/100*n));
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
   double dis   =NormalizeDouble((ExtDistanciya+(ExtStepDist*n))  *Point(),Digits());
   double spred =NormalizeDouble(m_symbol.Spread()                *Point(),Digits());
   double  CORR =NormalizeDouble(ExtPlus                          *Point(),Digits());
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//   
   int sigup=0;
   int sigdw=0;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
   if(Proc==true)
     {
      double x=0.0;
      double y=0.0;
      if(cl>min)
        {
         x=NormalizeDouble(cl*100/min-100,2);
        }
      if(cl<max)
        {
         y=NormalizeDouble(cl*100/max-100,2);
        }

      if(Procent*(-1)<=y && iClose(Symbol(),Period(),1)>iOpen(Symbol(),Period(),1))
        {
         sigup=1; sigdw=0;
        }
      if(Procent>=x && iClose(Symbol(),Period(),1)<iOpen(Symbol(),Period(),1))
        {
         sigup=0; sigdw=1;
        }
     }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
   int f=0;
   if(Martin==true)
     {
      if(total==0)
        {
         f=1;
        }
      if(total>=1)
        {
         f=total;
        }
      LotB=Lots_New*f;
      LotS=Lots_New*f;
     }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
   if(Martin==false)
     {
      LotB=LotS;
      LotS=LotB;
     }
//---
   if(!RefreshRates())
      return;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//  
   if((b==0 && sigup==1 && s==0) || (m_symbol.Ask()<opB-dis+spred && b>=1 && s==0))
     {
      m_trade.Buy(LotB,Symbol(),m_symbol.Ask(),0,0,"Buy ");
      return;
     }
   if((s==0 && sigdw==1 && b==0) || (m_symbol.Bid()>opS+dis+spred && s>=1 && b==0))
     {
      m_trade.Sell(LotS,Symbol(),m_symbol.Bid(),0,0,"Sell");
      return;
     }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
   double TP=NormalizeDouble(spred+ExtTakeProfit*m_symbol.Point(),m_symbol.Digits());
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
   bool buy_or_sell=false;
   if(!RefreshRates())
      return;
   for(int iq=total-1; iq>=0; iq--)
     {
      if(m_position.SelectByIndex(iq))
        {
         if(m_position.Symbol()==Symbol() && m_position.Magic()==Magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY && m_position.TakeProfit()==0 && b==1)
              {
               m_trade.PositionModify(m_position.Ticket(),
                                      m_position.StopLoss(),NormalizeDouble(m_position.PriceOpen()+TP,Digits()));
               buy_or_sell=true;
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.TakeProfit()==0 && s==1)
              {
               m_trade.PositionModify(m_position.Ticket(),
                                      m_position.StopLoss(),NormalizeDouble(m_position.PriceOpen()-TP,Digits()));
               buy_or_sell=true;
              }
           }
        }
     }
   if(buy_or_sell)
      return;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
   double nn=0,bb=0;
   double factb=0.0;
   for(int ui=total-1; ui>=0; ui--)
     {
      if(m_position.SelectByIndex(ui))
        {
         if(m_position.Symbol()==Symbol())
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY && m_position.Magic()==Magic)
              {
               double op=m_position.PriceOpen();
               double llot=m_position.Volume();
               double itog=op*llot;
               bb=bb+itog;
               nn=nn+llot;
               factb=bb/nn;
              }
           }
        }
     }
   double nnn=0,bbb=0;
   double facts=0.0;
   for(int usi=total-1; usi>=0; usi--)
     {
      if(m_position.SelectByIndex(usi))
        {
         if(m_position.Symbol()==Symbol())
           {
            if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.Magic()==Magic)
              {
               double ops=m_position.PriceOpen();
               double llots=m_position.Volume();;
               double itogs=ops*llots;
               bbb=bbb+itogs;
               nnn=nnn+llots;
               facts=bbb/nnn;
              }
           }
        }
     }
   buy_or_sell=false;
   if(!RefreshRates())
      return;
   for(int uui=total-1; uui>=0; uui--)
     {
      if(m_position.SelectByIndex(uui))
        {
         if(m_position.Symbol()==Symbol())
           {
            double pr_open=m_position.PriceOpen();
            double pr_curr=m_position.PriceCurrent();
            double pr_tp=m_position.TakeProfit();
            if(b>=2 && m_position.PositionType()==POSITION_TYPE_BUY && m_position.Magic()==Magic)
              {
               if(!CompareDoubles(m_position.TakeProfit(),factb+CORR))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),m_position.StopLoss(),factb+CORR))
                     DebugBreak();
                  buy_or_sell=true;
                 }
              }
            if(s>=2 && m_position.PositionType()==POSITION_TYPE_SELL && m_position.Magic()==Magic)
              {
               if(!CompareDoubles(m_position.TakeProfit(),facts-CORR))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),m_position.StopLoss(),facts-CORR))
                     DebugBreak();
                  buy_or_sell=true;
                 }
              }
           }
        }
     }
//---
   return;
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
//| Create a text label                                              | 
//+------------------------------------------------------------------+ 
bool LabelCreate() // priority for mouse click 
  {
//--- reset the error value 
   ResetLastError();
//--- create a text label 
   if(!ObjectCreate(0,"R",OBJ_LABEL,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates 
   ObjectSetInteger(0,"R",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"R",OBJPROP_YDISTANCE,10);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(0,"R",OBJPROP_CORNER,CORNER_LEFT_UPPER);
//--- set the text 
   ObjectSetString(0,"R",OBJPROP_TEXT,"WWW.TRADING-GO.RU  full version free");
//--- set text font 
   ObjectSetString(0,"R",OBJPROP_FONT,"Arial Black");
//--- set font size 
   ObjectSetInteger(0,"R",OBJPROP_FONTSIZE,15);
//--- set color 
   ObjectSetInteger(0,"R",OBJPROP_COLOR,clrRed);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,Digits()-1)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
