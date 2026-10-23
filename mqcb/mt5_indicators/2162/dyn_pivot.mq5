//+------------------------------------------------------------------+
//|                                                    Dyn_Pivot.mq5 | 
//|                                         Copyright © 2006, Modest |
//|                           http://forexsystems.ru/phpBB/index.php |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Modest"
#property link      "http://forexsystems.ru/phpBB/index.php"
#property description "An indicator of pivot points"
//--- indicator version number
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers is 1
#property indicator_buffers 1 
//--- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET  0 // a constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Dyn_Pivot indictaor drawing parameters       |
//+----------------------------------------------+
//--- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_SECTION
//--- the following colors are used as the indicator colors
#property indicator_color1  clrDarkOrange
//--- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "Dyn_Pivot"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input bool Formula=false;    // Calculation algorithm
input int   Shift=0;         // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double LineBuffer[];
double FP,FH,FL;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total,ret;
//+------------------------------------------------------------------+
//| Checking a new day                                              |
//+------------------------------------------------------------------+
bool isNewDay(const datetime &Time[],int shift)
  {
//--- 
   MqlDateTime tm;
   TimeToStruct(Time[shift],tm);
   if(!tm.hour && !tm.min) return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Get the FP level of the previous day                             |
//+------------------------------------------------------------------+
double GetFPofDay(int Rates_Total,const datetime &Time[],const double &High[],const double &Low[],const double &Close[],int shift)
  {
//---
   MqlDateTime tm;
   TimeToStruct(Time[shift+1],tm);
   int prevDay=tm.day;
//--- 
   int iii=1;
   while(tm.day==prevDay)
     {
      iii++;
      if(shift+iii==Rates_Total) break;
      TimeToStruct(Time[shift+iii],tm);
     }
   iii--;

   FH=High[ArrayMaximum(High,shift+1,iii)];
   FL=Low[ArrayMinimum(Low,shift+1,iii)];
   if(!Formula) FP=NormalizeDouble((FH+FL+Close[shift+1])/3.0,_Digits);
   else FP=NormalizeDouble((FH+FL+2*Close[shift+1])/4.0,_Digits);
//---
   return(FP);
  }
//+------------------------------------------------------------------+
//| Operate on a zero bar                                            |
//+------------------------------------------------------------------+
void SetNullBarValue(int Rates_Total,const datetime &Time[],const double &High[],const double &Low[],const double &Close[],int shift)
  {
//---
   MqlDateTime tm;
   TimeToStruct(Time[shift],tm);
   int currDay=tm.day;
//--- 
   int iii=1;
   TimeToStruct(Time[shift+1],tm);
   while(tm.day==currDay)
     {
      iii++;
      if(shift+iii==Rates_Total) break;
      TimeToStruct(Time[shift+iii],tm);
     }
   if(iii>=2)
     {
      iii-=2;
      for(int cnt=iii; cnt>0; cnt--) LineBuffer[shift+cnt]=0.0;
      FH=High[ArrayMaximum(High,shift,iii+1)];
      FL=Low[ArrayMinimum(Low,shift,iii+1)];
      if(!Formula) FP=NormalizeDouble((FH+FL+Close[shift+1])/3.0,_Digits);
      else FP=NormalizeDouble((FH+FL+2*Close[shift+1])/4.0,_Digits);
      LineBuffer[shift]=FP;
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- checking the timeframe
   if(Period()>PERIOD_H6)
     {
      Print("Indicator period cannot be greater than H6");
      return(INIT_FAILED);
     }
//--- Initialization of variables of the start of data calculation
   ret=int(PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT));
   min_rates_total=ret+1;
   FP=0.0;
   FH=0.0;
   FL=0.0;
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- Indexing buffer elements as timeseries   
   ArraySetAsSeries(LineBuffer,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Dyn_Pivot");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
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
//--- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
//--- declaration of local variables 
   int limit,bar;
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      limit=rates_total-2-min_rates_total; // starting index for the calculation of all bars

      limit=rates_total-1;
      int iii=1;
      MqlDateTime tm;
      TimeToStruct(time[limit],tm);
      int firstDay=tm.day;
      TimeToStruct(time[limit-iii],tm);
      while(tm.day==firstDay)
        {
         iii++;
         if(limit-iii==0) break;
         TimeToStruct(time[limit-iii],tm);
        }
      limit-=iii+ret;
     }
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars
//--- The main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(isNewDay(time,bar)) LineBuffer[bar]=GetFPofDay(rates_total,time,high,low,close,bar);
      else LineBuffer[bar]=0.0;
      if(!bar) SetNullBarValue(rates_total,time,high,low,close,bar);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
