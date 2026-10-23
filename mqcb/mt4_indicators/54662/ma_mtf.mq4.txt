//+------------------------------------------------------------------+
//|                                                       MA_MTF.mq4 |
//|                      Copyright © 2025, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2025, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 White
#property strict


//---- indicator parameters
extern int                 MAPeriode   = 30;             // MA Periode
extern ENUM_MA_METHOD      MA_Mode     = MODE_EMA;       // MA Mode
extern ENUM_APPLIED_PRICE  Price_Type  = PRICE_CLOSE;    // MA Applied Price
extern int                 MAShift     = 0;              // time Shift

//---- buffers
double MovingBuffer[];
int MAPeriod;
string short_name;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MovingBuffer);

   short_name ="MA( "+ IntegerToString(MAPeriode/Period()) + ", " + IntegerToString(MA_Mode) + ", " + IntegerToString(Price_Type) + " )";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);

   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    i,counted_bars=IndicatorCounted();

   if(Period() >= MAPeriode)
      return(0);
   
   MAPeriod = MAPeriode/Period();

//----
   if(Bars<=MAPeriod)
      return(0);


//---- initial zero
   if(counted_bars<1)
      for(i=1; i<=MAPeriod; i++)
         MovingBuffer[Bars-i]=EMPTY_VALUE;
//----
   int limit=Bars-counted_bars;
   if(counted_bars>0)
      limit++;
   for(i=0; i<limit; i++)
      MovingBuffer[i]=iMA(NULL,0,MAPeriod,MAShift,MA_Mode,Price_Type,i);
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
