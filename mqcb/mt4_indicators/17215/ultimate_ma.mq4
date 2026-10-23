//+------------------------------------------------------------------+
//|                                                  Ultimate MA.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"
//----
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 MediumVioletRed

//---- input parameters
extern ENUM_MA_METHOD MA_Method = MODE_SMA;  // Method
extern int fastperiod=5;                     // Fast Period
extern int middleperiod=34;                  // Middle Period
extern int slowperiod=55;                    // Slow Period
extern int fastK=4;                          // Fast Multiplier
extern int middleK=2;                        // Middle Multiplier
extern int slowK=1;                          // Slow Multiplier
//---- buffers
double UOBuffer[];
double BPBuffer[];
double divider;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   string name;
   name="UMA("+fastperiod+", "+middleperiod+", "+slowperiod+")";
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE,EMPTY);
   SetIndexBuffer(0,UOBuffer);
   SetIndexDrawBegin(0,slowperiod);
   SetIndexBuffer(1,BPBuffer);
   IndicatorShortName(name);
   IndicatorDigits(5);
   divider=fastK+middleK+slowK;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
//----
   int i,limit,limit2;
   double RawUO;
   if(counted_bars==0)
     {
      limit=Bars-2;
      limit2=Bars-slowperiod;
     }
   if(counted_bars>0)
     {
      limit=Bars-counted_bars;
      limit2=limit;
     }
   for(i=limit; i>=0; i--)
     {
      BPBuffer[i]=(2*((Open[i]+Close[i])/2)+((High[i]+Low[i])/2))/3;
     }
   for(i=limit2; i>=0; i--)
     {
      RawUO=(fastK+3*iATR(NULL, 0, fastperiod, i))*iMAOnArray(BPBuffer,0,fastperiod,0,MA_Method,i)
            +(middleK+3*iATR(NULL, 0, middleperiod, i))*iMAOnArray(BPBuffer,0,middleperiod,0,MA_Method,i)
            +(slowK+3*iATR(NULL, 0, slowperiod, i))*iMAOnArray(BPBuffer,0,slowperiod,0,MA_Method,i);
            
      divider=(fastK+3*iATR(NULL, 0, fastperiod, i))+(middleK+3*iATR(NULL, 0, middleperiod, i))+(slowK+3*iATR(NULL, 0, slowperiod, i));
      UOBuffer[i]=RawUO/divider;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
