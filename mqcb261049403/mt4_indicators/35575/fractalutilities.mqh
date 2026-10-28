// Fractal Utilities

#property copyright "Developed by Hosein Rahnama"
#property link "https://www.mql5.com/en/users/hosein.rahnama"
#property version "1.4"

#define KEY_END 35

enum ENUM_SHAPE {
    ARROW = 226,           // Arrow
    BOLD_ARROW = 234,      // Bold Arrow
    HALLOW_ARROW = 242,    // Hallow Arrow
    WING = 218,            // Wing
    CIRCLE = 159,          // Circle
    SQUARE = 167,          // Square
    RHOMBUS = 119,         // Rhombus
    STAR = 172             // Star
};

enum ENUM_BUFFER {
    UP_FRACTAL_ARROW = 0,
    DOWN_FRACTAL_ARROW = 1,
    UP_FRACTAL = 2,
    DOWN_FRACTAL = 3
};

enum ENUM_INDICATOR_TIMEFRAME {
    CURRENT,    // Current
    M1,         // M1
    M5,         // M5
    M15,        // M15
    M30,        // M30
    H1,         // H1
    H4,         // H4
    D1,         // D1
    W1,         // W1
    MN          // MN
};


ENUM_TIMEFRAMES getTimeFrame(ENUM_INDICATOR_TIMEFRAME inputTimeFrame) 
{
    ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT;
    switch (inputTimeFrame) {
    case CURRENT:
        timeFrame = PERIOD_CURRENT;
        break;
    case M1:
        timeFrame = PERIOD_M1;
        break;
    case M5:
        timeFrame = PERIOD_M5;
        break;
    case M15:
        timeFrame = PERIOD_M15;
        break;
    case M30:
        timeFrame = PERIOD_M30;
        break;
    case H1:
        timeFrame = PERIOD_H1;
        break;
    case H4:
        timeFrame = PERIOD_H4;
        break;
    case D1:
        timeFrame = PERIOD_D1;
        break;
    case W1:
        timeFrame = PERIOD_W1;
        break;
    case MN:
        timeFrame = PERIOD_MN1;
    }
    return timeFrame;
}


string getRelativePath()
{
    string path = __PATH__;
    string root = "MQL4\\Indicators\\";
    
    int startIndex = StringFind(path, root);
    string relativePath = StringSubstr(path, startIndex + StringLen(root));
    StringReplace(relativePath, "Fractal-Utilities.mqh", "Fractal-STF.ex4");

    return relativePath;
}


bool isUpFractal(const int bar, const int radius)
{
    for (int adjacentBar = 1; adjacentBar <= radius; adjacentBar++) {
        if (!(High[bar + adjacentBar] <= High[bar] && High[bar - adjacentBar] <= High[bar])) {
            return false;
        }
    }
    return true;
}


bool isDownFractal(const int bar, const int radius)
{
    for (int adjacentBar = 1; adjacentBar <= radius; adjacentBar++) {
        if (!(Low[bar + adjacentBar] >= Low[bar] && Low[bar - adjacentBar] >= Low[bar])) {
            return false;
        }
    }
    return true;
}


double YShiftToPriceShift(const int YShift)
{	
    double priceMin = ChartGetDouble(0, CHART_PRICE_MIN);
    double priceMax = ChartGetDouble(0, CHART_PRICE_MAX);
    long height = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
    double priceShift = YShift * ((priceMax - priceMin) / double(height));
    return priceShift; 
}


void adjustArrowOffset(const int YShift,
                       double & upFractalArrow[],
                       double & downFractalArrow[],
                       const double & upFractal[],
                       const double & downFractal[])
{	
    int numVisibleBars = WindowBarsPerChart();
    int oldestVisibleBar = WindowFirstVisibleBar();
    int newestVisibleBar = oldestVisibleBar - numVisibleBars;
    int offset = numVisibleBars / 4;
    
    int oldestBar = MathMin(oldestVisibleBar + offset, Bars - 1);
    int newestBar = MathMax(newestVisibleBar - offset, 0);

    double upShift = YShiftToPriceShift(YShift);
    double downShift = YShiftToPriceShift(YShift + 1);
    for (int bar = newestBar; bar <= oldestBar; bar++) {
        if (upFractal[bar] != EMPTY_VALUE) {
            upFractalArrow[bar] = High[bar] + upShift;
        }
        if (downFractal[bar] != EMPTY_VALUE) {
            downFractalArrow[bar] = Low[bar] - downShift;
        }
    }
}


void updatePriceRange() 
{
    bool state = ChartGetInteger(0, CHART_SCALEFIX);
    ChartSetInteger(0, CHART_SCALEFIX, state);
}
