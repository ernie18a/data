//+------------------------------------------------------------------+ 
//|                                                        NH_NL.mq5 | 
//|                                      Copyright © 2011, LenIFCHIK | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, LenIFCHIK"
#property link "" 
#property description "Calculates the difference between the number of pairs that have reached new"
#property description "highs or lows over a given period (USD currency rate is dealt with)."
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the four color histogram
#property indicator_color1 Gray,Teal,BlueViolet,IndianRed,Magenta
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 5
#property indicator_width1 5
//---- displaying the indicator label
#property indicator_label1 "NH-NL"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
#define SYMBOLSTOTAL 7
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input int Depth=30;
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of dynamic arrays that will further 
//---- be used as indicator buffers
double NhNlBuffer[],ColorNhNlBuffer[];
//----
double Array[];
string Symbols[SYMBOLSTOTAL]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCHF","USDJPY","USDCAD"};
//+------------------------------------------------------------------+    
//| NhNl indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=Depth;
   ArrayResize(Array,Depth);
   ArraySetAsSeries(Array,true);

//---- transformation of the dynamic array NhNlBuffer into an indicator buffer
   SetIndexBuffer(0,NhNlBuffer,INDICATOR_DATA);
//---- shifting the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(NhNlBuffer,true);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorNhNlBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(ColorNhNlBuffer,true);

//---- initializations of a variable for a short name of the indicator
   string shortname;
   StringConcatenate(shortname,"NhNl( ",Depth," )");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| Getting the minimum number of bars for all time series           |
//+------------------------------------------------------------------+
int Rates_Total()
  {
//----
   int Bars_[SYMBOLSTOTAL];
   for(int count=0; count<SYMBOLSTOTAL; count++)
     {
      Bars_[count]=Bars(Symbols[count],PERIOD_CURRENT);
     }
//----
   int error=GetLastError();
   ResetLastError();
   if(error==4401) return(-1);
//----
   return(Bars_[ArrayMinimum(Bars_,0,WHOLE_ARRAY)]);
  }
//+------------------------------------------------------------------+
//|  Check timeseries synchronization                                |
//+------------------------------------------------------------------+
bool SynchroCheck()
  {
//----
   datetime Time0[1],TimeN[1];
//----
   Time0[0]=0;

   for(int count=0; count<SYMBOLSTOTAL; count++)
      if(CopyTime(Symbols[count],0,0,1,Time0)>0) break;

   if(Time0[0]==0) return(false);

   for(int count=0; count<SYMBOLSTOTAL; count++)
     {
      if(CopyTime(Symbols[count],0,0,1,TimeN)<=0) return(false);
      else if(TimeN[0]!=Time0[0]) return(false);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+    
//| Function for checking the closing price on the USD maximum      | 
//+------------------------------------------------------------------+  
int newh(string symbol,int index)
  {
//--- copy new data in the array
   if(CopyClose(symbol,Period(),index,Depth,Array)<=0) return(-1);
   double HC=Array[ArrayMaximum(Array,0,Depth)];
   double LC=Array[ArrayMinimum(Array,0,Depth)];
   int nh;

   if(symbol=="EURUSD" || symbol=="GBPUSD" || symbol=="AUDUSD" || symbol=="NZDUSD")
     {
      if(Array[0]==LC) nh=1;
      else nh=0;
     }
   else if(symbol=="USDCHF" || symbol=="USDJPY" || symbol=="USDCAD")
     {
      if(Array[0]==HC) nh=1;
      else nh=0;
     }
   else
     {
      Print(__FUNCTION__,"(",symbol,") There is no such symbol! ");
      return(-1);
     }
//---- checking complete
   return(nh);
  }
//+------------------------------------------------------------------+    
//| Function for checking the closing price on USD minimum      | 
//+------------------------------------------------------------------+  
int newl(string symbol,int index)
  {
//--- copy new data in the array
   if(CopyClose(symbol,Period(),index,Depth,Array)<=0) return(-1);
   double HC=Array[ArrayMaximum(Array,0,Depth)];
   double LC=Array[ArrayMinimum(Array,0,Depth)];
   int nl;

   if(symbol=="EURUSD" || symbol=="GBPUSD" || symbol=="AUDUSD" || symbol=="NZDUSD")
     {
      if(Array[0]==HC) nl=1;
      else nl=0;
     }
   else if(symbol=="USDCHF" || symbol=="USDJPY" || symbol=="USDCAD")
     {
      if(Array[0]==LC) nl=1;
      else nl=0;
     }
   else
     {
      Print(__FUNCTION__,"(",symbol,") There is no such symbol! ");
      return(-1);
     }
//---- checking complete
   return(nl);
  }
//+------------------------------------------------------------------+  
//| NhNl iteration function                                          | 
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
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);
   
//---- Checking for the sufficiency of the number of bars for the calculation and the presence of the chart symbol in the array (Symbol_[]
   int Bars_=Rates_Total();
   if(Bars_<min_rates_total) return(RESET);

//---- Check timeseries synchronization
   if(!SynchroCheck()) return(prev_calculated);

//---- Declaration of variables
   int limit,bar,NH,NL,res;

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=Bars_-min_rates_total-1; // starting index for calculation of all bars
     }
   else limit=MathMin(Bars_,rates_total-prev_calculated); // starting index for calculation of new bars 

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {

      NH=0;
      NL=0;
      for(int count=0; count<SYMBOLSTOTAL; count++)
        {
         res=newh(Symbols[count],bar);
         if(res<0) return(RESET);
         NH+=res;

         res=newl(Symbols[count],bar);
         if(res<0) return(RESET);
         NL+=res;
        }
 
      if(Symbol()=="EURUSD" || Symbol()=="GBPUSD" || Symbol()=="AUDUSD" || Symbol()=="NZDUSD")
        {
         NhNlBuffer[bar]=NL-NH;
        }
      else if(Symbol()=="USDCHF" || Symbol()=="USDJPY" || Symbol()=="USDCAD")
        {
         NhNlBuffer[bar]=NH-NL;
        }
     } 
     
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//---- Main indicator coloring loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorNhNlBuffer[bar]=0;

      if(NhNlBuffer[bar]>0)
        {
         if(NhNlBuffer[bar]>NhNlBuffer[bar+1]) ColorNhNlBuffer[bar]=1;
         if(NhNlBuffer[bar]<NhNlBuffer[bar+1]) ColorNhNlBuffer[bar]=2;
        }

      if(NhNlBuffer[bar]<0)
        {
         if(NhNlBuffer[bar]<NhNlBuffer[bar+1]) ColorNhNlBuffer[bar]=3;
         if(NhNlBuffer[bar]>NhNlBuffer[bar+1]) ColorNhNlBuffer[bar]=4;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
