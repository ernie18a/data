//+------------------------------------------------------------------+
//|                  SupportResistTrade(barabashkakvn's edition).mq5 |
//|                                 Copyright © 2008, Gryb Alexander |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Gryb Alexander"
#property link      ""
#property version "1.002"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
#define MODE_LOW 1
#define MODE_HIGH 2
//---
input int      numBars=55;
input int      maPeriod=500;
input ENUM_TIMEFRAMES timeFrame=PERIOD_M1;   // TIMEFRAMES
input double   InpLot=0.1;
//---
double support;
double resist;
string trendType;
//---
ulong             m_magic     = 57985;       // magic number
ulong             m_slippage  = 30;          // slippage
int               handle_iMA;                // variable for storing the handle of the iMA indicator 

ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
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
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),timeFrame,maPeriod,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
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
   if(!HLineCreate(0,"lineSupport",0,0,clrBlue))
      return(INIT_FAILED);
   if(!HLineCreate(0,"lineResist",0,0,clrRed))
      return(INIT_FAILED);
   if(!LabelCreate(0,"lblTrendType",0,50,50,0,"TrendType","Tahoma",14,clrRed))
      return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0,0,-1);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MarketAnalize();
   if(CalculatePositions()==0)
      CheckForOpen();
   else
      CheckForClose();
//----
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarketAnalize()
  {
//--- определяем линии поддержки\сопротивления
   support=iLowest(m_symbol.Name(),timeFrame,MODE_LOW,numBars,1);
   resist=iHighest(m_symbol.Name(),timeFrame,MODE_HIGH,numBars,1);

   HLineMove(0,"lineSupport",support);
   HLineMove(0,"lineResist",resist);

//--- определяем состояние рынка: медведи или быки
   double ma=iMAGet(0);
   double open=iOpen(m_symbol.Name(),timeFrame,0);

   if(open>ma)
      trendType="bullish";

   if(open<ma)
      trendType="bearish";

   LabelTextChange(0,"lblTrendType",trendType);

//-- итог: есть линии поддержки\сопротивления и определено состояние рынка(бычий\медвежий)
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {

   if(trendType=="bullish")
     {
      if(!RefreshRates())
         return;

      if(m_symbol.Ask()>resist)
        {
         //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
         double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),InpLot,m_symbol.Ask(),ORDER_TYPE_BUY);

         if(chek_volime_lot!=0.0)
            if(chek_volime_lot>=InpLot)
              {
               double sl=m_symbol.NormalizePrice(support);

               if(m_trade.Buy(InpLot,NULL,m_symbol.Ask(),sl,0.0))
                 {
                  if(m_trade.ResultDeal()==0)
                    {
                     Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                  else
                     Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
               else
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
        }

     }
   if(trendType=="bearish")
     {
      if(!RefreshRates())
         return;

      if(m_symbol.Bid()<support)
        {
         //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
         double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),InpLot,m_symbol.Bid(),ORDER_TYPE_SELL);

         if(chek_volime_lot!=0.0)
            if(chek_volime_lot>=InpLot)
              {
               double sl=m_symbol.NormalizePrice(resist);

               if(m_trade.Sell(InpLot,NULL,m_symbol.Bid(),sl,0.0))
                 {
                  if(m_trade.ResultDeal()==0)
                    {
                     Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                  else
                     Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
               else
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForClose()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            //if(!RefreshRates())
            //   continue;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.Profit()>0)
                  if(m_position.PriceCurrent()<support)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
               //--- trailing
               if((m_position.PriceCurrent()>m_position.PriceOpen()+20*m_adjusted_point) &&
                  (m_position.StopLoss()<(m_position.PriceOpen()+10*m_adjusted_point)))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_position.PriceOpen()+10*m_adjusted_point,
                     m_position.TakeProfit()))
                     Print("PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
               if((m_position.PriceCurrent()>m_position.PriceOpen()+40*m_adjusted_point) &&
                  (m_position.StopLoss()<(m_position.PriceOpen()+20*m_adjusted_point)))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_position.PriceOpen()+20*m_adjusted_point,
                     m_position.TakeProfit()))
                     Print("PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
               if((m_position.PriceCurrent()>m_position.PriceOpen()+60*m_adjusted_point) &&
                  (m_position.StopLoss()<(m_position.PriceOpen()+30*m_adjusted_point)))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_position.PriceOpen()+30*m_adjusted_point,
                     m_position.TakeProfit()))
                     Print("PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.Profit()>0)
                  if(m_position.PriceCurrent()>resist)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
               //--- trailing
               if((m_position.PriceCurrent()<m_position.PriceOpen()-20*m_adjusted_point) &&
                  (m_position.StopLoss()>(m_position.PriceOpen()-10*m_adjusted_point)))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_position.PriceOpen()-10*m_adjusted_point,
                     m_position.TakeProfit()))
                     Print("PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
               if((m_position.PriceCurrent()<m_position.PriceOpen()-40*m_adjusted_point) && (m_position.StopLoss()>(m_position.PriceOpen()-20*m_adjusted_point)))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_position.PriceOpen()-20*m_adjusted_point,
                     m_position.TakeProfit()))
                     Print("PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
               if((m_position.PriceCurrent()<m_position.PriceOpen()-60*m_adjusted_point) && (m_position.StopLoss()>(m_position.PriceOpen()-30*m_adjusted_point)))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_position.PriceOpen()-30*m_adjusted_point,
                     m_position.TakeProfit()))
                     Print("PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
              }
           }
  }
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long   chart_ID=0,    // chart's ID 
                 const string name="line",   // line name 
                 const int    sub_window=0,  // subwindow index 
                 double       price=0,       // line price 
                 const color  clr=clrGreen)  // color line
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(ObjectFind(chart_ID,name)>=0)
     {
      return(HLineMove(chart_ID,name,price));
     }
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long     chart_ID=0,    // chart's ID 
               const string   name="line",   // line name 
               double         price=0)       // line price 
  {
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create a text label                                              | 
//+------------------------------------------------------------------+ 
bool LabelCreate(const long              chart_ID=0,               // chart's ID 
                 const string            name="Label",             // label name 
                 const int               sub_window=0,             // subwindow index 
                 const int               x=0,                      // X coordinate 
                 const int               y=0,                      // Y coordinate 
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                 const string            text="Label",             // text 
                 const string            font="Arial",             // font 
                 const int               font_size=10,             // font size 
                 const color             clr=clrRed,               // color 
                 const double            angle=0.0,                // text slope 
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                 const bool              back=false,               // in the background 
                 const bool              selection=false,          // highlight to move 
                 const bool              hidden=true,              // hidden in the object list 
                 const long              z_order=0)                // priority for mouse click 
  {
//--- reset the error value 
   ResetLastError();
//--- create a text label 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Change the label text                                            | 
//+------------------------------------------------------------------+ 
bool LabelTextChange(const long   chart_ID=0,   // chart's ID 
                     const string name="Label", // object name 
                     const string text="Text")  // text 
  {
//--- reset the error value 
   ResetLastError();
//--- change object text 
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
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
//| Подсчёт позиций Buy и Sell                                       |
//+------------------------------------------------------------------+
int CalculatePositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
