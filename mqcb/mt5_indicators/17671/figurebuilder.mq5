//+------------------------------------------------------------------+
//|                                                FigureBuilder.mq5 |
//|                                          Copyright 2017, Progid. |
//|                            https://www.mql5.com/en/users/progid/ |
//+------------------------------------------------------------------+
#property version   "1.0"
#property copyright "2017, Progid."
#property link      "https://www.mql5.com/en/users/progid/"


//+-------------------------------- Versions History --------------------------------+
//|
//| This tool helps to build the figures on the chart.
//| Ctrl + left click - put a dot in the chart.
//| Ctrl + Backspase  - undo the last action.
//| Ctrl + Delete     - clear the chart(remove all objects with the prefix name).
//| 
//| v.1.0
//| - 
//|
//+-------------------------------- Versions History --------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_chart_window

#property indicator_buffers 0
#property indicator_plots   0


//+------------------------------------------------------------------+
//| define
//+------------------------------------------------------------------+
#ifndef    _Error_
#define _Error_(info) {Print("Error: ",info," line: "+(string)__LINE__+" file: "+__FILE__+" function: "+__FUNCTION__+"; GetLastError: "+(string)GetLastError());}
#endif

#ifndef    _ErrorDefault_
#define _ErrorDefault_(info,r) {_Error_(info) r;}
#endif


//+------------------------------------------------------------------+
//| include
//+------------------------------------------------------------------+
#include <cFigureBuilder.mqh>


//+------------------------------------------------------------------+
//| inputs
//+------------------------------------------------------------------+
input string           Prefix_="Figure";//Objects prefix name

input string _dots_="------- Dot -------";//:
input uint             DotsMax_=5;//[2...]Dots Max Number

input uchar            DotEmptyArowCode_=161;//Empty Dot Code
input uint             DotEmptySize_=4;//Empty Dot Width

input uchar            DotFillArowCode_=108;//Filled Dot Code
input uint             DotFillSize_=2;//Filled Dot Width

input string _line_ = "------- Line -------";//:
input bool             LineLeftRay_  = false;//First Dot Line Left Ray
input bool             LineRightRay_ = false;//Last Dot Line Right Ray
input color            LineColor_=clrRed;//Lines color
input ENUM_LINE_STYLE  LineStyle_=STYLE_SOLID;//Lines Style
input uchar            LineWidth_=1;//Lines Width

//+------------------------------------------------------------------+
//| global
//+------------------------------------------------------------------+
string _Prefix;

cFigureBuilder _Builder;
//+------------------------------------------------------------------+
//| program start function
//+------------------------------------------------------------------+
int OnInit()
  {
   _Prefix=(Prefix_!="" ? Prefix_ : "Figure")+":";

   if(!_Builder.Init(DotsMax_)) _ErrorDefault_("", return INIT_FAILED)

      Print("Monitoring Started.");

   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| program deinit function
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("Monitoring Completed.");
  }
//+------------------------------------------------------------------+
//| chart event function
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   _Builder.OnEvent(id,lparam,dparam,sparam);
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
  { return 0; }
//+------------------------------------------------------------------+   
