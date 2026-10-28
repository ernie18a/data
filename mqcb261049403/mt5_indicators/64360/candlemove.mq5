
#property copyright   "Duy Van Nguy " 
#property link        ""
#property description "CandleMove"
#property version     "1.0"
#property indicator_chart_window

// The indicator uses only objects for display, but the line below is required for it to work.
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

 double PercentageLimit = 0; // PercentageLimit - Will not display number if percentage gain/loss is below limit.
input int PipsLimit = 100; // PipsLimit - Will not display number if pips gain/loss is below limit.
// If true, will compare Close of the current candle to Close of the previous one. Otherwise compares current Close to current Open.
input bool CloseToClose = true;
input color DisplayLossColor = clrRed;
input color DisplayGainColor = clrLimeGreen;
input int DisplayDistance = 100; // DisplayDistance - Distance in points from High/Low to percentage display.
input int MaxBars = 100; // MaxBars: More bars - more objects - more lag and memory usage.
 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

string FontFace = "Verdana";
 int FontSize = 10;
 string ObjectPrefix = "GLI-";
int OnInit()
{
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ObjectsDeleteAll(0, ObjectPrefix, -1, OBJ_TEXT);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    // Redraw visible labels.
    if (id == CHARTEVENT_CHART_CHANGE) RedrawVisibleLabels();
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
    string perc, points, name;
    double start;
    
    // Set arrays as series
    ArraySetAsSeries(time, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);

    int limit;
    if (prev_calculated == 0)
    {
        limit = rates_total - 1;
        if (limit > MaxBars) limit = MaxBars - 1;
    }
    else
    {
        limit = rates_total - prev_calculated;
    }

    for (int i = 0; i <= limit; i++)
    {
        if ((CloseToClose) && (i + 1 < rates_total)) 
            start = close[i + 1];
        else 
            start = open[i];

        name = ObjectPrefix + "Percent-" + TimeToString(time[i], TIME_DATE | TIME_MINUTES);
        ObjectDelete(0, name);
        
        if (((close[i] - start) / start) * 100 >= PercentageLimit) // Gain percent display
        {
            perc = DoubleToString(((close[i] - start) / start) * 100, 1) + "%";
            ObjectCreate(0, name, OBJ_TEXT, 0, time[i], high[i]);
            ObjectSetString(0, name, OBJPROP_TEXT, perc);
            ObjectSetString(0, name, OBJPROP_FONT, FontFace);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
            ObjectSetInteger(0, name, OBJPROP_COLOR, DisplayGainColor);
            
            int visible_bars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
            int first_bar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
            int last_bar = first_bar - visible_bars + 1;
            if ((i <= first_bar) && (i >= last_bar)) RedrawOneLabel(i, last_bar, time, high, open, close);
            
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_UPPER);
            ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        }
        else if (((start - close[i]) / start) * 100 >= PercentageLimit) // Loss percent display
        {
            perc = DoubleToString(((start - close[i]) / start) * 100, 1) + "%";
            ObjectCreate(0, name, OBJ_TEXT, 0, time[i], high[i]);
            ObjectSetString(0, name, OBJPROP_TEXT, perc);
            ObjectSetString(0, name, OBJPROP_FONT, FontFace);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
            ObjectSetInteger(0, name, OBJPROP_COLOR, DisplayLossColor);
            
            int visible_bars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
            int first_bar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
            int last_bar = first_bar - visible_bars + 1;
            if ((i <= first_bar) && (i >= last_bar)) RedrawOneLabel(i, last_bar, time, high, open, close);
            
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_UPPER);
            ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        }

        name = ObjectPrefix + "Pips-" + TimeToString(time[i], TIME_DATE | TIME_MINUTES);
        ObjectDelete(0, name);
        
        double pip_value = _Point * 10; // 1 pip = 10 points cho hầu hết các cặp tiền
        
        if ((close[i] - start) / pip_value >= PipsLimit) // Gain pips display
        {
            points = DoubleToString((close[i] - start) / pip_value, 1);
            ObjectCreate(0, name, OBJ_TEXT, 0, time[i], low[i]);
            ObjectSetString(0, name, OBJPROP_TEXT, points);
            ObjectSetString(0, name, OBJPROP_FONT, FontFace);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
            ObjectSetInteger(0, name, OBJPROP_COLOR, DisplayGainColor);
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_UPPER);
            ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        }
        else if ((start - close[i]) / pip_value >= PipsLimit) // Loss pips display
        {
            points = DoubleToString((start - close[i]) / pip_value, 1);
            ObjectCreate(0, name, OBJ_TEXT, 0, time[i], low[i]);
            ObjectSetString(0, name, OBJPROP_TEXT, points);
            ObjectSetString(0, name, OBJPROP_FONT, FontFace);
            ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
            ObjectSetInteger(0, name, OBJPROP_COLOR, DisplayLossColor);
            ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_UPPER);
            ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        }
    }

    return rates_total;
}

//+------------------------------------------------------------------+
//| Redraw visible labels                                            |
//+------------------------------------------------------------------+
void RedrawVisibleLabels()
{
    datetime time[];
    double high[], open[], close[];
    
    int copied = CopyTime(_Symbol, _Period, 0, MaxBars, time);
    if (copied <= 0) return;
    
    CopyHigh(_Symbol, _Period, 0, copied, high);
    CopyOpen(_Symbol, _Period, 0, copied, open);
    CopyClose(_Symbol, _Period, 0, copied, close);
    
    ArraySetAsSeries(time, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(close, true);
    
    int visible_bars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
    int first_bar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
    int last_bar = first_bar - visible_bars + 1;
  
    // Process all bars on the current screen.
    for (int i = first_bar; i >= last_bar; i--)
    {
        if (i < copied)
            RedrawOneLabel(i, last_bar, time, high, open, close);
    }
}

//+------------------------------------------------------------------+
//| Redraw one label                                                 |
//+------------------------------------------------------------------+
void RedrawOneLabel(const int i, const int last_bar, 
                    const datetime &time[], const double &high[],
                    const double &open[], const double &close[])
{
    int x, y, cw;
    uint w, h;
    datetime t;
    double p;
    string length, name;

    name = GenerateObjectName("Percent-", time[i]);
    if (ObjectFind(0, name) == -1) return;
    
    // Needed only for y; x is used as a dummy.
    if (last_bar >= 0 && last_bar < ArraySize(time))
    {
        ChartTimePriceToXY(0, 0, time[last_bar], high[i], x, y);
        
        // Get the height of the text based on font and its size.
        TextSetFont(FontFace, FontSize * -10);
        length = DoubleToString(MathRound((high[i] - MathMax(open[i], close[i])) / _Point), 0);
        TextGetSize(length, w, h);
        ChartXYToTimePrice(0, x, y - (int)h - 2, cw, t, p);
        ObjectSetDouble(0, name, OBJPROP_PRICE, p);
    }
}

string GenerateObjectName(const string prefix, const datetime time)
{
    return ObjectPrefix + prefix + TimeToString(time, TIME_DATE | TIME_MINUTES);
}
//+------------------------------------------------------------------+