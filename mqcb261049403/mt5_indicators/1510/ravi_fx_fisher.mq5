//+------------------------------------------------------------------+ 
//|                                               RAVI_FX_Fisher.mq5 | 
//|                         Copyright © 2005, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"
//---- indicator version number
#property version   "1.01"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrMagenta,clrDeepPink,clrGray,clrBlue,clrLime
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "RAVI FX Fisher"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int MAfast=4;  //fast moving average period 
input int MAslow=49; //slow moving average period
input  ENUM_MA_METHOD   MAType=MODE_EMA; //smoothing method
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE; //price
input double UpTrigger=+0.07; //breakthrough levelь
input double DnTrigger=-0.07; //breakthrough level
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//----Declaration of variables for storing the indicators handles 
int FsATR_Handle,SlATR_Handle,FsMA_Handle,SlMA_Handle;
//+------------------------------------------------------------------+    
//| RAVI FX Fisher indicator initialization function                 | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=MathMax(MAfast,MAslow);

//---- getting the ATR indicator handle
   FsATR_Handle=iATR(NULL,PERIOD_CURRENT,MAslow);
   if(FsATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");
   
//---- getting the ATR indicator handle
   SlATR_Handle=iATR(NULL,PERIOD_CURRENT,MAslow);
   if(SlATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");

//---- getting the iMA indicator handle
   FsMA_Handle=iMA(NULL,0,MAfast,0,MAType,MAPrice);
   if(FsMA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- getting the iMA indicator handle
   SlMA_Handle=iMA(NULL,0,MAslow,0,MAType,MAPrice);
   if(SlMA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(IndBuffer,true);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(ColorIndBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"RAVI FX Fisher");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);

//---- the number of the indicator 3 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,UpTrigger);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,DnTrigger);
//---- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrMagenta);
//---- short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| RAVI FX Fisher iteration function                                | 
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
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(FsMA_Handle)<rates_total
      || BarsCalculated(SlMA_Handle)<rates_total
      || BarsCalculated(FsATR_Handle)<rates_total
      || BarsCalculated(SlATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,clr;
   double MAValue,IFish0,IFish1,FsMA[],SlMA[],FsATR[],SlATR[];
   
//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(FsMA_Handle,0,0,to_copy,FsMA)<=0) return(RESET);
   if(CopyBuffer(SlMA_Handle,0,0,to_copy,SlMA)<=0) return(RESET);
   if(CopyBuffer(FsATR_Handle,0,0,to_copy,FsATR)<=0) return(RESET);
   if(CopyBuffer(SlATR_Handle,0,0,to_copy,SlATR)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(FsMA,true);
   ArraySetAsSeries(SlMA,true);
   ArraySetAsSeries(SlATR,true);
   ArraySetAsSeries(FsATR,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      MAValue=100*(FsMA[bar]-SlMA[bar])*FsATR[bar]/SlMA[bar]/SlATR[bar];
      IFish0=(MathExp(2*MAValue)-1.0)/(MathExp(2*MAValue)+1.0);    
      IndBuffer[bar]=IFish0;
     }

   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//---- main loop of the Ind indicator coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      clr=2;
      IFish0=IndBuffer[bar];
      IFish1=IndBuffer[bar+1];

      if(IFish0>UpTrigger)
        {
         if(IFish0>IFish1) clr=4;
         if(IFish0<IFish1) clr=3;
        }

      if(IFish0<DnTrigger)
        {
         if(IFish0<IFish1) clr=0;
         if(IFish0>IFish1) clr=1;
        }
        
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
