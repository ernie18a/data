//+------------------------------------------------------------------+
//|                                       UniformityFactorScript.mq5 |
//|                                    Copyright (c) 2026, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//+------------------------------------------------------------------+
#property copyright   "Copyright (c) 2026 Marketeer"
#property link        "https://www.mql5.com/en/users/marketeer"
#property description "Fast estimation of an exponent/power factor for transformation of variable-length price increments into uniform distribution, that makes them a \"random walk\"."
#property version     "1.0"

#property script_show_inputs

input int BarLimit = INT_MAX; // BarLimit (all chart bars, by default)

const int _bars = fmin(BarLimit, fmin(iBars(_Symbol, _Period), TerminalInfoInteger(TERMINAL_MAXBARS)));

void OnStart()
{
   double delta = 0;
   // straight loop through bars to calculate average range per bar
   for(int i = 1; i < _bars; i++)
   {
     delta += (iHigh(_Symbol, _Period, i) - iLow(_Symbol, _Period, i));
   }
   delta /= _Point;
   const int range = (int)(delta /= _bars);

   // now find out global range to estimate uniformity factor
   const int h = (iHighest(_Symbol, _Period, MODE_HIGH, _bars, 0));
   const int l = (iLowest(_Symbol, _Period, MODE_LOW, _bars, 0));
   const double high = (iHigh(_Symbol, _Period, h));
   const double low = (iLow(_Symbol, _Period, l));
   const double globalDelta = (high - low) / _Point;
   const double hintPowerFactor = MathLog(globalDelta / range) / MathLog(_bars);
   Print("Range=" + (string)range + " points/bar on " + (string)_bars + " bars [" + TimeToString(iTime(_Symbol, _Period, _bars - 1)) + "-" + TimeToString(iTime(_Symbol, _Period, 0)) + "]");
   Print("PowerFactor suggested: ", hintPowerFactor);
}
