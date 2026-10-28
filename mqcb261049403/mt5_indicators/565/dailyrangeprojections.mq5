//+------------------------------------------------------------------+
//|                                      Daily Range Projections.mq5 |
//|                           Copyright © 2010,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2010, Nikolay Kositsin"
//---- link to the website of the author
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+  
enum Width
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,      // Solid line
   DASH_,       // Dashed line
   DOT_,        // Dotted line
   DASHDOT_,    // Dot-dash line
   DASHDOTDOT_  // Dot-dash line with double dots
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input color  Color_MAX=Lime;        // Tomorrow's high line color
input STYLE  Style_MAX=SOLID_;      // Tomorrow's high line style
input Width  Width_MAX=Width_4;     // Tomorrow's high line width
//----
input color  Color_MID=DarkOrchid;  // Tomorrow's middle line color
input STYLE  Style_MID=DASHDOTDOT_; // Tomorrow's middle line style
input Width  Width_MID=Width_1;     // Tomorrow's middle line width
//----
input color  Color_MIN=Red;         // Tomorrow's low line color
input STYLE  Style_MIN=SOLID_;      // Tomorrow's low line style
input Width  Width_MIN=Width_4;     // Tomorrow's low line width
//+----------------------------------------------+
string MAX,MIN,MID;
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline(long   chart_id,  // chart ID
                 string name,      // object name
                 int    nwin,      // window index
                 double price,     // price level
                 color  Color,     // line color
                 int    style,     // line style
                 int    width,     // line width
                 string text)      // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the horizontal price level                    |
//+------------------------------------------------------------------+
void SetHline(long   chart_id,  // chart ID
              string name,      // object name
              int    nwin,      // window index
              double price,     // price level
              color  Color,     // line color
              int    style,     // line style
              int    width,     // line width
              string text)      // text
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,text);
   else
     {
      // ObjectSetDouble(chart_id,name,OBJPROP_MIDRICE,price);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- creating labels for displaying in DataWindow and the name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"Daily Range Projections");

   MAX="Maximum Daily Range Projections";
   MIN="Minimum Daily Range Projections";
   MID="Middle Daily Range Projections";
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,MAX);
   ObjectDelete(0,MID);
   ObjectDelete(0,MIN);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,     // number of bars in history at the current tick
                const int prev_calculated, // number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],      // price array of maximums of price for the calculation of indicator
                const double& low[],       // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- 
   if(_Period>=PERIOD_D1) return(RESET);

//---- declarations of static variables    
   double Tomorrow_High,Tomorrow_Low,Tomorrow_Middle;

//---- declarations of local variables   
   MqlRates rates[2]; // static array and reverse indexing of the elements (the current bar is the first one!)
   double X=0.0;

//---- copy newly appeared data in the rates array
   if(CopyRates(Symbol(),PERIOD_D1,0,2,rates)<=0) return(RESET);

   if(rates[1].close<rates[1].open) X=(rates[0].high+rates[0].low+rates[0].close+rates[0].low)/2.0;
   if(rates[1].close>rates[1].open) X=(rates[0].high+rates[0].low+rates[0].close+rates[0].high)/2.0;
   if(rates[1].close==rates[1].open) X=(rates[0].high+rates[0].low+rates[0].close+rates[0].close)/2.0;

   Tomorrow_High= NormalizeDouble(X-rates[0].low,_Digits);
   Tomorrow_Low = NormalizeDouble(X-rates[0].high,_Digits);
   Tomorrow_Middle=NormalizeDouble((Tomorrow_High+Tomorrow_Low)/2.0,_Digits);

   SetHline(0,MAX,0,Tomorrow_High,Color_MAX,Style_MAX,Width_MAX,"MAX "+DoubleToString(Tomorrow_High,_Digits));
   SetHline(0,MID,0,Tomorrow_Middle,Color_MID,Style_MID,Width_MID,"MID "+DoubleToString(Tomorrow_Middle,_Digits));
   SetHline(0,MIN,0,Tomorrow_Low,Color_MIN,Style_MIN,Width_MIN,"MIN "+DoubleToString(Tomorrow_Low,_Digits));
//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
