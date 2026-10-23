//+------------------------------------------------------------------+
//|                                                RSD_Histogram.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "RSD_Histogram"
#property strict

#include <MovingAverages.mqh>

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 10
#property  indicator_color1 clrNONE
#property  indicator_color2 clrGreen
#property  indicator_color3 clrLime
#property  indicator_color4 clrRed
#property  indicator_color5 clrTomato
#property  indicator_color6 clrBlack
#property  indicator_color7 clrRed
#property  indicator_color8 clrNONE
#property  indicator_color9 clrNONE
#property  indicator_color10 clrBlack
#property  indicator_width2  2
#property  indicator_width3  2
#property  indicator_width4  2
#property  indicator_width5  2
//--- indicator parameters
input int RSIPeriod=14;   // RSI Period
input int SMAPeriod=13;   // SMA Period on RSI
input int SignalEMA=9;  // EMA Period on RSD

input int PhaseBars = 5;
input double Diff0 = 10.0; // RSD / Histogram Difference (Dot + Alert)
input double Diff1 = 10.0; // RSD / Signal Difference (Dot + Alert)
input double Diff2 = 10; // RSD / Equilibrium Difference (Alert)
input double Diff3 = 10; // Histogram / Equilibrium Difference (Alert)

input bool Alert0En = true; // Alert RSD / Signal Cross
input bool Alert1En = true; // Alert RSD Zero Level Cross
input bool Alert2En = true; // Alert Histogram Phase 
input bool Alert3En = true; // Alert Signal Zero Level Cross
input bool Alert4En = true; // Alert RSD / Histogram Difference
input bool Alert5En = true; // Alert RSD / Signal Difference
input bool Alert6En = true; // Alert RSD / Equilibrium Difference
input bool Alert7En = true; // Alert Histogram / Equilibrium Difference


input bool send_alert = true; // Send Divergence Alert
input bool send_notification = true;// Send Divergence Notification
input bool bearish_normal = true; //Bearish Classic Divergence
input bool bullish_normal = true; //Bullish Classic Divergence
input bool bearish_hidden = true; //Bearish Hidden Divergence
input bool bullish_hidden = true; //Bullish Hidden Divergence
enum diver_mode_enum {ClosePrice, HighLowPrice};
input diver_mode_enum divergence_price_mode = HighLowPrice; //Divergency applied price
enum diver_mode_buffer_enum {RSD, HISTOGRAM};
input diver_mode_buffer_enum diver_mode_buffer = RSD;//Divergency applied buffer
input int sensitivity = 2; //Sensitivity
input int offset = 2; //Pivots offset
input int distance = 4; //Pivots distance
input int _div_count_check = 300; //Candles back

//--- indicator buffers
double ExtRSDHistogramBuffer[];
double HH[];
double HL[];
double LL[];
double LH[];  
double ExtRSDBuffer[];
double ExtSignalBuffer[];
double ExtRSIBuffer[];
double ExtRSIBuffer2[];
double DotBuffer[];

datetime AlertType[] = {0, 0, 0, 0, 0, 0, 0, 0};
string IndicatorName = "";
double Level = 0;

//--- right input parameters flag
bool      ExtParameters=false;
//---
string Prefix = "draw_";
int indi_window = -1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorDigits(Digits+1);
//--- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexStyle(7,DRAW_NONE);
   SetIndexStyle(8,DRAW_NONE);
   SetIndexStyle(9,DRAW_ARROW);
//---- indicator buffers
   SetIndexDrawBegin(1,SignalEMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRSDHistogramBuffer);
   SetIndexBuffer(1,HH);
   SetIndexBuffer(2,HL);
   SetIndexBuffer(3,LL);
   SetIndexBuffer(4,LH);
   SetIndexBuffer(5,ExtRSDBuffer);
   SetIndexBuffer(6,ExtSignalBuffer);
   SetIndexBuffer(7,ExtRSIBuffer);
   SetIndexBuffer(8,ExtRSIBuffer2);
   SetIndexBuffer(9,DotBuffer);
//--- name for DataWindow and indicator subwindow label
   IndicatorName = "RSD("+IntegerToString(RSIPeriod)+","+IntegerToString(SMAPeriod)+","+IntegerToString(SignalEMA)+")";
   IndicatorShortName(IndicatorName);
      indi_window = ChartWindowFind(0, IndicatorName);
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,"RSDHistogram_HH");
   SetIndexLabel(2,"RSDHistogram_HL");
   SetIndexLabel(3,"RSDHistogram_LL");
   SetIndexLabel(4,"RSDHistogram_LH");
   SetIndexLabel(5,"RSD");
   SetIndexLabel(6,"Signal");
   SetIndexLabel(7,NULL);
   SetIndexLabel(8,NULL);
   SetIndexArrow(9,117);
//--- check for input parameters
   if(RSIPeriod<=1 || SMAPeriod<=1 || SignalEMA<=1)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done
   return(INIT_SUCCEEDED);
  }
  
  void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, Prefix);
  }

//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
  {
   int i,limit;
//---
   if(rates_total<=SignalEMA || !ExtParameters)
      return(0);

   limit=rates_total-prev_calculated;

   if(prev_calculated>0)
      limit++;

   // RSI BUffer
   for(i=0; i<limit; i++)
      ExtRSIBuffer[i]=iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,i);

   // SMA on RSI
   SimpleMAOnBuffer(rates_total,prev_calculated,0,SMAPeriod,ExtRSIBuffer,ExtRSIBuffer2);

   // RSD Buffer
   for(i=0; i<limit; i++)
      ExtRSDBuffer[i]=ExtRSIBuffer[i]-ExtRSIBuffer2[i];

   // EMA on RSD
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,SignalEMA,ExtRSDBuffer,ExtSignalBuffer);

   // Histogram Buffer
   for(i=0; i<limit; i++)
      ExtRSDHistogramBuffer[i]=ExtRSDBuffer[i]-ExtSignalBuffer[i];
      
   if(limit==rates_total)
      limit--;

   // Histogram Buffer Colors
   for(i=0; i<limit; i++)
   {
      if(ExtRSDHistogramBuffer[i]>0 && ExtRSDHistogramBuffer[i]>ExtRSDHistogramBuffer[i+1])
      {
         HH[i]=ExtRSDHistogramBuffer[i];
         HL[i]=EMPTY_VALUE;
         LL[i]=EMPTY_VALUE;
         LH[i]=EMPTY_VALUE;
      }
      else if(ExtRSDHistogramBuffer[i]>0)
      {
         HH[i]=EMPTY_VALUE;
         HL[i]=ExtRSDHistogramBuffer[i];
         LL[i]=EMPTY_VALUE;
         LH[i]=EMPTY_VALUE;
      }
      else if(ExtRSDHistogramBuffer[i]<0 && ExtRSDHistogramBuffer[i]<ExtRSDHistogramBuffer[i+1])
      {
         HH[i]=EMPTY_VALUE;
         HL[i]=EMPTY_VALUE;
         LL[i]=ExtRSDHistogramBuffer[i];
         LH[i]=EMPTY_VALUE;
      }
      else if(ExtRSDHistogramBuffer[i]<0)
      {
         HH[i]=EMPTY_VALUE;
         HL[i]=EMPTY_VALUE;
         LL[i]=EMPTY_VALUE;
         LH[i]=ExtRSDHistogramBuffer[i];
      }
      else;
   }

   if(limit == rates_total)
      limit -= 2;

   // Dot Buffer
   for(i=0; i<limit; i++)
   {
      if(ExtRSDBuffer[i] > ExtRSDHistogramBuffer[i] + Diff0)
         DotBuffer[i] = 0;
      else if(ExtRSDBuffer[i] < ExtRSDHistogramBuffer[i] - Diff0)
         DotBuffer[i] = 0;
      else if(ExtRSDBuffer[i] > ExtSignalBuffer[i] + Diff1)
         DotBuffer[i] = 0;
      else if(ExtRSDBuffer[i] < ExtSignalBuffer[i] - Diff1)
         DotBuffer[i] = 0;
      else
         DotBuffer[i] = EMPTY_VALUE;
   }

   // Equilibrium Level
   double EQLevel = (ChartGetDouble(0, CHART_PRICE_MAX, WindowFind(IndicatorName)) + ChartGetDouble(0, CHART_PRICE_MIN, WindowFind(IndicatorName))) / 2;

   if(Level != EQLevel)
   {
      SetLevelValue(0, EQLevel);

      if(EQLevel > 0 && Level <= 0)
         Alert("Equilibrium-Level Above Zero Line -> " + DoubleToString(EQLevel, 3));
      else if(EQLevel < 0 && Level >= 0)
         Alert("Equilibrium-Level Below Zero Line -> " + DoubleToString(EQLevel, 3));
      else;

      Level = EQLevel;
   }

   // Alert Type-0
   if(Alert0En && ExtRSDHistogramBuffer[1] > 0 && ExtRSDHistogramBuffer[2] <= 0 && Time[0] != AlertType[0])
   {
      Alert(Symbol(), "->Histogram Cross Above Zero Level");
      AlertType[0] = Time[0];
   }
   else if(Alert0En && ExtRSDHistogramBuffer[1] < 0 && ExtRSDHistogramBuffer[2] >= 0 && Time[0] != AlertType[0])
   {
      Alert(Symbol(), "->Histogram Cross Below Zero Level");
      AlertType[0] = Time[0];
   }
   else;

   // Alert Type-1
   if(Alert1En && ExtRSDBuffer[1] > 0 && ExtRSDBuffer[2] <= 0 && Time[0] != AlertType[1])
   {
      Alert(Symbol(), "->RSD Cross Above Zero Level");
      AlertType[1] = Time[0];
   }
   else if(Alert1En && ExtRSDBuffer[1] < 0 && ExtRSDBuffer[2] >= 0 && Time[0] != AlertType[1])
   {
      Alert(Symbol(), "->RSD Cross Below Zero Level");
      AlertType[1] = Time[0];
   }
   else;

   // Alert Type-2
   if(Alert2En && CheckBullish() && ExtRSDHistogramBuffer[1] < 0 && Time[0] != AlertType[2])
   {
      Alert(Symbol(), "->Histogram Bullish Phase Broken");
      AlertType[2] = Time[0];
   }
   else if(Alert2En && CheckBearish() && ExtRSDHistogramBuffer[1] > 0 && Time[0] != AlertType[2])
   {
      Alert(Symbol(), "->Histogram Bearish Phase Broken");
      AlertType[2] = Time[0];
   }
   else;

   // Alert Type-3
   if(Alert3En && ExtSignalBuffer[1] > 0 && ExtSignalBuffer[2] <= 0 && Time[0] != AlertType[3])
   {
      Alert(Symbol(), "->Signal Cross Above Zero Level");
      AlertType[3] = Time[0];
   }
   else if(Alert3En && ExtSignalBuffer[1] < 0 && ExtSignalBuffer[2] >= 0 && Time[0] != AlertType[3])
   {
      Alert(Symbol(), "->Signal Cross Below Zero Level");
      AlertType[3] = Time[0];
   }
   else;

   // Alert Type-4
   bool Alert4_0 = ExtRSDBuffer[1] > ExtRSDHistogramBuffer[1] + Diff0;
   bool Alert4_0_Prev = ExtRSDBuffer[2] > ExtRSDHistogramBuffer[2] + Diff0;
   bool Alert4_1 = ExtRSDBuffer[1] < ExtRSDHistogramBuffer[1] - Diff0;
   bool Alert4_1_Prev = ExtRSDBuffer[2] < ExtRSDHistogramBuffer[2] - Diff0;

   if(Alert4En && Alert4_0 && !Alert4_0_Prev && Time[0] != AlertType[4])
   {
      Alert(Symbol(), "->RSD Above Histogram (by Point)");
      AlertType[4] = Time[0];
   }
   else if(Alert4En && Alert4_1 && !Alert4_1_Prev && Time[0] != AlertType[4])
   {
      Alert(Symbol(), "->RSD Below Histogram (by Point)");
      AlertType[4] = Time[0];
   }
   else;

   // Alert Type-5
   bool Alert5_0 = ExtRSDBuffer[1] > ExtSignalBuffer[1] + Diff1;
   bool Alert5_0_Prev = ExtRSDBuffer[2] > ExtSignalBuffer[2] + Diff1;
   bool Alert5_1 = ExtRSDBuffer[1] < ExtSignalBuffer[1] - Diff1;
   bool Alert5_1_Prev = ExtRSDBuffer[2] < ExtSignalBuffer[2] - Diff1;

   if(Alert5En && Alert5_0 && !Alert5_0_Prev && Time[0] != AlertType[5])
   {
      Alert(Symbol(), "->RSD Above Signal (by Point)");
      AlertType[5] = Time[0];
   }
   else if(Alert5En && Alert5_1 && !Alert5_1_Prev && Time[0] != AlertType[5])
   {
      Alert(Symbol(), "->RSD Below Signal (by Point)");
      AlertType[5] = Time[0];
   }
   else;

   // Alert Type-6
   bool Alert6_0 = ExtRSDBuffer[1] > EQLevel + Diff2;
   bool Alert6_0_Prev = ExtRSDBuffer[2] > EQLevel + Diff2;
   bool Alert6_1 = ExtRSDBuffer[1] < EQLevel - Diff2;
   bool Alert6_1_Prev = ExtRSDBuffer[2] < EQLevel - Diff2;

   if(Alert6En && Alert6_0 && !Alert6_0_Prev && Time[0] != AlertType[6])
   {
      Alert(Symbol(), "->RSD Above Signal (by Point)");
      AlertType[6] = Time[0];
   }
   else if(Alert6En && Alert6_1 && !Alert6_1_Prev && Time[0] != AlertType[6])
   {
      Alert(Symbol(), "->RSD Below Signal (by Point)");
      AlertType[6] = Time[0];
   }
   else;

   // Alert Type-7
   bool Alert7_0 = ExtRSDHistogramBuffer[1] > EQLevel + Diff3;
   bool Alert7_0_Prev = ExtRSDHistogramBuffer[2] > EQLevel + Diff3;
   bool Alert7_1 = ExtRSDHistogramBuffer[1] < EQLevel - Diff3;
   bool Alert7_1_Prev = ExtRSDHistogramBuffer[2] < EQLevel - Diff3;

   if(Alert7En && Alert7_0 && !Alert7_0_Prev && Time[0] != AlertType[7])
   {
      Alert(Symbol(), "->RSD Above Signal (by Point)");
      AlertType[7] = Time[0];
   }
   else if(Alert7En && Alert7_1 && !Alert7_1_Prev && Time[0] != AlertType[7])
   {
      Alert(Symbol(), "->RSD Below Signal (by Point)");
      AlertType[7] = Time[0];
   }
   else;

// -----------------
//--- Divergency RSD
// -----------------

   double price_arr_high[], price_arr_low[], indi_arr_high[], indi_arr_low[];

   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   if(divergence_price_mode == ClosePrice)
     {
      ArrayCopy(price_arr_high, close, 0, 0, _div_count_check);
      ArrayCopy(price_arr_low, close, 0, 0, _div_count_check);
     }
   else
     {
      ArrayCopy(price_arr_high, high, 0, 0, _div_count_check);
      ArrayCopy(price_arr_low, low, 0, 0, _div_count_check);
     }

   if(diver_mode_buffer==RSD)
     {
      ArrayCopy(indi_arr_high, ExtRSDBuffer, 0, 0, _div_count_check);
      ArrayCopy(indi_arr_low, ExtRSDBuffer, 0, 0, _div_count_check);
     }
   else
     {
      ArrayCopy(indi_arr_high, ExtRSDHistogramBuffer, 0, 0, _div_count_check);
      ArrayCopy(indi_arr_low, ExtRSDHistogramBuffer, 0, 0, _div_count_check);
     }

   if(rates_total>prev_calculated)
     {
      divergence_struct res[];
      static int last_lines_count = 0;

      if(bearish_normal)
        {
         find_diver(res, price_arr_high, price_arr_low, indi_arr_high, indi_arr_low, "bearish_regular", offset, distance, sensitivity);
         for(int i2 = 0; i2 < ArraySize(res); i2++)
           {
            divergence_struct _diver = res[i2];
            draw_line(_diver.arr1_1_idx, price_arr_high[ _diver.arr1_1_idx],  _diver.arr1_2_idx, price_arr_high[_diver.arr1_2_idx], clrRed, 0);
            draw_line(_diver.arr2_1_idx, indi_arr_high[ _diver.arr2_1_idx],  _diver.arr2_2_idx, indi_arr_high[_diver.arr2_2_idx], clrRed, indi_window);
           }
        }


      if(bullish_normal)
        {
         find_diver(res, price_arr_high, price_arr_low, indi_arr_high, indi_arr_low, "bullish_regular", offset, distance, sensitivity);
         for(int i2 = 0; i2 < ArraySize(res); i2++)
           {
            divergence_struct _diver = res[i2];
            draw_line(_diver.arr1_1_idx, price_arr_low[ _diver.arr1_1_idx],  _diver.arr1_2_idx, price_arr_low[_diver.arr1_2_idx], clrGreen, 0);
            draw_line(_diver.arr2_1_idx, indi_arr_low[ _diver.arr2_1_idx],  _diver.arr2_2_idx, indi_arr_low[_diver.arr2_2_idx], clrGreen, indi_window);
           }
        }


      if(bearish_hidden)
        {
         find_diver(res, price_arr_high, price_arr_low, indi_arr_high, indi_arr_low, "bearish_hidden", offset, distance, sensitivity);
         for(int i2 = 0; i2 < ArraySize(res); i2++)
           {
            divergence_struct _diver = res[i2];
            draw_line(_diver.arr1_1_idx, price_arr_high[ _diver.arr1_1_idx],  _diver.arr1_2_idx, price_arr_high[_diver.arr1_2_idx], clrRed, 0);
            draw_line(_diver.arr2_1_idx, indi_arr_high[ _diver.arr2_1_idx],  _diver.arr2_2_idx, indi_arr_high[_diver.arr2_2_idx], clrRed, indi_window);
           }
        }


      if(bullish_hidden)
        {
         find_diver(res, price_arr_high, price_arr_low, indi_arr_high, indi_arr_low, "bullish_hidden", offset, distance, sensitivity);
         for(int i2 = 0; i2 < ArraySize(res); i2++)
           {
            divergence_struct _diver = res[i2];
            draw_line(_diver.arr1_1_idx, price_arr_low[ _diver.arr1_1_idx],  _diver.arr1_2_idx, price_arr_low[_diver.arr1_2_idx], clrGreen, 0);
            draw_line(_diver.arr2_1_idx, indi_arr_low[ _diver.arr2_1_idx],  _diver.arr2_2_idx, indi_arr_low[_diver.arr2_2_idx], clrGreen, indi_window);
           }
        }

         if(lines_count() != last_lines_count)
           {
            string msg = "Divergency found in " + _Symbol + " " + (string)_Period + " TimeFrame";
            if(send_alert)
               Alert(msg);
            if(send_notification)
               SendNotification(msg);
            last_lines_count = lines_count();
           }
     }

//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+

bool CheckBullish()
{
   bool Result = true;
   
   for(int i = 2; i < 2 + PhaseBars; i++)
      if(ExtRSDHistogramBuffer[i] < 0)
      {
         Result = false;
         break;
      }

   return Result;
}

bool CheckBearish()
{
   bool Result = true;
   
   for(int i = 2; i < 2 + PhaseBars; i++)
      if(ExtRSDHistogramBuffer[i] > 0)
      {
         Result = false;
         break;
      }

   return Result;
}


//+------------------------------------------------------------------+
//| Find Divergence                                                                  |
//+------------------------------------------------------------------+
struct divergence_struct
  {
   int               arr1_1_idx;
   int               arr1_2_idx;
   int               arr2_1_idx;
   int               arr2_2_idx;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void find_diver(divergence_struct &res[], double &arr1_high[], double &arr1_low[], double &arr2_high[], double &arr2_low[], string _mode, int pivot_offset = 3, int pivots_distance = 5, int before_after = 4)
  {
// arr1 ie price
   ArrayFree(res);
   int arr1_pivots[], arr2_pivots[], _arr_tmp[];
   double arr_data1[], arr_data2[];
   if(_mode == "bearish_regular" || _mode == "bearish_hidden")
     {
      get_low_high(arr1_pivots, arr1_high, "high", before_after);
      get_low_high(arr2_pivots, arr2_high, "high", before_after);
      ArrayCopy(arr_data1, arr1_high);
      ArrayCopy(arr_data2, arr2_high);
     }

   if(_mode == "bullish_regular" || _mode == "bullish_hidden")
     {
      get_low_high(arr1_pivots, arr1_low, "low", before_after);
      get_low_high(arr2_pivots, arr2_low, "low", before_after);
      ArrayCopy(arr_data1, arr1_low);
      ArrayCopy(arr_data2, arr2_low);
     }

// Filtering by offset
   int arr1_offset[], arr2_offset[];
   for(int i = 0; i < ArraySize(arr1_pivots); i++)
     {
      int arr1_idx = arr1_pivots[i];
      for(int i2 = 0; i2 < ArraySize(arr2_pivots); i2++)
        {
         int arr2_idx = arr2_pivots[i2];
         if(MathAbs(arr1_idx - arr2_idx) <= pivot_offset)
           {
            ArrayResize(arr1_offset, ArraySize(arr1_offset) + 1);
            arr1_offset[ArraySize(arr1_offset) - 1] = arr1_idx;
            ArrayResize(arr2_offset, ArraySize(arr2_offset) + 1);
            arr2_offset[ArraySize(arr2_offset) - 1] = arr2_idx;
           }
        }
     }

// iterating all combinations
   divergence_struct diver_found[];
   for(int i = 0; i < ArraySize(arr1_offset) - 1; i++)
     {
      for(int i2 = i + 1; i2 < ArraySize(arr1_offset); i2++)
        {
         int arr1_first_idx = arr1_offset[i2];
         int arr1_second_idx = arr1_offset[i];

         int arr2_first_idx = arr2_offset[i2];
         int arr2_second_idx = arr2_offset[i];

         if(MathAbs(arr1_first_idx - arr1_second_idx) <= pivots_distance)
            continue;

         double arr1_first_price = arr_data1[arr1_first_idx];
         double arr1_second_price = arr_data1[arr1_second_idx];

         double arr2_first_price = arr_data2[arr2_first_idx];
         double arr2_second_price = arr_data2[arr2_second_idx];

         bool _found = false;
         if(_mode == "bearish_regular")
            if(arr1_second_price >= arr1_first_price && arr2_second_price < arr2_first_price)
               _found = true;

         if(_mode == "bearish_hidden")
            if(arr1_second_price < arr1_first_price && arr2_second_price > arr2_first_price)
               _found = true;

         if(_mode == "bullish_regular")
            if(arr1_second_price <= arr1_first_price && arr2_second_price > arr2_first_price)
               _found = true;

         if(_mode == "bullish_hidden")
            if(arr1_second_price > arr1_first_price && arr2_second_price < arr2_first_price)
               _found = true;

         if(!_found)
            continue;

         // Filter price cuts
         for(int i3 = arr1_first_idx - 1; i3 > arr1_second_idx; i3--)
           {
            double real1_y = check_location_trendline(arr1_first_idx, arr1_first_price, arr1_second_idx, arr1_second_price, i3);
            double real2_y = check_location_trendline(arr2_first_idx, arr2_first_price, arr2_second_idx, arr2_second_price, i3);

            if(_mode == "bearish_regular" || _mode == "bearish_hidden")
               if(arr_data1[i3] > real1_y || arr_data2[i3] > real2_y)
                 {
                  _found = false;
                  break;
                 }

            if(_mode == "bullish_regular" || _mode == "bullish_hidden")
               if(arr_data1[i3] < real1_y || arr_data2[i3] < real2_y)
                 {
                  _found = false;
                  break;
                 }
           }

         if(!_found)
            continue;

         divergence_struct _divergence;
         _divergence.arr1_1_idx = arr1_first_idx;
         _divergence.arr1_2_idx = arr1_second_idx;
         _divergence.arr2_1_idx = arr2_first_idx;
         _divergence.arr2_2_idx = arr2_second_idx;
         ArrayResize(diver_found, ArraySize(diver_found) + 1);
         diver_found[ArraySize(diver_found) - 1] = _divergence;

        }
     }

   ArrayCopy(res, diver_found);
   return;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_low_high(int &res[], double &data_list[], string mode, int candle_before_after = 2)
  {
// ***** Do not pass SERIES
   for(int i = candle_before_after; i < ArraySize(data_list) - candle_before_after; i++)
     {
      double curr_candle = data_list[i];

      bool _valid = true;
      for(int i2 = i - candle_before_after; i2 <= i + candle_before_after; i2++)
        {
         double sequence_price = data_list[i2]; // curr included

         if(i2 == i)
            continue;

         if(
            (sequence_price >= curr_candle && mode == "high") ||
            (sequence_price <= curr_candle && mode == "low")
         )
           {
            _valid = false;
            break;
           }
        }

      if(_valid)
        {
         ArrayResize(res, ArraySize(res) + 1);
         res[ArraySize(res) - 1] = i;
        }

     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double check_location_trendline(int idx1, double val1, int idx2, double val2, int idx_check)
  {
   int x1 = idx1;
   double y1 = val1;

   int x2 = idx2;
   double y2 = val2;

   if(x2 == x1)
      return 0;

   double m = (y2 - y1) / (x2 - x1);
   double real_y = m * (idx_check - x1) + y1;

   return real_y ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw_line(int idx1, double price1, int idx2, double price2, color _color, int indicator_window = 0)
  {
   string _myname = Prefix + (string)iTime(_Symbol, _Period, idx1) + (string)iTime(_Symbol, _Period, idx2) + (string)indicator_window;
   ObjectCreate(0, _myname, OBJ_TREND, indicator_window, 0, 0,  0, 0);
   ObjectSetInteger(0, _myname, OBJPROP_TIME1, iTime(_Symbol, _Period, idx1));
   ObjectSetInteger(0, _myname, OBJPROP_TIME2, iTime(_Symbol, _Period, idx2));
   ObjectSetDouble(0, _myname, OBJPROP_PRICE1, price1);
   ObjectSetDouble(0, _myname, OBJPROP_PRICE2, price2);
   ObjectSetInteger(0, _myname, OBJPROP_COLOR, _color);
   ObjectSetInteger(0, _myname, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, _myname, OBJPROP_RAY_RIGHT, false);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int lines_count()
  {
   int i2 = 0;
   for(int i = 0; i < ObjectsTotal(); i++)
     {
      string _name = ObjectName(0, i);
      if(StringFind(_name, Prefix) != -1)
         i2++;
     }
   return i2;
  }
//+------------------------------------------------------------------+
