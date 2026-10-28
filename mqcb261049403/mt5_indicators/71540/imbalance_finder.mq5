//+------------------------------------------------------------------+
//|                                             ImbalanceFinder.mq5  |
//|                                        Aurora Technologies, 2025 |
//|                                           https://aurora-tech.io |
//+------------------------------------------------------------------+
#property copyright "Aurora Technologies, 2025"
#property link      "https://aurora-tech.io"
#property version   "1.10"
#property description "Detects Fair Value Gaps (FVG / Imbalances) and tracks"
#property description "whether they have been tapped into or completely filled."

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 0

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input color InpClrImbalanceUp                = clrLime;       // Bullish Imbalance Color
input color InpClrImbalanceDown              = clrOrange;     // Bearish Imbalance Color
input bool  InpShowTappedOrFilled            = true;          // Show Tapped / Filled Imbalances
input color InpClrImbalanceUpTappedOrFilled  = clrDarkGreen;  // Tapped/Filled Bullish Color
input color InpClrImbalanceDownTappedOrFilled= clrRed;        // Tapped/Filled Bearish Color

//+------------------------------------------------------------------+
//| Indicator buffers                                                |
//+------------------------------------------------------------------+
double buf_imbalances_up[];                   // 0 = no imbalance, 1 = imbalance
double buf_imbalances_down[];                 // 0 = no imbalance, 1 = imbalance
double buf_imbalance_tapped[];                // 0 = not tapped,   1 = tapped
double buf_imbalance_tapped_until_price[];    // price level until which imbalance was tapped
double buf_imbalance_filled[];                // 0 = not filled,   1 = filled
double buf_candle_tapped_into_imbalance[];    // 0 = none, 1 = tapped, 2 = filled
double buf_candle_tapped_into_imbalance_type[];// 0 = none, 1 = bullish, 2 = bearish

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
string   m_prefix_up;
string   m_prefix_down;
string   m_symbol;
ENUM_TIMEFRAMES m_timeframe;
datetime m_current_candle;
long     m_chart_id;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   if(!SetIndexBuffer(0, buf_imbalances_up, INDICATOR_DATA)                      ||
      !SetIndexBuffer(1, buf_imbalances_down, INDICATOR_DATA)                    ||
      !SetIndexBuffer(2, buf_imbalance_tapped, INDICATOR_CALCULATIONS)           ||
      !SetIndexBuffer(3, buf_imbalance_tapped_until_price, INDICATOR_CALCULATIONS)||
      !SetIndexBuffer(4, buf_imbalance_filled, INDICATOR_CALCULATIONS)           ||
      !SetIndexBuffer(5, buf_candle_tapped_into_imbalance, INDICATOR_CALCULATIONS)||
      !SetIndexBuffer(6, buf_candle_tapped_into_imbalance_type, INDICATOR_CALCULATIONS))
     {
      return(INIT_FAILED);
     }

//--- initialize all buffers
   ArrayInitialize(buf_imbalances_up, EMPTY_VALUE);
   ArrayInitialize(buf_imbalances_down, EMPTY_VALUE);
   ArrayInitialize(buf_imbalance_tapped, EMPTY_VALUE);
   ArrayInitialize(buf_imbalance_tapped_until_price, EMPTY_VALUE);
   ArrayInitialize(buf_imbalance_filled, EMPTY_VALUE);
   ArrayInitialize(buf_candle_tapped_into_imbalance, EMPTY_VALUE);
   ArrayInitialize(buf_candle_tapped_into_imbalance_type, EMPTY_VALUE);

//--- set object name prefixes
   m_prefix_up   = "ImbalanceUp-";
   m_prefix_down = "ImbalanceDn-";

//--- cache symbol and timeframe
   m_symbol         = _Symbol;
   m_timeframe      = PERIOD_CURRENT;
   m_current_candle = iTime(m_symbol, m_timeframe, 1);
   m_chart_id       = ChartID();

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete only objects created by this indicator
   ObjectsDeleteAll(m_chart_id, m_prefix_up);
   ObjectsDeleteAll(m_chart_id, m_prefix_down);
   ChartRedraw();
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
//--- detect new bar
   datetime current_candle = iTime(m_symbol, m_timeframe, 0);

   if(m_current_candle != current_candle)
     {
      m_current_candle = current_candle;
      CalcImbalances(rates_total, prev_calculated, time, high, low);
     }

//--- check tapped/filled status
   if(prev_calculated > 0)
      CheckTappedLive(rates_total, time, high, low);
   else
      CheckTappedHistory(rates_total, prev_calculated, time, high, low);

//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Detect imbalances on closed bars                                 |
//+------------------------------------------------------------------+
void CalcImbalances(const int rates_total,
                    const int prev_calculated,
                    const datetime &time[],
                    const double &high[],
                    const double &low[])
  {
   int start = 0;

   if(prev_calculated > 0)
      start = rates_total - 2;

   for(int i = start; i < rates_total - 1; i++)
     {
      if(i < 2)
         continue;

      //--- check for bullish imbalance (FVG up)
      if(low[i] > high[i - 2])
        {
         buf_imbalances_up[i - 1] = 1;
         DrawImbalance(i - 1, low[i], high[i - 2], time, InpClrImbalanceUp, true);
        }
      else
        {
         buf_imbalances_up[i - 1] = EMPTY_VALUE;
        }

      //--- check for bearish imbalance (FVG down)
      if(low[i - 2] > high[i])
        {
         buf_imbalances_down[i - 1] = 1;
         DrawImbalance(i - 1, low[i - 2], high[i], time, InpClrImbalanceDown, false);
        }
      else
        {
         buf_imbalances_down[i - 1] = EMPTY_VALUE;
        }
     }
  }

//+------------------------------------------------------------------+
//| Check live bar against all open imbalances                       |
//+------------------------------------------------------------------+
void CheckTappedLive(const int rates_total,
                     const datetime &time[],
                     const double &high[],
                     const double &low[])
  {
   int index = rates_total - 1;

   for(int i = 1; i < rates_total - 2; i++)
     {
      //--- skip bars without imbalance or already filled
      if((buf_imbalances_up[i] == EMPTY_VALUE && buf_imbalances_down[i] == EMPTY_VALUE) ||
         buf_imbalance_filled[i] == 1)
         continue;

      //--- bullish imbalance: price comes down into it
      if(buf_imbalances_up[i] != EMPTY_VALUE)
        {
         //--- imbalance completely filled
         if(low[index] <= high[i - 1])
           {
            buf_imbalance_filled[i] = 1;
            buf_candle_tapped_into_imbalance[index]      = 2;
            buf_candle_tapped_into_imbalance_type[index]  = 1;

            UpdateImbalanceDrawing(i, low[i + 1], high[i - 1], time,
                                  InpClrImbalanceUpTappedOrFilled, true);
            //--- do not break; continue checking remaining imbalances
            continue;
           }

         //--- imbalance partially tapped
         if((buf_imbalance_tapped[i] != 1 && low[index] < low[i + 1] && low[index] > high[i - 1]) ||
            (buf_imbalance_tapped[i] == 1 && low[index] < buf_imbalance_tapped_until_price[i] && low[index] > high[i - 1]))
           {
            buf_imbalance_tapped[i] = 1;
            buf_imbalance_tapped_until_price[i]          = low[index];
            buf_candle_tapped_into_imbalance[index]      = 1;
            buf_candle_tapped_into_imbalance_type[index]  = 1;

            UpdateImbalanceDrawing(i, low[i + 1], high[i - 1], time,
                                  InpClrImbalanceUpTappedOrFilled, true);
           }
        }

      //--- bearish imbalance: price comes up into it
      if(buf_imbalances_down[i] != EMPTY_VALUE)
        {
         //--- imbalance completely filled
         if(high[index] >= low[i - 1])
           {
            buf_imbalance_filled[i] = 1;
            buf_candle_tapped_into_imbalance[index]      = 2;
            buf_candle_tapped_into_imbalance_type[index]  = 2;

            UpdateImbalanceDrawing(i, low[i - 1], high[i + 1], time,
                                  InpClrImbalanceDownTappedOrFilled, false);
            //--- do not break; continue checking remaining imbalances
            continue;
           }

         //--- imbalance partially tapped
         if((buf_imbalance_tapped[i] != 1 && high[index] > high[i + 1] && high[index] < low[i - 1]) ||
            (buf_imbalance_tapped[i] == 1 && high[index] > buf_imbalance_tapped_until_price[i] && high[index] < low[i - 1]))
           {
            buf_imbalance_tapped[i] = 1;
            buf_imbalance_tapped_until_price[i]          = high[index];
            buf_candle_tapped_into_imbalance[index]      = 1;
            buf_candle_tapped_into_imbalance_type[index]  = 2;

            UpdateImbalanceDrawing(i, low[i - 1], high[i + 1], time,
                                  InpClrImbalanceDownTappedOrFilled, false);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Check historical data for tapped/filled imbalances               |
//+------------------------------------------------------------------+
void CheckTappedHistory(const int rates_total,
                        const int prev_calculated,
                        const datetime &time[],
                        const double &high[],
                        const double &low[])
  {
   for(int i = 1; i < rates_total - 1; i++)
     {
      //--- skip bars without imbalance or already filled
      if((buf_imbalances_up[i] == EMPTY_VALUE && buf_imbalances_down[i] == EMPTY_VALUE) ||
         buf_imbalance_filled[i] == 1)
         continue;

      for(int x = i + 2; x < rates_total; x++)
        {
         //--- bullish imbalance: price comes down
         if(buf_imbalances_up[i] != EMPTY_VALUE)
           {
            //--- filled
            if(low[x] <= high[i - 1])
              {
               buf_imbalance_filled[i] = 1;
               buf_candle_tapped_into_imbalance[x]      = 2;
               buf_candle_tapped_into_imbalance_type[x]  = 1;

               UpdateImbalanceDrawing(i, low[i + 1], high[i - 1], time,
                                     InpClrImbalanceUpTappedOrFilled, true);
               break;
              }

            //--- tapped
            if((buf_imbalance_tapped[i] != 1 && low[x] < low[i + 1] && low[x] > high[i - 1]) ||
               (buf_imbalance_tapped[i] == 1 && low[x] < buf_imbalance_tapped_until_price[i] && low[x] > high[i - 1]))
              {
               buf_imbalance_tapped[i] = 1;
               buf_imbalance_tapped_until_price[i]      = low[x];
               buf_candle_tapped_into_imbalance[x]      = 1;
               buf_candle_tapped_into_imbalance_type[x]  = 1;

               UpdateImbalanceDrawing(i, low[i + 1], high[i - 1], time,
                                     InpClrImbalanceUpTappedOrFilled, true);
              }
           }

         //--- bearish imbalance: price comes up
         if(buf_imbalances_down[i] != EMPTY_VALUE)
           {
            //--- filled
            if(high[x] >= low[i - 1])
              {
               buf_imbalance_filled[i] = 1;
               buf_candle_tapped_into_imbalance[x]      = 2;
               buf_candle_tapped_into_imbalance_type[x]  = 2;

               UpdateImbalanceDrawing(i, low[i - 1], high[i + 1], time,
                                     InpClrImbalanceDownTappedOrFilled, false);
               break;
              }

            //--- tapped
            if((buf_imbalance_tapped[i] != 1 && high[x] > high[i + 1] && high[x] < low[i - 1]) ||
               (buf_imbalance_tapped[i] == 1 && high[x] > buf_imbalance_tapped_until_price[i] && high[x] < low[i - 1]))
              {
               buf_imbalance_tapped[i] = 1;
               buf_imbalance_tapped_until_price[i]      = high[x];
               buf_candle_tapped_into_imbalance[x]      = 1;
               buf_candle_tapped_into_imbalance_type[x]  = 2;

               UpdateImbalanceDrawing(i, low[i - 1], high[i + 1], time,
                                     InpClrImbalanceDownTappedOrFilled, false);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Draw an imbalance rectangle on the chart                         |
//+------------------------------------------------------------------+
void DrawImbalance(int index,
                   double price_up,
                   double price_dn,
                   const datetime &time[],
                   color clr,
                   bool is_up)
  {
   string obj_name = (is_up ? m_prefix_up : m_prefix_down) + (string)index;

   ObjectDelete(m_chart_id, obj_name);

   ObjectCreate(m_chart_id, obj_name, OBJ_RECTANGLE, 0,
                time[index + 1], price_up,
                time[index - 1], price_dn);
   ObjectSetInteger(m_chart_id, obj_name, OBJPROP_FILL, true);
   ObjectSetInteger(m_chart_id, obj_name, OBJPROP_BACK, true);
   ObjectSetInteger(m_chart_id, obj_name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Update imbalance drawing when tapped or filled                   |
//+------------------------------------------------------------------+
void UpdateImbalanceDrawing(int index,
                            double price_up,
                            double price_dn,
                            const datetime &time[],
                            color clr,
                            bool is_up)
  {
//--- do nothing if user disabled tapped/filled visuals
   if(!InpShowTappedOrFilled)
      return;

   string obj_name = (is_up ? m_prefix_up : m_prefix_down) + (string)index;
   string obj_name_tapped = obj_name + "-tapped";
   string obj_name_filled = obj_name + "-filled";

//--- imbalance partially tapped (not yet filled)
   if(buf_imbalance_filled[index] != 1 && buf_imbalance_tapped[index] == 1)
     {
      ObjectDelete(m_chart_id, obj_name_tapped);

      double tapped_price = buf_imbalance_tapped_until_price[index];
      double rect_top     = (is_up ? price_up : tapped_price);
      double rect_bottom  = (is_up ? tapped_price : price_dn);

      ObjectCreate(m_chart_id, obj_name_tapped, OBJ_RECTANGLE, 0,
                   time[index + 1], rect_top,
                   time[index - 1], rect_bottom);
      ObjectSetInteger(m_chart_id, obj_name_tapped, OBJPROP_FILL, true);
      ObjectSetInteger(m_chart_id, obj_name_tapped, OBJPROP_BACK, true);
      ObjectSetInteger(m_chart_id, obj_name_tapped, OBJPROP_COLOR, clr);
     }
//--- imbalance completely filled
   else if(buf_imbalance_filled[index] == 1)
     {
      ObjectDelete(m_chart_id, obj_name);
      ObjectDelete(m_chart_id, obj_name_tapped);

      ObjectCreate(m_chart_id, obj_name_filled, OBJ_RECTANGLE, 0,
                   time[index + 1], price_up,
                   time[index - 1], price_dn);
      ObjectSetInteger(m_chart_id, obj_name_filled, OBJPROP_FILL, true);
      ObjectSetInteger(m_chart_id, obj_name_filled, OBJPROP_BACK, true);
      ObjectSetInteger(m_chart_id, obj_name_filled, OBJPROP_COLOR, clr);
     }
  }
//+------------------------------------------------------------------+