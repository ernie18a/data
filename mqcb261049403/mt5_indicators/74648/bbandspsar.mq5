//+------------------------------------------------------------------+
//|                                                   BBandsPsar.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Wamek EA"
#property link      "https://www.mql5.com/en/users/wamek"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Lime      // UpLevel
#property indicator_width1  2
#property indicator_label1  "UpLevel"

#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  Red       // DownLevel
#property indicator_width2  2
#property indicator_label2  "DownLevel"

#property indicator_level1     0.5
#property indicator_level2    -0.5
#property indicator_level3     1.5
#property indicator_level4    -1.5
#property indicator_level5     2.5
#property indicator_level6    -2.5


//---- indicator buffers
double UpLevelBuffer[];
double DownLevelBuffer[];

//-- Input parameters
input int    blpd = 20;        // Bollinger Bands period
input double bldev = 2.0;    // Bollinger Bands deviation
input double pstep = 0.02;         // SAR step
input double pMax = 0.2;           // SAR maximum

//-- Handles for technical indicators
int sarHandle;
int bandsHandle;

//--Array to store indicator values
double sarPart[];
double upperPart[], lowerPart[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //-- Set indicator buffers
   SetIndexBuffer(0, UpLevelBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, DownLevelBuffer, INDICATOR_DATA);
   
   //-- Create indicator handles
   bandsHandle = iBands(_Symbol, _Period, 20, 0, 2, PRICE_CLOSE);   
   sarHandle   = iSAR(_Symbol, _Period, pstep, pMax);

   if(sarHandle == INVALID_HANDLE || bandsHandle == INVALID_HANDLE)
   {  
     Print("iBands handle=", bandsHandle, 
     "iSAR handle=", sarHandle," err=", GetLastError());
      return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(sarHandle != INVALID_HANDLE)
      IndicatorRelease(sarHandle);

   if(bandsHandle != INVALID_HANDLE)
      IndicatorRelease(bandsHandle);
   
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
   if(rates_total < blpd)
      return(0);

   int pStart;
   if(prev_calculated == 0)
   {
      ArrayInitialize(UpLevelBuffer, EMPTY_VALUE);
      ArrayInitialize(DownLevelBuffer, EMPTY_VALUE);
      pStart = 0;
   }
   else
      pStart = prev_calculated - 1;

   //--Number of new bars to calculate
   int count = rates_total - pStart;
   if(count <= 0) return(rates_total);

   //--Copy only the required portion
   if(CopyBuffer(sarHandle, 0, 0, count, sarPart) != count) return(0);
   if(CopyBuffer(bandsHandle, 1, 0, count, upperPart) != count) return(0);
   if(CopyBuffer(bandsHandle, 2, 0, count, lowerPart) != count) return(0);

   //-- Process the new bars
   for(int i = 0; i < count; i++)
   {
      int idx = i + pStart;   // actual bar index
      
      UpLevelBuffer[idx] = EMPTY_VALUE;
      DownLevelBuffer[idx] = EMPTY_VALUE;
      
      if(sarPart[i] == EMPTY_VALUE || upperPart[i] == EMPTY_VALUE 
       || lowerPart[i] == EMPTY_VALUE) continue;

      double bandWidth = MathAbs(upperPart[i] - lowerPart[i]);
      if(bandWidth == 0.0) bandWidth = _Point;

      double minOC = MathMin(open[idx], close[idx]);
      double maxOC = MathMax(open[idx], close[idx]);
      
      double invBandWidth = 1.0 / bandWidth;
      double upLevel = (minOC - sarPart[i])* invBandWidth;
      double downLevel = (maxOC - sarPart[i])* invBandWidth;

      if(upLevel > 0)
         UpLevelBuffer[idx] = upLevel;
      else if(downLevel < 0)
         DownLevelBuffer[idx] = downLevel;
   }

   return(rates_total);
}