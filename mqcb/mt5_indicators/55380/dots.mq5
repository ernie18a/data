//+------------------------------------------------------------------+
//|Based on NonLagDOT.mq4 by TrendLaboratory                         |
//+------------------------------------------------------------------+

#property version   "1.02"
#property strict

#property description "Uses price curve angle calculations to come up with simple price indication."
#property description "Simple strategy: enter when 2 dots of same color appear; exit, when different color dot appears."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrRoyalBlue, clrRed
#property indicator_width1  2
#property indicator_style1  STYLE_SOLID

//---- input parameters
input int    Length       = 10;
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;
input int    Filter       = 0;
input double Deviation    = 0;
input int    Shift        = 0;

//---- indicator buffers
double Buffer[];
double Color[];

double MAB[];

//---- global variables
double Cycle = 4;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   SetIndexBuffer(0, Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, Color, INDICATOR_COLOR_INDEX);
   
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   PlotIndexSetInteger(0, PLOT_SHIFT, Shift);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, int(Length * Cycle + Length));

   IndicatorSetString(INDICATOR_SHORTNAME, "Dots("+IntegerToString(Length)+")");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
}

//+------------------------------------------------------------------+
//| Dots                                                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickvolume[],
                const long &volume[],
                const int &spread[])
{
   int    i, shift, counted_bars = prev_calculated, limit, trend = 0, myMA;
   double alfa, beta, t, Sum, Weight, g, price, MABuffer_prev = 0, MABuffer = 0;

   double Coeff = 3 * M_PI;
   double Phase = Length - 1;
   int Len = int(Length * Cycle + Phase);
   
   if (counted_bars < 0) return(0);
   if (counted_bars > 0) limit = counted_bars - 1;
   else limit = Len - 1; 

   for (shift = limit; shift < rates_total; shift++) 
   {	
      Weight = 0; Sum = 0; t = 0;
       
      myMA = iMA(NULL, 0, 1, 0, MODE_SMA, AppliedPrice);
      if  (CopyBuffer(myMA, 0, rates_total - shift - 1, Len, MAB) != Len) return(0);
      
      for (i = Len - 1; i >= 0; i--)
	   {
         g = 1.0 / (Coeff * t + 1);   
         if (t <= 0.5 ) g = 1;
         beta = MathCos(M_PI * t);
         alfa = g * beta;
         price = MAB[i]; 
         Sum += alfa * price;
         Weight += alfa;
         if (t < 1) t += 1.0 / (Phase - 1); 
         else if (t < Len - 1) t += (2 * Cycle - 1) / (Cycle * Length - 1);
      }
      
      if (shift > 0) MABuffer_prev = Buffer[shift - 1];

      if (Weight > 0) MABuffer = (1.0 + Deviation / 100) * Sum / Weight;
   
      if (Filter > 0)
         if (MathAbs(MABuffer - MABuffer_prev) < Filter * _Point) MABuffer = MABuffer_prev;
      
      if (MABuffer - MABuffer_prev > Filter * _Point) trend = 1; 
      else if (MABuffer_prev - MABuffer > Filter * _Point) trend = -1; 

      if (trend != 0) Buffer[shift] = MABuffer;
      else if (shift > 0) Buffer[shift] = Buffer[shift - 1];
      
      if (trend > 0) Color[shift] = 0;
      else if (trend < 0) Color[shift] = 1;
      else if (shift > 0) Color[shift] = Color[shift - 1];
   }

	return(rates_total);	
}