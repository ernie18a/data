/*
 * <<< DIGITAL FILTERS FOR METATRADER 5 >>>
 *
 * Place DF.dll file to "\MetaTrader5\MQL5\Libraries\"
 * Attention! Three additional dll files are required for DF.dll operation - 
 * bdsp.dll, lapack.dll and mkl_support.dll (mathematical treatment block).
 * The files must be placed in "C:\Windows\System32\" for 32-bit Windows OS
 * or "C:\Windows\SysWOW64\" for 64-bit Windows OS
 *
 * Check the following things before use:
 * 
 * 1. "Allow DLL imports" checkbox is marked in Tools->Options->Expert Advisors
 * 2. "C:\Windows\System32\" or "C:\Windows\SysWOW64\" folder contains 
 * bdsp.dll, lapack.dll and mkl_support.dll files (additional mathematical libraries)
 *
 * Input parameters description:
 * 
 * Ftype -  filter type: 0 - LPF (FATL/SATL/KGLP), 1 - HPF (KGHP), 
 *          2 - band-pass (RBCI/KGBP), 3 - rejection (KGBS)
 * P1 -     P1 cut-off period, bars
 * D1 -     D1 transient process cut-off period, bars
 * A1 -     A1 attenuation in a rejection band, dB
 * P2 -     P2 cut-off period, bars
 * D2 -     D2 transient process cut-off period, bars
 * A2 -     A2 attenuation in a rejection band, dB
 * Ripple - Pulsations in a pass band, dB
 * Delay -  Delay, bars
 *
 * P2, D2 and A2 parameters' values must not be considered for LPF and HPF
 * Working conditions:
 * LPF: P1>D1
 * HPF: P1<D1
 * Band-pass and rejection: D2>P2>P1>D1
 */
//+------------------------------------------------------------------+
//|         Digital Low Pass (FATL/SATL, KGLP) Filter    DFilter.mq5 | 
//|                    Digital Filter: Copyright (c) Sergey Ilyukhin |
//|                           Moscow, qpo@mail.ru  http://fx.qrz.ru/ |
//|                              MQL5 CODE: 2010,   Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "2005, Sergey Ilyukhin, Moscow"
//---- link to the website of the author
#property link      "http://fx.qrz.ru/"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//---- only one plot is used
#property indicator_plots   1
//---- drawing of the indicator as a line
#property indicator_type1   DRAW_LINE
//---- dark violet color is used as the color of the indicator line
#property indicator_color1  DarkViolet
//---- indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- display indicator label
#property indicator_label1  "DFilter"
//---- declaration and initialization of the enumeration of type of digital filters
enum FType_ //Filter type
  {
   LPF, //LPF (FATL/SATL/KGLP)
   HPE, //HPF (KGHP)
   BPF, //band-pass (RBCI/KGBP)
   SPF, //rejection (KGBS)
  };

//---- indicator input parameters
input FType_ FType=LPF; // Filter type
                        //0 - LPF (FATL/SATL/KGLP), 1 - HPF (KGHP), 2 - band-pass (RBCI/KGBP), 3 - rejection (KGBS)
input int    P1 = 28;       // Cut-off period 1, bars
input int    D1 = 19;       // Transient process cut-off period 1, bars
input int    A1 = 40;       // Attenuation in a rejection band 1, dB
input int    P2 = 0;        // Cut-off period 2, bars
input int    D2 = 0;        // Transient process cut-off period 2, bars
input int    A2 = 0;        // Attenuation in a rejection band 2, dB
input int    Delay=0;       // Delay, bars
input double Ripple=0.08;   // Pulsations in a pass band, dB 
input int    FILTERShift=0; //Horizontal shift of moving average in bars 

//---- DLL file import
#import "DF.dll"
int DigitalFilter(int FType,int P1,int D1,int A1,int P2,int D2,int A2,double Ripple,int Delay,double &array[]);
#import

//---- declaration and initialization of a variable for storing the number of calculated bars
int FILTERPeriod;

//---- declaration of a dynamic array that 
// will be used as indicator buffer
double ExtLineBuffer[];

//---- declaration and initialization of an array for the coefficient of the digital filter
double FILTERTable[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set ExtLineBuffer dynamic array as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by FILTERShift
   PlotIndexSetInteger(0,PLOT_SHIFT,FILTERShift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,FILTERPeriod);
//---- initializations of a variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"FILTER(",FILTERShift,")");
//---- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- Calculation of the digital filter coefficients and FILTERTable[] buffer size
   double Array[1500];
   FILTERPeriod=DigitalFilter(FType,P1,D1,A1,P2,D2,A2,Ripple,Delay,Array);
//----  changing the FILTERTable[] buffer size for the necessary number of the digital filter coefficients
   if(FILTERPeriod<=0)
     {
      Print("Input parameters are incorrect. Indicator cannot be launched!");
      return;
     }
//---- copy data from the temporary array having the size 1500 to the basic array of the size of FILTERPeriod
   ArrayCopy(FILTERTable,Array,0,0,FILTERPeriod);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<FILTERPeriod-1+begin)
      return(0);

//---- declaration of local variables 
   int first,bar,iii;
   double FILTER;

//---- calculation of the 'first' starting index for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of the indicator
     {
      first=FILTERPeriod-1+begin; // starting index for calculation of all bars
      //--- increase the position of the beginning of data by 'begin' bars as a result of calculation using data of another indicator
      if(begin>0)
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+FILTERPeriod);
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main loop of indicator calculation
   for(bar=first; bar<rates_total; bar++)
     {
      //---- formula for the digital filter calculation
      FILTER=0.0;
      for(iii=0; iii<FILTERPeriod; iii++)
         FILTER+=FILTERTable[iii] *price[bar-iii];

      //---- Initialization of a cell of the indicator buffer with the received FILTER value
      ExtLineBuffer[bar]=FILTER;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
