//+------------------------------------------------------------------+ 
//|                                          MaksiGen_Range_Move.mq5 |
//|                                       Copyright © 2006, MaksiGen | 
//|                                             olegvs2003@yahoo.com | 
//+------------------------------------------------------------------+ 
//--- copyright
#property copyright "Copyright © 2006, MaksiGen"
//--- link to the website of the author
#property link "olegvs2003@yahoo.com" 
//--- Indicator version
#property version   "1.00"
#property description "Flat determining indicator"
//--- buffers are not used for indicator calculation and drawing
#property indicator_buffers 0
//--- no graphical constructions
#property indicator_plots   0
//+----------------------------------------------+ 
//| Indicator drawing parameters                 |
//+----------------------------------------------+ 
//--- drawing the indicator in the main window
#property indicator_chart_window 
//+----------------------------------------------+
//| declaring constants                          |
//+----------------------------------------------+
#define RESET 0 // A constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+ 
//| declaration of enumerations                  |
//+----------------------------------------------+ 
enum ENUM_WIDTH //Type of constant
  {
   w_1 = 1,     //1
   w_2,         //2
   w_3,         //3
   w_4,         //4
   w_5          //5
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum STYLE
  {
   SOLID_,       // Solid line
   DASH_,        // Dashed line
   DOT_,         // Dotted line
   DASHDOT_,     // Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
  };
//+----------------------------------------------+ 
//| Indicator input parameters                   |
//+----------------------------------------------+ 
//--- common settings
input string LinesSirname="MaksiGen_Range_Move"; // Line name
//---
input uint Pfast=5;
input uint Pslow=8;
input double K_RangeOpen=1.4;
//--- Settings for hi1
input color Line_Color_1=clrTeal;                // Line color of hi1
input STYLE Line_Style_1=DOT_;                   // Line style of hi1
input ENUM_WIDTH Line_Width_1=w_1;               // Line width of hi1
input bool Line_Background_1=true;               // Background mode for the hi1 line
//--- settings for 1
input color Line_Color_2=clrRed;                 // Line color of lo1
input STYLE Line_Style_2=DOT_;                   // Line style of lo1
input ENUM_WIDTH Line_Width_2=w_1;               // Line width of lo1
input bool Line_Background_2=true;               // Background mode for the lo1 line
//--- settings for hi2
input color Line_Color_3=clrTeal;                // Line color of hi2
input STYLE Line_Style_3=DASH_;                  // Line style of hi2
input ENUM_WIDTH Line_Width_3=w_1;               // Line width of hi2
input bool Line_Background_3=true;               // Background mode for the hi2 line
//--- settings for lo2
input color Line_Color_4=clrRed;                 // Line color of lo2
input STYLE Line_Style_4=DASH_;                  // Line style of lo2
input ENUM_WIDTH Line_Width_4=w_1;               // Line width of lo2
input bool Line_Background_4=true;               // Background mode for the lo2 line
//--- settings for Bar#1
input color Line_Color_5=clrGold;                // Line color of Bar#1
input STYLE Line_Style_5=DOT_;                   // Line style of Bar#1
input ENUM_WIDTH Line_Width_5=w_1;               // Line width of Bar#1
input bool Line_Background_5=true;               // Background mode for the Bar#1 line
//--- settings for Bar#Pfast
input color Line_Color_6=clrMagenta;             // Line color of Bar#Pfast
input STYLE Line_Style_6=DOT_;                   // Line style of Bar#Pfast
input ENUM_WIDTH Line_Width_6=w_1;               // Line width of Bar#Pfast
input bool Line_Background_6=true;               // Background mode for the Bar#Pfast line
//--- settings for Bar#Pslow
input color Line_Color_7=clrBlue;                // Line color of Bar#Pslow
input STYLE Line_Style_7=DOT_;                   // Line style of Bar#Pslow
input ENUM_WIDTH Line_Width_7=w_1;               // Line width of Bar#Pslow
input bool Line_Background_7=true;               // Background mode for the Bar#Pslow line
//--- settings for TrendHIGH
input color Line_Color_8=clrBlueViolet;          // Line color of TrendHIGH
input STYLE Line_Style_8=SOLID_;                 // Line style of TrendHIGH
input ENUM_WIDTH Line_Width_8=w_1;               // Line width of TrendHIGH
input bool Line_Background_8=true;               // Background mode for the TrendHIGH line
//--- settings for TrendLOW
input color Line_Color_9=clrBlueViolet;          // Line color of Trend_LOW
input STYLE Line_Style_9=SOLID_;                 // Line style of Trend_LOW
input ENUM_WIDTH Line_Width_9=w_1;               // Line width of Trend_LOW
input bool Line_Background_9=true;               // Background mode for the Trend_LOW line
//--- settings for SELL_STOP
input color Line_Color_10=clrMagenta;             // Line color of SELL_STOP
input STYLE Line_Style_10=DOT_;                   // Line style of SELL_STOP
input ENUM_WIDTH Line_Width_10=w_1;               // Line width of SELL_STOP
input bool Line_Background_10=true;               // Background mode for the SELL_STOP line
//--- settings for BUY_STOP
input color Line_Color_11=clrTeal;                // Line color of BUY_STOP
input STYLE Line_Style_11=DOT_;                   // Line style of BUY_STOP
input ENUM_WIDTH Line_Width_11=w_1;               // Line width of BUY_STOP
input bool Line_Background_11=true;               // Background mode for the BUY_STOP line
//+----------------------------------------------+
//--- declaring variables of the line labels
string name_1,name_2,name_3,name_4,name_5,name_6,name_7,name_8,name_9,name_10,name_11;
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void Deinit()
  {
//---
   ObjectDelete(0,name_1);
   ObjectDelete(0,name_2);
   ObjectDelete(0,name_3);
   ObjectDelete(0,name_4);
   ObjectDelete(0,name_5);
   ObjectDelete(0,name_6);
   ObjectDelete(0,name_7);
   ObjectDelete(0,name_8);
   ObjectDelete(0,name_9);
   ObjectDelete(0,name_10);
   ObjectDelete(0,name_11);
//---
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(Pfast,Pslow));
//--- initialization of string labels
   name_1=LinesSirname+" hi1";
   name_2=LinesSirname+" lo1";
   name_3=LinesSirname+" hi2";
   name_4=LinesSirname+" lo2";
   name_5=LinesSirname+" Bar#1";
   name_6=LinesSirname+" Bar#Pfast";
   name_7=LinesSirname+" Bar#Pslow";
   name_8=LinesSirname+" TrendHIGH";
   name_9=LinesSirname+" TrendLOW";
   name_10=LinesSirname+" SELL_STOP";
   name_11=LinesSirname+" BUY_STOP";
//--- name for the data window and the label for sub-windows 
   IndicatorSetString(INDICATOR_SHORTNAME,"MaksiGen_Range_Move");
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//---
   Deinit();
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
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total || rates_total==prev_calculated) return(RESET);
//--- declarations of local variables 
   double hi1,hi2,lo1,lo2;
   datetime ftime,stime,time1;
//--- indexing elements in arrays as in timeseries 
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---
   hi1=high[ArrayMaximum(high,1,Pfast)];
   lo1=low[ArrayMinimum(low,1,Pfast)];
   hi2=high[ArrayMaximum(high,1,Pslow)];
   lo2=low[ArrayMinimum(low,1,Pslow)];
//---
   ftime=time[Pfast];
   stime=time[Pslow];
   time1=time[1];
//---
   SetHline(0,name_1,0,hi1,Line_Color_1,Line_Style_1,Line_Width_1,name_1);
   SetHline(0,name_2,0,lo1,Line_Color_2,Line_Style_2,Line_Width_2,name_2);
   SetHline(0,name_3,0,hi2,Line_Color_3,Line_Style_3,Line_Width_3,name_3);
   SetHline(0,name_4,0,lo2,Line_Color_4,Line_Style_4,Line_Width_4,name_4);
//---
   SetVline(0,name_5,0,time1,Line_Color_5,Line_Style_5,Line_Width_5,name_5);
   SetVline(0,name_6,0,ftime,Line_Color_6,Line_Style_6,Line_Width_6,name_6);
   SetVline(0,name_7,0,stime,Line_Color_7,Line_Style_7,Line_Width_7,name_7);
   SetTline(0,name_8,0,time[Pslow],hi2,time[Pfast],hi1,Line_Color_8,Line_Style_8,Line_Width_8,name_8);
   SetTline(0,name_9,0,time[Pslow],lo2,time[Pfast],lo1,Line_Color_9,Line_Style_9,Line_Width_9,name_9);
//---
   if(hi1-lo1==hi2-lo2)
     {
      double Range=(hi1-lo1)*K_RangeOpen;
      SetHline(0,name_10,0,lo1-Range,Line_Color_10,Line_Style_10,Line_Width_10,name_10);
      SetHline(0,name_11,0,hi1+Range,Line_Color_11,Line_Style_11,Line_Width_11,name_11);
     }
//--- 
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Creating a trend line                                           |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,      // Chart ID
                 string   name,          // object name
                 int      nwin,          // window index
                 datetime time1,         // price level time 1
                 double   price1,        // price level 1
                 datetime time2,         // price level time 2
                 double   price2,        // price level 2
                 color    Color,         // line color
                 int      style,         // line style
                 int      width,         // line width
                 string   text)          // text 
  {
//---
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
//---
  }
//+------------------------------------------------------------------+
//|  Resetting a trend line                                          |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,      // Chart ID
              string   name,          // object name
              int      nwin,          // window index
              datetime time1,         // price level time 1
              double   price1,        // price level 1
              datetime time2,         // price level time 2
              double   price2,        // price level 2
              color    Color,         // line color
              int      style,         // line style
              int      width,         // line width
              string   text)          // text 
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//---
  }
//+------------------------------------------------------------------+
//|  Create a vertical line                                          |
//+------------------------------------------------------------------+
void CreateVline(long     chart_id,      // Chart id
                 string   name,          // object name
                 int      nwin,          // window index
                 datetime time1,         // vertical level time
                 color    Color,         // line color
                 int      style,         // line style
                 int      width,         // line width
                 string   text)          // text
  {
//---
   ObjectCreate(chart_id,name,OBJ_VLINE,nwin,time1,999999999);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n"); // tooltip disabling
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); // background object
//---
  }
//+------------------------------------------------------------------+
//|  Resetting the vertical line                                     |
//+------------------------------------------------------------------+
void SetVline(long     chart_id,      // chart id
              string   name,          // object name
              int      nwin,          // window index
              datetime time1,         // vertical level time
              color    Color,         // line color
              int      style,         // line style
              int      width,         // line width
              string   text)          // text
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateVline(chart_id,name,nwin,time1,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,999999999);
     }
//---
  }
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline(long   chart_id,      // Chart ID
                 string name,          // object name
                 int    nwin,          // window index
                 double price,         // price level
                 color  Color,         // line color
                 int    style,         // line style
                 int    width,         // line width
                 string text)          // text 
  {
//---
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//---
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the horizontal price level                    |
//+------------------------------------------------------------------+
void SetHline(long   chart_id,      // chart ID
              string name,          // object name
              int    nwin,          // window index
              double price,         // price level
              color  Color,         // line color
              int    style,         // line style
              int    width,         // line width
              string text)          // text  
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//---
  }
//+------------------------------------------------------------------+
