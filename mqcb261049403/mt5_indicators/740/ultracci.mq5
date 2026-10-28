//+------------------------------------------------------------------+
//|                                                     UltraCCI.mq5 |
//|                                   Copyright © 2008, dm34@mail.ru | 
//|                                    http://www.fxexpert.ru/forum/ | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2008, dm34@mail.ru"
//---- link to the website of the author
#property link "http://www.fxexpert.ru/forum/"
//---- indicator version
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- four buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- two plots are used
#property indicator_plots   3
//+-----------------------------------+ 
//|  Declaration of constants         |
//+-----------------------------------+ 
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Filling drawing parameters       |
//+-----------------------------------+
//---- drawing indicator as a filling between two lines
#property indicator_type1   DRAW_FILLING
//---- SteelBlue and HotPink colors are used as the indicator filling
#property indicator_color1  SteelBlue,HotPink
//---- displaying the indicator label
#property indicator_label1 "Ultra CCI"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color2  Red
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//---- displaying the indicator label
#property indicator_label2  "Ultra CCI Speed Down"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- lime color is used for the indicator
#property indicator_color3  Lime
//---- the indicator 3 line width is equal to 4
#property indicator_width3  4
//---- displaying the indicator label
#property indicator_label3 "Ultra CCI Speed Up"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA[];
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+  
enum WIDTH
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,       // Solid line
   DASH_,        // Dashed line
   DOT_,         // Dotted line
   DASHDOT_,     // Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int CCI_Period=13;                            // CCI indicator period
input ENUM_APPLIED_PRICE Applied_price=PRICE_CLOSE; // Applied price
//----
input Smooth_Method W_Method=MODE_JJMA;             // Smoothing method
input int StartLength=3;                            // Initial smoothing period                    
input int WPhase=100;                               // Smoothing parameter
//----  
input uint Step=5;                                  // Period change step
input uint StepsTotal=10;                           // Number of period changes
//----
input Smooth_Method SmoothMethod=MODE_JJMA;         // Smoothing method
input int SmoothLength=3;                           // Smoothing depth
input int SmoothPhase=100;                          // Smoothing parameter
//----                          
input uint UpLevel=80;                              // Overbought level, %%
input uint DnLevel=20;                              // Oversold level, %%
input color UpLevelsColor=DarkViolet;               // Overbought level color
input color DnLevelsColor=DarkViolet;               // Oversold level color
input STYLE Levelstyle=DASHDOTDOT_;                 // Levels style
input WIDTH LevelsWidth=Width_1;                    // Levels width                       
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double BullsBuffer[];
double BearsBuffer[];
double UpBuffer[];
double DnBuffer[];
//---- declaration of the variables array for storing WPR indicator signal lines periods
int period[];
//---- declaration of variables arrays for the CCI indicator smoothed values storage
double xcci0[],xcci1[];
//---- declaration of integer variables for the indicators handles
int CCI_Handle;
//---- declaration of the integer variables for the start of data calculation
double middle;
uint StTot1,StTot2;
int min_rates_total,min_rates_cci,min_rates_xma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- memory distribution for variables' arrays
   int size=int(StepsTotal+3);
   if(ArrayResize(XMA,size)<size) Print("Failed to distribute the memory for XMA[] array");
   size-=2;
   if(ArrayResize(xcci0,size)<size) Print("Failed to distribute the memory for xcci0[] array");
   if(ArrayResize(xcci1,size)<size) Print("Failed to distribute the memory for xcci1[] array");
   if(ArrayResize(period,size)<size) Print("Failed to distribute the memory for period[] array");

   ZeroMemory(xcci0);
   ZeroMemory(xcci1);
   ZeroMemory(period);

//---- initialization of variables
   for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--) period[sm]=int(StartLength+sm*Step);

   middle=StepsTotal*(UpLevel+DnLevel)/200;

//---- setting up alerts for unacceptable values of external variables
   XMA[0].XMALengthCheck("StartLength", StartLength);
   XMA[0].XMAPhaseCheck("WPhase", WPhase, W_Method);
   XMA[0].XMALengthCheck("SmoothLength", SmoothLength);
   XMA[0].XMAPhaseCheck("SmoothPhase", SmoothPhase, SmoothMethod);

//---- initialization of variables of the start of data calculation
   min_rates_cci=CCI_Period;
   min_rates_xma=min_rates_cci+XMA[0].GetStartBars(W_Method,StartLength+Step*StepsTotal,WPhase)+1;
   min_rates_total=min_rates_xma+XMA[0].GetStartBars(SmoothMethod,SmoothLength,SmoothPhase);
   StTot1=StepsTotal+1;
   StTot2=StepsTotal+2;

//---- getting handle of the CCI indicator
   CCI_Handle=iCCI(NULL,0,CCI_Period,Applied_price);
   if(CCI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the CCI indicator");
      return(1);
     }
//---- set BullsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BullsBuffer,true);

//---- set BearsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(BearsBuffer,true);

//---- set UpBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,DnBuffer,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 3 by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(DnBuffer,true);

//---- set DnBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,UpBuffer,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 4 by min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(UpBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname="Ultra CCI";
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);

//---- lines drawing parameters  
   IndicatorSetInteger(INDICATOR_LEVELS,2);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,StepsTotal*UpLevel/100);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,UpLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelsWidth);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,StepsTotal*DnLevel/100);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,DnLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelsWidth);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(CCI_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declarations of local variables 
   int to_copy,limit,bar,maxbar1,maxbar2;
   double CCI[],upsch,dnsch;

//---- calculation of maxbar initial index for the XMASeries() function
   maxbar1=rates_total-1-min_rates_cci;
   maxbar2=rates_total-1-min_rates_xma;

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=maxbar1;                       // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
//----   
   to_copy=limit+2;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(CCI,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--)
         xcci0[sm]=XMA[sm].XMASeries(maxbar1,prev_calculated,rates_total,W_Method,WPhase,period[sm],CCI[bar],bar,true);

      if(bar>maxbar2)
        {
         if(bar) ArrayCopy(xcci1,xcci0,0,0,WHOLE_ARRAY);
         continue;
        }

      upsch=0;
      dnsch=0;
      for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--)
         if(xcci0[sm]>xcci1[sm]) upsch++;
      else                    dnsch++;

      BullsBuffer[bar]=XMA[StTot1].XMASeries(maxbar2,prev_calculated,rates_total,SmoothMethod,SmoothPhase,SmoothLength,upsch,bar,true);
      BearsBuffer[bar]=XMA[StTot2].XMASeries(maxbar2,prev_calculated,rates_total,SmoothMethod,SmoothPhase,SmoothLength,dnsch,bar,true);

      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;

      if(BullsBuffer[bar]<BearsBuffer[bar])
        {
         if(BearsBuffer[bar+1]<=BearsBuffer[bar]) DnBuffer[bar]=middle;
         else UpBuffer[bar]=middle;
        }
      else
        {
         if(BullsBuffer[bar+1]<=BullsBuffer[bar]) UpBuffer[bar]=middle;
         else DnBuffer[bar]=middle;
        }

      if(bar) ArrayCopy(xcci1,xcci0,0,0,WHOLE_ARRAY);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
