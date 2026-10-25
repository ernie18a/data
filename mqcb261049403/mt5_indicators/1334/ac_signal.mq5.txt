//+------------------------------------------------------------------+
//|                                                    AC_Signal.mq5 |
//|                               Copyright © 2011, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
#property description ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color1  Magenta
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- bullish indicator label display
#property indicator_label1  "AC Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- blue color is used for the indicator bullish line
#property indicator_color2  Blue
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//---- bearish indicator label display
#property indicator_label2 "AC Buy"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input string  InfoComment="AC_Signal ";  //the first part of the message comment
input uint SignalBar=1;                  //signal bar index, 0 is a current bar
input uint AlertCount=0;                 //number of alerts
input bool push=true;                    //allow to send push-messages
input bool email=false;                  //allow to send e-mail messages
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//---- Declaration of integer variables for the indicator handles
int AC_Handle,ATR_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables   
   min_rates_total=33+3;

//---- getting the Accelerator Oscillator indicator handle 
   AC_Handle=iAC(Symbol(),PERIOD_CURRENT);
   if(AC_Handle==INVALID_HANDLE) Print(" Failed to get handle of the Accelerator Oscillator indicator");
   
//---- getting the ATR indicator handle
   ATR_Handle=iATR(NULL,0,15);
   if(ATR_Handle==INVALID_HANDLE) Print(" Failed to get handle of the ATR indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SellBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BuyBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="AC_Signal";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
//---- checking for the sufficiency of bars for the calculation
   if(BarsCalculated(AC_Handle)<rates_total
    || BarsCalculated(ATR_Handle)<rates_total 
    || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar;
   double AC[],ATR[];
   static uint UpCount,DnCount;
   static datetime UpTime1=0,DnTime1=0;
   static datetime UpTime2=0,DnTime2=0;

//--- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
        limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(AC,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   
//--- copy newly appeared data in the array
   if(CopyBuffer(AC_Handle,0,0,limit+3,AC)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,limit+1,ATR)<=0) return(RESET);

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {    
      if(AC[bar+2]>AC[bar+1]&&AC[bar+1]<AC[bar]) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8; else BuyBuffer[bar]=0.0;
      if(AC[bar+2]<AC[bar+1]&&AC[bar+1]>AC[bar]) SellBuffer[bar]=high[bar]+ATR[bar]*3/8; else SellBuffer[bar]=0.0;
     }
     
//---- alerts counters reset to zeros
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
     }
   
   //---- submission of an alert for buying
   if(UpCount<AlertCount&&BuyBuffer[SignalBar])
     {
      UpCount++;
      Alert(InfoComment+Symbol()+GetStringTimeframe(PERIOD_CURRENT)+": Buy signal "+Symbol());
     }
    
   //---- submission of an alert for selling
   if(DnCount<AlertCount&&SellBuffer[SignalBar])
     {
      DnCount++;
      Alert(InfoComment+Symbol()+GetStringTimeframe(PERIOD_CURRENT)+": Sell signal "+Symbol());
     }
     
   if(push)
   {
    if(BuyBuffer[SignalBar]&&UpTime1!=time[SignalBar])
     {
       if(SendNotification(InfoComment+Symbol()+GetStringTimeframe(PERIOD_CURRENT)+": Buy signal "+Symbol()))
         UpTime1=time[SignalBar];
     }
     
    if(SellBuffer[SignalBar]&&DnTime1!=time[SignalBar])
     {
       if(SendNotification(InfoComment+Symbol()+GetStringTimeframe(PERIOD_CURRENT)+": Sell signal "+Symbol()))
         DnTime1=time[SignalBar];
     }   
   }
   
   if(email)
   {
    if(BuyBuffer[SignalBar]&&UpTime2!=time[SignalBar])
     {
      string text=InfoComment+Symbol()+GetStringTimeframe(PERIOD_CURRENT)+": Buy signal "+Symbol();
      if(SendMail(text,text)) UpTime2=time[SignalBar];
     }
     
    if(SellBuffer[SignalBar]&&DnTime2!=time[SignalBar])
     {
      string text=InfoComment+Symbol()+GetStringTimeframe(PERIOD_CURRENT)+": Sell signal "+Symbol();
      if(SendMail(text,text)) DnTime2=time[SignalBar];
     }   
   }  
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
