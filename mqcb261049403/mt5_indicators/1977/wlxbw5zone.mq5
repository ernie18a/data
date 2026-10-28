//+------------------------------------------------------------------+
//|                                                   wlxBW5Zone.mq5 |
//|                                          Copyright © 2005, Wellx |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2005, Wellx"
//--- link to the website of the author
#property link      "https://www.metaquotes.net/"
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- two buffers are used for calculating and drawing the indicator
#property indicator_buffers 2
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+ 
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // A constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//--- pink is used for the color of the bearish indicator line
#property indicator_color1  clrMagenta
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- indicator bullish label display
#property indicator_label1  "wlxBW5Zone Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//--- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- green color is used as the color of the indicator bullish line
#property indicator_color2  clrLime
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//---- bearish indicator label display
#property indicator_label2 "wlxBW5Zone Buy"
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Direct //Type of constant
  {
   ON = 0,     // By trend
   OFF         // Against trend
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Direct Dir=ON; // Direction of signals
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//--- declaration of integer variables for the indicators handles
int AC_Handle,AO_Handle,ATR_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of global variables 
   int ATR_Period=12;
   int AC_Period=37;
   int AO_Period=33;
   min_rates_total=int(MathMax(MathMax(AC_Period,AO_Period)+4,ATR_Period));

//---- Getting the handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }
//--- getting the handle of Accelerator Oscillator 
   AC_Handle=iAC(Symbol(),PERIOD_CURRENT);
   if(AC_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of Accelerator Oscillator");
      return(INIT_FAILED);
     }
//--- getting the handle of Awesome Oscillator 
   AO_Handle=iAO(Symbol(),PERIOD_CURRENT);
   if(AO_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of Awesome Oscillator");
      return(INIT_FAILED);
     }
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,119);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);

//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string short_name="wlxBW5ZoneSig";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- initialization end
   return(INIT_SUCCEEDED);
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
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(AC_Handle)<rates_total
      || BarsCalculated(AO_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//--- declarations of local variables 
   int to_copy,limit,bar;
   double AC[],AO[],ATR[],range;
   bool flagUP,flagDown;
   static bool flagUP_,flagDown_;

//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total; // starting index for calculation of all bars
      flagUP_=false;
      flagDown_=false;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }

   to_copy=limit+1;
//--- copy the new data to arrays AO[],AC[] and ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   to_copy+=4;
   if(CopyBuffer(AC_Handle,0,0,to_copy,AC)<=0) return(RESET);
   if(CopyBuffer(AO_Handle,0,0,to_copy,AO)<=0) return(RESET);

//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(AC,true);
   ArraySetAsSeries(AO,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//--- Restore values of the variables
   flagUP=flagUP_;
   flagDown=flagDown_;

//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;

      if(!flagUP)
         if((AO[bar]>AO[bar+1] && AO[bar+1]>AO[bar+2] && AO[bar+2]>AO[bar+3] && AO[bar+3]>AO[bar+4])
            && (AC[bar]>AC[bar+1] && AC[bar+1]>AC[bar+2] && AC[bar+2]>AC[bar+3] && AC[bar+3]>AC[bar+4]))
           {
            range=ATR[bar]*3/8;
            if(Dir==ON) BuyBuffer[bar]=low[bar]-range;
            else SellBuffer[bar]=high[bar]+range;
            flagUP=true;
           }

      if(!flagDown)
         if((AO[bar]<AO[bar+1] && AO[bar+1]<AO[bar+2] && AO[bar+2]<AO[bar+3] && AO[bar+3]<AO[bar+4])
            && (AC[bar]<AC[bar+1] && AC[bar+1]<AC[bar+2] && AC[bar+2]<AC[bar+3] && AC[bar+3]<AC[bar+4]))
           {
            range=ATR[bar]*3/8;
            if(Dir==ON) SellBuffer[bar]=high[bar]+range;
            else BuyBuffer[bar]=low[bar]-range;
            flagDown=true;
           }

      if(AO[bar+0]<AO[bar+1] || AC[bar+0]<AC[bar+1]) flagUP=false;
      if(AO[bar+0]>AO[bar+1]||AC[bar+0]>AC[bar+1]) flagDown=false;

      //--- Save the values of the variables
      if(bar)
        {
         flagUP_=flagUP;
         flagDown_=flagDown;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+