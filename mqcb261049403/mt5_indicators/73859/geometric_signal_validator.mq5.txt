//+------------------------------------------------------------------+
//|                              Geometric Signal Validation Engine  |
//|                                           Copyright 2026, phade  |
//+------------------------------------------------------------------+
#property copyright "phade"
#property link      "https://forge.mql5.io"
#property description "Geometric Signal Validation Engine"
#property version   "6.02"

#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots 10

/*****  Main indicator  ***/
#property indicator_label1  "Low Candidate"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDarkSlateBlue
#property indicator_width1  1
#property indicator_label2  "High Candidate"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDarkSlateBlue
#property indicator_width2  1
#property indicator_label3  "Middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkSlateGray
#property indicator_width3  1
#property indicator_label4  "High Shifts"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_width4  1
#property indicator_label5  "Low Shifts"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSilver
#property indicator_width5  1

/*****  Geometric signal validation  ***/
#property indicator_label6  "ZigZag"
#property indicator_type6   DRAW_SECTION
#property indicator_color6  clrGray
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
#property indicator_label7  "TopPivot"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrGray
#property indicator_width7  2
#property indicator_label8  "BottomPivot"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrGray
#property indicator_width8  2
#property indicator_label9  "TopInvalidPivot"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrRed
#property indicator_width9  4
#property indicator_label10 "BottomInvalidPivot"
#property indicator_type10  DRAW_ARROW
#property indicator_color10 clrRed
#property indicator_width10 4

input int iPeriods = 18;  // Period of the extreme channel


double high_shifts[];
double low_shifts[];
double candidate_low[];
double candidate_high[];
double middle_band[];
double zz_buffer[];
double top_pivot_arrow[];
double bottom_pivot_arrow[];
double invalid_top_pivot_arrow[];
double invalid_bottom_pivot_arrow[];
double zz_state_buffer[];
double signal_buffer[];

enum ENUM_ZZ_STATE
{
   ZZ_IDLE = 0,
   ZZ_SEARCH_HIGH = 1,
   ZZ_SEARCH_LOW = 2
};

int    zz_state;
int    zz_last_index;
double zz_last_price;
bool   zz_last_was_high;


void GeometricSignalValidation(int i, const double &high[], const double &low[], const double &close[]);

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, candidate_low, INDICATOR_DATA);
   SetIndexBuffer(1, candidate_high, INDICATOR_DATA);
   SetIndexBuffer(2, middle_band, INDICATOR_DATA);
   SetIndexBuffer(3, high_shifts, INDICATOR_DATA);
   SetIndexBuffer(4, low_shifts, INDICATOR_DATA);
   SetIndexBuffer(5, zz_buffer, INDICATOR_DATA);
   SetIndexBuffer(6, top_pivot_arrow, INDICATOR_DATA);
   SetIndexBuffer(7, bottom_pivot_arrow, INDICATOR_DATA);
   SetIndexBuffer(8, invalid_top_pivot_arrow, INDICATOR_DATA);
   SetIndexBuffer(9, invalid_bottom_pivot_arrow, INDICATOR_DATA);
   
   // Map the two hidden structural calculation buffers
   SetIndexBuffer(10, zz_state_buffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(11, signal_buffer, INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(0, PLOT_ARROW, 217);
   PlotIndexSetInteger(1, PLOT_ARROW, 218);
   PlotIndexSetInteger(6, PLOT_ARROW, 238);
   PlotIndexSetInteger(7, PLOT_ARROW, 236);
   PlotIndexSetInteger(8, PLOT_ARROW, 251);
   PlotIndexSetInteger(9, PLOT_ARROW, 251);

   zz_state = ZZ_IDLE;
   zz_last_index = -1;
   zz_last_price = 0;
   zz_last_was_high = false;

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
   int channel_start;

   if(prev_calculated == 0)
     {
      channel_start = iPeriods;
      ArrayInitialize(candidate_low, EMPTY_VALUE);
      ArrayInitialize(candidate_high, EMPTY_VALUE);
      ArrayInitialize(high_shifts, EMPTY_VALUE);
      ArrayInitialize(low_shifts, EMPTY_VALUE);
      ArrayInitialize(middle_band, EMPTY_VALUE);
      ArrayInitialize(zz_buffer, EMPTY_VALUE);
      ArrayInitialize(top_pivot_arrow, EMPTY_VALUE);
      ArrayInitialize(bottom_pivot_arrow, EMPTY_VALUE);
      ArrayInitialize(invalid_top_pivot_arrow, EMPTY_VALUE);
      ArrayInitialize(invalid_bottom_pivot_arrow, EMPTY_VALUE);
      ArrayInitialize(zz_state_buffer, 0.0);
      ArrayInitialize(signal_buffer, 0.0);
      
      zz_state = ZZ_IDLE;
      zz_last_index = -1;
      zz_last_price = 0;
      zz_last_was_high = false;
     }
   else
     {
      channel_start = prev_calculated - 1;

      for(int j = channel_start - 1; j >= 0; j--)
        {
         if(zz_buffer[j] != EMPTY_VALUE)                              // find the last valid pivot index and price
           {
            zz_last_index = j;
            zz_last_price = zz_buffer[j];    
                                                                
            zz_state         = (int)zz_state_buffer[j];               // re-read background tracker state
            zz_last_was_high = (zz_state == ZZ_SEARCH_LOW);           // if last pivot was high, low search should be true, otherwise it's false
            break; 
           }
        }
     }

   for(int i = channel_start; i < rates_total; i++)
     {
      candidate_low[i]   = EMPTY_VALUE;
      candidate_high[i]  = EMPTY_VALUE;
      zz_buffer[i]       = EMPTY_VALUE;

      int max_idx = ArrayMaximum(high, i - iPeriods + 1, iPeriods);
      int min_idx = ArrayMinimum(low, i - iPeriods + 1, iPeriods);

      if(max_idx < 0 || min_idx < 0) continue;

      high_shifts[i] = high[max_idx];
      low_shifts[i]  = low[min_idx];
      middle_band[i] = (high_shifts[i] + low_shifts[i]) / 2.0;

      //if(max_idx == i) candidate_high[i] = high[i];                // local high
      //if(min_idx == i) candidate_low[i]  = low[i];                 // local low

      if(i>2){
         bool indSignalBuy  = low_shifts[i-1] > low_shifts[i-2];     // arbitrary buy signal to force the Geometric signal validator to work hard (for testing)
         bool indSignalSell = high_shifts[i-1] < high_shifts[i-2];   // arbitrary sell signal to force the Geometric signal validator to work hard (for testing)   
         
         if(indSignalBuy) candidate_high[i] = high[i];
         if(indSignalSell) candidate_low[i]  = low[i];
      }

      GeometricSignalValidation(i, high, low, close);
      
      zz_state_buffer[i] = (double)zz_state;                         // buffer to track what the state machine is currently parsing
     }

   int prev_zz_idx = -1;
   double prev_zz_price = 0;
   int j = channel_start - 1;

   while(j >= 0 && prev_zz_idx < 0)                                 // Move backwards to find the previous confirmed pivot index
     {
      if(zz_buffer[j] != EMPTY_VALUE)
        {
         prev_zz_idx   = j;
         prev_zz_price = zz_buffer[j];
        }
      j--;
     }

   for(int i = channel_start; i < rates_total; i++)
     {
      if(zz_buffer[i] == EMPTY_VALUE) continue;

      if(prev_zz_idx == -1)                                         // no prior pivot found at all
        {
         prev_zz_idx = i;                                           // move from this first index
         prev_zz_price = zz_buffer[i];
         continue;                                                  // wait for the next pivot to confirm it
        }

      if(zz_buffer[i] > prev_zz_price)                              // current leg value is higher than previous pivot
        {
         bottom_pivot_arrow[prev_zz_idx] = low_shifts[prev_zz_idx]; //  previous is a low (confirmed up arrow)
         top_pivot_arrow[prev_zz_idx]    = EMPTY_VALUE;             //  ensure a high pivot arrow doesn't paint on the same bar
         
         if(prev_calculated != 0) 
            signal_buffer[i] = (double)ZZ_SEARCH_HIGH;               // New confirmed bottom  -> in uptrend searching for high
        }
      else                                                           // current leg value is lower than previous pivot
        {
         top_pivot_arrow[prev_zz_idx]    = high_shifts[prev_zz_idx]; //  previous is a high (confirmed down arrow)
         bottom_pivot_arrow[prev_zz_idx] = EMPTY_VALUE;              //  ensure a low pivot arrow doesn't paint on the same bar
         
         if(prev_calculated != 0) 
            signal_buffer[i] = (double)ZZ_SEARCH_LOW;                // New confirmed top  -> in downtrend searching for low
        }
   
      //Print("State: ", signal_buffer[i]);
      prev_zz_idx   = i;
      prev_zz_price = zz_buffer[i];
     }

   return rates_total;
}


//+------------------------------------------------------------------+
//| Geometric Signal Validation                                      |
//+------------------------------------------------------------------+
void GeometricSignalValidation(int i, const double &high[], const double &low[], const double &close[])
{
   if(zz_state == ZZ_IDLE)
   {
      if(candidate_high[i] != EMPTY_VALUE)
      {
         zz_buffer[i] = high_shifts[i];
         zz_last_index = i;
         zz_last_price = high[i];
         zz_last_was_high = true;
         zz_state = ZZ_SEARCH_LOW;
      }
      else if(candidate_low[i] != EMPTY_VALUE)
      {
         zz_buffer[i] = low_shifts[i];
         zz_last_index = i;
         zz_last_price = low[i];
         zz_last_was_high = false;
         zz_state = ZZ_SEARCH_HIGH;
      }
      return;
   }
   if(zz_state == ZZ_SEARCH_HIGH)
   {
      if(candidate_high[i] != EMPTY_VALUE)
      {
         if(i > 1 && zz_last_index != -1 && close[i-1] < low[zz_last_index] && !zz_last_was_high)  // Geometric anomaly (last pivot was a bottom and the price moved below it)
         {
            zz_buffer[zz_last_index] = EMPTY_VALUE;                                                // Erase the geometrically invalid pivot
            invalid_top_pivot_arrow[i] = high_shifts[i];                                           // Draw the invalid pivot marker
            top_pivot_arrow[i]         = high_shifts[i];                                           // Draw the trapped signal arrow
            
            // update current leg
            zz_buffer[i]     = high_shifts[i];
            zz_last_index    = i;
            zz_last_price    = high[i];
            zz_last_was_high = true;
            zz_state         = ZZ_SEARCH_LOW;
         }
         else                                                                                      // record the valid high and change to low search
         {
            zz_buffer[i]     = high_shifts[i];
            zz_last_index    = i;
            zz_last_price    = high[i];
            zz_last_was_high = true;
            zz_state         = ZZ_SEARCH_LOW;
         }
      }
   }
   else if(zz_state == ZZ_SEARCH_LOW)
   {
      if(candidate_low[i] != EMPTY_VALUE)
      {
         if(i > 1 && zz_last_index != -1 && close[i-1] > high[zz_last_index] && zz_last_was_high)  // Geometric anomaly (last pivot was a top and the price moved above it)
         {
            zz_buffer[zz_last_index] = EMPTY_VALUE;                                                // Erase the geometrically invalid pivot
            invalid_bottom_pivot_arrow[i] = low_shifts[i];                                         // Draw the invalid pivot marker
            bottom_pivot_arrow[i]         = low_shifts[i];                                         // Draw the trapped signal arrow

            // update current leg
            zz_buffer[i]     = low_shifts[i];
            zz_last_index    = i;
            zz_last_price    = low[i];
            zz_last_was_high = false;
            zz_state         = ZZ_SEARCH_HIGH;
         }
         else                                                                                      // record the valid low and change to high search
         {
            zz_buffer[i]     = low_shifts[i];
            zz_last_index    = i;
            zz_last_price    = low[i];
            zz_last_was_high = false;
            zz_state         = ZZ_SEARCH_HIGH;
         }
      }
   }
}