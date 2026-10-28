//+-------------------------------------------------------------------+
//|                                               wd.Multi_LineMA.mq5 |
//|                 Copyright © 2023, Karya Prima Rajasa Mediavestama |
//|                                  Programmed by widhie75@yahoo.com |
//+-------------------------------------------------------------------+
#property copyright   "Copyright © 2023, Karya Prima Rajasa Mediavestama."
#property link        "https://www.mql5.com/en/code/47513"
#property version     "2.23"
#property strict
#property description "Provides valuable insights into Moving Average values from a higher timeframe."
#property description "It features visual elements for streamlines analysis, including customizable trails and a dynamic MA horizontal price line."
#property description "The Multi-Timeframe Moving Average adapts to different timeframes, displaying values from higher timeframes if applicable." 
#property description "A customizable Moving Average trail simplifies historical analysis."
#property description "The real-time dynamic MA Horizontal Price Line facilitating effective support and resistance identification."
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

//--- MA plot
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrViolet
#property indicator_style1 STYLE_DOT
#property indicator_width1 1

//--- Input parameters
input int                  ma_Trail = 35;                // MA Trail
input ENUM_TIMEFRAMES      MTF_period = PERIOD_H1;       // MA TimeFrame
input string   Comment1="===== Moving Average Settings =======";       //=======================
input int                  ma_period = 3;                // MA Period
input int                  ma_shift = 0;                 // MA Shift
input ENUM_MA_METHOD       ma_method = MODE_EMA;         // MA Method
input ENUM_APPLIED_PRICE   applied_price = PRICE_CLOSE;  // MA Applied price
input color                ma_color = clrViolet;         // MA Color 
input ENUM_LINE_STYLE      ma_style = STYLE_DASHDOTDOT;  // MA Style
input int                  ma_width = 3;                 // MA width
input string   Comment2="===== MA Horizontal Price Line Settings =====";       //=======================
input color                hl_color = clrViolet;         // MA Price line color
input ENUM_LINE_STYLE      hl_style = STYLE_SOLID;       // MA Price line style
input int                  hl_width = 2;                 // MA Price line width

//--- Array that stores the values of the Moving Average
double ma_Buffer[];

//--- Variable that stores the handle of the iMA indicator
int ma_Handle;

//--- String variables that stores name of the indicator
string short_name;
string name_maHzLine = "MA Horizontal Price Line";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- Assignment of array to indicator buffer
    SetIndexBuffer(0, ma_Buffer, INDICATOR_DATA);

    //--- Set MA plot properties
    PlotIndexSetInteger(0, PLOT_SHIFT, ma_shift);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, ma_color);
    PlotIndexSetInteger(0, PLOT_LINE_STYLE, ma_style);
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, ma_width);

    //--- Create MA handle based on input parameters.
    ma_Handle = iMA(_Symbol, MTF_period, ma_period, ma_shift, ma_method, applied_price);

    //--- Create Moving Average short name, based on the timeframe, method and period
    ENUM_TIMEFRAMES MTF = (MTF_period == PERIOD_CURRENT) ? Period() : MTF_period;
    short_name = StringSubstr(EnumToString(MTF), 7) + StringFormat("(%s,%d)", StringSubstr(EnumToString(ma_method),5), ma_period);
    IndicatorSetString(INDICATOR_SHORTNAME, "MA " + short_name);
    PlotIndexSetString(0, PLOT_LABEL,short_name);
    
    //--- Create MA horizontal price Line short name, based on the timeframe and period
    name_maHzLine = StringSubstr(EnumToString(MTF), 7) + StringFormat("(%d)", ma_period);
    
    //--- Create MA horizontal price line
    ObjectCreate(0, name_maHzLine, OBJ_HLINE, 0, 0, SymbolInfoDouble(Symbol(), SYMBOL_BID));
    ObjectSetInteger(0, name_maHzLine, OBJPROP_COLOR, hl_color);
    ObjectSetInteger(0, name_maHzLine, OBJPROP_STYLE, hl_style);
    ObjectSetInteger(0, name_maHzLine, OBJPROP_WIDTH, hl_width);
    ObjectSetInteger(0, name_maHzLine, OBJPROP_BACK, false);
    ObjectSetInteger(0, name_maHzLine, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name_maHzLine, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name_maHzLine, OBJPROP_HIDDEN, true);
    ObjectSetString(0, name_maHzLine, OBJPROP_TEXT, name_maHzLine);

    return (INIT_SUCCEEDED);
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
    //--- Retrieve MA Values from Higher Timeframe and stores them in the array val_HigherTF
    double val_HigherTF[];
    int h = Bars(_Symbol, MTF_period, time[0], time[rates_total - 1]);
    CopyBuffer(ma_Handle, 0, 0, h, val_HigherTF);

    //--- Copies last MA value to places 'MA Horizontal Price Line' to the price
    double ma_Price[];
    CopyBuffer(ma_Handle, 0, -ma_shift, 1, ma_Price);
    if (!ma_Price[0])
        ma_Price[0] = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    
    //--- Move MA Horizontal Price Line to new price level
    ObjectMove(0, name_maHzLine, 0, 0, ma_Price[0]);
    
    //--- Loop to fills ma_Buffer array with MA values from val_HigherTF, for a specific range of bars (trails)
    for (int i = 0; i <= rates_total - 1; i++)
    {
        int PrevShift = iBarShift(_Symbol, MTF_period, time[i], true);
        ma_Buffer[i] = (PrevShift != -1 && PrevShift < h && i >= rates_total - ma_Trail) ? val_HigherTF[h - PrevShift - 1] : EMPTY_VALUE;
    }

    //================================================================================//
    // Loop condition to display MA plot from MTF_period, or limited lower timeframe  //
    //================================================================================//
    //--- Show higherTF plot (on current chart)
    if (Period() < MTF_period)
    {
        for (int i = rates_total - ma_Trail; i <= 0; i--)
        {
            ma_Buffer[i] = iMA(_Symbol, MTF_period, ma_period, ma_shift, ma_method, applied_price);
        }
    }
    else
    {
        //--- Showing limited lowerTF plot or hide lowerTF values (on current chart)
        for (int i = rates_total - ma_Trail; i >= 0; i--)
        {
            ma_Buffer[i] = EMPTY_VALUE;
        }
    }

    return (rates_total);
}

//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(0, name_maHzLine);
   IndicatorRelease(ma_Handle);
}

//+------------------------------------------------------------------+
