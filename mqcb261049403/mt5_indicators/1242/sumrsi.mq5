//+------------------------------------------------------------------+
//|                                                       SumRSI.mq5 |
//|                                        Copyright © 2008, jax1000 |
//|                                                  jax1000@list.ru |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2008, jax1000"
//---- author of the indicator
#property link      "jax1000@list.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//---- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  SumRSI indicator drawing parameters         |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- DarkOrange color is used as the color of the bullish line of the indicator
#property indicator_color1  clrDarkOrange
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 3
#property indicator_width1  3
//---- displaying of the bullish label of the indicator
#property indicator_label1  "SumRSI"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 70.0
#property indicator_level2 50.0
#property indicator_level3 30.0
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Window borders fixing parameters             |
//+----------------------------------------------+
#property indicator_minimum   0
#property indicator_maximum 100
//+----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                  |
//+----------------------------------------------+
input uint StartLength=3; // initial smoothing period
input uint EndLength=25; // final smoothing period                  
input ENUM_APPLIED_PRICE Applied_Price=PRICE_CLOSE; // type of price
input int Shift=0; // horizontal shift of the indicator in bars
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SumRSIBuffer[];
//---- 
bool Init;
//---- declaration of integer variables for the indicators handles
int RSI_Handle[];
//---- Declaration of integer variables of data starting point
int min_rates_total,xSize;
//+------------------------------------------------------------------+
//|  Arrays of variables                                             |
//+------------------------------------------------------------------+  
class CRSI
  {
public: double    m_RSI[];
  };
//+------------------------------------------------------------------+
//| Create arrays with two dimensions                                |
//+------------------------------------------------------------------+
CRSI RSI[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- setting alerts for invalid values of external parameters
   if(StartLength>EndLength)
     {
      Init=false;
      Print("The initial period of the indicator can not be greater than the final period!");
      return;
     }

//---- memory allocation for arrays of variables
   xSize=int(EndLength-StartLength+1);

   if(ArrayResize(RSI_Handle,xSize)<xSize)
     {
      Init=false;
      Print("Failed to distribute the memory for RSI_Handle[] array!");
      return;
     }

   if(ArrayResize(RSI,xSize)<xSize)
     {
      Init=false;
      Print("Failed to distribute the memory for RSI[] object array!");
      return;
     }
   else Init=true;

//---- indexing elements in arrays as timeseries  
   for(int count=0; count<xSize; count++) ArraySetAsSeries(RSI[count].m_RSI,true);

//---- getting handle of the iRSI indicator
   for(int count=0; count<xSize; count++)
     {
      RSI_Handle[count]=iRSI(NULL,PERIOD_CURRENT,StartLength+count,Applied_Price);
      if(RSI_Handle[count]==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the iRSI indicator");
         Init=false;
         return;
        }
     }

//---- Initialization of variables of the start of data calculation
   min_rates_total=int(EndLength);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SumRSIBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SumRSIBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"SumRSI(",StartLength,", ",EndLength,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//----
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
//---- checking the number of bars to be enough for calculation
   if(!Init || rates_total<min_rates_total) return(RESET);
   for(int count=0; count<xSize; count++) if(BarsCalculated(RSI_Handle[count])<rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,to_copy;
   double Sum;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

   to_copy=limit+1;
//---- copy the newly appeared data into the RSI[count].m_RSI[] arrays
   for(int count=0; count<xSize; count++) if(CopyBuffer(RSI_Handle[count],0,0,to_copy,RSI[count].m_RSI)<=0) return(RESET);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Sum=0.0;
      for(int count=0; count<xSize; count++) Sum+=RSI[count].m_RSI[bar];
      SumRSIBuffer[bar]=Sum/(EndLength-StartLength+1);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
