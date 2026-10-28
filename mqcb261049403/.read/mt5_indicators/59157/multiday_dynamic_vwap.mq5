//+------------------------------------------------------------------+
//|                                       Multi-Day Dynamic VWAP.mq5 |
//|                            Copyright phade 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright phade 2025, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 1
#property indicator_color1 clrDarkGray, clrDimGray
#property indicator_label1 "Close Prices"


enum ENUM_CUSTOM_PLOT{

   CANDLES, // Candle
   BARS, // Bar
   LINE, // Line
   HISTOGRAM // Histogram
};

input ENUM_TIMEFRAMES input_time = PERIOD_D1; // VWAP Timeframe
input int barsToUse = 5; // VWAP Averaging Period
input int ha_smoothing = 2; // HA Smoothing
input bool show_info = true; // Display VWAP price information
input ENUM_CUSTOM_PLOT drawing = HISTOGRAM; // Plot to represent close prices

// Buffers
double Buffer[];  
datetime timeBuf[];
double ExtOBuffer[], ExtCBuffer[], ExtHBuffer[], ExtLBuffer[];
double dailyHigh[], dailyLow[], dailyClose[];
long dailyVolume[];
double closecol[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   string short_name;
   
   if(drawing == HISTOGRAM){
   
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_HISTOGRAM);   
      SetIndexBuffer(0,Buffer,INDICATOR_DATA);     
      SetIndexBuffer(1,closecol,INDICATOR_COLOR_INDEX);        
      SetIndexBuffer(2,ExtOBuffer, INDICATOR_CALCULATIONS);
      SetIndexBuffer(3,ExtCBuffer, INDICATOR_CALCULATIONS);
   }
   else if(drawing == CANDLES){
   
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_CANDLES);        
      SetIndexBuffer(0,ExtOBuffer, INDICATOR_DATA);
      SetIndexBuffer(1,ExtHBuffer,INDICATOR_DATA); 
      SetIndexBuffer(2,ExtLBuffer,INDICATOR_DATA); 
      SetIndexBuffer(3,ExtCBuffer, INDICATOR_DATA);

      SetIndexBuffer(4,closecol,INDICATOR_COLOR_INDEX);
   }
   else if(drawing == BARS){
   
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_BARS);        
      SetIndexBuffer(0,ExtOBuffer, INDICATOR_DATA);
      SetIndexBuffer(1,ExtHBuffer,INDICATOR_DATA); 
      SetIndexBuffer(2,ExtLBuffer,INDICATOR_DATA); 
      SetIndexBuffer(3,ExtCBuffer, INDICATOR_DATA);
      SetIndexBuffer(4,closecol,INDICATOR_COLOR_INDEX);
   }
   else if(drawing == LINE){
   
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_LINE);        
      SetIndexBuffer(0,Buffer,INDICATOR_DATA);     
      SetIndexBuffer(1,closecol,INDICATOR_COLOR_INDEX);        
      SetIndexBuffer(2, ExtOBuffer, INDICATOR_CALCULATIONS);
      SetIndexBuffer(3, ExtCBuffer, INDICATOR_CALCULATIONS);
   }   

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   
   ArraySetAsSeries(timeBuf, true);
   ArraySetAsSeries(dailyHigh, true);
   ArraySetAsSeries(dailyLow, true);
   ArraySetAsSeries(dailyClose, true);
   ArraySetAsSeries(dailyVolume, true);   

   short_name = "Multi-Day Dynamic VWAP";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);

   IndicatorSetInteger(INDICATOR_LEVELS, 1);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, clrDarkOrange);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, STYLE_SOLID);  
   
   ChartNavigate(0, CHART_END);

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
  
   int start = (prev_calculated == 0) ? 1 : prev_calculated - 1;
   
   static double VWAP_Price = 0.0;

   double cumulativePV = 0.0;
   long cumulativeVol = 0;
   
   if((drawing!=LINE && drawing!=HISTOGRAM) && prev_calculated == 0){
      ExtLBuffer[0]=low[0]; ExtHBuffer[0]=high[0];
      ExtOBuffer[0]=open[0]; ExtCBuffer[0]=close[0];
   }

   if (CopyHigh(_Symbol, input_time, 0, barsToUse, dailyHigh) == barsToUse &&
       CopyLow(_Symbol, input_time, 0, barsToUse, dailyLow) == barsToUse &&
       CopyClose(_Symbol, input_time, 0, barsToUse, dailyClose) == barsToUse &&
       CopyTickVolume(_Symbol, input_time, 0, barsToUse, dailyVolume) == barsToUse)
   {
   
       for (int i = 0; i < barsToUse; i++)
       {
           double typicalPrice = (dailyHigh[i] + dailyLow[i] + dailyClose[i]) / 3.0;
           cumulativePV += typicalPrice * dailyVolume[i];
           cumulativeVol += dailyVolume[i];
       }
   
       if (cumulativeVol > 0)
           VWAP_Price = cumulativePV / cumulativeVol;
   }

   for (int i = 1; i < rates_total && !IsStopped(); i++) {
      Vcolor(i, open, close, high, low);
   }

   static bool lastStatusAboveVWAP = false;
   
   bool isAboveVWAP = close[rates_total - 1] > VWAP_Price;
   
   if (isAboveVWAP != lastStatusAboveVWAP) {
       if (show_info)
           Comment(isAboveVWAP ? "Price is above VWAP" : "Price is below VWAP");
       lastStatusAboveVWAP = isAboveVWAP;
   }

   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, VWAP_Price);
   
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Plotted buffers which represent the close prices                 |
//+------------------------------------------------------------------+
void Vcolor(int p, const double &Open[], const double &Close[], const double &High[], const double &Low[])
  { 
   double ha_open =(ExtOBuffer[p-1]+ExtCBuffer[p-1])/2;
   double ha_close=(Open[p]+High[p]+Low[p]+Close[p])/4;
   double ha_high=MathMax(High[p],MathMax(ha_open,ha_close));
   double ha_low =MathMin(Low[p],MathMin(ha_open,ha_close));
   
   if(drawing == CANDLES || drawing == BARS){
   ExtLBuffer[p]=ha_low;
   ExtHBuffer[p]=ha_high;    
   }  
   ExtOBuffer[p]=ha_open;
   ExtCBuffer[p]=ha_close;
     
   // Applying smoothing to the heiken ashi open and close
   int smoothingPeriod = ha_smoothing; 
   double smooth_ha_open  = CalculateEMA(p, ExtOBuffer, smoothingPeriod);
   double smooth_ha_close = CalculateEMA(p, ExtCBuffer, smoothingPeriod); 
     
   if(drawing == CANDLES){
      ExtOBuffer[p]=smooth_ha_open;
      ExtCBuffer[p]=smooth_ha_close;  
      ExtHBuffer[p] = ha_high;
      ExtLBuffer[p] = ha_low;
   }
   else if(drawing == BARS){
      ExtOBuffer[p]=smooth_ha_open;
      ExtCBuffer[p]=smooth_ha_close;  
      ExtHBuffer[p] = ha_high;
      ExtLBuffer[p] = ha_low;
   }   
   else if(drawing == LINE){
      Buffer[p]=Close[p];
   }      
   else if(drawing == HISTOGRAM){
      Buffer[p]=Close[p];
   }
   
   if(smooth_ha_open<smooth_ha_close)
     {
      closecol[p] = 0;
     }
   else
     {
      closecol[p] = 1;
     } 
  }

double CalculateEMA(int index, const double &src[], int period)
  {
   double alpha = 2.0 / (period + 1);
   if(index == 0)
      return src[0]; // Initialize EMA with first value
   return alpha * src[index] + (1 - alpha) * src[index - 1];
  }

void OnDeinit(const int reason){

   Comment("");
}