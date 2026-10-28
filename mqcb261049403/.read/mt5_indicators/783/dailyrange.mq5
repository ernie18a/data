//+------------------------------------------------------------------+
//|                                                   DailyRange.mq5 |
//|                                       Copyright © 2005, mishanya |
//|                                   http://www.fxtradercenter.com/ |
//+------------------------------------------------------------------+
//---- copyright
#property copyright "Copyright © 2005, mishanya"
//---- site
#property link      "http://www.fxtradercenter.com/"
//---- indicator version
#property version   "1.00"
//---- indicator in chart window
#property indicator_chart_window 
#property indicator_buffers  0
#property indicator_plots    0
//+-----------------------------------+
//|  number enumeration               |
//+-----------------------------------+
enum Number
  {
   Number_0,
   Number_1,
   Number_2,
   Number_3
  };
//+-----------------------------------+
//|  width enumeration                |
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
//|  style enumeration                |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,       // solid
   DASH_,        // dash
   DOT_,         // dot
   DASHDOT_,     // dash-dot
   DASHDOTDOT_   // dash-dot-dot
  };
//+----------------------------------------------+
//|  enumeration                                 |
//+----------------------------------------------+
#define RESET  0 // indicator recalculation (reset)
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint StepBack=0;
//----
input color  Color_Res = Lime;    // Color of Resistance level
input color  Color_Sup = Red;     // Color of Support level
//----
input STYLE  Style_Res = SOLID_;  // Style of Resistance level
input STYLE  Style_Sup = SOLID_;  // Style of Support level
//----
input Width  Width_Res = Width_2; // Width of Resistance level
input Width  Width_Sup = Width_2; // Width of Support level
//+----------------------------------------------+
//----
int d;
//+------------------------------------------------------------------+
//| Creation of horizontal level                                     |
//+------------------------------------------------------------------+
void CreateHline(long   chart_id,   // chart ID
                 string name,       // name
                 int    nwin,       // window index
                 double price,      // price
                 color  Color,      // color
                 int    style,      // style
                 int    width,      // width
                 string text)       // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
//----
  }
//+------------------------------------------------------------------+
//| Reset of horizontal level                                        |
//+------------------------------------------------------------------+
void SetHline(long   chart_id,   // chart ID
              string name,       // name
              int    nwin,       // window index
              double price,      // price
              color  Color,      // color
              int    style,      // style
              int    width,      // width
              string text)       // text
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateHline(chart_id,name,nwin,price,Color,style,width,text);
     }
   else
     {
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
//----  
   d=int(1+StepBack);

//---- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- set indicator short name (shown in DataWindow and tooltip)
   IndicatorSetString(INDICATOR_SHORTNAME,"DailyRange");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,"DSup line");
   ObjectDelete(0,"DRes line");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // total bars in history at current tick
                const int prev_calculated,// bars, calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // High[] prices array
                const double& low[],      // Low[] prices array
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- 
   if(_Period>=PERIOD_D1) return(RESET);

   static double sup,res;

   if(prev_calculated!=rates_total)
     {
      //---- declaration of local variables
      double dOpen[],dClose[],dLow[],dHigh[],X;
      uint to_copy=d+1;
      //---- copy new data to arrays
      if(CopyOpen(Symbol(), PERIOD_D1,0,to_copy,dOpen) <=0) return(RESET);
      if(CopyClose(Symbol(),PERIOD_D1,0,to_copy,dClose)<=0) return(RESET);
      if(CopyLow(Symbol(),  PERIOD_D1,0,to_copy,dLow)  <=0) return(RESET);
      if(CopyHigh(Symbol(), PERIOD_D1,0,to_copy,dHigh) <=0) return(RESET);

      //---- set indexing as time series
      ArraySetAsSeries(dOpen,true);
      ArraySetAsSeries(dClose,true);
      ArraySetAsSeries(dLow,true);
      ArraySetAsSeries(dHigh,true);

      X=dHigh[d]+dLow[d]+dClose[d];
      if(dClose[d]<dOpen[d]) X+=dLow[d];
      if(dClose[d]>dOpen[d]) X+=dHigh[d];
      if(dClose[d]==dOpen[d]) X+=dClose[d];
      X/=2;
      res=X-dLow[d];
      sup=X-dHigh[d];
     }

   SetHline(0,"DSup line",0,sup,Color_Sup,Style_Sup,Width_Sup,"DSup line"+DoubleToString(sup,_Digits));
   SetHline(0,"DRes line",0,res,Color_Res,Style_Res,Width_Res,"DRes line"+DoubleToString(res,_Digits));
//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
