//+------------------------------------------------------------------+ 
//|                                                      RES-SUP.mq5 | 
//|                               Copyright © 2013, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- Indicator version
#property version   "1.00"
#property description "Resistance and support levels by daily timeframes"
//--- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers 4
#property indicator_buffers 4 
//--- four plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0                         // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "BRES-SUP"       // A constant for the indicator name
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- the color of the indicator
#property indicator_color1  clrBlue
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME+"Up 2"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- the color of the indicator
#property indicator_color2  clrDodgerBlue
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2  INDICATOR_NAME+"Up 1"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 3 as a line
#property indicator_type3   DRAW_LINE
//--- the color of the indicator
#property indicator_color3  clrMagenta
//--- indicator 3 line width is equal to 2
#property indicator_width3  2
//--- displaying the indicator label
#property indicator_label3  INDICATOR_NAME+"Down 1"
//+----------------------------------------------+
//|  Indicator 4 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator 4 as a line
#property indicator_type4   DRAW_LINE
//--- the color of the indicator
#property indicator_color4  clrRed
//--- indicator 1 line width is equal to 4
#property indicator_width4  4
//--- displaying the indicator label
#property indicator_label4  INDICATOR_NAME+"Down 2"
//+-------------------------------------+
//| Indicator input parameters          |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_D1;             // Chart period for calculating the levels
input int                 Shift=0;                     // Horizontal shift of the indicator in bars
//+-------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
double Ind4Buffer[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- Checking the correctness of the indicator timeframe
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame,Period())) return(INIT_FAILED);
//--- initialization of variables 
   min_rates_total=2;
//--- Initialize indicator buffers
   IndInit(0,Ind1Buffer,0.0,min_rates_total,Shift);
   IndInit(1,Ind2Buffer,0.0,min_rates_total,Shift);
   IndInit(2,Ind3Buffer,0.0,min_rates_total,Shift);
   IndInit(3,Ind4Buffer,0.0,min_rates_total,Shift);
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",EnumToString(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
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
//--- declaration of integer variables
   int limit,bar;
//--- declaration of variables with a floating point  
   double iClose[2],iLow[2],iHigh[2];
   datetime iTime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for calculation of new bars 

//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Ind1Buffer[bar]=0.0;
      Ind2Buffer[bar]=0.0;
      Ind3Buffer[bar]=0.0;
      Ind4Buffer[bar]=0.0;

      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,iTime)<=0) return(RESET);

      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         LastCountBar=bar;
         Ind1Buffer[bar+1]=0.0;
         Ind2Buffer[bar+1]=0.0;
         Ind3Buffer[bar+1]=0.0;
         Ind4Buffer[bar+1]=0.0;

         //--- copy newly appeared data in the array
         if(CopyClose(Symbol(),TimeFrame,time[bar],2,iClose)<=0) return(RESET);
         if(CopyHigh(Symbol(),TimeFrame,time[bar],2,iHigh)<=0) return(RESET);
         if(CopyLow(Symbol(),TimeFrame,time[bar],2,iLow)<=0) return(RESET);

         double res1=(iLow[0]+iHigh[0]+iClose[0])/3;
         double res2=iHigh[0]-iLow[0];

         //--- Loading the obtained values in the indicator buffers
         Ind1Buffer[bar]=res1+res2*0.618;
         Ind2Buffer[bar]=res1+res2*0.5;
         Ind3Buffer[bar]=res1-res2*0.5;
         Ind4Buffer[bar]=res1-res2*0.618;
        }

      if(Ind1Buffer[bar+1] && !Ind1Buffer[bar])
        {
         Ind1Buffer[bar]=Ind1Buffer[bar+1];
         Ind2Buffer[bar]=Ind2Buffer[bar+1];
         Ind3Buffer[bar]=Ind3Buffer[bar+1];
         Ind4Buffer[bar]=Ind4Buffer[bar+1];
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Indicator buffer initialization                                  |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES inTFrame,  //Chart period for indicator calculation
                     ENUM_TIMEFRAMES outTFrame) //Indicator chart period
  {
//--- Checking correctness of the chart periods
   if(inTFrame<=outTFrame)
     {
      Print("Chart period for indicator "+IndName+" cannot be less than ",GetStringTimeframe(inTFrame));
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+
