//+------------------------------------------------------------------+
//|            Custom Moving Average                                 |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1


//--- Plot Settings
#property indicator_label1  "EMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2


//--- Buffer to store indicator values
double Buffer[];


//--- Input Parameters
input int                     MA_Period = 14;            // Period
input ENUM_APPLIED_PRICE      PriceType = PRICE_CLOSE;   // Source Price

//+------------------------------------------------------------------+
//| Indicator Initialization                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Configuring the buffer
   SetIndexBuffer(0, Buffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrDodgerBlue);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator Calculations                                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
// Check if there is enough data
   if(rates_total < MA_Period)
      return(0);

// Smooth Factor
   double k = 2.0 / (MA_Period + 1);

// Define calculation start point
   int start = prev_calculated;
   if(start == 0)
     {
      // Start first calculated value as SMA
      double sum = 0.0;
      for(int i = 0; i < MA_Period; i++)
         sum += AppliedPrice(i, open, high, low, close);

      Buffer[MA_Period-1] = sum / MA_Period;
      start = MA_Period;
     }

// EMA loop calculation
   for(int i = start; i < rates_total; i++)
     {
      double price = AppliedPrice(i, open, high, low, close);
      Buffer[i] = price * k + Buffer[i-1] * (1 - k);
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Support function to choose the applied price                     |
//+------------------------------------------------------------------+
double AppliedPrice(int index, const double &open[], const double &high[],
                    const double &low[], const double &close[])
  {
   switch(PriceType)
     {
      case PRICE_CLOSE:
         return(close[index]);
      case PRICE_OPEN:
         return(open[index]);
      case PRICE_HIGH:
         return(high[index]);
      case PRICE_LOW:
         return(low[index]);
      case PRICE_MEDIAN:
         return((high[index] + low[index]) / 2.0);
      case PRICE_TYPICAL:
         return((high[index] + low[index] + close[index]) / 3.0);
      case PRICE_WEIGHTED:
         return((high[index] + low[index] + close[index] + close[index]) / 4.0);
     }
   return(close[index]); // fallback
  }
//+------------------------------------------------------------------+
