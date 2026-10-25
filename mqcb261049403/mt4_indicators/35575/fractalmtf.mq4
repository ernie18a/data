// Multi Time Frame (MTF) Fractal Indicator

// Include required header files.
#include "Fractal-Utilities.mqh"

#property copyright "Developed by Hosein Rahnama"
#property link "https://www.mql5.com/en/users/hosein.rahnama"
#property version "1.4"
#property description "This indicator identifies fractals of a specified timeframe within a neighborhood. The neighborhood has a radius which represents the number of candles to each side of the fractal candle. The high or low of the fractal candle is a local extremum within this neighborhood."

#property strict

#property indicator_chart_window

// Set the number of indicator buffers which are drawn.
#property indicator_buffers 4
#property indicator_plots 4

// Set initial setting for drawing up-factal arrows.
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

// Set initial setting for drawing down-factal arrows.
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

// Set initial setting for drawing up-factals.
#property indicator_type3 DRAW_NONE
#property indicator_color3 clrNONE

// Set initial setting for drawing down-factals.
#property indicator_type4 DRAW_NONE
#property indicator_color4 clrNONE

// Indicator buffers are set.
double upFractalArrow[];
double downFractalArrow[];
double upFractal[];
double downFractal[];

// Define global variables and data types.
bool onCalculateFirstCall = true;

// Default values for input parameters are set.
input int inputRadius = 2;                                  // Radius
input int inputYShift = 20;                                 // Arrow Offset
input ENUM_SHAPE inputShape = WING;                         // Arrow Shape
input int inputArrowSize = 3;                               // Arrow Size
input ENUM_INDICATOR_TIMEFRAME inputTimeFrame = CURRENT;    // Indicator Timeframe

// Copy inputs for possible modification during the program.
int radius = inputRadius;
int YShift = inputYShift;
ENUM_SHAPE shape = inputShape;
int arrowSize = inputArrowSize;
ENUM_TIMEFRAMES highTimeFrame = getTimeFrame(inputTimeFrame);
string indicatorPath = getRelativePath();


int OnInit() 
{
    // Check validity of the radius and the Y shift.
    if (radius < 1) {
        radius = 2;
        Print("Radius cannot be smaller than 1. The default value 2 is used instead.");
    }
    if (YShift < 0) {
        YShift = 20;
        Print("Arrow offset cannot be a negative value. The default value 10 is used instead.");
    }
    if (highTimeFrame < PERIOD_CURRENT) {
        Print("[ERROR] Indicator timeframe cannot be smaller than the chart timeframe.");
        return INIT_FAILED;
    } 

    // Set buffer parameters for up-fractal arrows.
    SetIndexBuffer(UP_FRACTAL_ARROW, upFractalArrow);
    SetIndexLabel(UP_FRACTAL_ARROW, NULL);
    SetIndexArrow(UP_FRACTAL_ARROW, shape);
    SetIndexEmptyValue(UP_FRACTAL_ARROW, EMPTY_VALUE);
    SetIndexStyle(UP_FRACTAL_ARROW, DRAW_ARROW, STYLE_SOLID, arrowSize);

    // Set buffer parameters for down-fractal arrows.
    if (shape == ARROW || shape == BOLD_ARROW || shape == HALLOW_ARROW || shape == WING) {
        shape = ENUM_SHAPE(shape - 1);
    }
    SetIndexBuffer(DOWN_FRACTAL_ARROW, downFractalArrow);
    SetIndexLabel(DOWN_FRACTAL_ARROW, NULL);
    SetIndexArrow(DOWN_FRACTAL_ARROW, shape);
    SetIndexEmptyValue(DOWN_FRACTAL_ARROW, EMPTY_VALUE);
    SetIndexStyle(DOWN_FRACTAL_ARROW, DRAW_ARROW, STYLE_SOLID, arrowSize);

    // Set buffer parameters for up-fractals.
    SetIndexBuffer(UP_FRACTAL, upFractal);
    SetIndexLabel(UP_FRACTAL, "Fractal-Up (" + string(radius) + ")");
    SetIndexEmptyValue(UP_FRACTAL, EMPTY_VALUE);

    // Set buffer parameters for up-fractals.
    SetIndexBuffer(DOWN_FRACTAL, downFractal);
    SetIndexLabel(DOWN_FRACTAL, "Fractal-Down (" + string(radius) + ")");
    SetIndexEmptyValue(DOWN_FRACTAL, EMPTY_VALUE);

    // Set a short name for the indicator.
    IndicatorSetString(INDICATOR_SHORTNAME, "Fractal (" + string(radius) + ")" );

    // Set accuracy of indicator calculations.
    IndicatorSetInteger(INDICATOR_DIGITS, Digits);

    return INIT_SUCCEEDED;
}


int OnCalculate(const int ratesTotal,
                const int prevCalculated,
                const datetime & time[],
                const double & open[],
                const double & high[],
                const double & low[],
                const double & close[],
                const long & tickVolume[],
                const long & volume[],
                const int & spread[])
{
    // Check for the minimum number of bars required for calculation.
    int highRatesTotal = iBars(_Symbol, highTimeFrame);
    if (highRatesTotal < (2 * radius + 1)) {
        return 0;
    }
    
    // Guarantee that all buffers are initialized to EMPTY_VALUE when the timeframe or history is changed.
    if (prevCalculated == 0) {
        ArrayInitialize(upFractal, EMPTY_VALUE);
        ArrayInitialize(upFractalArrow, EMPTY_VALUE);
        ArrayInitialize(downFractal, EMPTY_VALUE);
        ArrayInitialize(downFractalArrow, EMPTY_VALUE);
    }

    // When the indicator is dropped on the chart, variable newBars equals the number of candles in the chart.
    // If newBars is 0 the current candle is changing. If newBars is 1, a new candle has just been started.
    // In these two cases, calculation is only done for the recent bars. However, if newBars is greater than 1 then a change
    // in data history has occured, so it is wise to do the calculations over all of the candles again.
    int newBars = ratesTotal - prevCalculated;

    // Find the range of bar indices for calculation assuming a timeseries indexing direction.
    int timeFrameRatio = highTimeFrame / _Period;
    
    int oldestBar, newestBar;
    if (timeFrameRatio > 1) {
        oldestBar = (newBars <= 1) ? iBarShift(_Symbol, _Period, iTime(_Symbol, highTimeFrame, radius + 1)) : (ratesTotal - 1) - radius;
        newestBar = iBarShift(_Symbol, _Period, iTime(_Symbol, highTimeFrame, radius)) + 1;
    } else {
        oldestBar = (newBars <= 1) ? (radius + 1) : (ratesTotal - 1) - radius;
        newestBar = radius + 1;
    }

    // Carry out indicator calculations.
    double upShift = YShiftToPriceShift(YShift);
    double downShift = YShiftToPriceShift(YShift + 1);
    int bar = newestBar;
    while (bar <= oldestBar) {
        if (timeFrameRatio > 1) {
            int highTimeFrameBar = iBarShift(_Symbol, highTimeFrame, Time[bar]);
            double upFractalValue = iCustom(_Symbol, highTimeFrame, indicatorPath, radius, YShift, shape, arrowSize, UP_FRACTAL, highTimeFrameBar);
            double downFractalValue = iCustom(_Symbol, highTimeFrame, indicatorPath, radius, YShift, shape, arrowSize, DOWN_FRACTAL, highTimeFrameBar);
            
            int currentHighTimeFrameBar = highTimeFrameBar;
            while (currentHighTimeFrameBar == highTimeFrameBar && bar <= oldestBar) {
                if (upFractalValue == High[bar]) {
                    upFractal[bar] = upFractalValue;
                    upFractalArrow[bar] = upFractalValue + upShift;
                }
                if (downFractalValue == Low[bar]) {
                    downFractal[bar] = downFractalValue;
                    downFractalArrow[bar] = downFractalValue - downShift;
                }
                bar++;
                currentHighTimeFrameBar = iBarShift(_Symbol, highTimeFrame, Time[bar]);
            }
        } else {
            if (isUpFractal(bar, radius)) {
                upFractal[bar] = High[bar];
                upFractalArrow[bar] = High[bar] + upShift;
            }
            if (isDownFractal(bar, radius)) {
                downFractal[bar] = Low[bar];
                downFractalArrow[bar] = Low[bar] - downShift;
            }
            bar++;
        }
    }

    // Return the number of available bars in this function call. This will be accessible with prevCalculated in the next call.
    return ratesTotal;
}


// Take care of chart events for keeping the vertical shift in pixels constant.
void OnChartEvent(const int id, const long & lparam, const double & dparam, const string & sparam) 
{
    // Make sure that OnCalculate has run one time.
    if (onCalculateFirstCall) {
        onCalculateFirstCall = false;
        return;
    }
    
    // Force updating of CHART_PRICE_MIN and CHART_PRICE_MAX.
    if (id == CHARTEVENT_KEYDOWN && int(lparam) == KEY_END) {
        updatePriceRange();
    }
            
    if (id == CHARTEVENT_CHART_CHANGE) {
        adjustArrowOffset(YShift, upFractalArrow, downFractalArrow, upFractal, downFractal);
        ChartRedraw();
    }
}
