//+------------------------------------------------------------------+
//|                                                 PositionInfo.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Indicator of state of open position"

//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//+----------------------------------------------+
// type_font enumeration description             |
// CFontName class description                   | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input color  UpColor=Lime;//color of profitable position
input color  DnColor=Red;//color of unprofitable position
input color  ZrColor=Gray;//color of position without profit
input int    FontSize=15; //font size
input type_font FontType=Font14; //font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; //location corner
input uint Y_=1; //vertical location
input uint X_=5; //horizontal location
//+----------------------------------------------+
string sFontType;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//----
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit();
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   ObjectDelete(0,"PositionInfo_Label_1");
   ObjectDelete(0,"PositionInfo_Label_2");
   ObjectDelete(0,"PositionInfo_Label_3");
   ObjectDelete(0,"PositionInfo_Label_4");
   ObjectDelete(0,"PositionInfo_Label_5");
//----
  }
//+------------------------------------------------------------------+
//|  Creation of a text label                                        |
//+------------------------------------------------------------------+
void CreateTLabel
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner,// base corner location
 ENUM_ANCHOR_POINT point, // anchor point location
 int    X,                // the distance from the base corner along the X-axis in pixels
 int    Y,                // the distance from the base corner along the Y-axis in pixels
 string text,             // text
 color  Color,            // text color
 string Font,             // text font
 int    Size              // font size
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Text label reinstallation                                       |
//+------------------------------------------------------------------+
void SetTLabel
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner,// base corner location
 ENUM_ANCHOR_POINT point, // anchor point location
 int    X,                // the distance from the base corner along the X-axis in pixels
 int    Y,                // the distance from the base corner along the Y-axis in pixels
 string text,             // text
 color  Color,            // text color
 string Font,             // text font
 int    Size              // font size
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//----
   bool Res=PositionSelect(Symbol());
   ENUM_POSITION_TYPE PosType=ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE));
//---- Checking, if there is an open position
   if(!Res || PosType!=POSITION_TYPE_SELL && PosType!=POSITION_TYPE_BUY)
     {
      Deinit();
      return(rates_total);
     }

   string sPosType;
   color Color;
   int nStop,nTake,nProfit;
   double point,price,Stop,Take,Profit,OpenPrice;
   point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   int digit=int(SymbolInfoInteger(Symbol(),SYMBOL_DIGITS));
   if(PosType==POSITION_TYPE_BUY) price=SymbolInfoDouble(Symbol(), SYMBOL_BID);
   else price=SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   if(!digit || !point || !price) return(TRADE_RETCODE_ERROR);

//----
   Stop=PositionGetDouble(POSITION_SL);
   Take=PositionGetDouble(POSITION_TP);
   Profit=PositionGetDouble(POSITION_PROFIT);
   OpenPrice=PositionGetDouble(POSITION_PRICE_OPEN);

   if(PosType==POSITION_TYPE_BUY)
     {
      if(Stop) nStop=int((price-Stop)/_Point); else nStop=0;
      if(Take) nTake=int((Take-price)/_Point); else nTake=0;
      nProfit=int((price-OpenPrice)/_Point);
      sPosType="BUY";
     }
   else
     {
      if(Stop) nStop=int((Stop-price)/_Point); else nStop=0;
      if(Take) nTake=int((price-Take)/_Point); else nTake=0;
      nProfit=int((OpenPrice-price)/_Point);
      sPosType="SELL";
     }

   if(Profit>0) Color=UpColor;
   else if(Profit<0) Color=DnColor;
   else Color=ZrColor;

   string sStop,sTake,sNProfit,sPProfit;

   sPProfit="Profit = "+DoubleToString(Profit,2);
   sNProfit="Point Profit = "+string(nProfit);
   if(Stop) sStop="SL = "+string(nStop); else sStop="SL = None";
   if(Take) sTake="TP = "+string(nTake); else sTake="TP = None";
//----
   int shift_1,shift_2,shift_3,shift_4,shift_5;

   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=80;
         shift_2=60;
         shift_3=40;
         shift_4=20;
         shift_5=0;
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=80;
         shift_2=60;
         shift_3=40;
         shift_4=20;
         shift_5=0;
         break;
        }
      default:
        {
         shift_1=0;
         shift_2=20;
         shift_3=40;
         shift_4=60;
         shift_5=80;
        }
     }

   SetTLabel(0,"PositionInfo_Label_1",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+shift_1,sPosType,Color,sFontType,FontSize);
   SetTLabel(0,"PositionInfo_Label_2",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+shift_2,sPProfit,Color,sFontType,FontSize);
   SetTLabel(0,"PositionInfo_Label_3",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+shift_3,sNProfit,Color,sFontType,FontSize);
   SetTLabel(0,"PositionInfo_Label_4",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+shift_4,sTake,Color,sFontType,FontSize);
   SetTLabel(0,"PositionInfo_Label_5",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+shift_5,sStop,Color,sFontType,FontSize);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
