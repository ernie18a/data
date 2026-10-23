//+------------------------------------------------------------------+
//|                                                 AverageRange.mq5 |
//+------------------------------------------------------------------+
#property copyright "Mahmut Deniz"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   5

// Plot definitions
#property indicator_label1  "Mid High"
#property indicator_type1   DRAW_ARROW
#property indicator_style1  STYLE_DASHDOTDOT
#property indicator_color1  clrLightSalmon
#property indicator_width1  2

#property indicator_label2  "Mid Low"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLightSalmon
#property indicator_width2  2

#property indicator_label3  "Max High"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrTomato
#property indicator_width3  1

#property indicator_label4  "Min Low"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrTomato
#property indicator_width4  1

#property indicator_label5  "Open"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrKhaki
#property indicator_width5  1

// Input parameters
input int    length = 13;   // Ortalama Aralık Uzunluğu
input int    rb = 13;        // Geriye Gidilecek Bar Sayısı
input ENUM_TIMEFRAMES period = PERIOD_MN1;

// Buffers
double HighBuffer[];
double LowBuffer[];
double MaxHighBuffer[];
double MinLowBuffer[];
double OpenBuffer[];
//double Colors[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                           |
//+------------------------------------------------------------------+
int OnInit()
{
    
    IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Average Range ( %d ) \n",length));
    // Initialize buffers

    SetIndexBuffer(0, HighBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, LowBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, MaxHighBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, MinLowBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, OpenBuffer, INDICATOR_DATA);
    //SetIndexBuffer(5, Colors,INDICATOR_COLOR_INDEX);
    ArraySetAsSeries(HighBuffer,true);
    ArraySetAsSeries(LowBuffer,true);
    ArraySetAsSeries(MaxHighBuffer,true);
    ArraySetAsSeries(MinLowBuffer,true);
    ArraySetAsSeries(OpenBuffer,true);
    //ArraySetAsSeries(Colors,true);
    PlotIndexSetInteger(0,PLOT_ARROW,158);
    PlotIndexSetInteger(1,PLOT_ARROW,158);
    PlotIndexSetInteger(2,PLOT_ARROW,158);
    PlotIndexSetInteger(3,PLOT_ARROW,158);
    PlotIndexSetInteger(4,PLOT_ARROW,158);
    // Not Draw Empty Values
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    ArrayInitialize(HighBuffer, EMPTY_VALUE);
    ArrayInitialize(LowBuffer, EMPTY_VALUE);
    ArrayInitialize(MaxHighBuffer, EMPTY_VALUE);
    ArrayInitialize(MinLowBuffer, EMPTY_VALUE);
    ArrayInitialize(OpenBuffer, EMPTY_VALUE);
    //ArrayInitialize(Colors,EMPTY_VALUE);
    if (PeriodSeconds(PERIOD_CURRENT)>PeriodSeconds(period)) return INVALID_HANDLE;

    return(INIT_SUCCEEDED);
}


double CalculateAverageRange(int startIndex, int ar_length, ENUM_TIMEFRAMES ar_period)
{
   double sum = 0;
   // +1 for one month before not calculate existing bar because its changing always, prevent repaint
   for(int i = startIndex + 1; i < startIndex + ar_length + 1; i++) {
      sum += iHigh(NULL, ar_period, i) - iLow(NULL, ar_period, i);
   }
   return sum / ar_length;
}  


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
    if (rates_total - prev_calculated==0) return rates_total;   // If no new bar dont calculate
    int BarsBack = iBarShift(NULL, PERIOD_CURRENT, iTime(NULL, period, rb));
    //int limit = prev_calculated == 0 ? rates_total - 1 : rates_total - prev_calculated;
    int limit = prev_calculated == 0 ? BarsBack : rates_total - prev_calculated;
    for(int i = 0; i < limit; i++){
            int HigherTimeFrameIDX = iBarShift(NULL, period, iTime(NULL, PERIOD_CURRENT, i));
            double adr = CalculateAverageRange(HigherTimeFrameIDX, length, period);
            double PeriodOpenPrice   = iOpen(NULL, period, HigherTimeFrameIDX);
            OpenBuffer[i]  = PeriodOpenPrice;
            HighBuffer[i] = PeriodOpenPrice + adr/2;
            LowBuffer[i]  = PeriodOpenPrice - adr/2;
            MaxHighBuffer[i] = PeriodOpenPrice + adr;
            MinLowBuffer[i]  = PeriodOpenPrice - adr;
    }
    return(rates_total);
}

void OnDeinit(const int reason) {
    ArrayInitialize(HighBuffer, EMPTY_VALUE);
    ArrayInitialize(LowBuffer, EMPTY_VALUE);
    ArrayInitialize(MaxHighBuffer, EMPTY_VALUE);
    ArrayInitialize(MinLowBuffer, EMPTY_VALUE);
    ArrayInitialize(OpenBuffer, EMPTY_VALUE);
}
