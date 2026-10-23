//+------------------------------------------------------------------+
//|                                               Pivot_Point_II.mq5 |
//|                                  Copyright 2026, Gemini AI Labs. |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5

// --- Plot Bollinger Bands (1, 2, 3) ---
#property indicator_label1  "BB Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSalmon

#property indicator_label2  "BB Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLightSalmon

#property indicator_label3  "BB Middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLightGray
#property indicator_style3  STYLE_DOT

// --- Plot Multi-TF Pivot (4) ---
#property indicator_label4  "Pivot Multi-TF"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDeepSkyBlue
#property indicator_width4  2

// --- Plot Current PP (5) ---
#property indicator_label5  "Pivot Current (Fixed)"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGold
#property indicator_style5  STYLE_DASH

//--- Input Parameters
input ENUM_TIMEFRAMES   InpPivotTF   = PERIOD_D1;    // Timeframe untuk Multi-TF PP
input int               InpBBPereiod = 20;           // BB Period
input double            InpBBDev     = 2.0;          // BB Deviation
input int               InpBBShift   = 0;            // BB Shift

//--- Buffers
double BBUpperBuffer[];
double BBLowerBuffer[];
double BBMidBuffer[];
double PPMultiBuffer[];
double PPCurrentBuffer[];

int handleBB;

//+------------------------------------------------------------------+
int OnInit()
{
   // Mapping 5 buffers secara tersusun
   SetIndexBuffer(0, BBUpperBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, BBLowerBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, BBMidBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, PPMultiBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, PPCurrentBuffer, INDICATOR_DATA);
   
   // Handle BB
   handleBB = iBands(_Symbol, _Period, InpBBPereiod, InpBBShift, InpBBDev, PRICE_CLOSE);
   
   if(handleBB == INVALID_HANDLE) return(INIT_FAILED);

   IndicatorSetString(INDICATOR_SHORTNAME, "Pivot+BB_Fixed");
   return(INIT_SUCCEEDED);
}

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
   if(rates_total < InpBBPereiod) return(0);

   // 1. Salin data BB ke buffer (Pastikan indeks buffer betul: 0=Mid, 1=Upper, 2=Lower)
   if(CopyBuffer(handleBB, 1, 0, rates_total, BBUpperBuffer) <= 0) return(0);
   if(CopyBuffer(handleBB, 2, 0, rates_total, BBLowerBuffer) <= 0) return(0);
   if(CopyBuffer(handleBB, 0, 0, rates_total, BBMidBuffer) <= 0)   return(0);

   // --- PIVOT CURRENT (Fixed 1,1,1) ---
   double curH = iHigh(_Symbol, _Period, 2);
   double curL = iLow(_Symbol, _Period, 2);
   double curC = iClose(_Symbol, _Period, 12);
   double ppCurrentValue = (curH + curL + curC) / 3.0;

   // --- PIVOT MULTI-TF (Input) ---
   double multiH = iHigh(_Symbol, InpPivotTF, 1);
   double multiL = iLow(_Symbol, InpPivotTF, 1);
   double multiC = iClose(_Symbol, InpPivotTF, 1);
   double ppMultiValue = (multiH + multiL + multiC) / 3.0;

   // 2. Isi Buffer
   int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;
   for(int i = start; i < rates_total; i++)
   {
      PPMultiBuffer[i]   = ppMultiValue;
      PPCurrentBuffer[i] = ppCurrentValue;
   }

   return(rates_total);
}