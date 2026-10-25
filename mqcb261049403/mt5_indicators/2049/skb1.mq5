//+------------------------------------------------------------------+ 
//|                                                        SKB-1.mq5 | 
//|                            Copyright © 2005, Kara Software Corp. | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Kara Software Corp."
#property link      ""
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//--- the following colors are used as the indicator colors
#property indicator_color1  clrLightSkyBlue
//--- displaying the indicator label
#property indicator_label1  "SKB-1"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // a constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
//--- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//--- declaration of dynamic arrays that will be used as indicator buffers
double ExtABuffer[];
double ExtBBuffer[];

int FRA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=7;
//--- getting the handle of the iFractals indicator
   FRA_Handle=iFractals(Symbol(),PERIOD_CURRENT);
   if(FRA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iFractals indicator");
      return(INIT_FAILED);
     }
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtABuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtBBuffer,INDICATOR_DATA);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtBBuffer,true);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"SKB-1");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(FRA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int limit;
   int CCU1,CCU2,CCL1,CCL2,i,j;
   double UpFractal[1],DnFractal[1];
   double FU,FL;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated;   // starting index for calculation of new bars
     }
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(CopyBuffer(FRA_Handle,0,bar+3,1,UpFractal)<=0) return(RESET);
      if(CopyBuffer(FRA_Handle,1,bar+3,1,DnFractal)<=0) return(RESET);

      FU=UpFractal[0];
      FL=DnFractal[0];

      if(FU && FU!=EMPTY_VALUE)
        {
         i=bar+3+1;
         if(CopyBuffer(FRA_Handle,0,i,1,UpFractal)<=0) return(RESET);
         while(!UpFractal[0] || UpFractal[0]==EMPTY_VALUE)
           {
            i++;
            if(i==rates_total-1) break;
            if(CopyBuffer(FRA_Handle,0,i,1,UpFractal)<=0) return(RESET);
           }
         for(j=bar+3; j<=i; j++)
           {
            if(CopyBuffer(FRA_Handle,1,j,1,DnFractal)<=0) return(RESET);
            if(DnFractal[0] && DnFractal[0]!=EMPTY_VALUE)
              {
               CCU1=bar+3;
               CCU2=i;
               if(!CCL1) CCL1=j;
               else if(Low[j]<Low[CCL1]) CCL1=j;
               CCL2=0;
              }
           }
         if(j==i && High[i]>High[bar+3]) FU=0;
        }

      if(FL && FL!=EMPTY_VALUE)
        {
         i=bar+3+1;
         if(CopyBuffer(FRA_Handle,1,i,1,DnFractal)<=0) return(RESET);
         while(!DnFractal[0] || DnFractal[0]==EMPTY_VALUE)
           {
            i++;
            if(i==rates_total-1) break;
            if(CopyBuffer(FRA_Handle,1,i,1,DnFractal)<=0) return(RESET);
           }
         for(j=bar+3; j<=i; j++)
           {
            if(CopyBuffer(FRA_Handle,0,j,1,UpFractal)<=0) return(RESET);
            if(UpFractal[0] && UpFractal[0]!=EMPTY_VALUE)
              {
               if(!CCU1) CCU1=j;
               else if(High[j]>High[CCU1]) CCU1=j;
               CCU2=0;
               CCL1=bar+3;
               CCL2=i;
              }
           }
        }
      CCU1=MathMin(CCU1,rates_total-1);
      CCU2=MathMin(CCU2,rates_total-1);
      CCL1=MathMin(CCL1,rates_total-1);
      CCL2=MathMin(CCL2,rates_total-1);
      if(CCU1>0 && CCU2>0)
        {
         if(High[CCU1]>High[CCU2])
           {
            ExtABuffer[bar]=High[CCU1]+(High[CCU1]-High[CCU2])/(CCU2-CCU1)*(CCU1-bar);
            ExtBBuffer[bar]=Low[CCL1]+(High[CCU1]-High[CCU2])/(CCU2-CCU1)*(CCL1-bar);
           }
         if(High[CCU1]<High[CCU2])
           {
            ExtABuffer[bar]=High[CCU1]-(High[CCU2]-High[CCU1])/(CCU2-CCU1)*(CCU1-bar);
            ExtBBuffer[bar]=Low[CCL1]-(High[CCU2]-High[CCU1])/(CCU2-CCU1)*(CCL1-bar);
           }
        }
      if(CCL1>0 && CCL2>0)
        {
         if(Low[CCL1]<Low[CCL2])
           {
            ExtABuffer[bar]=High[CCU1]-(Low[CCL2]-Low[CCL1])/(CCL2-CCL1)*(CCU1-bar);
            ExtBBuffer[bar]=Low[CCL1]-(Low[CCL2]-Low[CCL1])/(CCL2-CCL1)*(CCL1-bar);
           }
         if(Low[CCL1]>Low[CCL2])
           {
            ExtABuffer[bar]=High[CCU1]+(Low[CCL1]-Low[CCL2])/(CCL2-CCL1)*(CCU1-bar);
            ExtBBuffer[bar]=Low[CCL1]+(Low[CCL1]-Low[CCL2])/(CCL2-CCL1)*(CCL1-bar);
           }
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
