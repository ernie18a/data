//+------------------------------------------------------------------+
//|                                        Syssy Quarters Theory.mq5 |
//|                                               SYLVESTER AKLAMAVO |
//|                                             syssyforex@gmail.com |
//+------------------------------------------------------------------+
#property copyright "SYLVESTER AKLAMAVO"
#property link      "syssyforex@gmail.com"
#property version   "1.0"
#property description "Quarters Theory Indicator- Multi-Asset Version"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   4

// Enum for base level types
enum ENUM_BASE_LEVEL
{
    BASE_CURRENT_CLOSE,        // Current daily close
    BASE_PREV_DAY_CLOSE,       // Previous day close
    BASE_PREV_WEEK_CLOSE,      // Previous week close
    BASE_PREV_MONTH_CLOSE,     // Previous month close
    BASE_WEEKLY_OPEN,          // Weekly open
    BASE_MONTHLY_OPEN,         // Monthly open
    BASE_CUSTOM_LEVEL          // Custom level
};

// Enum for price units
enum ENUM_PRICE_UNITS
{
    UNITS_PIPS,                // Use pips
    UNITS_POINTS,              // Use points
    UNITS_PERCENT,             // Use percentage
    UNITS_ABSOLUTE             // Use absolute price
};

// Input parameters
input int             BaseValue = 1000;               // Base value for quarters
input ENUM_PRICE_UNITS PriceUnits = UNITS_POINTS;    // Units to use for quarter size
input double          PercentageValue = 1.0;         // Percentage value if using percent units
input double          AbsoluteValue = 0.01;          // Absolute value if using absolute units
input ENUM_BASE_LEVEL BaseLevelType = BASE_PREV_WEEK_CLOSE; // Base level calculation method
input color           Quarter1Color = clrGold;       // Quarter 1 color
input color           Quarter2Color = clrGold;       // Quarter 2 color
input color           Quarter3Color = clrGold;       // Quarter 3 color
input color           Quarter4Color = clrGold;       // Quarter 4 color
input int             LineWidth = 1;                 // Line width
input bool            ShowLabels = true;             // Show quarter labels
input bool            ShowMiddleLines = true;        // Show middle lines for each quarter
input string          CustomBaseLevel = "";          // Custom base level (leave empty for auto)
input bool            UseDynamicCalculation = true;  // Dynamic calculation for all instruments

// Buffers for quarters lines
double Quarter1UpperBuffer[];
double Quarter1LowerBuffer[];
double Quarter2UpperBuffer[];
double Quarter2LowerBuffer[];
double Quarter3UpperBuffer[];
double Quarter3LowerBuffer[];
double Quarter4UpperBuffer[];
double Quarter4LowerBuffer[];

// Global variables
double baseLevel;
double quarterRange;
datetime lastBarTime;
string currentSymbol;
bool isForex;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set indicator properties
    SetIndexBuffer(0, Quarter1UpperBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, Quarter1LowerBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, Quarter2UpperBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, Quarter2LowerBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, Quarter3UpperBuffer, INDICATOR_DATA);
    SetIndexBuffer(5, Quarter3LowerBuffer, INDICATOR_DATA);
    SetIndexBuffer(6, Quarter4UpperBuffer, INDICATOR_DATA);
    SetIndexBuffer(7, Quarter4LowerBuffer, INDICATOR_DATA);
    
    // Set drawing styles
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
    
    // Set line colors and styles
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, Quarter1Color);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, Quarter1Color);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, Quarter2Color);
    PlotIndexSetInteger(3, PLOT_LINE_COLOR, Quarter2Color);
    PlotIndexSetInteger(4, PLOT_LINE_COLOR, Quarter3Color);
    PlotIndexSetInteger(5, PLOT_LINE_COLOR, Quarter3Color);
    PlotIndexSetInteger(6, PLOT_LINE_COLOR, Quarter4Color);
    PlotIndexSetInteger(7, PLOT_LINE_COLOR, Quarter4Color);
    
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, LineWidth);
    PlotIndexSetInteger(1, PLOT_LINE_WIDTH, LineWidth);
    PlotIndexSetInteger(2, PLOT_LINE_WIDTH, LineWidth);
    PlotIndexSetInteger(3, PLOT_LINE_WIDTH, LineWidth);
    PlotIndexSetInteger(4, PLOT_LINE_WIDTH, LineWidth);
    PlotIndexSetInteger(5, PLOT_LINE_WIDTH, LineWidth);
    PlotIndexSetInteger(6, PLOT_LINE_WIDTH, LineWidth);
    PlotIndexSetInteger(7, PLOT_LINE_WIDTH, LineWidth);
    
    // Detect instrument type
    currentSymbol = Symbol();
    isForex = IsForexSymbol(currentSymbol);
    
    // Calculate initial base level and quarter range
    baseLevel = CalculateBaseLevel();
    quarterRange = CalculateQuarterRange(baseLevel);
    
    // Initialize last bar time
    lastBarTime = 0;
    
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
    // Check if we have enough data
    if(rates_total < 2)
        return(0);
    
    // Check if new bar or symbol changed
    bool symbolChanged = (currentSymbol != Symbol());
    if((time[0] == lastBarTime && prev_calculated > 0) && !symbolChanged)
        return(rates_total);
    
    lastBarTime = time[0];
    
    if(symbolChanged)
    {
        currentSymbol = Symbol();
        isForex = IsForexSymbol(currentSymbol);
    }
    
    // Recalculate base level if needed
    if(BaseLevelType != BASE_CUSTOM_LEVEL || StringLen(CustomBaseLevel) == 0)
    {
        baseLevel = CalculateBaseLevel();
    }
    else if(BaseLevelType == BASE_CUSTOM_LEVEL && StringLen(CustomBaseLevel) > 0)
    {
        baseLevel = StringToDouble(CustomBaseLevel);
    }
    
    // Recalculate quarter range (dynamic if enabled)
    if(UseDynamicCalculation || symbolChanged)
    {
        quarterRange = CalculateQuarterRange(baseLevel);
    }
    
    // Calculate quarter levels
    double quarter1Upper = baseLevel + quarterRange;
    double quarter1Lower = baseLevel;
    double quarter2Upper = baseLevel + 2 * quarterRange;
    double quarter2Lower = baseLevel + quarterRange;
    double quarter3Upper = baseLevel;
    double quarter3Lower = baseLevel - quarterRange;
    double quarter4Upper = baseLevel - quarterRange;
    double quarter4Lower = baseLevel - 2 * quarterRange;
    
    // Fill buffers with quarter levels
    for(int i = 0; i < rates_total; i++)
    {
        Quarter1UpperBuffer[i] = quarter1Upper;
        Quarter1LowerBuffer[i] = quarter1Lower;
        Quarter2UpperBuffer[i] = quarter2Upper;
        Quarter2LowerBuffer[i] = quarter2Lower;
        Quarter3UpperBuffer[i] = quarter3Upper;
        Quarter3LowerBuffer[i] = quarter3Lower;
        Quarter4UpperBuffer[i] = quarter4Upper;
        Quarter4LowerBuffer[i] = quarter4Lower;
    }
    
    // Draw labels if enabled
    if(ShowLabels)
    {
        DrawLabels(quarter1Upper, quarter1Lower, quarter2Upper, quarter2Lower,
                  quarter3Upper, quarter3Lower, quarter4Upper, quarter4Lower,
                  time[rates_total-1]);
    }
    
    // Draw middle lines if enabled
    if(ShowMiddleLines)
    {
        DrawMiddleLines(quarter1Upper, quarter1Lower, quarter2Upper, quarter2Lower,
                       quarter3Upper, quarter3Lower, quarter4Upper, quarter4Lower,
                       time[rates_total-1]);
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Calculate quarter range based on selected units                  |
//+------------------------------------------------------------------+
double CalculateQuarterRange(double currentBaseLevel)
{
    double range = 0;
    
    switch(PriceUnits)
    {
        case UNITS_PIPS:
            range = BaseValue * GetPipValue();
            break;
            
        case UNITS_POINTS:
            range = BaseValue * _Point;
            break;
            
        case UNITS_PERCENT:
            range = currentBaseLevel * (PercentageValue / 100.0);
            break;
            
        case UNITS_ABSOLUTE:
            range = AbsoluteValue;
            break;
    }
    
    return range;
}

//+------------------------------------------------------------------+
//| Check if symbol is Forex                                         |
//+------------------------------------------------------------------+
bool IsForexSymbol(string symbol)
{
    string forexSuffixes[] = {"USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "NZD", "CNH", "HKD", "SGD", "NOK", "SEK", "TRY", "ZAR", "MXN"};
    
    for(int i = 0; i < ArraySize(forexSuffixes); i++)
    {
        if(StringFind(symbol, forexSuffixes[i]) > 0)
            return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Calculate base level based on selected method                    |
//+------------------------------------------------------------------+
double CalculateBaseLevel()
{
    double level = 0;
    
    switch(BaseLevelType)
    {
        case BASE_CURRENT_CLOSE:
            level = GetPriceWithFallback(PERIOD_D1, 0, PRICE_CLOSE);
            break;
            
        case BASE_PREV_DAY_CLOSE:
            level = GetPreviousPeriodClose(PERIOD_D1);
            break;
            
        case BASE_PREV_WEEK_CLOSE:
            level = GetPreviousPeriodClose(PERIOD_W1);
            break;
            
        case BASE_PREV_MONTH_CLOSE:
            level = GetPreviousPeriodClose(PERIOD_MN1);
            break;
            
        case BASE_WEEKLY_OPEN:
            level = GetWeeklyOpen();
            break;
            
        case BASE_MONTHLY_OPEN:
            level = GetMonthlyOpen();
            break;
            
        case BASE_CUSTOM_LEVEL:
            if(StringLen(CustomBaseLevel) > 0)
                level = StringToDouble(CustomBaseLevel);
            else
                level = GetPriceWithFallback(PERIOD_D1, 0, PRICE_CLOSE);
            break;
    }
    
    return level;
}

//+------------------------------------------------------------------+
//| Get price with fallback to available timeframes                  |
//+------------------------------------------------------------------+
double GetPriceWithFallback(ENUM_TIMEFRAMES timeframe, int shift, ENUM_APPLIED_PRICE priceType)
{
    double price = 0;
    
    // Try the requested timeframe first
    if(IsTimeframeAvailable(timeframe))
    {
        switch(priceType)
        {
            case PRICE_OPEN: price = iOpen(Symbol(), timeframe, shift); break;
            case PRICE_HIGH: price = iHigh(Symbol(), timeframe, shift); break;
            case PRICE_LOW: price = iLow(Symbol(), timeframe, shift); break;
            case PRICE_CLOSE: price = iClose(Symbol(), timeframe, shift); break;
        }
    }
    
    // If not available, try lower timeframes
    if(price == 0)
    {
        if(timeframe == PERIOD_MN1)
        {
            if(IsTimeframeAvailable(PERIOD_W1)) price = GetPriceWithFallback(PERIOD_W1, shift * 4, priceType);
            else if(IsTimeframeAvailable(PERIOD_D1)) price = GetPriceWithFallback(PERIOD_D1, shift * 30, priceType);
        }
        else if(timeframe == PERIOD_W1)
        {
            if(IsTimeframeAvailable(PERIOD_D1)) price = GetPriceWithFallback(PERIOD_D1, shift * 7, priceType);
        }
    }
    
    // Final fallback to current chart close
    if(price == 0)
    {
        MqlRates currentRates[];
        ArraySetAsSeries(currentRates, true);
        if(CopyRates(Symbol(), Period(), 0, 1, currentRates) > 0)
        {
            price = currentRates[0].close;
        }
    }
    
    return price;
}

//+------------------------------------------------------------------+
//| Check if timeframe is available for the symbol                   |
//+------------------------------------------------------------------+
bool IsTimeframeAvailable(ENUM_TIMEFRAMES timeframe)
{
    // For stocks and some commodities, higher timeframes might not be available
    MqlRates rates[];
    int copied = CopyRates(Symbol(), timeframe, 0, 1, rates);
    return (copied > 0);
}

//+------------------------------------------------------------------+
//| Get previous period close price                                  |
//+------------------------------------------------------------------+
double GetPreviousPeriodClose(ENUM_TIMEFRAMES timeframe)
{
    if(!IsTimeframeAvailable(timeframe))
    {
        Print("Timeframe not available for symbol: ", EnumToString(timeframe));
        return GetPriceWithFallback(PERIOD_D1, 0, PRICE_CLOSE);
    }
    
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    // Get rates (2 bars to ensure we get previous period)
    if(CopyRates(Symbol(), timeframe, 0, 2, rates) < 2)
    {
        Print("Error getting previous period close for ", EnumToString(timeframe), ": Not enough data");
        return GetPriceWithFallback(timeframe, 0, PRICE_CLOSE);
    }
    
    // Return previous period's close (index 1 since array is series)
    return rates[1].close;
}

//+------------------------------------------------------------------+
//| Get weekly open price                                            |
//+------------------------------------------------------------------+
double GetWeeklyOpen()
{
    if(!IsTimeframeAvailable(PERIOD_W1))
    {
        // Fallback to daily data to find weekly open
        MqlRates rates[];
        ArraySetAsSeries(rates, true);
        
        if(CopyRates(Symbol(), PERIOD_D1, 0, 7, rates) >= 7)
        {
            // Find Monday's open (start of week)
            for(int i = 0; i < 7; i++)
            {
                MqlDateTime dt;
                TimeToStruct(rates[i].time, dt);
                
                if(dt.day_of_week == 1) // Monday
                {
                    return rates[i].open;
                }
            }
        }
    }
    
    return GetPriceWithFallback(PERIOD_W1, 0, PRICE_OPEN);
}

//+------------------------------------------------------------------+
//| Get monthly open price                                           |
//+------------------------------------------------------------------+
double GetMonthlyOpen()
{
    if(!IsTimeframeAvailable(PERIOD_MN1))
    {
        // Fallback to daily data to find monthly open
        MqlRates rates[];
        ArraySetAsSeries(rates, true);
        
        if(CopyRates(Symbol(), PERIOD_D1, 0, 31, rates) >= 31)
        {
            // Find first day of month's open
            MqlDateTime currentDt, barDt;
            TimeToStruct(TimeCurrent(), currentDt);
            
            for(int i = 0; i < 31; i++)
            {
                TimeToStruct(rates[i].time, barDt);
                
                if(barDt.mon == currentDt.mon && barDt.day == 1)
                {
                    return rates[i].open;
                }
            }
        }
    }
    
    return GetPriceWithFallback(PERIOD_MN1, 0, PRICE_OPEN);
}

//+------------------------------------------------------------------+
//| Get pip value based on symbol (only for Forex)                   |
//+------------------------------------------------------------------+
double GetPipValue()
{
    if(!isForex)
        return _Point * 10; // Default for non-Forex instruments
    
    string symbol = Symbol();
    int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    
    if(digits == 5 || digits == 3)
        return(0.0001);
    else if(digits == 2 || digits == 4)
        return(0.01);
    else
        return(_Point * 10); // Fallback
}

//+------------------------------------------------------------------+
//| Draw quarter labels on chart                                     |
//+------------------------------------------------------------------+
void DrawLabels(double q1Upper, double q1Lower, double q2Upper, double q2Lower,
                double q3Upper, double q3Lower, double q4Upper, double q4Lower,
                datetime time)
{
    // Remove existing labels
    ObjectsDeleteAll(0, "QuarterLabel_");
    
    // Create labels for each quarter
    CreateLabel("Q1", "Q1: " + DoubleToString(q1Lower, _Digits) + " - " + DoubleToString(q1Upper, _Digits),
                time + PeriodSeconds() * 10, (q1Upper + q1Lower) / 2, Quarter1Color);
    
    CreateLabel("Q2", "Q2: " + DoubleToString(q2Lower, _Digits) + " - " + DoubleToString(q2Upper, _Digits),
                time + PeriodSeconds() * 10, (q2Upper + q2Lower) / 2, Quarter2Color);
    
    CreateLabel("Q3", "Q3: " + DoubleToString(q3Lower, _Digits) + " - " + DoubleToString(q3Upper, _Digits),
                time + PeriodSeconds() * 10, (q3Upper + q3Lower) / 2, Quarter3Color);
    
    CreateLabel("Q4", "Q4: " + DoubleToString(q4Lower, _Digits) + " - " + DoubleToString(q4Upper, _Digits),
                time + PeriodSeconds() * 10, (q4Upper + q4Lower) / 2, Quarter4Color);
    
    // Add base level label
    string baseLevelText = "Base: " + DoubleToString(baseLevel, _Digits) + " (" + GetBaseLevelDescription() + ")";
    CreateLabel("Base", baseLevelText, time + PeriodSeconds() * 10, baseLevel, clrWhite);
    
    // Add units info
    string unitsText = "Range: " + DoubleToString(quarterRange, _Digits) + " (" + GetUnitsDescription() + ")";
    CreateLabel("Units", unitsText, time + PeriodSeconds() * 10, baseLevel - quarterRange, clrSilver);
}

//+------------------------------------------------------------------+
//| Get description of units type                                    |
//+------------------------------------------------------------------+
string GetUnitsDescription()
{
    switch(PriceUnits)
    {
        case UNITS_PIPS: return "Pips";
        case UNITS_POINTS: return "Points";
        case UNITS_PERCENT: return DoubleToString(PercentageValue, 2) + "%";
        case UNITS_ABSOLUTE: return "Absolute";
    }
    return "Unknown";
}

//+------------------------------------------------------------------+
//| Draw middle lines for each quarter                               |
//+------------------------------------------------------------------+
void DrawMiddleLines(double q1Upper, double q1Lower, double q2Upper, double q2Lower,
                    double q3Upper, double q3Lower, double q4Upper, double q4Lower,
                    datetime time)
{
    // Remove existing middle lines
    ObjectsDeleteAll(0, "MiddleLine_");
    
    // Create middle lines for each quarter
    CreateHorizontalLine("Middle_Q1", (q1Upper + q1Lower) / 2, Quarter1Color, STYLE_DOT);
    CreateHorizontalLine("Middle_Q2", (q2Upper + q2Lower) / 2, Quarter2Color, STYLE_DOT);
    CreateHorizontalLine("Middle_Q3", (q3Upper + q3Lower) / 2, Quarter3Color, STYLE_DOT);
    CreateHorizontalLine("Middle_Q4", (q4Upper + q4Lower) / 2, Quarter4Color, STYLE_DOT);
}

//+------------------------------------------------------------------+
//| Create horizontal line on chart                                  |
//+------------------------------------------------------------------+
void CreateHorizontalLine(string name, double price, color clr, ENUM_LINE_STYLE style)
{
    ObjectCreate(0, "MiddleLine_" + name, OBJ_HLINE, 0, 0, price);
    ObjectSetInteger(0, "MiddleLine_" + name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, "MiddleLine_" + name, OBJPROP_STYLE, style);
    ObjectSetInteger(0, "MiddleLine_" + name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, "MiddleLine_" + name, OBJPROP_BACK, true);
}

//+------------------------------------------------------------------+
//| Create text label on chart                                       |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, datetime time, double price, color clr)
{
    ObjectCreate(0, "QuarterLabel_" + name, OBJ_TEXT, 0, time, price);
    ObjectSetString(0, "QuarterLabel_" + name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, "QuarterLabel_" + name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, "QuarterLabel_" + name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0, "QuarterLabel_" + name, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, "QuarterLabel_" + name, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Get description of base level type                               |
//+------------------------------------------------------------------+
string GetBaseLevelDescription()
{
    switch(BaseLevelType)
    {
        case BASE_CURRENT_CLOSE: return "Current Close";
        case BASE_PREV_DAY_CLOSE: return "Prev Day Close";
        case BASE_PREV_WEEK_CLOSE: return "Prev Week Close";
        case BASE_PREV_MONTH_CLOSE: return "Prev Month Close";
        case BASE_WEEKLY_OPEN: return "Weekly Open";
        case BASE_MONTHLY_OPEN: return "Monthly Open";
        case BASE_CUSTOM_LEVEL: return "Custom Level";
    }
    return "Unknown";
}

//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Clean up objects
    ObjectsDeleteAll(0, "QuarterLabel_");
    ObjectsDeleteAll(0, "MiddleLine_");
}