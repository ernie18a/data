//+------------------------------------------------------------------+
//|                                                    IndMATEMA.mq5 |
//|                                                           Shovel |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Shovel"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window

#property indicator_buffers 8
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Green,Red,DodgerBlue,Gold,Gray
#property indicator_width1  2
#property indicator_label1  "MATEMA"
#property indicator_style1  STYLE_SOLID 
#property indicator_level1  0.0

//--- input parameters
//--- 1 MA
input int            InpMA1Period=10;        // Period MA Close
input ENUM_MA_METHOD InpMA1Method=MODE_SMMA; // Method MA Close
int                  InpMA1Shift=0;          // Shift  MA Close
ENUM_APPLIED_PRICE   InpMA1Price=PRICE_CLOSE;// PriceClose MA Close
//--- 2 MA
input int            InpMA2Period=10;        // Period MA Open
input ENUM_MA_METHOD InpMA2Method=MODE_SMMA; // Method MA Open
int                  InpMA2Shift=0;          // Shift  MA Open
ENUM_APPLIED_PRICE   InpMA2Price=PRICE_OPEN; // PriceOpen MA Open

input double         delta=0.0002;           // Delta 

//--- 1 TEMA
input int            InpTEMA1Period=20;      // Period TEMA Close
int                  InpTEMA1Shift=0;        // Shift TEMA Close
ENUM_APPLIED_PRICE   InpTEMA1Price=PRICE_CLOSE;// PriceClose TEMA Close
//--- 2 TEMA
input int            InpTEMA2Period=20;      // Period TEMA Open
int                  InpTEMA2Shift=0;        // Shift  TEMA Open
ENUM_APPLIED_PRICE   InpTEMA2Price=PRICE_OPEN;// PriceOpen TEMA Open

//--- indicator buffers
double ExtBuffer[];
double ExtColorBuffer[];
//--- MA Buffers
double ExtMAOpenBuffer[];
double ExtMACloseBuffer[];
double ExtMABuffer[];
//--- TEMA Buffers
double ExtTEMAOpenBuffer[];
double ExtTEMACloseBuffer[];
double ExtTEMABuffer[];
//--- handles for MAs
int    ExtMAOpenHandle;
int    ExtMACloseHandle;
//--- handles for TEMAs
int    ExtTEMAOpenHandle;
int    ExtTEMACloseHandle;

int DATA_LIMIT;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorBuffer,INDICATOR_COLOR_INDEX);

   SetIndexBuffer(2,ExtMAOpenBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtMACloseBuffer,INDICATOR_CALCULATIONS);

   SetIndexBuffer(4,ExtTEMAOpenBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtTEMACloseBuffer,INDICATOR_CALCULATIONS);

   SetIndexBuffer(6,ExtMABuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,ExtTEMABuffer,INDICATOR_CALCULATIONS);

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);

//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DATA_LIMIT);
//--- name for DataWindow 
   IndicatorSetString(INDICATOR_SHORTNAME,"MATEMA ("+string(InpMA1Period)+" - "+string(InpMA2Period)+" : "+string(InpTEMA1Period)+" - "+string(InpTEMA2Period)+")");
//--- get handles
   ExtMAOpenHandle=iMA(NULL,0,InpMA1Period,InpMA1Shift,InpMA1Method,InpMA1Price);
   ExtMACloseHandle=iMA(NULL,0,InpMA2Period,InpMA2Shift,InpMA2Method,InpMA2Price);
   ExtTEMAOpenHandle=iTEMA(NULL,0,InpTEMA1Period,InpTEMA1Shift,InpTEMA1Price);
   ExtTEMACloseHandle=iTEMA(NULL,0,InpTEMA2Period,InpTEMA2Shift,InpTEMA2Price);

   int per1 = MathMax(InpMA1Period,InpMA2Period);
   int per2 = MathMax(InpTEMA1Period,InpTEMA2Period);
   DATA_LIMIT=MathMax(per1,per2);

//---
   return(0);
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
//---
//--- check for rates total
   if(rates_total<=DATA_LIMIT) return(0);// not enough bars for calculation
//--- not all data may be calculated
   int calculated=BarsCalculated(ExtTEMACloseHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtTEMACloseHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }

//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }

//--- get MA1OpenBuffer buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtMAOpenHandle,0,0,to_copy,ExtMAOpenBuffer)<=0)
     {
      Print("Getting MAOpenBuffer is failed! Error",GetLastError());
      return(0);
     }
//--- get MA2CloseBuffer buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtMACloseHandle,0,0,to_copy,ExtMACloseBuffer)<=0)
     {
      Print("Getting MACloseBuffer is failed! Error",GetLastError());
      return(0);
     }
//--- get TEMA1OpenBuffer buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtTEMAOpenHandle,0,0,to_copy,ExtTEMAOpenBuffer)<=0)
     {
      Print("Getting TEMAOpenBuffer is failed! Error",GetLastError());
      return(0);
     }
//--- get TEMA2CloseBuffer buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtTEMACloseHandle,0,0,to_copy,ExtTEMACloseBuffer)<=0)
     {
      Print("Getting TEMACloseBuffer is failed! Error",GetLastError());
      return(0);
     }
//--- first calculation or number of bars was changed
   int i,limit;
   if(prev_calculated<=DATA_LIMIT)
     {
      for(i=0;i<DATA_LIMIT;i++)
         ExtBuffer[i]=0.0;
      limit=DATA_LIMIT;
     }
   else limit=prev_calculated-1;

//--- main loop of calculations
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtMABuffer[i]=ExtMAOpenBuffer[i]-ExtMACloseBuffer[i];
      ExtTEMABuffer[i]=ExtTEMAOpenBuffer[i]-ExtTEMACloseBuffer[i];
      ExtBuffer[i]=ExtMABuffer[i]+ExtTEMABuffer[i];

      if( ExtBuffer[i]>0.0)   ExtColorBuffer[i]=0.0;   // set color Green Long
      else                    ExtColorBuffer[i]=1.0;   // set color Red Short

      //---  if( ExtColorBuffer[i]==0.0 && ExtColorBuffer[i-1]==1.0)   ExtColorBuffer[i]=2.0;      // set color DodgerBlue Signal Long
      //---  else if( ExtColorBuffer[i]==1.0 && ExtColorBuffer[i-1]==0.0) ExtColorBuffer[i]=3.0;   // set color Gold Signal Short

      if(MathAbs(ExtBuffer[i])<delta && ExtColorBuffer[i]<2.0) ExtColorBuffer[i]=4.0;    // set color Gray

     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
