//+------------------------------------------------------------------+ 
//|                        BackgroundСandle_BlauTSStochastic_HTF.mq5 | 
//|                               Copyright © 2013, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- Indicator version
#property version   "1.30"
#property description "A candlestick indicator colored based on the BlauTSStochastic indicator with timeframe selection option available in input parameters"
//--- Drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers is 12
#property indicator_buffers 12 
//--- 6 graphical plots are used
#property indicator_plots   6
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0                                            // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "BackgroundСandle_BlauTSStochastic" // A constant for the indicator name
#define SIZE  1                                            // A constant for the number of calls of the CountIndicator function in the code
#define EMPTYVALUE 0                                       // A constant for undisplayed indicator values
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//--- the color of the indicator
#property indicator_color1  clrLime,clrMagenta
//--- displaying the indicator label
#property indicator_label1  "Upper Shade"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type2   DRAW_FILLING
//--- the color of the indicator
#property indicator_color2  clrLimeGreen,clrDeepPink
//--- displaying the indicator label
#property indicator_label2  "Body"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type3   DRAW_FILLING
//--- the color of the indicator
#property indicator_color3  clrLime,clrMagenta
//--- displaying the indicator label
#property indicator_label3  "Lower Shade"
//+----------------------------------------------+
//|  Indicator 4 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type4   DRAW_FILLING
//--- the color of the indicator
#property indicator_color4  clrLime,clrMagenta
//--- displaying the indicator label
#property indicator_label4  "Upper Shade"
//+----------------------------------------------+
//|  Indicator 5 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type5   DRAW_FILLING
//--- the color of the indicator
#property indicator_color5  clrLimeGreen,clrDeepPink
//--- displaying the indicator label
#property indicator_label5  "Body"
//+----------------------------------------------+
//|  Indicator 6 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type6   DRAW_FILLING
//--- the color of the indicator
#property indicator_color6  clrLime,clrMagenta
//--- displaying the indicator label
#property indicator_label6  "Lower Shade"
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Applied_price_      // type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE_,        // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price 
  };
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Smooth_Method
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
  };
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum VisualMode
  {
   MODE_MAIN,   // a signal from the histogram
   MODE_CLOUD   // a signal from the cloud with a signal line
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Indicator chart period
input VisualMode Mode=MODE_MAIN;           // Display option 
input Smooth_Method XMA_Method=MODE_EMA;   // Averaging method
input uint XLength=5;                      // Period of stochastic momentum
input uint XLength1=20;                    // Depth of the first averaging
input uint XLength2=5;                     // Depth of the second averaging
input uint XLength3=3;                     // Depth of the third averaging
input uint XLength4=3;                     // Signal line averaging depth
input int XPhase=15;                       // Smoothing parameter
//--- XPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- XPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;      // Price constant
input int    Shift=0;                      // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double ExtA1Buffer[];
double ExtB1Buffer[];
double ExtA2Buffer[];
double ExtB2Buffer[];
double ExtA3Buffer[];
double ExtB3Buffer[];
double ExtA4Buffer[];
double ExtB4Buffer[];
double ExtA5Buffer[];
double ExtB5Buffer[];
double ExtA6Buffer[];
double ExtB6Buffer[];
//--- declaration of integer variables of data starting point
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int Ind_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- Checking correctness of the chart periods
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//--- initialization of variables 
   min_rates_total=2;
//--- getting the handle of BlauTSStochastic
   Ind_Handle=iCustom(Symbol(),TimeFrame,"BlauTSStochastic",XMA_Method,XLength,XLength1,XLength2,XLength3,XLength4,XPhase,IPC);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of BlauTSStochastic");
      return(INIT_FAILED);
     }
//--- set dynamic arrays as indicator buffers
   ArrayInit(0,ExtA1Buffer);
   ArrayInit(1,ExtB1Buffer);
   ArrayInit(2,ExtA2Buffer);
   ArrayInit(3,ExtB2Buffer);
   ArrayInit(4,ExtA3Buffer);
   ArrayInit(5,ExtB3Buffer);
   ArrayInit(6,ExtA4Buffer);
   ArrayInit(7,ExtB4Buffer);
   ArrayInit(8,ExtA5Buffer);
   ArrayInit(9,ExtB5Buffer);
   ArrayInit(10,ExtA6Buffer);
   ArrayInit(11,ExtB6Buffer);
//--- initialization of indicators
   PlotInit(0,2,Shift);
   PlotInit(1,2,Shift);
   PlotInit(2,2,Shift);
   PlotInit(3,2,Shift);
   PlotInit(4,2,Shift);
   PlotInit(5,2,Shift);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",EnumToString(TimeFrame),")");
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
   if(!CountIndicator(0,Symbol(),TimeFrame,Ind_Handle,
      ExtA1Buffer,ExtB1Buffer,ExtA2Buffer,ExtB2Buffer,
      ExtA3Buffer,ExtB3Buffer,ExtA4Buffer,ExtB4Buffer,
      ExtA5Buffer,ExtB5Buffer,ExtA6Buffer,ExtB6Buffer,
      time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // The number of the CountLine function in the list in the indicator code (starting number - 0)
                    string   Symb,            // Chart symbol
                    ENUM_TIMEFRAMES TFrame,   // Chart period
                    int      IndHandle,       // The handle of the processed indicator
                    double&  ExtA1Buff[],      // Receiving buffer of indicator 1
                    double&  ExtB1Buff[],      // Receiving buffer of indicator 2
                    double&  ExtA2Buff[],      // Receiving buffer of indicator 3
                    double&  ExtB2Buff[],      // Receiving buffer of indicator 4
                    double&  ExtA3Buff[],      // Receiving buffer of indicator 5
                    double&  ExtB3Buff[],      // Receiving buffer of indicator 6
                    double&  ExtA4Buff[],      // Receiving buffer of indicator 7
                    double&  ExtB4Buff[],      // Receiving buffer of indicator 8
                    double&  ExtA5Buff[],      // Receiving buffer of indicator 9
                    double&  ExtB5Buff[],      // Receiving buffer of indicator 10
                    double&  ExtA6Buff[],      // Receiving buffer of indicator 11
                    double&  ExtB6Buff[],      // Receiving buffer of indicator 11
                    const datetime &Time[],    // Time timeseries
                    const int Rates_Total,     // amount of history in bars at the current tick
                    const int Prev_Calculated, // number of bars calculated at previous call
                    const int Min_Rates_Total) // minimum amount of history in bars for calculation
  {
//---
   static int Sign;
   static datetime LastTime;
   static int LastCountBar[SIZE],PrevLastCountBar[SIZE];
   double iOpen[1],iLow[1],iHigh[1],iClose[1];
   datetime iTime[1];
   int limit;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=Rates_Total-Min_Rates_Total-1; // starting index for the calculation of all bars
      LastCountBar[Numb]=limit;
      PrevLastCountBar[Numb]=limit;
      LastTime=0;
      Sign=1;
     }
   else limit=MathMin(PrevLastCountBar[Numb]+Rates_Total-Prev_Calculated,Rates_Total-2); // starting index for calculation of new bars
//--- main calculation loop of the indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- copy new data to the IndTime array
      if(CopyTime(Symbol(),TFrame,Time[bar],1,iTime)<=0) return(RESET);

      if(Time[bar]>=iTime[0] && Time[bar+1]<iTime[0])
        {
         if(bar) PrevLastCountBar[Numb]=LastCountBar[Numb]; 
         LastCountBar[Numb]=bar;
         if(iTime[0]!=LastTime)
           {
            LastTime=iTime[0];
            Sign*=(-1);
           }

         if(CopyOpen(Symbol(),TFrame,Time[bar],1,iOpen)<=0) return(RESET);
         if(CopyLow(Symbol(),TFrame,Time[bar],1,iLow)<=0) return(RESET);
         if(CopyHigh(Symbol(),TFrame,Time[bar],1,iHigh)<=0) return(RESET);
         if(CopyClose(Symbol(),TFrame,Time[bar],1,iClose)<=0) return(RESET);

         double mathmax=MathMax(iOpen[0],iClose[0]);
         double mathmin=MathMin(iOpen[0],iClose[0]);

         if(Mode==MODE_CLOUD)
           {
            double iUp[1],iDn[1];
            //--- copy newly appeared data in the arrays
            if(CopyBuffer(IndHandle,0,Time[bar],1,iUp)<=0) return(RESET);
            if(CopyBuffer(IndHandle,1,Time[bar],1,iDn)<=0) return(RESET);

            if(Sign>0)
              {
               if(iUp[0]>=iDn[0])
                 {
                  ExtA1Buff[bar]=iHigh[0];
                  ExtB1Buff[bar]=mathmax;
                  ExtA2Buff[bar]=mathmax;
                  ExtB2Buff[bar]=mathmin;
                  ExtA3Buff[bar]=mathmin;
                  ExtB3Buff[bar]=iLow[0];
                 }
               else
                 {
                  ExtB1Buff[bar]=iHigh[0];
                  ExtA1Buff[bar]=mathmax;
                  ExtB2Buff[bar]=mathmax;
                  ExtA2Buff[bar]=mathmin;
                  ExtB3Buff[bar]=mathmin;
                  ExtA3Buff[bar]=iLow[0];
                 }

               ExtA4Buff[bar]=EMPTYVALUE;
               ExtB4Buff[bar]=EMPTYVALUE;
               ExtA5Buff[bar]=EMPTYVALUE;
               ExtB5Buff[bar]=EMPTYVALUE;
               ExtA6Buff[bar]=EMPTYVALUE;
               ExtB6Buff[bar]=EMPTYVALUE;
              }
            else
              {
               if(iUp[0]>=iDn[0])
                 {
                  ExtA4Buff[bar]=iHigh[0];
                  ExtB4Buff[bar]=mathmax;
                  ExtA5Buff[bar]=mathmax;
                  ExtB5Buff[bar]=mathmin;
                  ExtA6Buff[bar]=mathmin;
                  ExtB6Buff[bar]=iLow[0];
                 }
               else
                 {
                  ExtB4Buff[bar]=iHigh[0];
                  ExtA4Buff[bar]=mathmax;
                  ExtB5Buff[bar]=mathmax;
                  ExtA5Buff[bar]=mathmin;
                  ExtB6Buff[bar]=mathmin;
                  ExtA6Buff[bar]=iLow[0];
                 }
               ExtA1Buff[bar]=EMPTYVALUE;
               ExtB1Buff[bar]=EMPTYVALUE;
               ExtA2Buff[bar]=EMPTYVALUE;
               ExtB2Buff[bar]=EMPTYVALUE;
               ExtA3Buff[bar]=EMPTYVALUE;
               ExtB3Buff[bar]=EMPTYVALUE;
              }
           }

         if(Mode==MODE_MAIN)
           {
            double iInd[2];
            //--- copy newly appeared data in the array
            if(CopyBuffer(IndHandle,2,Time[bar],2,iInd)<=0) return(RESET);

            if(Sign>0)
              {
               if(iInd[1]>=iInd[0])
                 {
                  ExtA1Buff[bar]=iHigh[0];
                  ExtB1Buff[bar]=mathmax;
                  ExtA2Buff[bar]=mathmax;
                  ExtB2Buff[bar]=mathmin;
                  ExtA3Buff[bar]=mathmin;
                  ExtB3Buff[bar]=iLow[0];
                 }
               else
                 {
                  ExtB1Buff[bar]=iHigh[0];
                  ExtA1Buff[bar]=mathmax;
                  ExtB2Buff[bar]=mathmax;
                  ExtA2Buff[bar]=mathmin;
                  ExtB3Buff[bar]=mathmin;
                  ExtA3Buff[bar]=iLow[0];
                 }
               ExtA4Buff[bar]=EMPTYVALUE;
               ExtB4Buff[bar]=EMPTYVALUE;
               ExtA5Buff[bar]=EMPTYVALUE;
               ExtB5Buff[bar]=EMPTYVALUE;
               ExtA6Buff[bar]=EMPTYVALUE;
               ExtB6Buff[bar]=EMPTYVALUE;
              }
            else
              {
               if(iInd[1]>=iInd[0])
                 {
                  ExtA4Buff[bar]=iHigh[0];
                  ExtB4Buff[bar]=mathmax;
                  ExtA5Buff[bar]=mathmax;
                  ExtB5Buff[bar]=mathmin;
                  ExtA6Buff[bar]=mathmin;
                  ExtB6Buff[bar]=iLow[0];
                 }
               else
                 {
                  ExtB4Buff[bar]=iHigh[0];
                  ExtA4Buff[bar]=mathmax;
                  ExtB5Buff[bar]=mathmax;
                  ExtA5Buff[bar]=mathmin;
                  ExtB6Buff[bar]=mathmin;
                  ExtA6Buff[bar]=iLow[0];
                 }
               ExtA1Buff[bar]=EMPTYVALUE;
               ExtB1Buff[bar]=EMPTYVALUE;
               ExtA2Buff[bar]=EMPTYVALUE;
               ExtB2Buff[bar]=EMPTYVALUE;
               ExtA3Buff[bar]=EMPTYVALUE;
               ExtB3Buff[bar]=EMPTYVALUE;
              }
           }
        }
      else
        {
         int bar1=bar+1;
         ExtA1Buff[bar]=ExtA1Buff[bar1];
         ExtB1Buff[bar]=ExtB1Buff[bar1];
         ExtA2Buff[bar]=ExtA2Buff[bar1];
         ExtB2Buff[bar]=ExtB2Buff[bar1];
         ExtA3Buff[bar]=ExtA3Buff[bar1];
         ExtB3Buff[bar]=ExtB3Buff[bar1];
         ExtA4Buff[bar]=ExtA4Buff[bar1];
         ExtB4Buff[bar]=ExtB4Buff[bar1];
         ExtA5Buff[bar]=ExtA5Buff[bar1];
         ExtB5Buff[bar]=ExtB5Buff[bar1];
         ExtA6Buff[bar]=ExtA6Buff[bar1];
         ExtB6Buff[bar]=ExtB6Buff[bar1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| PlotInit()                                                       |
//+------------------------------------------------------------------+    
void PlotInit(uint PlotNumber,
              int DrawBegin,
              int PlotShift)
  {
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(PlotNumber,PLOT_DRAW_BEGIN,DrawBegin);
//--- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(PlotNumber,PLOT_SHIFT,PlotShift);
//---
  }
//+------------------------------------------------------------------+
//| ArrayInit()                                                      |
//+------------------------------------------------------------------+    
void ArrayInit(uint ArrNumber,
               double &Array[])
  {
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(ArrNumber,Array,INDICATOR_DATA);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Array,true);
//---
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Indicator 1 chart period (smallest timeframe)
  {
//--- Checking correctness of the chart periods
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
