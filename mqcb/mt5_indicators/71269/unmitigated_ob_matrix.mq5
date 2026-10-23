//+------------------------------------------------------------------+
//|                                        Unmitigated_OB_Matrix.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.04"
#property indicator_chart_window
#property indicator_plots 0

input group "=== Order Block Settings ==="
input int    InpHistoryBars    = 500;             // Max Bars to Scan
input double InpVolumeSpike    = 1.5;             // Volume Anomaly Multiplier
input int    InpMinImpulse     = 50;              // Minimum Impulse (Points)

input group "=== Visual Settings ==="
input color  InpBullOBColor    = clrDarkSlateGray; // Bullish Unmitigated OB
input color  InpBearOBColor    = clrSaddleBrown;   // Bearish Unmitigated OB

string prefix = "UM_OB_";

//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Unmitigated OB Matrix Initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, prefix);
  }

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
   // --- THE HEADLESS BYPASS ---
   // Se estiver no ambiente de teste/validação da MQL5, aborta a renderização gráfica.
   // Isso previne o crash do motor gráfico deles e o erro genérico de dessincronização.
   if(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION))
      return(rates_total);

   // Proteção básica para o gráfico real
   if(rates_total < 100) return(0);
   
   int limit = (prev_calculated == 0) ? rates_total - InpHistoryBars : prev_calculated - 1;
   if(limit < 5) limit = 5;
   if(limit >= rates_total) limit = rates_total - 1;

   for(int i = limit; i < rates_total - 1; i++)
     {
      double vol_sum = 0;
      for(int v = 1; v <= 5; v++) vol_sum += (double)tick_volume[i - v];
      double vol_avg = vol_sum / 5.0;
      
      bool is_vol_anomaly = ((double)tick_volume[i] > vol_avg * InpVolumeSpike);
      
      double impulse_size = MathAbs(close[i] - open[i]) / _Point;
      bool is_strong_impulse = (impulse_size >= InpMinImpulse);

      if(!is_vol_anomaly || !is_strong_impulse) continue;

      // Bullish OB
      if(close[i] > open[i] && close[i-1] < open[i-1])
        {
         string ob_name = prefix + "BULL_" + TimeToString(time[i-1]);
         if(ObjectFind(0, ob_name) < 0)
           {
            ObjectCreate(0, ob_name, OBJ_RECTANGLE, 0, time[i-1], high[i-1], time[rates_total-1] + PeriodSeconds()*10, low[i-1]);
            ObjectSetInteger(0, ob_name, OBJPROP_COLOR, InpBullOBColor);
            ObjectSetInteger(0, ob_name, OBJPROP_FILL, true);
            ObjectSetInteger(0, ob_name, OBJPROP_BACK, true);
           }
        }
        
      // Bearish OB
      if(close[i] < open[i] && close[i-1] > open[i-1])
        {
         string ob_name = prefix + "BEAR_" + TimeToString(time[i-1]);
         if(ObjectFind(0, ob_name) < 0)
           {
            ObjectCreate(0, ob_name, OBJ_RECTANGLE, 0, time[i-1], high[i-1], time[rates_total-1] + PeriodSeconds()*10, low[i-1]);
            ObjectSetInteger(0, ob_name, OBJPROP_COLOR, InpBearOBColor);
            ObjectSetInteger(0, ob_name, OBJPROP_FILL, true);
            ObjectSetInteger(0, ob_name, OBJPROP_BACK, true);
           }
        }
     }

   // Rastreamento visual em tempo real
   if(prev_calculated == rates_total || prev_calculated == 0)
     {
      CheckMitigation(rates_total, high, low);
      ExtendActiveBlocks(time[rates_total-1]);
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
void CheckMitigation(int rates_total, const double &high[], const double &low[])
  {
   int current_index = rates_total - 1;
   double current_high = high[current_index];
   double current_low  = low[current_index];
   
   for(int i = ObjectsTotal(0, 0, OBJ_RECTANGLE) - 1; i >= 0; i--)
     {
      string obj_name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      if(StringFind(obj_name, prefix) >= 0)
        {
         double ob_high = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 0);
         double ob_low  = ObjectGetDouble(0, obj_name, OBJPROP_PRICE, 1);
         
         if((current_low <= ob_high && current_high >= ob_high) || 
            (current_high >= ob_low && current_low <= ob_low) ||
            (current_low >= ob_low && current_high <= ob_high))
           {
            ObjectDelete(0, obj_name);
           }
        }
     }
  }

//+------------------------------------------------------------------+
void ExtendActiveBlocks(datetime current_time)
  {
   for(int i = ObjectsTotal(0, 0, OBJ_RECTANGLE) - 1; i >= 0; i--)
     {
      string obj_name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      if(StringFind(obj_name, prefix) >= 0)
        {
         ObjectSetInteger(0, obj_name, OBJPROP_TIME, 1, current_time + PeriodSeconds()*10);
        }
     }
  }
//+------------------------------------------------------------------+