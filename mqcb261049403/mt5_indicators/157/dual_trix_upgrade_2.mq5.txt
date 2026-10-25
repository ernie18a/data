//+------------------------------------------------------------------+
//|                                                 DemoTrixText.mq5 |
//|                                         Copyright 2010, Q_IMPORT |
//|                                              mql.shell@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Q_IMPORT"
#property version   "4.1"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4

//--- plot First Plot
#property indicator_label1  "Plot1"      //Type Of Line To Draw On First Plot
#property indicator_type1   DRAW_LINE       
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Second Plot                 
#property indicator_label2  "Plot2"     //Type Of Line To Draw On Second Plot
#property indicator_type2   DRAW_LINE
#property indicator_color2  Blue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Plot3"      //Type Of Line To Draw On First Plot
#property indicator_type3  DRAW_LINE       
#property indicator_color3  Red
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "Plot4"      //Type Of Line To Draw On First Plot
#property indicator_type4  DRAW_LINE       
#property indicator_color4  Blue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//+------------------------------------------------------------------+
//--- input parameters
input string   seperator1="*--Indicator Settings--*";
input bool               State1=true;
input string   seperator2="*--Periods--*";
input int                Plot1=15;
input int                Plot2=30;
input string   seperator3="Indicator_Coordinates_Fast";
input int        XCord_Indicator_Value_Fast = 0;
input int        YCord_Indicator_Value_Fast = 0;
input string   seperator4="Indicator_Coordinates_Slow";
input int        XCord_Indicator_Slow = 0;
input int        YCord_Indicator_Slow = 20;
input string   seperator5="*--Chart_Coordinates Fast--*";
input int        XCord_Chart_Value_Fast = 0;
input int        YCord_Chart_Value_Fast = 0;
input string   seperator6="*--Chart_Coordinates Slow--*";
input int        XCord_Chart_Slow = 0;
input int        YCord_Chart_Slow = 20;
input string   seperator7="*--Period_Coordinates Fast--*";
input int        XCord_Chart_Period_Fast = 60;
input int        YCord_Chart_Period_Fast = 0;
input string   seperator8="*--Period_Coordinates_Slow--*";
input int        XCord_Chart_Period_Slow = 60;
input int        YCord_Chart_Period_Slow = 20;

input ENUM_APPLIED_PRICE ToClose=PRICE_CLOSE;
//+------------------------------------------------------------------+
//--- indicator buffers
double TriX1[],
TriX2[],
TriX3[],
TriX4[];
int    TriXHandle1,
TriXHandle2,
TriXHandle3,
TriXHandle4;

//+------------------------------------------------------------------+
int window1;

string    objectName="Guage1";
string    slowchart="Guage_slow_chart";
string    objectName1="Guage2";
string    fastchart="Guage_fast_chart";
string    objectName2="Guage3";
string    objectName3="Guage4";
string    slowind="Guage_slow_ind";
string    fastind="Guage_slow_ind";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,TriX1,INDICATOR_DATA);
   SetIndexBuffer(1,TriX2,INDICATOR_DATA);
   SetIndexBuffer(2,TriX3,INDICATOR_DATA);
   SetIndexBuffer(3,TriX4,INDICATOR_DATA);

   ArraySetAsSeries(TriX1,true);  // index Trix1 array as a time series
   ArraySetAsSeries(TriX2,true);  // index Trix1 array as a time series
   ArraySetAsSeries(TriX3,true);  // index Trix1 array as a time series
   ArraySetAsSeries(TriX4,true);  // index Trix1 array as a time series
//+------------------------------------------------------------------+
   TriXHandle1=iTriX(Symbol(),0,Plot1,ToClose);
   TriXHandle2=iTriX(Symbol(),0,Plot2,ToClose);
   TriXHandle3=iTriX(Symbol(),0,Plot2,ToClose);
   TriXHandle4=iTriX(Symbol(),0,Plot1,ToClose);
//+------------------------------------------------------------------+   
   IndicatorSetInteger(INDICATOR_DIGITS,6);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,    // size of the price[] array;
                 const int prev_calculated,// number of available bars at the previous call;
                 const int begin,          // what index in the array price[] the reliable information starts from;
                 const double &price[])    // array the indicator will be calculated by;
  {
//--- we can copy not all data
   int i=0;
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<=0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      //--- last value is always copied
      to_copy++;
     }

   (CopyBuffer(TriXHandle1,0,0,to_copy,TriX1));
   (CopyBuffer(TriXHandle2,0,0,to_copy,TriX2));
   (CopyBuffer(TriXHandle3,0,0,to_copy,TriX3));
   (CopyBuffer(TriXHandle4,0,0,to_copy,TriX4));

//----------------------------------------------------------------------------=
//--              Chart Guage                                                -=
//----------------------------------------------------------------------------=
   ObjectCreate(0,slowchart,OBJ_LABEL,0,0,0);
   ObjectSetString(0,slowchart,OBJPROP_TEXT,""+IntegerToString(Plot1));
   ObjectSetInteger(0,slowchart,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,slowchart,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,slowchart,OBJPROP_XDISTANCE,XCord_Chart_Period_Fast);
   ObjectSetInteger(0,slowchart,OBJPROP_YDISTANCE,YCord_Chart_Period_Fast);
   ObjectSetInteger(0,slowchart,OBJPROP_COLOR,White);
   ObjectSetString(0,slowchart,OBJPROP_FONT,"Impact");
   ObjectSetInteger(0,slowchart,OBJPROP_FONTSIZE,10);

   ObjectCreate(0,fastchart,OBJ_LABEL,0,0,0);
   ObjectSetString(0,fastchart,OBJPROP_TEXT,""+IntegerToString(Plot2));
   ObjectSetInteger(0,fastchart,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,fastchart,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,fastchart,OBJPROP_XDISTANCE,XCord_Chart_Period_Slow);
   ObjectSetInteger(0,fastchart,OBJPROP_YDISTANCE,YCord_Chart_Period_Slow);
   ObjectSetInteger(0,fastchart,OBJPROP_COLOR,White);
   ObjectSetString(0,fastchart,OBJPROP_FONT,"Impact");
   ObjectSetInteger(0,fastchart,OBJPROP_FONTSIZE,10);

   ObjectCreate(0,objectName3,OBJ_LABEL,0,0,0);
   ObjectSetString(0,objectName3,OBJPROP_TEXT,DoubleToString(TriX4[to_copy-1],6));
   ObjectSetInteger(0,objectName3,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,objectName3,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,objectName3,OBJPROP_XDISTANCE,XCord_Chart_Value_Fast);
   ObjectSetInteger(0,objectName3,OBJPROP_YDISTANCE,YCord_Chart_Value_Fast);
   ObjectSetInteger(0,objectName3,OBJPROP_COLOR,Red);
   ObjectSetString(0,objectName3,OBJPROP_FONT,"Impact");
   ObjectSetInteger(0,objectName3,OBJPROP_FONTSIZE,10);
   datetime tm2[1];
   CopyTime(_Symbol,_Period,0,1,tm2);
   ObjectSetInteger(0,objectName3,OBJPROP_TIME,tm2[0]);
   ObjectSetDouble(0,objectName3,OBJPROP_PRICE,(TriX4[to_copy-1]));

   ObjectCreate(0,objectName,OBJ_LABEL,0,0,0);
   ObjectSetString(0,objectName,OBJPROP_TEXT,DoubleToString(TriX3[to_copy-1],6));
   ObjectSetInteger(0,objectName,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,objectName,OBJPROP_XDISTANCE,XCord_Chart_Slow);
   ObjectSetInteger(0,objectName,OBJPROP_YDISTANCE,YCord_Chart_Slow);
   ObjectSetInteger(0,objectName,OBJPROP_COLOR,Blue);
   ObjectSetString(0,objectName,OBJPROP_FONT,"Impact");
   ObjectSetInteger(0,objectName,OBJPROP_FONTSIZE,10);
   datetime tm[1];
   CopyTime(_Symbol,_Period,0,1,tm);
   ObjectSetInteger(0,objectName,OBJPROP_TIME,tm[0]);
   ObjectSetDouble(0,objectName,OBJPROP_PRICE,(TriX3[to_copy-1]));

//----------------------------------------------------------------------------=
//    Indicator Guage  
//---------------------------------------------------------------------------=
   ObjectCreate(0,objectName2,OBJ_LABEL,1,0,0);
   ObjectSetString(0,objectName2,OBJPROP_TEXT,DoubleToString(TriX2[to_copy-1],6));
   ObjectSetInteger(0,objectName2,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,objectName2,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,objectName2,OBJPROP_XDISTANCE,XCord_Indicator_Slow);
   ObjectSetInteger(0,objectName2,OBJPROP_YDISTANCE,YCord_Indicator_Slow);
   ObjectSetInteger(0,objectName2,OBJPROP_COLOR,Blue);
   ObjectSetString(0,objectName2,OBJPROP_FONT,"Impact");
   ObjectSetInteger(0,objectName2,OBJPROP_FONTSIZE,10);
   datetime tm1[1];
   CopyTime(_Symbol,_Period,0,1,tm1);
   ObjectSetInteger(0,objectName2,OBJPROP_TIME,tm1[0]);
   ObjectSetDouble(0,objectName2,OBJPROP_PRICE,(TriX2[to_copy-1]));

   ObjectCreate(0,objectName1,OBJ_LABEL,1,0,0);
   ObjectSetString(0,objectName1,OBJPROP_TEXT,DoubleToString(TriX1[to_copy-1],6));
   ObjectSetInteger(0,objectName1,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,objectName1,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,objectName1,OBJPROP_XDISTANCE,XCord_Indicator_Value_Fast);
   ObjectSetInteger(0,objectName1,OBJPROP_YDISTANCE,YCord_Indicator_Value_Fast);
   ObjectSetInteger(0,objectName1,OBJPROP_COLOR,Red);
   ObjectSetString(0,objectName1,OBJPROP_FONT,"Impact");
   ObjectSetInteger(0,objectName1,OBJPROP_FONTSIZE,10);
   datetime tm3[1];
   CopyTime(_Symbol,_Period,0,1,tm3);
   ObjectSetInteger(0,objectName1,OBJPROP_TIME,tm3[0]);
   ObjectSetDouble(0,objectName1,OBJPROP_PRICE,(TriX1[to_copy-1]));

   return(rates_total);

  }
//+------------------------------------------------------------------+
