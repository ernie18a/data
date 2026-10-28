//+------------------------------------------------------------------+ 
//|                                                  iBBands_HTF.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version number
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers 3
#property indicator_buffers 3 
//--- only three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0                  // The constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "iBBands" // The constant for the indicator name
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator 1 as a zigzag
#property indicator_type1   DRAW_SECTION
//--- the following colors are used for the indicator
#property indicator_color1  clrLightSeaGreen
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- drawing the indicator 2 as a zigzag
#property indicator_type2   DRAW_SECTION
//--- the following colors are used for the indicator
#property indicator_color2  clrBlue
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- drawing the indicator 3 as a zigzag
#property indicator_type3   DRAW_SECTION
//--- the following colors are used for the indicator
#property indicator_color3  clrMagenta
//--- indicator 3 line width is equal to 2
#property indicator_width3  2
//+-------------------------------------+
//| Indicator input parameters          |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;          // Chart period
input uint MA_Period=15;                            // Period of averaging
input ENUM_APPLIED_PRICE Applied_price=PRICE_CLOSE; // Price constant
input double Deviation=2.0;                         // Deviation
input int Shift=0;                                  // Horizontal shift of the indicator in bars
input int PriceShift=0;                             // Vertical shift of the indicator in points
//+-------------------------------------+
//--- declaration of dynamic arrays that further will be used as indicator buffers
double MdIndBuffer[],UpIndBuffer[],DnIndBuffer[];
//--- declaration of a variable for storing the indicator initialization result
bool Init;
double dPriceShift;
//--- declaration of strings
string Symbol_,Word;
//--- declaration of integer variables for the indicators handles
int Ind_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("iBBands indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- getting handle of the iMA indicator
   Ind_Handle=iBands(NULL,TimeFrame,MA_Period,0,Deviation,Applied_price);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iMA indicator");
      return(INIT_FAILED);
     }
//--- initialization of variables 
   min_rates_total=int((PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT))*MA_Period);
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" indicator: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Upper "+INDICATOR_NAME);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpIndBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,MdIndBuffer,INDICATOR_DATA);
//--- shifting the beginning of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Middle "+INDICATOR_NAME);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(MdIndBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,DnIndBuffer,INDICATOR_DATA);
//--- shifting the beginning of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//--- create a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Lower "+INDICATOR_NAME);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnIndBuffer,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- end of initialization
   return(INIT_FAILED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking the number of bars to be enough for calculation
   if(BarsCalculated(Ind_Handle)<2 || rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of local variables 
   double UpBB[1],MdBB[1],DnBB[1];
   int limit,bar;
   datetime iTime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied and
//--- the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-2; // starting index for calculation of all bars
      LastCountBar=limit;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for calculation of new bars 
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//--- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for calculation
      UpIndBuffer[bar+1]=0.0;
      MdIndBuffer[bar+1]=0.0;
      DnIndBuffer[bar+1]=0.0;
      //--- copy newly appeared data in the iTime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,iTime)<=0) return(RESET);
      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         //--- copy newly appeared data into the arrays
         if(CopyBuffer(Ind_Handle,UPPER_BAND,time[bar+1],1,UpBB)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,BASE_LINE,time[bar+1],1,MdBB)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,LOWER_BAND,time[bar+1],1,DnBB)<=0) return(RESET);
         //---
         LastCountBar=bar;
         UpIndBuffer[bar+1]=UpBB[0]+dPriceShift;
         MdIndBuffer[bar+1]=MdBB[0]+dPriceShift;
         DnIndBuffer[bar+1]=DnBB[0]+dPriceShift;
        }
     }
//--- copy newly appeared data into the arrays
   if(CopyBuffer(Ind_Handle,UPPER_BAND,time[0],1,UpBB)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,BASE_LINE,time[0],1,MdBB)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,LOWER_BAND,time[0],1,DnBB)<=0) return(RESET);

   UpIndBuffer[0]=UpBB[0]+dPriceShift;
   MdIndBuffer[0]=MdBB[0]+dPriceShift;
   DnIndBuffer[0]=DnBB[0]+dPriceShift;
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
