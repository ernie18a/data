//+------------------------------------------------------------------+
//|                                                    ExTrendV2.mq5 |
//|                           Copyright © 2006, Alex Sidd (Executer) | 
//|                                           mailto:work_st@mail.ru | 
//+------------------------------------------------------------------+ 
//--- Copyright
#property copyright "Copyright © 2006, Alex Sidd (Executer)k"
//--- Copyright
#property link      "mailto:work_st@mail.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//--- two buffers are used for calculating and drawing the indicator
#property indicator_buffers 2
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//| Indicator 1 drawing parameters               |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//--- the following colors are used as the indicator colors
#property indicator_color1  clrForestGreen,clrHotPink
//--- displaying of the the indicator label
#property indicator_label1  "Up Line"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET 0       // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+ 
input color UpLineColor=clrTeal;     // Trend color of the upper fractals
input color DnLineColor=clrMagenta;  // Trend color of the lower fractals
input int Shift=0;                   // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double UpBuffer[];
double DnBuffer[];
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//---
string Up_level_name,Dn_level_name;
double FractUp1,FractUp2,FractDn1,FractDn2,Res1,Res2;
datetime FTimeUp1,FTimeUp2,FTimeDn1,FTimeDn2,curTime;
//+------------------------------------------------------------------+
//| Creating a trend line                                            |
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
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
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
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//---
  }
//+------------------------------------------------------------------+
//| Level Calculate Function                                         |
//| a function from the FractalLines Indicator                       |
//+------------------------------------------------------------------+
double LevelCalculate(double Price1,double Time1,double Price2,double Time2,double NewTime)
  {
//---
   if(Time2!=Time1) return((NewTime-Time1)*(Price2-Price1)/(Time2-Time1)+Price1);
//---
   return(Price2);
  }
//+------------------------------------------------------------------+
//| isUpFract                                                        |
//+------------------------------------------------------------------+  
double isUpFract(const double &High[],int index)
  {
//---
   if(High[index+3]>High[index+2] && High[index+3]>High[index+4]
      && High[index+4]>High[index+5] && High[index+2]>High[index+1])
      return(High[index+3]);
//--- 
   return(0);
  }
//+------------------------------------------------------------------+
//| isDnFract                                                        |
//+------------------------------------------------------------------+
double isDnFract(const double &Low[],int index)
  {
//---
   if(Low[index+3]<Low[index+2] && Low[index+3]<Low[index+4]
      && Low[index+4]<Low[index+5] && Low[index+2]<Low[index+1])
      return(Low[index+3]);
//--- 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of data calculation start
   min_rates_total=10;
   FractUp1=0.0;
   FractUp2=0.0;
   FractDn1=0.0;
   FractDn2=0.0;
   Res1=240*60.0;
   Res2=double(1.0/Res1);
//--- set the UpBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);
//--- set DnBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);
//--- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"ExTrend(",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---  
   Up_level_name=shortname+" Up_level";
   Dn_level_name=shortname+" Dn_level";
   if(ObjectFind(0,Up_level_name)==-1) SetTline(0,Up_level_name,0,0,0,0,0,UpLineColor,0,1,Up_level_name);
   if(ObjectFind(0,Dn_level_name)==-1) SetTline(0,Dn_level_name,0,0,0,0,0,DnLineColor,0,1,Dn_level_name);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//--- deleting trend lines from the chart
   ObjectDelete(0,Up_level_name);
   ObjectDelete(0,Dn_level_name);
//---
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
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int limit;
   double Fup,Fdn,positive,negative;
   static double positive_,negative_;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      UpBuffer[limit+1]=0.000000001;
      DnBuffer[limit+1]=0.000000001;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---   
   positive=positive_;
   negative=negative_;
//--- main calculation loop of the indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      negative=0.0;
      positive=0.0;
      Fup=isUpFract(high,bar);
      Fdn=isDnFract(low,bar);
      //---
      if(Fup)
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
      //---
      if(Fdn)
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
      //---
      if(FractUp1 && FractUp2)
        {
         SetTline(0,Up_level_name,0,FTimeUp1,FractUp1,FTimeUp2,FractUp2,UpLineColor,0,1,Up_level_name);
         double y = double((FTimeUp2 - FTimeUp1)/Res1);
         double x = (FractUp2 - FractUp1)*240.0;
         if(!y) y=Res2;
         positive=MathArctan(x/y);
        }
      //---
      if(FractDn1 && FractDn2)
        {
         SetTline(0,Dn_level_name,0,FTimeDn1,FractDn1,FTimeDn2,FractDn2,DnLineColor,0,1,Dn_level_name);
         double y = double((FTimeDn2 - FTimeDn1)/Res1);
         double x = (FractDn2 - FractDn1)*240.0;
         if(!y) y=Res2;
         negative=MathArctan(x/y);
        }
      //---
      UpBuffer[bar]=positive;
      DnBuffer[bar]=negative;
      //---
      if(bar==1)
        {
         positive_=positive;
         negative_=negative;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
