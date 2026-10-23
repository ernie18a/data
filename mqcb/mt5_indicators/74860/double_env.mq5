//+------------------------------------------------------------------+
//|                                      DualEnvelopeIndependent.mq5 |
//|                                          Amarnath Kondiyan Mohan |
//+------------------------------------------------------------------+
#property copyright "Amarnath Kondiyan Mohan"
#property version   "2.60"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

input int                InpEnv1Period  = 14;
input ENUM_MA_METHOD     InpEnv1Method  = MODE_SMA;
input ENUM_APPLIED_PRICE InpEnv1Price   = PRICE_CLOSE;
input double             InpEnv1Dev     = 0.1;

input int                InpEnv2Period  = 21;
input ENUM_MA_METHOD     InpEnv2Method  = MODE_EMA;
input ENUM_APPLIED_PRICE InpEnv2Price   = PRICE_CLOSE;
input double             InpEnv2Dev     = 0.25;

input bool               InpAllowMultiple = false;
input color              InpTargetColor   = clrMediumSeaGreen;
input color              InpSLColor       = clrCrimson;
input int                InpBandLength    = 5;
input double             InpBaseLot       = 0.1;
input double             InpMartingale    = 2.0;

//--- Globals
struct SimTrade { int type; double entry, tp, sl, lot; void Set(int t, double e, double p, double s, double l) { type=t; entry=e; tp=p; sl=s; lot=l; } };
int            h1, h2, active_count = 0;
double         pip_size, current_lot, BuyBuf[], SellBuf[], u1[], l1[], u2[], l2[];
SimTrade       trades[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
// 1. INPUT SANITIZATION (CRITICAL FOR MARKET VALIDATOR)
   int p1 = (InpEnv1Period < 2) ? 14 : InpEnv1Period;
   int p2 = (InpEnv2Period < 2) ? 21 : InpEnv2Period;

// Force ENUMs to valid ranges
   ENUM_MA_METHOD m1 = (InpEnv1Method < 0 || InpEnv1Method > 3) ? MODE_SMA : InpEnv1Method;
   ENUM_MA_METHOD m2 = (InpEnv2Method < 0 || InpEnv2Method > 3) ? MODE_EMA : InpEnv2Method;

   ENUM_APPLIED_PRICE pr1 = (InpEnv1Price < 0 || InpEnv1Price > 6) ? PRICE_CLOSE : InpEnv1Price;
   ENUM_APPLIED_PRICE pr2 = (InpEnv2Price < 0 || InpEnv2Price > 6) ? PRICE_CLOSE : InpEnv2Price;

   IndicatorRelease(h1);
   IndicatorRelease(h2);

   h1 = iEnvelopes(_Symbol, _Period, p1, 0, m1, pr1, InpEnv1Dev);
   h2 = iEnvelopes(_Symbol, _Period, p2, 0, m2, pr2, InpEnv2Dev);

   if(h1 == INVALID_HANDLE || h2 == INVALID_HANDLE)
      return(INIT_FAILED);

   SetIndexBuffer(0, BuyBuf, INDICATOR_DATA);
   SetIndexBuffer(1, SellBuf, INDICATOR_DATA);
   pip_size = (_Digits == 3 || _Digits == 5) ? _Point * 10 : _Point;
   current_lot = InpBaseLot;
   ArrayResize(trades, 500);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates, const int prev, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick[], const long &vol[], const int &spr[])
  {
// Handle potential handle loss during execution
   if(h1 == INVALID_HANDLE || h2 == INVALID_HANDLE)
      return(0);

   int start = MathMax(prev - 1, InpEnv1Period);

   if(CopyBuffer(h1, 0, 0, rates, u1) <= 0)
      return(0);
   CopyBuffer(h1, 1, 0, rates, l1);
   CopyBuffer(h2, 0, 0, rates, u2);
   CopyBuffer(h2, 1, 0, rates, l2);

   for(int i = start; i < rates - 1; i++)
     {
      if(u1[i] == EMPTY_VALUE || u1[i-1] == EMPTY_VALUE)
         continue;

      for(int t = active_count - 1; t >= 0; t--)
        {
         bool hit = false;
         if(trades[t].type == 1 && (low[i] <= trades[t].sl || high[i] >= trades[t].tp))
           {
            current_lot = (low[i] <= trades[t].sl) ? current_lot * InpMartingale : InpBaseLot;
            hit = true;
           }
         else
            if(trades[t].type == -1 && (high[i] >= trades[t].sl || low[i] <= trades[t].tp))
              {
               current_lot = (high[i] >= trades[t].sl) ? current_lot * InpMartingale : InpBaseLot;
               hit = true;
              }
         if(hit)
           {
            trades[t] = trades[active_count-1];
            active_count--;
           }
        }

      bool b = (close[i] > u1[i] && close[i-1] <= u1[i-1]);
      bool s = (close[i] < l1[i] && close[i-1] >= l1[i-1]);

      if(!InpAllowMultiple)
        {
         for(int t=0; t<active_count; t++)
           {
            if(trades[t].type==1)
               b=false;
            if(trades[t].type==-1)
               s=false;
           }
        }

      if(b || s)
        {
         if(active_count >= ArraySize(trades))
            ArrayResize(trades, active_count + 10);
         if(b)
           {
            BuyBuf[i]=low[i]-10*_Point;
            trades[active_count].Set(1, close[i], u2[i], l1[i-1], current_lot);
           }
         else
           {
            SellBuf[i]=high[i]+10*_Point;
            trades[active_count].Set(-1, close[i], l2[i], u1[i-1], current_lot);
           }
         active_count++;
        }
     }
   return(rates);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) { IndicatorRelease(h1); IndicatorRelease(h2); ObjectsDeleteAll(0, "EnvBO_"); }
//+------------------------------------------------------------------+
