//+------------------------------------------------------------------+
//|                                                     Monthly VWAP |
//|                            https://www.mql5.com/en/users/syllyon |
//+------------------------------------------------------------------+
#property copyright "Guillermo Pineda"
#property link      "www.mql5.com/en/users/syllyon"
#property version   "1.00"
#property strict

//--- Plotting properties
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

//--- Plot 1: Daily VWAP
#property indicator_label1	"Monthly VWAP"
#property indicator_type1	DRAW_LINE
#property indicator_color1	clrDodgerBlue
#property indicator_width1	1

//--- Indicator Data Buffer
double VWAPBuffer[];
//--- Price Data Buffer
double nPriceArr[];
double nTotalTPV[];
double nTotalVol[];

//--- Global Variables
double nSumMonthlyTPV = 0.0;
double nSumMonthlyVol = 0.0;
int nIdx = 0;
int nIdxMonthly = 0;
bool bIsFirstRun = true;
ENUM_TIMEFRAMES LastTimePeriod = PERIOD_MN1;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CreateDateTime(const datetime dtDay=D'2000.01.01 00:00:00',
                        const int pHour=0,
                        const int pMinute=0,
                        const int pSecond=0) {
   datetime    dtReturnDate;
   MqlDateTime timeStruct;
   
   TimeToStruct(dtDay, timeStruct);
   timeStruct.hour = pHour;
   timeStruct.min = pMinute;
   timeStruct.sec = pSecond;
   dtReturnDate = (StructToTime(timeStruct));
   
	timeStruct.day = 1;
	dtReturnDate = (StructToTime(timeStruct));
   return dtReturnDate;
}

datetime dtLastMonth = CreateDateTime();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
   //--- Indicator buffer mapping
   SetIndexBuffer(0, VWAPBuffer, INDICATOR_DATA);

   //--- Setup for Plot 0 (Daily VWAP)
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 1);

   //--- Set indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME, "Monthly VWAP");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[]) {
   // Check if timeframe has changed
   if (PERIOD_CURRENT!=LastTimePeriod) {
      bIsFirstRun = true;
      LastTimePeriod = PERIOD_CURRENT;
   }
   //
   if (rates_total>prev_calculated || bIsFirstRun) {
      ArrayResize(nPriceArr, rates_total);
      ArrayResize(nTotalTPV, rates_total);
      ArrayResize(nTotalVol, rates_total);

      nIdx = nIdxMonthly;
      nSumMonthlyTPV = 0;
      nSumMonthlyVol = 0;

      for ( ; nIdx<rates_total ; nIdx++) {
         if(CreateDateTime(time[nIdx])!=dtLastMonth) {
            nIdxMonthly = nIdx;
            nSumMonthlyTPV = 0;
            nSumMonthlyVol = 0;
         }
         // Get Smoothed Price
         nPriceArr[nIdx] = (close[nIdx]+high[nIdx]+low[nIdx])/3;
         // Get Volume
         if (tick_volume[nIdx]) {
            nTotalTPV[nIdx] = (nPriceArr[nIdx] * tick_volume[nIdx]);
            nTotalVol[nIdx] = (double)tick_volume[nIdx];
         } 
         else if (volume[nIdx]) {
            nTotalTPV[nIdx] = (nPriceArr[nIdx] * volume[nIdx]);
            nTotalVol[nIdx] = (double)volume[nIdx];
         }
         if (nIdx>=nIdxMonthly) {
            nSumMonthlyTPV += nTotalTPV[nIdx];
            nSumMonthlyVol += nTotalVol[nIdx];
            // Set Buffer
            VWAPBuffer[nIdx] = (nSumMonthlyTPV/nSumMonthlyVol);
         }
         dtLastMonth = CreateDateTime(time[nIdx]);
      }
      bIsFirstRun = false;
   }
   return(rates_total);
}
//+------------------------------------------------------------------+