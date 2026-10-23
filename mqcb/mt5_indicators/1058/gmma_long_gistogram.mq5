//+------------------------------------------------------------------+
//|                                          GMMA_Long_Gistogram.mq5 | 
//|                                       Copyright © 2010, dmmikl86 |
//|                                                   mhs_86@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, dmmikl86"
#property link      "mhs_86@mail.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  declaration of constants              |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a three-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the three-color line are
#property indicator_color1 Red,Magenta,Gray,Teal,Lime
//---- the indicator line is a continuous curve
#property indicator_style1 STYLE_SOLID
//---- the indicator line width is 4
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "GMMA_Long_Gistogram"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Blue
#property indicator_levelstyle STYLE_SOLID
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS     |
//+-----------------------------------+       
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- indicator buffer
double ExtBuffer[],ColorExtBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- Declaration of integer variables for the indicator handles
int InpInd_Handle[6];
//+------------------------------------------------------------------+   
//| GMMA_Long_Gistogram indicator initialization function            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of data starting point
   min_rates_total=61;

//---- getting the iMA indicator handle
   InpInd_Handle[0]=iMA(Symbol(),PERIOD_CURRENT,30,0,MODE_EMA,PRICE_CLOSE);
   if(InpInd_Handle[0]==INVALID_HANDLE) Print(" Failed to get the iMA indicator handle");

//---- getting the iMA indicator handle
   InpInd_Handle[1]=iMA(Symbol(),PERIOD_CURRENT,35,0,MODE_EMA,PRICE_CLOSE);
   if(InpInd_Handle[1]==INVALID_HANDLE) Print(" Failed to get the iMA indicator handle");

//---- getting the iMA indicator handle
   InpInd_Handle[2]=iMA(Symbol(),PERIOD_CURRENT,40,0,MODE_EMA,PRICE_CLOSE);
   if(InpInd_Handle[2]==INVALID_HANDLE) Print(" Failed to get the iMA indicator handle");

//---- getting the iMA indicator handle
   InpInd_Handle[3]=iMA(Symbol(),PERIOD_CURRENT,45,0,MODE_EMA,PRICE_CLOSE);
   if(InpInd_Handle[3]==INVALID_HANDLE) Print(" Failed to get the iMA indicator handle");

//---- getting the iMA indicator handle
   InpInd_Handle[4]=iMA(Symbol(),PERIOD_CURRENT,50,0,MODE_EMA,PRICE_CLOSE);
   if(InpInd_Handle[4]==INVALID_HANDLE) Print(" Failed to get the iMA indicator handle");

//---- getting the iMA indicator handle
   InpInd_Handle[5]=iMA(Symbol(),PERIOD_CURRENT,60,0,MODE_EMA,PRICE_CLOSE);
   if(InpInd_Handle[5]==INVALID_HANDLE) Print(" Failed to get the iMA indicator handle");

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(ExtBuffer,true);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorExtBuffer,INDICATOR_COLOR_INDEX);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(ColorExtBuffer,true);

//---- initialization of a variable for a short name of the indicator
   string shortname="GMMA_Long_Gistogram";
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| GMMA_Long_Gistogram iteration function                           | 
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
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);
   for(int numb=0; numb<6; numb++) if(BarsCalculated(InpInd_Handle[numb])<min_rates_total) return(RESET);

//---- declaring local variables 
   int limit,bar,to_copy;
   double EMA0[],EMA1[],EMA2[],EMA3[],EMA4[],EMA5[];

//---- indexing array elements as time series  
   ArraySetAsSeries(EMA0,true);
   ArraySetAsSeries(EMA1,true);
   ArraySetAsSeries(EMA2,true);
   ArraySetAsSeries(EMA3,true);
   ArraySetAsSeries(EMA4,true);
   ArraySetAsSeries(EMA5,true);

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+2;
//---- copy the new data into the array
   if(CopyBuffer(InpInd_Handle[0],0,0,to_copy,EMA0)<=0) return(RESET);
   if(CopyBuffer(InpInd_Handle[1],0,0,to_copy,EMA1)<=0) return(RESET);
   if(CopyBuffer(InpInd_Handle[2],0,0,to_copy,EMA2)<=0) return(RESET);
   if(CopyBuffer(InpInd_Handle[3],0,0,to_copy,EMA3)<=0) return(RESET);
   if(CopyBuffer(InpInd_Handle[4],0,0,to_copy,EMA4)<=0) return(RESET);
   if(CopyBuffer(InpInd_Handle[5],0,0,to_copy,EMA5)<=0) return(RESET);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtBuffer[bar]=(EMA0[bar]-EMA0[bar+1])+(EMA1[bar]-EMA1[bar+1])*1.2+(EMA2[bar]-EMA2[bar+1])*1.4+
                     (EMA3[bar]-EMA3[bar+1])*1.6+(EMA4[bar]-EMA4[bar+1])*1.8+(EMA5[bar]-EMA5[bar+1])*2;
     }

   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//---- Main indicator line coloring loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorExtBuffer[bar]=2;

      if(ExtBuffer[bar]>0)
        {
         if(ExtBuffer[bar]>ExtBuffer[bar+1]) ColorExtBuffer[bar]=4;
         if(ExtBuffer[bar]<ExtBuffer[bar+1]) ColorExtBuffer[bar]=3;
        }
        
      if(ExtBuffer[bar]<0)
        {
         if(ExtBuffer[bar]>ExtBuffer[bar+1]) ColorExtBuffer[bar]=1;
         if(ExtBuffer[bar]<ExtBuffer[bar+1]) ColorExtBuffer[bar]=0;
        }

     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
