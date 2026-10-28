//+------------------------------------------------------------------+
//|                                              iSimpleClock_v2.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "https://www.mql5.com/en/users/integer"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

#include <IncGUI_v4.mqh>
/*
   The second version of iSimpleClock. Now, the clocks are displayed via the "label" graphical object. 
   It is possible to change a label color, font size, label location.

   IncGUI_v4.mqh library is required for the indicator operation. 
   IncGUI_v4.mqh library is located here: http://www.mql5.com/en/code/542.
   Direct link for the library download: http://p.mql5.com/data/18/542/IncGUI_v4__4.mqh.
   The library must be located in the MQL5\Include directory of the terminal data folder.
   Terminal data folder can be found the following way: select "Open"
   in the "Journal" tab context menu, and go one level up in the emerged window

   Parameters:

   FontSize - font size;
   FontColor - color;
   Corner - location corner;
   PosX - horizontal offset of the chart margin;
   PosY - vertical offset of the chart margin.
   
*/

input int               FontSize    =  8;
input color             FontColor   =  clrKhaki;
input ENUM_BASE_CORNER  Corner      =  CORNER_RIGHT_LOWER;
input int               PosX        =  0;
input int               PosY        =  0;
datetime BarTime=0;
string   ObjName="Clock";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   g.CreateLabel(ObjName,0,0);
   g.SetColor(ObjName,FontColor);
   g.SetFontSize(ObjName,FontSize);
   g.SetCorner(ObjName,Corner);
   g.SetXYDistance(ObjName,PosX,PosY);
   if(Corner==CORNER_LEFT_UPPER)g.SetAnchor(ObjName,ANCHOR_LEFT_UPPER);
   if(Corner==CORNER_LEFT_LOWER)g.SetAnchor(ObjName,ANCHOR_LEFT_LOWER);
   if(Corner==CORNER_RIGHT_UPPER)g.SetAnchor(ObjName,ANCHOR_RIGHT_UPPER);
   if(Corner==CORNER_RIGHT_LOWER)g.SetAnchor(ObjName,ANCHOR_RIGHT_LOWER);
   EventSetTimer(1);
   return(0);
  }
void OnDeinit(const int reason)
  {
//--- indicator buffers mapping
   g.Delete(ObjName);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   BarTime=time[rates_total-1];
   OnTimer();

   return(rates_total);
  }
void OnTimer()
  {
   if(Period()==PERIOD_W1 || Period()==PERIOD_MN1)
     {
      return;
     }
   if(BarTime==0)
     {
      g.SetText(ObjName,"Waiting for price change...");
      return;
     }
   datetime tc=TimeCurrent();
   datetime tf=tc-BarTime;
   datetime tt=PeriodSeconds(Period())-tf;
   if(tt<0)
     {
      g.SetText(ObjName,"Waiting for a new bar opening...");
      return;
     }

   g.SetText(ObjName,TimeToString(tc,TIME_SECONDS)+" - "+
             TimeToString(tf,TIME_SECONDS)+" - "+
             TimeToString(tt,TIME_SECONDS)
             );

  }
//+------------------------------------------------------------------+
