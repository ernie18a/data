#property indicator_separate_window 
#property indicator_buffers 1
#property indicator_plots 1

#property indicator_type1 DRAW_LINE
#property indicator_color1 clrBlue

input int InpDepth = 1500;
input bool InpAlign = true;
input ENUM_TIMEFRAMES InpTimePeriod = PERIOD_CURRENT;
input string InpExpression = "2 ^ (1 + EURUSD.m) + EURUSD.m / 3.5 * GBPUSD.m";

#include <AIV/Matrices.mqh>

int iSize;
int iDepth;
int iLoader;
double S0[];
string iNames[];
string iValues[];
string iTokens[];
SSeries iSeries[];
SSeries iCharts[];
CExpression * iExpression;

void OnDeinit(const int reason)
{
    delete(iExpression);
}

int OnInit()
{
    SetIndexBuffer(0, S0, INDICATOR_DATA); 
    ArraySetAsSeries(S0, true); 
    ArrayInitialize(S0, 0);
    
    IndicatorSetInteger(INDICATOR_DIGITS, 5);
    IndicatorSetString(INDICATOR_SHORTNAME, InpExpression);

    string duplicates = "";
    iExpression = new CExpression();
    string expression = iExpression.getExpression(InpExpression, iTokens);
    int tokens = ArraySize(iTokens);

    for (int k = 0; k < tokens; k++) 
    {
        if (StringFind(duplicates, iTokens[k]) < 0 && SymbolSelect(iTokens[k], true))
        {
            int symbols = ArraySize(iSeries);
            ArrayResize(iSeries, symbols + 1);
            iSeries[symbols].mSymbol.mName = iTokens[k];
            duplicates += iTokens[k];
        }
    }

    iLoader = 0;
    iDepth = InpDepth;
    iSize = ArraySize(iSeries);

    ArrayResize(iNames, iSize);
    ArrayResize(iValues, iSize);
    
    setupSeries(iSeries, iSize, iDepth);
    setupSeries(iCharts, iSize, iDepth);
    
    EventSetMillisecondTimer(500);

    return(0);
}

/**
 * Preload quotes from missing charts by timer
 */
void OnTimer()
{
    int bars = Bars(Symbol(), InpTimePeriod);

    if (iDepth > bars)
    {
        iDepth = MathMin(bars - 1, iDepth);
    }

    if (synchronize(iSeries, InpTimePeriod, iSize, iDepth, 0, false) < 1)
    {
        return;
    }

    iLoader = 1;
    
    Calculate();
    ChartRedraw(ChartID());
    EventKillTimer();
}

int OnCalculate(const int bars, const int counted, const int start, const double &price[])
{
    if (iLoader == 1)
    {
        Calculate();
    }
    
    return bars;
}

int Calculate()
{
    int records = PeriodSeconds(PERIOD_CURRENT) >= PeriodSeconds(PERIOD_D1) ? 
        getQuotes(iSeries, InpTimePeriod, iSize, iDepth, 0) : 
        synchronize(iSeries, InpTimePeriod, iSize, iDepth, 0, false);

    if (records < 1)
    {
        return 0;
    }

    if (InpAlign)
    {   
        getEquityMatrix(iSeries, iCharts, iSize, records, false);
    }
    
    int index = 0;
    int bars = ArraySize(S0);

    for (int k = records - 1; k >= 0; k--)
    {
        for (int n = 0; n < iSize; n++)
        {
            iNames[n] = iSeries[n].mSymbol.mName;
            iValues[n] = DoubleToString(InpAlign ? iCharts[n].mPoints[k].mPoint : iSeries[n].mPoints[k].mPoint);
        }
        
        if (index >= bars - 1)
        {
            break;
        }
        
        S0[index] = iExpression.getResult(iTokens, iNames, iValues);
        index++;
    }

    return 1;
}