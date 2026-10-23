//+------------------------------------------------------------------+ 
//|                                               TrendMagic_HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.00"
#property description "TrendMagic with the timeframe selection option available in input parameters"
//--- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-------------------------------------+
//| declaration of constants            |
//+-------------------------------------+
#define RESET 0                      // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "TrendMagic"  // A constant for the indicator name
#define SIZE 1                       // A constant for the number of calls of the CountIndicator function
//+-------------------------------------+
//| Indicator 1 drawing parameters      |
//+-------------------------------------+
//--- drawing the indicator as a multicolored line
#property indicator_type1   DRAW_COLOR_LINE
//--- the following colors are used in a three-color line
#property indicator_color1  clrGreen,clrMagenta
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 4
#property indicator_width1  4
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME
//+-------------------------------------+
//| Indicator input parameters          |
//+-------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; //Indicator chart period
input uint CCI_Period=50;                         // CCI period
input ENUM_APPLIED_PRICE   CCIPrice=PRICE_MEDIAN; // CCI price
input uint ATR_Period=5;                          // ATR period
input int Shift=0;                                // Horizontal shift of the indicator in bars
input int PriceShift=0;                           // Vertical shift of the indicator in points
//+-------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//--- declaration of string variables
string Symbol_,Word;
//--- declaration of integer variables of data starting point
int min_rates_total;
//--- declaration of integer variables for the indicator handles
int Ind_Handle;
//+------------------------------------------------------------------+
//|  Getting a timeframe as a string                                 |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- checking correctness of the chart periods
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//--- initialization of variables 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" indicator: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- getting the handle of the TrendMagic indicator
   Ind_Handle=iCustom(Symbol(),TimeFrame,INDICATOR_NAME,CCI_Period,CCIPrice,ATR_Period,0,PriceShift);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the TrendMagic indicator");
      return(INIT_FAILED);
     }
//--- initialization of indicator buffers
   IndInit(0,IndBuffer,ColorIndBuffer,0.0,min_rates_total,0);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
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
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer,1,ColorIndBuffer,
      time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Indicator buffer initialization                                  |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double &ColorBuffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//---
   int indnumb=2*Number;
   int plotnumb=indnumb;
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(indnumb,Buffer,INDICATOR_DATA);
   SetIndexBuffer(indnumb+1,ColorBuffer,INDICATOR_COLOR_INDEX);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(plotnumb,PLOT_DRAW_BEGIN,Draw_Begin);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(plotnumb,PLOT_EMPTY_VALUE,Empty_Value);
//--- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(plotnumb,PLOT_SHIFT,nShift);
//---- Indexing buffer elements as timeseries
   ArraySetAsSeries(Buffer,true);
   ArraySetAsSeries(ColorBuffer,true);
//---
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // The number of the CountLine function in the list in the indicator code (starting number - 0)
                    string   Symb,            // Chart symbol
                    ENUM_TIMEFRAMES TFrame,   // Chart period
                    int      IndHandle,       // The handle of the processed indicator
                    uint     BuffNumb,        // The number of the buffer of the processed indicator
                    double&  IndBuf[],        // Receiving buffer of the indicator
                    uint     ColBuffNumb,     // The index of the buffer of the processed indicator
                    double&  ColIndBuf[],     // Receiving indicator buffer
                    const datetime& iTime[],  // Timeseries of time
                    const int Rates_Total,    // amount of history in bars on the current tick
                    const int Prev_Calculated,// amount of history in bars at the previous tick
                    const int Min_Rates_Total)// minimum amount of history in bars for calculation
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=Rates_Total-Min_Rates_Total-1; // starting index for the calculation of all bars
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // starting index for calculation of new bars 

//--- main calculation loop of the indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for the calculation
      IndBuf[bar]=0.0;

      //--- copy new data to the IndTime array
      if(CopyTime(Symbol_,TFrame,iTime[bar],1,IndTime)<=0) return(RESET);

      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1],ColArr[1];
         //--- copy newly appeared data in the arrays
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,ColBuffNumb,iTime[bar],1,ColArr)<=0) return(RESET);
         IndBuf[bar]=Arr[0];
         ColIndBuf[bar]=ColArr[0];
        }
      else
        {
         IndBuf[bar]=IndBuf[bar+1];
         ColIndBuf[bar]=ColIndBuf[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Indicator chart period
  {
//--- checking correctness of the chart periods
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Chart period for the "+IndName+" indicator cannot be less than the period of the current chart!");
      Print ("You must change the indicator input parameters!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
