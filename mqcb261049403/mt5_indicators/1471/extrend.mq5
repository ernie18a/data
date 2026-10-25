//+------------------------------------------------------------------+
//|                                                      ExTrend.mq5 |
//|                           Copyright © 2006, Alex Sidd (Executer) | 
//|                                           mailto:work_st@mail.ru | 
//+------------------------------------------------------------------+ 
//---- author of the indicator
#property copyright "Copyright © 2006, Alex Sidd (Executer)k"
//---- author of the indicator
#property link      "mailto:work_st@mail.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- Lime color is used as the color of the indicator basic line
#property indicator_color1  clrLime
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "Up Line"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- Magenta color is used for the indicator signal line
#property indicator_color2  clrMagenta
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator line label
#property indicator_label2  "Down Line"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0       // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+ 
input color UpLineColor=clrTeal; //upper fractals trend color
input color DnLineColor=clrMagenta; //lower fractals trend color
input int Shift=0;        // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double UpBuffer[];
double DnBuffer[];
//---- declaration of integer variables for the indicators handles
int FRA_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//----
string Up_level_name,Dn_level_name;
double FractUp1,FractUp2,FractDn1,FractDn2;
datetime FTimeUp1,FTimeUp2,FTimeDn1,FTimeDn2,curTime;
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline(
                 long     chart_id,      // chart ID
                 string   name,          // object name
                 int      nwin,          // window index
                 datetime time1,         // price level time 1
                 double   price1,        // price level 1
                 datetime time2,         // price level time 2
                 double   price2,        // price level 2
                 color    Color,         // line color
                 int      style,         // line style
                 int      width,         // line width
                 string   text           // text
                 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline(
              long     chart_id,      // chart ID
              string   name,          // object name
              int      nwin,          // window index
              datetime time1,         // price level time 1
              double   price1,        // price level 1
              datetime time2,         // price level time 2
              double   price2,        // price level 2
              color    Color,         // line color
              int      style,         // line style
              int      width,         // line width
              string   text           // text
              )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=10;
   FractUp1=0.0;
   FractUp2=0.0;
   FractDn1=0.0;
   FractDn2=0.0;

//---- getting the ATR indicator handle
   FRA_Handle=iFractals(NULL,0);
   if(FRA_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора iFractals");

//---- set UpBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(UpBuffer,true);

//---- set DnBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 2 drawing by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(DnBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"ExTrend(",Shift,")");
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determine the accuracy of displaying indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//----  
   Up_level_name=shortname+" Up_level";
   Dn_level_name=shortname+" Dn_level";
   if(ObjectFind(0,Up_level_name)==-1) SetTline(0,Up_level_name,0,0,0,0,0,UpLineColor,0,1,Up_level_name);
   if(ObjectFind(0,Dn_level_name)==-1) SetTline(0,Dn_level_name,0,0,0,0,0,DnLineColor,0,1,Dn_level_name);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---- delete trend lines from the chart
   ObjectDelete(0,Up_level_name);
   ObjectDelete(0,Dn_level_name);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking for the sufficiency of bars for the calculation
   if(BarsCalculated(FRA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy,limit;
   double UpFr[],DnFr[];

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      to_copy=rates_total; // calculated number of all copied data
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else
     {
      to_copy=rates_total-prev_calculated+6; // calculated number of new copied data only
      limit=rates_total-prev_calculated+2; // starting index for the calculation of new bars
     }

//---- copy the newly appeared data into the UpFr[] and DnFr[] arrays
   if(CopyBuffer(FRA_Handle,0,0,to_copy,UpFr)<=0) return(RESET);
   if(CopyBuffer(FRA_Handle,1,0,to_copy,DnFr)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(UpFr,true);
   ArraySetAsSeries(DnFr,true);
   ArraySetAsSeries(time,true);

//---- Zeroizing unused cells of buffers
   for(int bar=2; bar>=0 && !IsStopped(); bar--)
     {
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
     }

//---- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double negative=0;
      double positive=0;
      double Fup=UpFr[bar+3];
      double Fdn=DnFr[bar+3];

      if(Fup && Fup!=EMPTY_VALUE)
        {
         if(!FractUp1 && !FractUp2)
           {
            FractUp1 = Fup;
            FTimeUp1 = time[bar+3];
           }

         if(FractUp1 && !FractUp2 && FTimeUp1!=time[bar+3])
           {
            FractUp2 = Fup;
            FTimeUp2 = time[bar+3];
           }

         if(FractUp1 && FractUp2 && FTimeUp2!=time[bar+3])
           {
            FractUp1 = FractUp2;
            FTimeUp1 = FTimeUp2;
            FractUp2 = Fup;
            FTimeUp2 = time[bar+3];
           }
        }

      if(Fdn && Fdn!=EMPTY_VALUE)
        {
         if(!FractDn1 && !FractDn2)
           {
            FractDn1 = Fdn;
            FTimeDn1 = time[bar+3];
           }

         if(FractDn1 && !FractDn2 && FTimeDn1!=time[bar+3])
           {
            FractDn2 = Fdn;
            FTimeDn2 = time[bar+3];
           }

         if(FractDn1 && FractDn2 && FTimeDn2!=time[bar+3])
           {
            FractDn1 = FractDn2;
            FTimeDn1 = FTimeDn2;
            FractDn2 = Fdn;
            FTimeDn2 = time[bar+3];
           }
        }

      if(FractUp1 && FractUp2)
        {
         SetTline(0,Up_level_name,0,FTimeUp1,FractUp1,FTimeUp2,FractUp2,UpLineColor,0,1,Up_level_name);
         double y = double((FTimeUp2 - FTimeUp1) / (240*60.0));
         double x = (FractUp2 - FractUp1)*(240.0);
         if(!y) y=double(1/(240*60.0));
         positive=MathArctan(x/y);
        }

      if(FractDn1 && FractDn2)
        {
         SetTline(0,Dn_level_name,0,FTimeDn1,FractDn1,FTimeDn2,FractDn2,DnLineColor,0,1,Dn_level_name);
         double a = double((FTimeDn2 - FTimeDn1) / (240*60.0));
         double b = (FractDn2 - FractDn1)*(240.0);
         if(!a) a=double(1/(240*60.0));
         negative=MathArctan(b/a);
        }
      UpBuffer[bar+3]=positive;
      DnBuffer[bar+3]=negative;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
