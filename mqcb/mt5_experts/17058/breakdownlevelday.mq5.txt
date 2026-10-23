//+------------------------------------------------------------------+
//|                   BreakdownLevelDay(barabashkakvn's edition).mq5 |
//|                               Copyright © 2011, Hlystov Vladimir |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, http://cmillion.narod.ru"
#property link      "cmillion@narod.ru"
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
//---
input string   TimeSet     = "07:32";  //Order place time, if TimeSet = "00:00", the EA works on the breakdown of the previous day. 
input ushort   InpDelta    = 6;        //Order price shift (in points) from High/Low price
input ushort   InpSL       = 120;      //Stop Loss (in points)
input ushort   InpTP       = 90;       //Take Profit (in points)
input double   risk        = 0;        //if 0, fixed lot is used
input ushort   InpNoLoss   = 0;        //if 0, it doesn't uses break-even
input ushort   InpTrailing = 0;        //if 0, it doesn't uses Trailing
input double   InpLot      = 0.10;     //used only if risk = 0
input bool     OpenStop    = true;     //Place stop orders if position is opened
input color    color_BAR   = DarkBlue; //info color
//---
double         MaxPrice=0.0,MinPrice=0.0;
int            STOPLEVEL=0,LastDay=0;
datetime       TimeBarbuy=0,TimeBarSell=0;
ulong          m_magic=123321;

double         ExtDelta=0.0;
double         ExtSL=0.0;
double         ExtTP=0.0;
double         ExtNoLoss=0.0;
double         ExtTrailing=0.0;
double         ExtLot=InpLot;
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
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtDelta    = InpDelta     * digits_adjust;
   ExtSL       = InpSL        * digits_adjust;
   ExtTP       = InpTP        * digits_adjust;
   ExtNoLoss   = InpNoLoss    * digits_adjust;
   ExtTrailing = InpTrailing  * digits_adjust;

   STOPLEVEL=m_symbol.StopsLevel();
   if(ExtSL<STOPLEVEL)
      ExtSL=STOPLEVEL;

   if(ExtTP<STOPLEVEL)
      ExtTP=STOPLEVEL;

   if(ExtNoLoss<STOPLEVEL && ExtNoLoss!=0)
      ExtNoLoss=STOPLEVEL;

   if(ExtTrailing<STOPLEVEL && ExtTrailing!=0)
      ExtTrailing=STOPLEVEL;

   Comment("Copyright © 2011 cmillion@narod.ru\n BreakdownLevelDay input parameters"+"\n"+
           "TimeSet   ",TimeSet,"\n",
           "Delta       ",DoubleToString(ExtDelta,0),"\n",
           "SL           ",DoubleToString(ExtSL,0),"\n",
           "TP          ",DoubleToString(ExtTP,0),"\n",
           "Lot          ",DoubleToString(ExtLot,2),"\n",
           "risk         ",risk,"\n",
           "NoLoss    ",DoubleToString(ExtNoLoss,0),"\n",
           "Trailing     ",DoubleToString(ExtTrailing,0));
   if(TimeSet=="00:00") LastDay=1;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(OpenStop)
     {
      m_magic=str1.day;
      m_trade.SetExpertMagicNumber(m_magic);
     }
   if(m_account.TradeMode()==ACCOUNT_TRADE_MODE_REAL)
     {
      Comment("Demo version, contact cmillion@narod.ru");
      return;
     }
//---
   int buy=0,sel=0;
   bool BUY=false,SEL=false;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               BUY=true;
            if(m_position.PositionType()==POSITION_TYPE_SELL)
               SEL=true;
           }

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
           {
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
               buy++;
            if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
               sel++;
           }

   if((BUY || SEL) && (buy!=0 || sel!=0))
      DelAllStop();          // delete stop orders if order opened

   if(BUY || SEL)
     {
      if(ExtTrailing!=0)
         TrailingStop();

      if(ExtNoLoss!=0)
         No_Loss();

      return;                                              // opened order exist
     }

   if(TimeStr(TimeCurrent())!=TimeSet)
      return;                // if time isn't equal to order set time

   datetime expiration=TimeCurrent()+(23-str1.hour)*3600+(60-str1.min)*60;  //set order expiration time

   double TrPr=0.0,StLo=0.0;

   if(risk!=0)
      ExtLot=LOT();

   if(!RefreshRates())
      return;
   if(buy<1 && TimeBarbuy!=str1.day)
     {
      MaxPrice=iHigh(m_symbol.Name(),PERIOD_D1,LastDay)+NormalizeDouble(ExtDelta*Point(),Digits());

      if(m_symbol.Ask()+STOPLEVEL*Point()>MaxPrice)
         MaxPrice=NormalizeDouble(m_symbol.Ask()+STOPLEVEL*Point(),Digits());

      if(ExtTP!=0)
         TrPr=NormalizeDouble(MaxPrice+ExtTP*Point(),Digits());

      if(ExtSL!=0)
         StLo=NormalizeDouble(MaxPrice-ExtSL*Point(),Digits());

      if(!m_trade.BuyStop(ExtLot,MaxPrice,m_symbol.Name(),StLo,TrPr,ORDER_TIME_SPECIFIED,expiration,"BUYSTOP BLD"))
         Print("BUY_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
               ", ticket of order: ",m_trade.ResultOrder());
      else
         TimeBarbuy=str1.day;
     }
   if(sel<1 && TimeBarSell!=str1.day)
     {
      MinPrice=iLow(m_symbol.Name(),PERIOD_D1,LastDay)-NormalizeDouble(ExtDelta*Point(),Digits());

      if(m_symbol.Bid()-STOPLEVEL*Point()<MinPrice)
         MinPrice=NormalizeDouble(m_symbol.Bid()-STOPLEVEL*Point(),Digits());

      if(ExtTP!=0)
         TrPr=NormalizeDouble(MinPrice-ExtTP*Point(),Digits());

      if(ExtSL!=0)
         StLo=NormalizeDouble(MinPrice+ExtSL*Point(),Digits());

      if(!m_trade.SellStop(ExtLot,MinPrice,m_symbol.Name(),StLo,TrPr,ORDER_TIME_SPECIFIED,expiration,"SELLSTOP BLD"))
         Print("SELL_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
               ", ticket of order: ",m_trade.ResultOrder());
      else
         TimeBarSell=str1.day;
     }
   if(buy<1 && sel<1)
     {
      ObjectDelete(0,"bar0");
      ObjectCreate(0,"bar0",OBJ_RECTANGLE,0,iTime(m_symbol.Name(),PERIOD_D1,0),MaxPrice,TimeCurrent(),MinPrice);
      ObjectSetInteger(0,"bar0",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,"bar0",OBJPROP_COLOR,color_BAR);
      ObjectSetInteger(0,"bar0",OBJPROP_BACK,true);
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DelAllStop()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
           {
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP || m_order.OrderType()==ORDER_TYPE_SELL_STOP)
               m_trade.OrderDelete(m_order.Ticket());
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingStop()
  {
   double TrPr=0.0,StLo=0.0;
//bool error;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(!RefreshRates())
                  return;
               StLo=m_symbol.Bid()-ExtTrailing*Point();
               if(StLo>m_position.StopLoss() && StLo>m_position.PriceOpen())
                 {
                  m_trade.PositionModify(m_position.Ticket(),
                                         NormalizeDouble(StLo,Digits()),
                                         m_position.TakeProfit());
                  Comment("Trailing "+IntegerToString(m_position.Ticket()));
                  //Sleep(500);
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(!RefreshRates())
                  return;
               StLo=m_symbol.Ask()+ExtTrailing*Point();
               if(StLo<m_position.StopLoss() && StLo<m_position.PriceOpen())
                 {
                  m_trade.PositionModify(m_position.Ticket(),
                                         NormalizeDouble(StLo,Digits()),m_position.TakeProfit());
                  Comment("Trailing "+IntegerToString(m_position.Ticket()));
                  //Sleep(500);
                 }
              }
            //if(error==false && ExtSL!=0) Alert("Error SELLSTOP ",GetLastError(),"   ",Symbol(),"   ExtSL ",StLo);
           }
//}//tip<2
//}//OrderSelect
//}//for
  }
//------------------------------------------------------------------+
double LOT()
  {
   double MINLOT=m_symbol.LotsMin();

   double margin_required=0.0;
   if(!OrderCalcMargin(ORDER_TYPE_BUY,m_symbol.Name(),1.0,m_symbol.Ask(),margin_required))
      return(MINLOT);

   double LOT=m_account.FreeMargin()*risk/100.0/margin_required/15.0;

   if(LOT>m_symbol.LotsMax())
      LOT=m_symbol.LotsMax();

   if(LOT<MINLOT)
      LOT=MINLOT;

   if(MINLOT<0.1)
      LOT=NormalizeDouble(LOT,2);
   else
      LOT=NormalizeDouble(LOT,1);

   return(LOT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void No_Loss()
  {
   double TrPr=0.0,StLo=0.0;
//bool error;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.StopLoss()>=m_position.PriceOpen())
                  return;

               if(!RefreshRates())
                  return;
               StLo=m_symbol.Bid()-ExtNoLoss*Point();
               if(StLo>m_position.StopLoss() && StLo>m_position.PriceOpen())
                 {
                  m_trade.PositionModify(m_position.Ticket(),
                                         NormalizeDouble(StLo,Digits()),
                                         m_position.TakeProfit());
                  Comment("Trailing "+IntegerToString(m_position.Ticket()));
                  //Sleep(500);
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.StopLoss()<=m_position.PriceOpen())
                  return;

               if(!RefreshRates())
                  return;
               StLo=m_symbol.Ask()+ExtNoLoss*Point();
               if(StLo<m_position.StopLoss() && StLo<m_position.PriceOpen())
                 {
                  m_trade.PositionModify(m_position.Ticket(),
                                         NormalizeDouble(StLo,Digits()),
                                         m_position.TakeProfit());
                  Comment("Trailing "+IntegerToString(m_position.Ticket()));
                  //Sleep(500);
                 }
              }
            //if(error==false && ExtSL!=0) Alert("Error SELLSTOP ",GetLastError(),"   ",Symbol(),"   ExtSL ",StLo);
           }//tip<2
//}//OrderSelect
// }//for
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeStr(datetime taim)
  {
   MqlDateTime str1;
   TimeToStruct(taim,str1);

   string sTaim="";
   int HH=str1.hour;     // Hour                  
   int MM=str1.min;   // Minute   

   if(HH<10)
      StringConcatenate(sTaim,"0",HH);
   else
      sTaim=IntegerToString(HH);

   if(MM<10)
      StringConcatenate(sTaim,sTaim,":0",MM);
   else
      StringConcatenate(sTaim,sTaim,":",IntegerToString(MM));

   return(sTaim);
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
//--------------------------------------------------------------------
