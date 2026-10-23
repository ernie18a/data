//+------------------------------------------------------------------+
//|                                        Brooky_Trend_Strength.mq5 |
//|                              Original MQL4 code credit to Brooky |
//|                               http://forex-indicators.weebly.com |
//+------------------------------------------------------------------+
#property copyright "© 2023, Ryan Lawrence Johnson"
#property link      "https://www.mql5.com/en/users/rjo/seller"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots 6

#property indicator_level1 0

#property indicator_width1 1
#property indicator_color1 clrBlue

#property indicator_color2 clrBlue
#property indicator_width2 2

#property indicator_color3 clrCrimson
#property indicator_width3 2

#property indicator_color4 clrGray
#property indicator_width4 2

#property indicator_color5 clrDodgerBlue
#property indicator_width5 2

#property indicator_color6 clrPink
#property indicator_width6 2

#property indicator_style7 DRAW_NONE
#property indicator_style8 DRAW_NONE
#property indicator_style9 DRAW_NONE

//---- input parameters
sinput string     Calculation_Periods = "Amount of Bars used to Calculate";
input int         slow_period = 26;
input int         fast_period = 12;
input int         signal_period = 9;
input ENUM_MA_METHOD slow_period_method = MODE_EMA;
input ENUM_MA_METHOD fast_period_method = MODE_EMA;
input ENUM_MA_METHOD signal_period_method = MODE_SMA;
input ENUM_APPLIED_PRICE Price_Constant = PRICE_CLOSE;
input string      Sensitivity = "Control Strength Sensitivity";
input double      min_move = 1;
input int         hi_lo_bars_back = 5;

int handle_ma_now;
int handle_iatr;
int handle_istddev;
int copyBars;
int limit;
int bar;

//---- buffers
double slow_array[];
double up_hist[];
double dn_hist[];
double tup_hist[];
double tdn_hist[];
double sig_array[];

double move_array[];
double ma_now[];
double iatr[];
double istddev[];

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle_ma_now != INVALID_HANDLE) IndicatorRelease(handle_ma_now);
   if(handle_istddev != INVALID_HANDLE) IndicatorRelease(handle_istddev);
   if(handle_iatr != INVALID_HANDLE) IndicatorRelease(handle_iatr);      
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  { 
//---- indicator buffers mapping
   SetIndexBuffer(0, slow_array,INDICATOR_DATA);
   SetIndexBuffer(1, up_hist, INDICATOR_DATA);
	SetIndexBuffer(2, dn_hist, INDICATOR_DATA);
	SetIndexBuffer(3, sig_array, INDICATOR_DATA);
	SetIndexBuffer(4, tup_hist, INDICATOR_DATA);
	SetIndexBuffer(5, tdn_hist, INDICATOR_DATA);
	
	SetIndexBuffer(6, move_array, INDICATOR_CALCULATIONS);
	SetIndexBuffer(7, ma_now, INDICATOR_CALCULATIONS);
	SetIndexBuffer(8, iatr, INDICATOR_CALCULATIONS);
	SetIndexBuffer(9, istddev, INDICATOR_CALCULATIONS);
	
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
	PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
	PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
	PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
	PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
	
	PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
	PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
	PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID);
	PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_SOLID);
	PlotIndexSetInteger(4, PLOT_LINE_STYLE, STYLE_SOLID);
	PlotIndexSetInteger(5, PLOT_LINE_STYLE, STYLE_SOLID);			
	
  	handle_ma_now = iCustom(NULL, 0, "Custom_Moving_Average_sep_win", fast_period, 0, fast_period_method, Price_Constant);
   handle_istddev = iCustom(NULL, 0, "StdDev_sep_win", slow_period, 0, slow_period_method, Price_Constant);	
   handle_iatr = iCustom(NULL, 0, "ATR_sep_win", slow_period, Price_Constant);	

//---- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME, "Brooky Trend Strength " + "Period (" +(string)slow_period+")");   
//----
   return(INIT_SUCCEEDED);
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
//----
   //if(IsStopped() == true)
	 //return(0);

   //---	check that we have enough bars available to calculate
   if (prev_calculated < 0 ||rates_total < slow_period - 1)
    return(0);

   //--- set indexation as timeseries
	ArraySetAsSeries(slow_array, true);
	ArraySetAsSeries(up_hist, true);	
	ArraySetAsSeries(dn_hist, true);
	ArraySetAsSeries(tup_hist, true);
	ArraySetAsSeries(tdn_hist, true);			
	ArraySetAsSeries(sig_array, true);
	ArraySetAsSeries(move_array, true);
	
	ArraySetAsSeries(ma_now, true);
	ArraySetAsSeries(istddev, true);
	ArraySetAsSeries(iatr, true);  
   
   //--- calculation of the starting bar index
   if (prev_calculated == 0) // check for the first call of OnCalculate function
    {                      
       limit = rates_total - slow_period - 1;  // starting index for the calculation of all of the bars
       copyBars = rates_total - slow_period - 1;
    }
   else
    {
     limit = rates_total - prev_calculated; // starting index for the calculation of new bars
     copyBars = rates_total - prev_calculated;
    }
   
   //if(IsStopped() == true)
    //return(0);
   
	if(CopyBuffer(handle_ma_now, 0, 0, copyBars, ma_now) <= 0
	   || CopyBuffer(handle_istddev, 0, 0, copyBars, istddev) <= 0	   
	   || CopyBuffer(handle_iatr, 0, 0, copyBars, iatr) <= 0)   
	    return(-1);     
   
   //--- main loop
   for(bar = limit; bar >= 0; bar--)
    {
     //--sensitivity--+
     move_array[bar] = MathAbs((((iHighest(NULL, 0, MODE_HIGH, hi_lo_bars_back, bar)
     							- iLowest(NULL, 0, MODE_LOW, hi_lo_bars_back, bar))) * _Point) * 100000);    							
	  //--power--+		
     slow_array[bar] = istddev[bar] - iatr[bar];
     //--drawing--+
     if(ma_now[bar] >= ma_now[bar+1] && move_array[bar] >= min_move)
      {
       up_hist[bar] = slow_array[bar];
      }
     if(ma_now[bar] <= ma_now[bar+1] && move_array[bar] >= min_move)
      {
       dn_hist[bar] = slow_array[bar];      
      }
     if(ma_now[bar] <= ma_now[bar+1] && move_array[bar] <= min_move)
      {
       tup_hist[bar] = slow_array[bar];  
      }
     if(ma_now[bar] >= ma_now[bar+1] && move_array[bar] <= min_move)
      {
       tdn_hist[bar] = slow_array[bar];
      }  
    }
   //--power smooth--+
   for(bar = limit; bar >= 0; bar--)
    {
     sig_array[bar] = iMAOnArray(slow_array, signal_period, 0, signal_period_method, bar);
    }

//---- return value of prev_calculated for next call
   return(rates_total-1);
  }

//+------------------------------------------------------------------+
//| Custom iMAOnArray function                                       |
//+------------------------------------------------------------------+
double iMAOnArray(double& array[], int period, int ma_shift, ENUM_MA_METHOD ma_method, int shift){

   double buf[], arr[];
   int total = ArraySize(array);   

   if(total <= period)
      return 0;      

   if(shift > total - period - ma_shift)
      return 0;     

   switch(ma_method) {

   case MODE_SMA: {

      total = ArrayCopy(arr, array, 0, shift + ma_shift, period);
      if (ArrayResize(buf, total) < 0)
         return 0;

      double sum = 0;
      int i, pos = total-1;      

      for (i = 1; i < period; i++, pos--)

         sum += arr[pos];

      while (pos >= 0) {

         sum += arr[pos];

         buf[pos] = sum / period;

         sum -= arr[pos + period - 1];

         pos--;

      }

      return buf[0];

   }

      

   case MODE_EMA: {

      if (ArrayResize(buf, total) < 0)

         return 0;

      double pr = 2.0 / (period + 1);

      int pos = total - 2;

      

      while (pos >= 0) {

         if (pos == total - 2)

            buf[pos+1] = array[pos+1];

         buf[pos] = array[pos] * pr + buf[pos+1] * (1-pr);

         pos--;

      }

      return buf[shift+ma_shift];

   }

   

   case MODE_SMMA: {

      if (ArrayResize (buf, total) < 0)

         return(0);

      double sum = 0;

      int i, k, pos;

      

      pos = total - period;

      while (pos >= 0) {

         if (pos == total - period) {

            for (i = 0, k = pos; i < period; i++, k++) {

               sum += array[k];

               buf[k] = 0;

            }

         }

         else

            sum = buf[pos+1] * (period-1) + array[pos];

         buf[pos]=sum/period;

         pos--;

      }

      return buf[shift+ma_shift];

   }

   

   case MODE_LWMA: {

         if (ArrayResize (buf, total) < 0)

            return 0;

         double sum = 0.0, lsum = 0.0;

         double price;

         int i, weight = 0, pos = total-1;

         

         for(i = 1; i <= period; i++, pos--) {

            price = array[pos];

            sum += price * i;

            lsum += price;

            weight += i;

         }

         pos++;

         i = pos + period;

         while (pos >= 0) {

            buf[pos] = sum / weight;

            if (pos == 0)

               break;

            pos--;

            i--;

            price = array[pos];

            sum = sum - lsum + price * period;

            lsum -= array[i];

            lsum += price;

         }         

         return buf[shift+ma_shift];

      }

   }

   return 0;

}

//+------------------------------------------------------------------+
