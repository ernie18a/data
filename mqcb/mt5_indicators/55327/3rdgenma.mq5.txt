//+------------------------------------------------------------------+
//|                                                     3rdGenMA.mq4 |
//|                                    Copyright © 2025 Wolfforex.com|
//|                                        https://www.wolfforex.com |
//+------------------------------------------------------------------+
#property copyright "www.Wolfforex.com, 2025"
#property version   "1.01"
#property strict

#property description "3rd Generation MA based on research paper by Dr. Manfred"
#property description "Offers least possible lag but still provides price smoothing."

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 1
#property indicator_color1 clrRed
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

// Indicator parameters.
input int MA_Period = 50; 
input int MA_Sampling_Period = 220; // MA_Sampling_Period (should be more than 4 * MA_Period)
input ENUM_MA_METHOD MA_Method = MODE_EMA;
input ENUM_APPLIED_PRICE MA_Applied_Price = PRICE_TYPICAL;

// Indicator buffers.
double MA3G[];
double MA1[];
double MA2[];

// Global variables.
double Lambda, Alpha;
int handle;
bool FirstRun = true;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   string short_name;

   if (MA_Sampling_Period < MA_Period * 4)
   {
      Print("MA_Sampling_Period should be >= MA_Period * 4.");
      return(INIT_FAILED);
   }

   SetIndexBuffer(0, MA3G, INDICATOR_DATA);
   SetIndexBuffer(1, MA1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, MA2, INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(MA3G, true);
   ArraySetAsSeries(MA1, true);
   ArraySetAsSeries(MA2, true);
   
   switch(MA_Method)
   {
      case MODE_EMA:
         short_name = "3GEMA(";  
         break;
      case MODE_SMMA:
         short_name = "3GSMMA(";
         break;
      case MODE_LWMA:
         short_name = "3GLWMA(";
         break;
      default:
         short_name = "3GSMA(";
   }

   IndicatorSetString(INDICATOR_SHORTNAME, short_name + IntegerToString(MA_Period) + "," + IntegerToString(MA_Sampling_Period) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   handle = iMA(NULL, 0, MA_Sampling_Period, 0, MA_Method, MA_Applied_Price);
   if (handle == INVALID_HANDLE)
   {
      Print("Failed to initialize Moving Average.");
      return(INIT_FAILED);
   }

   Lambda = 1.0 * MA_Sampling_Period / (1.0 * MA_Period);
   Alpha = Lambda * (MA_Sampling_Period - 1) / (MA_Sampling_Period - Lambda);

   Print("Lambda = ", Lambda, "; Alpha = ", Alpha);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| 3rd Generation Moving Average Custom Indicator                   |
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
   int i, ExtCountedBars;
   int TotalPeriod = MA_Period + MA_Sampling_Period;
   
   if (rates_total <= TotalPeriod)
   {
      Print("Not enough bars.");
      return(0);
   }

   if (FirstRun) ExtCountedBars = 0;
   else
   {
      ExtCountedBars = prev_calculated;
      if (ExtCountedBars < 0) return(-1);
      if (rates_total - ExtCountedBars < TotalPeriod) ExtCountedBars = rates_total - TotalPeriod;
   }

   // +2 to use in iMAOnArrayMQL4()
   // + MA_Period because we need that amount more to calculate the components of the resulting indicator
   int MABars = rates_total - ExtCountedBars + MA_Period + 2;
   if (MABars > rates_total) MABars = rates_total;
   if (CopyBuffer(handle, 0, 0, MABars, MA1) != MABars) return(0);
   
   int MAonMABars = rates_total - ExtCountedBars + MA_Period;
   if (MAonMABars > rates_total) MAonMABars = rates_total;
   iMAOnArrayMQL4(MA1, MAonMABars, MA_Period, MA_Method, MA2);
   
   for (i = rates_total - ExtCountedBars - 1; i >= 0; i--)
      MA3G[i] = (Alpha + 1) * MA1[i] - Alpha * MA2[i];

   FirstRun = false;
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Based on https://www.mql5.com/en/articles/81.                    |
//+------------------------------------------------------------------+
void iMAOnArrayMQL4(double &array[], // Input array.
                      int total,		 // Number of input array values to use.
                      int period,	 // Period of the MA.
                      int ma_method, // Method of the MA.
                      double &buf[]) // Output array.
{
   double arr[];
   
   // If no number of input array values given, use the whole array.
   if (total == 0) total = ArraySize(array);
   // If the period is greater than the input array size to use, stop.
   if (total <= period) return;
   
   switch(ma_method)
   {
		case MODE_SMA:
		{
			total = ArrayCopy(arr, array, 0, 0, period);
			// Try to resize the output array to the required size.
			if (ArrayResize(buf, total) < 0) return;
			
			double sum = 0;
			int    i, pos = total - 1;
			
			for (i = 1; i < period; i++, pos--)	sum += arr[pos];
			
			while (pos >= 0)
			{
				sum += arr[pos];
				buf[pos] = sum / period;
				sum -= arr[pos + period - 1];
				pos--;
			}
			return;
		}
		case MODE_EMA:
		{
			// Try to resize the output array to the required size.
			if (ArrayResize(buf, total) < 0) return;
			double pr = 2.0 / (period + 1);
			int    pos = total - 2;
			while (pos >= 0)
			{
				// As buf might already hold previously calculated values, 
				// overwriting the starting cell with input value is only correct when the respective buf value is empty.
				if ((pos == total - 2) && (buf[pos + 1] == EMPTY_VALUE)) buf[pos + 1] = array[pos + 1];
				buf[pos] = array[pos] * pr + buf[pos + 1] * (1 - pr);
				pos--;
			}
			return;
		}
		case MODE_SMMA:
		{
			// Try to resize the output array to the required size.
			if (ArrayResize(buf, total) < 0) return;
			double sum = 0;
			int    i, k, pos;
			pos = total - period;
			while (pos >= 0)
			{
				if (pos == total - period)
				{
					for (i = 0, k = pos; i < period; i++, k++)
					{
						sum += array[k];
						buf[k] = 0;
					}
				}
				else sum = buf[pos + 1] * (period - 1) + array[pos];
				buf[pos] = sum / period;
				pos--;
			}
			return;
		}
		case MODE_LWMA:
		{
			// Try to resize the output array to the required size.
			if (ArrayResize(buf, total) < 0) return;
			double sum = 0, lsum = 0;
			double price;
			int    i, weight = 0, pos = total - 1;
			for (i = 1; i <= period; i++, pos--)
			{
				price = array[pos];
				sum += price * i;
				lsum += price;
				weight += i;
			}
			pos++;
			i = pos + period;
			while (pos >= 0)
			{
				buf[pos] = sum / weight;
				if (pos == 0) break;
				pos--;
				i--;
				price = array[pos];
				sum = sum - lsum + price * period;
				lsum -= array[i];
				lsum += price;
			}
			return;
		}
		default:
		return;
	}
}
//+------------------------------------------------------------------+