//+------------------------------------------------------------------+
//|                                         MACDinsti.mq5            |
//|                                  Fernando Javier De Mendonça     |
//+------------------------------------------------------------------+
#property copyright "Fernando Javier De Mendonca"
#property link      "https://www.algomercados.com"
#property description "MACD Institutional is an advanced indicator designed for traders seeking to operate in sync with smart money. Unlike the standard MACD, which processes every tick or candle close without distinction, this indicator reconstructs the price structure using a dynamic volume filter before calculating its moving averages."
#property version   "1.52"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Filtered MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Signal Line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- Input parameters
input int      InpMAVolumePeriod = 20;   // Periodo Media Volumen
input int      InpBufferSize     = 500;  // N valores en el array (ventana de análisis)
input int      InpFastEMA        = 12;   // MACD Fast EMA
input int      InpSlowEMA        = 26;   // MACD Slow EMA
input int      InpSignalSMA      = 9;    // MACD Signal Period

//--- Buffers
double         BufferMACD[];
double         BufferSignal[];
double         FilteredCloses[]; 
int            CountFiltered = 0; 

//+------------------------------------------------------------------+
int OnInit()
{
   if(InpBufferSize < InpSlowEMA)
   {
      Print("Error: BufferSize debe ser mayor que InpSlowEMA.");
      return(INIT_PARAMETERS_INCORRECT);
   }

   SetIndexBuffer(0, BufferMACD, INDICATOR_DATA);
   SetIndexBuffer(1, BufferSignal, INDICATOR_DATA);
   
   ArrayResize(FilteredCloses, InpBufferSize);
   ArrayInitialize(FilteredCloses, 0.0);
   ArraySetAsSeries(FilteredCloses, true);
   
   IndicatorSetString(INDICATOR_SHORTNAME, "MACDinsti(N:" + (string)InpBufferSize + ")");
   return(INIT_SUCCEEDED);
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
   if(rates_total < InpMAVolumePeriod) return(0);

   int limit = (prev_calculated == 0) ? 0 : prev_calculated - 1;

   if(prev_calculated == 0) CountFiltered = 0;

   for(int i = limit; i < rates_total; i++)
   {
      double sumVol = 0;
      int start = (i - InpMAVolumePeriod + 1);
      if(start < 0) start = 0;
      
      for(int v = start; v <= i; v++) sumVol += (double)tick_volume[v];
      double avgVol = sumVol / InpMAVolumePeriod;

      if((double)tick_volume[i] > avgVol)
      {
         for(int n = InpBufferSize - 1; n > 0; n--)
            FilteredCloses[n] = FilteredCloses[n-1];
         
         FilteredCloses[0] = close[i];
         if(CountFiltered < InpBufferSize) CountFiltered++;
      }

      if(CountFiltered >= InpSlowEMA)
      {
         BufferMACD[i] = CalculateFilteredMACD();
         BufferSignal[i] = CalculateSignal(i);
      }
      else
      {
         BufferMACD[i] = EMPTY_VALUE;
         BufferSignal[i] = EMPTY_VALUE;
      }
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
double CalculateFilteredMACD()
{
   double fastEMA = CalculateEMA(InpFastEMA);
   double slowEMA = CalculateEMA(InpSlowEMA);
   return fastEMA - slowEMA;
}

double CalculateEMA(int period)
{
   if(CountFiltered < period) return 0.0;

   double k = 2.0 / (period + 1.0);
   double ema = FilteredCloses[period - 1]; 
   
   for(int i = period - 2; i >= 0; i--)
   {
      ema = (FilteredCloses[i] * k) + (ema * (1.0 - k));
   }
   return ema;
}

double CalculateSignal(int current_pos)
{
   if(current_pos < InpSignalSMA) return 0.0;
   
   double sum = 0;
   int valid_counts = 0;
   
   for(int i = 0; i < InpSignalSMA; i++)
   {
      if(BufferMACD[current_pos - i] != EMPTY_VALUE)
      {
         sum += BufferMACD[current_pos - i];
         valid_counts++;
      }
   }
   
   return (valid_counts > 0) ? (sum / valid_counts) : 0.0;
}           