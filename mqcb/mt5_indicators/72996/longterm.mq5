#property copyright "Edoardo Centorame"
#property version   "1.01"
#property description "Long-term TRIX momentum and trend oscillator"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   5

//--- Plot 1
#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_DASH
#property indicator_width1  1
#property indicator_color1  clrLime
#property indicator_label1  "Bull Momentum"

//--- Plot 2
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DASH
#property indicator_width2  1
#property indicator_color2  clrDeepSkyBlue
#property indicator_label2  "Weak Momentum"

//--- Plot 3
#property indicator_type3   DRAW_LINE
#property indicator_style3  STYLE_DASH
#property indicator_width3  2
#property indicator_color3  clrRed
#property indicator_label3  "Bear Trend"

//--- Plot 4
#property indicator_type4   DRAW_LINE
#property indicator_style4  STYLE_DASH
#property indicator_width4  2
#property indicator_color4  clrBlueViolet
#property indicator_label4  "Long Bull Trend"

//--- Plot 5
#property indicator_type5   DRAW_LINE
#property indicator_style5  STYLE_DASH
#property indicator_width5  1
#property indicator_color5  clrDodgerBlue
#property indicator_label5  "Transition"

//---------------------------------------------------
// INPUTS
//---------------------------------------------------

input int FastTRIX = 24;
input int SlowTRIX = 42;
input int SmoothMA = 4;

//---------------------------------------------------
// BUFFERS
//---------------------------------------------------

double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];

//---------------------------------------------------
// HANDLES
//---------------------------------------------------

int TriX_handle      = INVALID_HANDLE;
int TriX_handle2     = INVALID_HANDLE;
int MA_handle        = INVALID_HANDLE;

//---------------------------------------------------
// ARRAYS
//---------------------------------------------------

double TriX[];
double TriX2[];
double MA[];

//+------------------------------------------------------------------+
//| Custom indicator initialization                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Buffers
   SetIndexBuffer(0, Buffer1, INDICATOR_DATA);
   SetIndexBuffer(1, Buffer2, INDICATOR_DATA);
   SetIndexBuffer(2, Buffer3, INDICATOR_DATA);
   SetIndexBuffer(3, Buffer4, INDICATOR_DATA);
   SetIndexBuffer(4, Buffer5, INDICATOR_DATA);

   //--- Empty values
   for(int i = 0; i < 5; i++)
   {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   }

   //--- Minimum bars check
   if(Bars(_Symbol, _Period) < 100)
   {
      Print("Not enough bars.");
      return(INIT_FAILED);
   }

   //--- Fast TRIX
   TriX_handle = iTriX(_Symbol, PERIOD_CURRENT, FastTRIX, PRICE_CLOSE);

   if(TriX_handle == INVALID_HANDLE)
   {
      Print("Failed to create Fast TRIX.");
      return(INIT_FAILED);
   }

   //--- MA of TRIX
   MA_handle = iMA(_Symbol,
                   PERIOD_CURRENT,
                   SmoothMA,
                   0,
                   MODE_LWMA,
                   TriX_handle);

   if(MA_handle == INVALID_HANDLE)
   {
      Print("Failed to create MA.");
      return(INIT_FAILED);
   }

   //--- Slow TRIX
   TriX_handle2 = iTriX(_Symbol, PERIOD_CURRENT, SlowTRIX, PRICE_CLOSE);

   if(TriX_handle2 == INVALID_HANDLE)
   {
      Print("Failed to create Slow TRIX.");
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator calculation                                     |
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
   //--- Safety check
   if(rates_total < 100)
      return(0);

   //--- Calculate limit
   int limit;

   if(prev_calculated == 0)
   {
      limit = rates_total - 1;

      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
      ArrayInitialize(Buffer3, EMPTY_VALUE);
      ArrayInitialize(Buffer4, EMPTY_VALUE);
      ArrayInitialize(Buffer5, EMPTY_VALUE);
   }
   else
   {
      limit = rates_total - prev_calculated + 1;
   }

   //--- Check handles
   if(BarsCalculated(TriX_handle) <= 0)
      return(prev_calculated);

   if(BarsCalculated(MA_handle) <= 0)
      return(prev_calculated);

   if(BarsCalculated(TriX_handle2) <= 0)
      return(prev_calculated);

   //--- Copy buffers
   if(CopyBuffer(TriX_handle, 0, 0, rates_total, TriX) <= 0)
      return(prev_calculated);

   if(CopyBuffer(MA_handle, 0, 0, rates_total, MA) <= 0)
      return(prev_calculated);

   if(CopyBuffer(TriX_handle2, 0, 0, rates_total, TriX2) <= 0)
      return(prev_calculated);

   //--- Arrays as series
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(Buffer4, true);
   ArraySetAsSeries(Buffer5, true);

   ArraySetAsSeries(TriX, true);
   ArraySetAsSeries(MA, true);
   ArraySetAsSeries(TriX2, true);

   //--- Main loop
   for(int i = MathMin(limit, rates_total - 3); i >= 0; i--)
   {
      Buffer1[i] = EMPTY_VALUE;
      Buffer2[i] = EMPTY_VALUE;
      Buffer3[i] = EMPTY_VALUE;
      Buffer4[i] = EMPTY_VALUE;
      Buffer5[i] = EMPTY_VALUE;

      //--- Strong bullish momentum
      if(TriX[i + 1] >= MA[i + 1] &&
         TriX[i + 1] > TriX2[i + 1])
      {
         Buffer1[i] = TriX[i];
      }

      //--- Weak momentum
      if(TriX[i + 1] <= MA[i + 1])
      {
         Buffer2[i] = TriX[i];
      }

      //--- Bearish trend
      if(TriX2[i + 1] <= TriX[i + 1])
      {
         Buffer3[i] = TriX2[i];
      }

      //--- Long bullish structure
      if(TriX2[i + 1] >= TriX[i + 1])
      {
         Buffer4[i] = TriX2[i];
      }

      //--- Transition phase
      if(TriX[i + 1] < TriX2[i + 1])
      {
         Buffer5[i] = TriX[i];
      }
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Release resources                                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(TriX_handle != INVALID_HANDLE)
      IndicatorRelease(TriX_handle);

   if(MA_handle != INVALID_HANDLE)
      IndicatorRelease(MA_handle);

   if(TriX_handle2 != INVALID_HANDLE)
      IndicatorRelease(TriX_handle2);
}