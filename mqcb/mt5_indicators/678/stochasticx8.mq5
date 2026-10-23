//+------------------------------------------------------------------+
//|                                                Stochastic-X8.mq5 | 
//|                                       Copyright © 2010,   lukas1 | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, lukas1"
#property link ""
#property description "Stochastic-X8"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define LINES_TOTAL  8  // The constant for the number of the indicator lines
#define RESET        0  // The constant for getting the command for the indicator recalculation back to the terminal
//---- number of indicator buffers
#property indicator_buffers LINES_TOTAL 
//---- number of graphical plots
#property indicator_plots   LINES_TOTAL
//+-----------------------------------+
//|  Indicators drawing parameters    |
//+-----------------------------------+
//---- drawing the oscillators as lines
#property indicator_type1   DRAW_LINE
//---- selection of the lines colors
#property indicator_color1  BlueViolet
//---- lines are dott-dash curves
#property indicator_style1 STYLE_SOLID
//---- lines 1 width
#property indicator_width1  1
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
//---- indicator parameters
input int Stoch_K=12;                              // the K period (the number of bars) for %K line calculation
input int Stoch_D=8;                               // smoothing period for %D line calculation
input int Stoch_S=5;                               // Deceleration value
input double Koef=1.2;                             // Periods additional multiplying ratio
input ENUM_MA_METHOD   ma_method=MODE_LWMA;        // Smoothing type
input ENUM_STO_PRICE   price_field=STO_CLOSECLOSE; // Stochastic calculation method
//+-----------------------------------+
//---- declaration of integer variables for the indicators handles
int Stoch_Handle[LINES_TOTAL];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//|  Variables arrays for the indicator buffers creation             |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
  };
//+------------------------------------------------------------------+
//| Indicator buffers creation                                       |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[LINES_TOTAL];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int((Stoch_K+Stoch_D+Stoch_S)*MathPow(Koef,LINES_TOTAL-1));

//----
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      double K=MathPow(Koef,numb);
      int period=int(Stoch_K*K);
      int Kperiod=int(Stoch_D*K);
      int Dperiod=int(Stoch_S*K);

      //---- getting handle of the iStochastic indicator
      Stoch_Handle[numb]=iStochastic(NULL,0,period,Kperiod,Dperiod,ma_method,price_field);
      if(Stoch_Handle[numb]==INVALID_HANDLE)Print(" Failed to get handle of the iStochastic indicator ",numb);

      string shortname="";
      StringConcatenate(shortname,"Stochastic X",LINES_TOTAL,"*",DoubleToString(Koef,1),"(",period,Kperiod,Dperiod,")");
      //--- creation of the name to be displayed in a separate sub-window and in a tooltip
      PlotIndexSetString(numb,PLOT_LABEL,shortname);
      //---- setting the indicator values that won't be visible on a chart
      PlotIndexSetDouble(numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- performing the shift of the beginning of the indicator drawing
      PlotIndexSetInteger(numb,PLOT_DRAW_BEGIN,min_rates_total);
      //---- set dynamic arrays as indicator buffers
      SetIndexBuffer(numb,Ind[numb].IndBuffer,INDICATOR_DATA);
      //---- indexing the elements in buffers as timeseries   
      ArraySetAsSeries(Ind[numb].IndBuffer,true);
      //---- copying the indicator first line parameters for all the rest ones
      PlotIndexSetInteger(numb,PLOT_DRAW_TYPE,PlotIndexGetInteger(0,PLOT_DRAW_TYPE));
      PlotIndexSetInteger(numb,PLOT_LINE_STYLE,PlotIndexGetInteger(0,PLOT_LINE_STYLE));
      PlotIndexSetInteger(numb,PLOT_LINE_WIDTH,PlotIndexGetInteger(0,PLOT_LINE_WIDTH));
      PlotIndexSetInteger(numb,PLOT_LINE_COLOR,PlotIndexGetInteger(0,PLOT_LINE_COLOR));
     }
//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Stochastic X",LINES_TOTAL,"*",
                     DoubleToString(Koef,1),"(",EnumToString(ma_method),", ",EnumToString(price_field),")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);
   for(int numb=0; numb<LINES_TOTAL; numb++) if(BarsCalculated(Stoch_Handle[numb])<min_rates_total) return(0);

//---- declarations of local variables 
   int to_copy;

//---- calculation of the necessary amount of data to be copied
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      to_copy=rates_total-1;
   else to_copy=rates_total-prev_calculated+1;

//---- copy newly appeared data in the indicator buffers
   for(int numb=0; numb<LINES_TOTAL; numb++) if(CopyBuffer(Stoch_Handle[numb],0,0,to_copy,Ind[numb].IndBuffer)<=0) return(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
