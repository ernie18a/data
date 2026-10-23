#property indicator_separate_window 
#property indicator_buffers 10
#property indicator_plots   10

#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue

#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlack

#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed

#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver

#property indicator_type5   DRAW_LINE
#property indicator_color5  clrLime

#property indicator_type6   DRAW_LINE
#property indicator_color6  clrMagenta

#property indicator_type7   DRAW_LINE
#property indicator_color7  clrOrange

#property indicator_type8   DRAW_LINE
#property indicator_color8  clrDeepSkyBlue

#property indicator_type9   DRAW_LINE
#property indicator_color9  clrAqua

#property indicator_type10  DRAW_LINE
#property indicator_color10 clrPurple

#include <Math/Alglib/alglib.mqh>
#include <AIV/Charts.mqh>

enum eMatrices 
{
    Logs,
    Limits
};

input int InpVector = 0;
input int InpFrame = 200;
input int InpDepth = 500;
input int InpForward = 0;
input int InpMaPeriod = 1;
input ENUM_TIMEFRAMES InpTimePeriod = PERIOD_CURRENT;
input bool InpSynthetics = true;
input eMatrices InpPrices = Logs;
input string InpSymbols = "AUDUSD,EURUSD,USDCHF,USDJPY,USDCAD";
input string InpMagic = "SNTS";

struct SGenerics
{
    double S0[], S1[], S2[], S3[], S4[], S5[], S6[], S7[], S8[], S9[], iVars[], iSigns[];
};

SGenerics iG;

int iOrder;
int iFrame; 
int iLines;
int iUpdate;
int iChartIndex;
CMatrixDouble iVectors;
CMatrixDouble iMatrices;
SSeries iSeries[];
SSeries iCharts[];

/**
 * Clean up and initialize
 */
int OnInit()
{
    Setup();
    HidePanel(InpMagic);
    EventSetMillisecondTimer(500);
    
    return 0;
}

/**
 * Preload quotes from missing charts by timer
 */
void OnTimer()
{
    int bars = getBars(iSeries, InpTimePeriod, iOrder);

    if (bars == 0)
    {
        return;
    }

    // Do not try to display more bars thanavailable in history

    if (iChartIndex > bars)
    {
        iChartIndex = MathMax(MathMin(bars - 2, iChartIndex), 0);
    }

    // Display history

    while (iChartIndex > 0)
    {
        if (Calculate(iChartIndex) < 1)
        {
            return;
        }
        
        iChartIndex--;
    }

    // If most recent bars has been drawn, end up with history

    if (Calculate(0) > 0)
    {
        ChartRedraw(ChartID());
        EventKillTimer();
        iUpdate = 1;
    }
}

/**
 * Call calculation only for current bar
 * Bars needs to be loaded by timer
 * It was made to update indicator even on a dead market without new ticks
 */
int OnCalculate(
    const int bars,
    const int counted,
    const int start,
    const double &price[])
{
    if (isNewPeriod())
    {
        iUpdate = 1;
    }

    if (iChartIndex < 1 && iUpdate == 1)
    {
        if (Calculate(0) > 0)
        {
            iUpdate = 0;
        }
    }

    return bars;
}

/**
 * Create indicator buffers and set chart properties
 */
void Setup()
{
    // Get list of currency pairs from provided string

    iUpdate = 0;
    iOrder = listPairs(iSeries, InpSymbols);
    iLines = InpSynthetics ? 1 : iOrder;
    
    // If user chose to show synthetics only, leave only one buffer
    
    if (iLines > 0) { SetIndexBuffer(0, iG.S0, INDICATOR_DATA); ArraySetAsSeries(iG.S0, true); ArrayInitialize(iG.S0, 0); }
    if (iLines > 1) { SetIndexBuffer(1, iG.S1, INDICATOR_DATA); ArraySetAsSeries(iG.S1, true); ArrayInitialize(iG.S1, 0); }
    if (iLines > 2) { SetIndexBuffer(2, iG.S2, INDICATOR_DATA); ArraySetAsSeries(iG.S2, true); ArrayInitialize(iG.S2, 0); }
    if (iLines > 3) { SetIndexBuffer(3, iG.S3, INDICATOR_DATA); ArraySetAsSeries(iG.S3, true); ArrayInitialize(iG.S3, 0); }
    if (iLines > 4) { SetIndexBuffer(4, iG.S4, INDICATOR_DATA); ArraySetAsSeries(iG.S4, true); ArrayInitialize(iG.S4, 0); }
    if (iLines > 5) { SetIndexBuffer(5, iG.S5, INDICATOR_DATA); ArraySetAsSeries(iG.S5, true); ArrayInitialize(iG.S5, 0); }
    if (iLines > 6) { SetIndexBuffer(6, iG.S6, INDICATOR_DATA); ArraySetAsSeries(iG.S6, true); ArrayInitialize(iG.S6, 0); }
    if (iLines > 7) { SetIndexBuffer(7, iG.S7, INDICATOR_DATA); ArraySetAsSeries(iG.S7, true); ArrayInitialize(iG.S7, 0); }
    if (iLines > 8) { SetIndexBuffer(8, iG.S8, INDICATOR_DATA); ArraySetAsSeries(iG.S8, true); ArrayInitialize(iG.S8, 0); }
    if (iLines > 9) { SetIndexBuffer(9, iG.S9, INDICATOR_DATA); ArraySetAsSeries(iG.S9, true); ArrayInitialize(iG.S9, 0); }

    for (int k = 0; k < 10; k++)
    {
        if (k < iLines) 
        {
            PlotIndexSetInteger(k, PLOT_DRAW_TYPE, DRAW_LINE);
            PlotIndexSetString(k, PLOT_LABEL, iSeries[k].mSymbol.mName); 
            continue;
        }

        PlotIndexSetInteger(k, PLOT_DRAW_TYPE, DRAW_NONE);
    }

    IndicatorSetInteger(INDICATOR_DIGITS, 5);
    IndicatorSetString(INDICATOR_SHORTNAME, InpMagic);

    // Initialize array of structures with symbol names and prices

    iFrame = InpFrame;
    iChartIndex = InpDepth;
    
    setupSeries(iSeries, iOrder, iFrame);
    setupSeries(iCharts, iOrder, iFrame);

    iVectors.Resize(iOrder, iOrder);
    iMatrices.Resize(iFrame, iOrder);
    
    ArrayResize(iG.iVars, iOrder);
    ArrayResize(iG.iSigns, iOrder);

    ZeroMemory(iG.iVars);
    ZeroMemory(iG.iSigns);
    
    GlobalVariablesDeleteAll(InpMagic);
}

/**
 * Calculate value for synthetics for selected position (bar)
 * User chooses InpDepth bars in params, so this method will be executed InpDepth times
 * Every call of this method is copying InpFrame bars and compute PCA based on it
 */
int Calculate(int position)
{
    int sign = 1;
    int result = 0;
    int last = iFrame - 1;

    // Synchronize prices by time, preferably, only for intraday time frames, where bars may be missing

    int bars = synchronize(iSeries, InpTimePeriod, iOrder, iFrame, MathMax(position, 1), false);

    if (bars < 1)
    {
        return 0;
    }

    // Normalize prices to prevent significant bias between prices, e.g. between EURUSD and USDJPY

    switch (InpPrices)
    {
        case Logs : getLogMatrix(iSeries, iCharts, iOrder, iFrame); break;
        case Limits : getLimitMatrix(iSeries, iCharts, iOrder, iFrame); break;
    }

    // Copy internal structure to alglib container

    for (int k = 0; k < iOrder; k++)
    {
        for (int n = 0; n < iFrame; n++)
        {
            iMatrices[n].Set(k, iCharts[k].mPoints[n].mPoint);
        }
    }

    double synthetics = 0;

    // If current bar is equal to InpForward, then draw line that shows OOS period

    if (position == InpForward)
    {
        datetime dates[];
        CopyTime(Symbol(), InpTimePeriod, position, 1, dates);
        SetLine(InpMagic, dates[0]);
    }

    // If current bar is older then InpForward, compute PCA vectors, otherwise, use previously calculated

    if (position > InpForward - 1)
    {
        CAlglib::PCABuildBasis(iMatrices, iFrame, iOrder, result, iG.iVars, iVectors);
        
        // PCA does't pay attention to resulting sign of the vector
        // Thus, to prevent false sign changes, calculate most probable sign, based on previous values
        
        double plus = 0;
        double minus = 0;
        
        for (int k = 0; k < iOrder; k++) 
        {
            plus += MathAbs(iVectors[k][InpVector] + iG.iSigns[k]);
            minus += MathAbs(iVectors[k][InpVector] - iG.iSigns[k]);
        }

        sign = Inverse(iVectors, iG.iSigns, iOrder) || minus > plus ? -1 : 1;
    }
    else
    {
        // If this is first PCA value, think that sign is correct and leave it as is
    
        sign = 1;
    }

    // Update PCA vectors with correct sign

    for (int k = 0; k < iOrder; k++) 
    {
        iVectors[k].Set(InpVector, iVectors[k][InpVector] * sign);
        synthetics += iCharts[k].mPoints[last].mPoint * iVectors[k][InpVector];
        iG.iSigns[k] = iVectors[k][InpVector];
    }

    // Show vector values for each currency on the chart, until OOS period

    if (position > InpForward - 1)
    {
        ShowVectorCustom(iSeries, iVectors, InpVector, iOrder, InpMagic);
    }

    // Show either synthetics or list of separate, normalized and smoothed by MA, currency pairs

    if (InpSynthetics)
    {
        iG.S0[position] = EMA(synthetics, iG.S0[position + 1], InpMaPeriod);
    }
    else
    {
        if (iLines > 0) iG.S0[position] = EMA(iCharts[0].mPoints[last].mPoint, iG.S0[position + 1], InpMaPeriod);
        if (iLines > 1) iG.S1[position] = EMA(iCharts[1].mPoints[last].mPoint, iG.S1[position + 1], InpMaPeriod);
        if (iLines > 2) iG.S2[position] = EMA(iCharts[2].mPoints[last].mPoint, iG.S2[position + 1], InpMaPeriod);
        if (iLines > 3) iG.S3[position] = EMA(iCharts[3].mPoints[last].mPoint, iG.S3[position + 1], InpMaPeriod);
        if (iLines > 4) iG.S4[position] = EMA(iCharts[4].mPoints[last].mPoint, iG.S4[position + 1], InpMaPeriod);
        if (iLines > 5) iG.S5[position] = EMA(iCharts[5].mPoints[last].mPoint, iG.S5[position + 1], InpMaPeriod);
        if (iLines > 6) iG.S6[position] = EMA(iCharts[6].mPoints[last].mPoint, iG.S6[position + 1], InpMaPeriod);
        if (iLines > 7) iG.S7[position] = EMA(iCharts[7].mPoints[last].mPoint, iG.S7[position + 1], InpMaPeriod);
        if (iLines > 8) iG.S8[position] = EMA(iCharts[8].mPoints[last].mPoint, iG.S8[position + 1], InpMaPeriod);
        if (iLines > 9) iG.S9[position] = EMA(iCharts[9].mPoints[last].mPoint, iG.S9[position + 1], InpMaPeriod);
    }

    // Set global values that can be used by EA

    for (int k = 0; k < iOrder; k++)
    {
        GlobalVariableSet(InpMagic + ":" + "V" + ":" + iSeries[k].mSymbol.mName, iVectors[k][InpVector]);
        GlobalVariableSet(InpMagic + ":" + "S" + ":" + iSeries[k].mSymbol.mName, iSeries[k].mPoints[last].mPoint / SymbolInfoDouble(iSeries[k].mSymbol.mName, SYMBOL_POINT));
    }
    
    return 1;
}

/**
 * Display vector values (coefficients) at the top right corner
 */
void ShowVectorCustom(SSeries& series[], CMatrixDouble& vectors, const int index, const int order, const string name)
{
    double max = 0;    
    datetime times[];
    int X = 10, Y = 5, size = 8, offset = int(ChartGetDouble(0, CHART_SHIFT_SIZE) * ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) / 100);

    // Choose min and max to scale appropriately

    for (int k = 0; k < order; k++) 
    {
        max = MathAbs(vectors[k][index]) > max ? MathAbs(vectors[k][index]) : max;
    }

    int maxPixel = offset - 155;

    // Draw each vector

    for (int k = 0; k < order; k++) 
    {
        string alignment = (vectors[k][index] >= 0 ? " " : "") + DoubleToString(vectors[k][index], _Digits);
        string label = StringFormat("%s  | %s", series[k].mSymbol.mName, alignment);
        int level = int(MathCeil(MathAbs(vectors[k][index]) * maxPixel / (max == 0 ? 1 : max)));

        ShowItem(name, OBJ_LABEL, name + series[k].mSymbol.mName + "A", label, X, Y, size, clrBlack);
        ShowItem(name, OBJ_RECTANGLE_LABEL, name + series[k].mSymbol.mName + "B", series[k].mSymbol.mName, X + level + 140, Y + 2, size, vectors[k][index] > 0 ? clrDeepSkyBlue : clrTomato, level, 10);
        
        Y += size * 2;
    }
}

/**
 * Check if sign accidentally changed and needs to be inverted after previous PCA calculation
 */
bool Inverse(CMatrixDouble &vectors, double &signs[], int order)
{
    for (int k = 0; k < order; k++)
    {
        bool C1 = MathMax(vectors[k][InpVector], 0) > 0 && MathMax(signs[k], 0) > 0;
        bool C2 = MathMin(vectors[k][InpVector], 0) < 0 && MathMin(signs[k], 0) < 0;
    
        if (C1 || C2)
        {
            return false;
        }
    }

    return true;
}