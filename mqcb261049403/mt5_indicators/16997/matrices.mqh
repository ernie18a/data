#include <AIV/Resources.mqh>

/**
 * Copy array of structures
 */
void copySeries(SSeries &source[], SSeries &destination[])
{
    int N = ArraySize(source);
    
    for (int k = 0; k < N; k++)
    {
        destination[k].mSymbol.mName = source[k].mSymbol.mName;
        destination[k].mSymbol.mMean = source[k].mSymbol.mMean;
        destination[k].mSymbol.mUnit = source[k].mSymbol.mUnit;
        destination[k].mSymbol.mOrder = source[k].mSymbol.mOrder;
        ArrayCopy(destination[k].mPoints, source[k].mPoints);
    }
}

/**
 * Clean up and initialize array of structures
 */
void setupSeries(SSeries& series[], int rows, int cols)
{
    ArrayResize(series, rows);
    
    for (int k = 0; k < rows; k++)
    {
        series[k].mSymbol.mMean = 0;
        series[k].mSymbol.mUnit = 0;
        series[k].mSymbol.mOrder = 0;
        ArrayResize(series[k].mPoints, cols);
    }
}

/**
 * Copy matrices
 */
void setupMatrix(SMatrix& series[], int rows, int cols)
{
    ArrayResize(series, rows);
    
    for (int k = 0; k < rows; k++)
    {
        series[k].mSymbol.mMean = 0;
        series[k].mSymbol.mUnit = 0;
        series[k].mSymbol.mOrder = 0;
        ArrayResize(series[k].mAsk, cols);
        ArrayResize(series[k].mBid, cols);
        ArrayResize(series[k].mLow, cols);
        ArrayResize(series[k].mHigh, cols);
        ArrayResize(series[k].mOpen, cols);
        ArrayResize(series[k].mClose, cols);
        ArrayResize(series[k].mPoint, cols);
        ArrayResize(series[k].mSpread, cols);
        ArrayResize(series[k].mVolume, cols);
        ArrayResize(series[k].mTime, cols);
    }
}

/**
 * Get number of minimum available bars in history
 */
int getBars(SSeries& series[], ENUM_TIMEFRAMES period, int order)
{
    int bars = 1000000;

    for (int k = 0; k < order; k++)
    {
        MqlRates rates[];
        bars = MathMin(bars, Bars(series[k].mSymbol.mName, period));
        
        if (bars < 1)
        {
            Print(
                "Synchronization : " + series[k].mSymbol.mName + ", " + 
                "Bars : " + IntegerToString(bars));
            
            return 0;
        }
    }
    
    return bars;
}        

/**
 * List combinations of provided currencies
 */
int listCombinations(SSeries& series[], string names, string end = "")
{
    string syms[];
    int index = 0;
    int count = StringSplit(names, ',', syms);

    for (int k = 0; k < count; k++)
    {
        for (int n = 0; n < count; n++)
        {
            string s1 = syms[k] + syms[n];
            string s2 = syms[n] + syms[k];
            bool c1 = SymbolSelect(s1 + end, true);
            bool c2 = SymbolSelect(s2 + end, true);
            bool c3 = seriesByName(series, index, s1 + end) < 0;
            bool c4 = seriesByName(series, index, s2 + end) < 0;
            bool c5 = SymbolInfoInteger(s1 + end, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL;
            bool c6 = SymbolInfoInteger(s2 + end, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL;

            if ((c1 && c3 && c5) || (c2 && c4 && c6))
            {
                ArrayResize(series, index + 1);
                series[index].mSymbol.mName = (c1 ? s1 : s2) + end;
                index++;
            }
        }
    }

    return index;
}

/**
 * Split string of symbols by separator
 */
int listPairs(SSeries& series[], string names, bool validate = true)
{
    string syms[];
    int index = 0, count = StringSplit(names, ',', syms);

    for (int k = 0; k < count; k++)
    {
        string inverse = StringSubstr(syms[k], 3, 3) + StringSubstr(syms[k], 0, 3) + StringSubstr(syms[k], 6);
        bool A = SymbolSelect(syms[k], true) && SymbolInfoInteger(syms[k], SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL;
        bool B = SymbolSelect(inverse, true) && SymbolInfoInteger(inverse, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL;

        if (A || validate == false)
        {
            ArrayResize(series, index + 1); 
            series[index].mSymbol.mName = syms[k];
            series[index].mSymbol.mOrder = 0;
            index++;
        }
        else if (B || validate == false)
        {
            ArrayResize(series, index + 1); 
            series[index].mSymbol.mName = inverse;
            series[index].mSymbol.mOrder = 1;
            index++;
        }
    }
    
    return index;
}

int getGroups(SSeries &series[], SGroup &groups[], string symbol = NULL)
{
    int n = 0;
    uchar codes[];
    
    int K = ArraySize(series);
    ArrayResize(codes, K);
    ArrayFill(codes, 0, K, 0);

    while (getChain(codes, K))
    {
        string name;
    
        for (int k = 0; k < K; k++) 
        {
            name += codes[k] ? (series[k].mSymbol.mName + ":") : "";
        }
        
        if (symbol == NULL || isChannel(name, symbol))
        {
            ArrayResize(groups, n + 1);
            groups[n++].mName = StringSubstr(name, 0, StringLen(name) - 1);
        }
   }

    return ArraySize(groups);
}

int isChannel(string name, string symbol = NULL)
{
    string T;
    string B;
    string sT;
    string sB;

    ZeroMemory(T);
    ZeroMemory(B);

    int L = StringLen(name);
    int E = StringLen(":");

    for (int k = 0; k < L; k += E + 6)
    {
        sT = StringSubstr(name, k, 3);
        sB = StringSubstr(name, k + 3, 3);

        int D1 = StringFind(T, sB);
        int D2 = StringFind(B, sT);

        if (D1 > -1) T = StringSubstr(T, 0, D1) + StringSubstr(T, D1 + 3, StringLen(T)); else B += sB;
        if (D2 > -1) B = StringSubstr(B, 0, D2) + StringSubstr(B, D2 + 3, StringLen(B)); else T += sT;
    }

    return 
        (symbol == NULL && StringLen(T) == 0 && StringLen(B) == 0) || 
        (StringLen(B) == 0 && StringFind(T, symbol) > -1) || 
        (StringLen(T) == 0 && StringFind(B, symbol) > -1);
}

string logRange(SSeries &series[], SBet &results[])
{
    string bets = "";
    int K = ArraySize(series);
    
    if (K > 0)
    {
        int N = ArraySize(series[0].mPoints);
        ArrayResize(results, N);
    
        for (int n = 0; n < N; n++)
        {
            int C = 0;
            int W = 0;
        
            for (int k = 0; k < K; k++)
            {
                if (series[k].mPoints[n].mPoint < 2)
                {
                    C++;
                    if (series[k].mPoints[n].mPoint == 1) W += int(series[k].mPoints[n].mPoint);
                }
            }
    
            results[n].mPlus = W;
            results[n].mCount = C;
            results[n].mMinus = C - W;
    
            bets += 
                IntegerToString(n) + " : " + 
                IntegerToString(C) + " : " + 
                IntegerToString(W) + " : " + 
                IntegerToString(C - W) + (n < N - 1 ? "\n" : "");
        }
    }
    
    return bets;
}

/** 
 * Get quotes without synchronization
 */
int getQuotes(SSeries& series[], ENUM_TIMEFRAMES period, int order, int depth, int position)
{
    int bars = MathMin(getBars(series, period, order), depth);

    for (int k = 0; k < order; k++)
    {
        MqlRates rates[];
        int counted = CopyRates(series[k].mSymbol.mName, period, position, bars, rates);

        if (counted < 1)
        {
            Print(
                "Synchronization : " + series[k].mSymbol.mName + ", " + 
                "Position : " + IntegerToString(position) + ", " + 
                "Depth : " + IntegerToString(depth) + ", " + 
                "Bars : " + IntegerToString(bars));

            return 0;
        }
        
        int index = counted - 1;
        
        for (int n = index; n > -1; n--)
        {
            series[k].mPoints[n].mLow = rates[n].low;
            series[k].mPoints[n].mHigh = rates[n].high;
            series[k].mPoints[n].mOpen = rates[n].open;
            series[k].mPoints[n].mClose = rates[n].close;
            series[k].mPoints[n].mPoint = rates[n].close;
            series[k].mPoints[n].mSpread = rates[n].spread;
            series[k].mPoints[n].mVolume = double(rates[n].tick_volume);
            series[k].mPoints[n].mTime = rates[n].time;
        }
    }

    return bars;
}

/**
 * Synchronize series by time
 */
int synchronize(SSeries& series[], ENUM_TIMEFRAMES period, int order, int depth, int position, bool closes = true)
{
    int bars = MathMin(getBars(series, period, order), depth);
    datetime lastTime = getLastTime(series, period, position);

    for (int k = 0; k < order; k++)
    {
        MqlRates rates[];
        datetime currentTime = lastTime;
        double points = SymbolInfoDouble(series[k].mSymbol.mName, SYMBOL_POINT);
        int counted = CopyRates(series[k].mSymbol.mName, period, position, bars, rates);

        if (counted < 1)
        {
            Print(
                "Synchronization : " + series[k].mSymbol.mName + ", " + 
                "Position : " + IntegerToString(position) + ", " + 
                "Depth : " + IntegerToString(depth) + ", " + 
                "Bars : " + IntegerToString(bars));
            
            return 0;
        }

        int index = counted - 1;
        
        series[k].mSymbol.mMean = 0;
        series[k].mPoints[depth - 1].mLow = rates[index].low;
        series[k].mPoints[depth - 1].mHigh = rates[index].high;
        series[k].mPoints[depth - 1].mOpen = rates[index].open;
        series[k].mPoints[depth - 1].mClose = rates[index].close;
        series[k].mPoints[depth - 1].mPoint = closes ? rates[index].close : rates[index].open;
        series[k].mPoints[depth - 1].mSpread = rates[index].spread * points;
        series[k].mPoints[depth - 1].mTime = rates[index].time;

        MqlDateTime dates = {0};
        int secondsInPeriod = PeriodSeconds(period);
        int secondsInWeekend = 2 * PeriodSeconds(PERIOD_D1);

        for (int n = depth - 1; n >= 0; n--)
        {
            if (secondsInWeekend >= secondsInPeriod) 
            {
                TimeToStruct(currentTime, dates);

                if (dates.day_of_week == 0) 
                {
                    currentTime -= secondsInWeekend;
                }
            }

            if (currentTime == rates[index].time)
            {
                series[k].mPoints[n].mSpread = rates[index].spread * points;
                series[k].mPoints[n].mPoint = closes ? rates[index].close : rates[index].open;
                series[k].mPoints[n].mClose = rates[index].close;
                series[k].mPoints[n].mOpen = rates[index].open;
                series[k].mPoints[n].mHigh = rates[index].high;
                series[k].mPoints[n].mLow = rates[index].low;
                index = index > 0 ? index - 1 : index;
            }
            else if (n < depth - 1)
            {
                series[k].mPoints[n].mSpread = series[k].mPoints[n + 1].mSpread;
                series[k].mPoints[n].mPoint = series[k].mPoints[n + 1].mPoint;
                series[k].mPoints[n].mClose = series[k].mPoints[n + 1].mClose;
                series[k].mPoints[n].mOpen = series[k].mPoints[n + 1].mOpen;
                series[k].mPoints[n].mHigh = series[k].mPoints[n + 1].mHigh;
                series[k].mPoints[n].mLow = series[k].mPoints[n + 1].mLow;
            }

            series[k].mPoints[n].mTime = currentTime;
            series[k].mSymbol.mMean += series[k].mPoints[n].mPoint;
            currentTime -= PeriodSeconds(period);
        }
        
        series[k].mSymbol.mMean /= depth;
    }

    return bars;
}

/**
 * Search in array of structures by name
 */
int seriesByName(SSeries &series[], int order, string name)
{
    for (int k = 0; k < order; k++)
    {
        if (series[k].mSymbol.mName == name)
        {
            return k;
        }
    }
    
    return -1;
}

/**
 * Clean up and initialize matrices
 */
int getMinIndex(SSeries& series[], int order)
{
    int minIndex = 0;
    double max = 0, min = 1000000;

    for (int k = 0; k < order; k++)
    {
        double currentMin = series[k].mPoints[0].mPoint;
        double currentMax = series[k].mPoints[0].mPoint;

        if (MathAbs(min) > MathAbs(currentMin) && MathAbs(max) > MathAbs(currentMax))
        {
            min = currentMin;
            max = currentMax;
            minIndex = k;
        }
    }
    
    return minIndex;
}

/**
 * Detrend series using derivative expression (O[n] - O[n-1]) / O[n-1]
 */
void getReturnsMatrix(SSeries& series[], SSeries& equity[], int order, int depth, int range = 1)
{
    for (int k = 0; k < order; k++)
    {
        equity[k].mSymbol.mName = series[k].mSymbol.mName;
        
        for (int n = 0; n < range; n++)
        {
            equity[k].mPoints[n].mPoint = series[k].mPoints[n].mPoint - series[k].mPoints[0].mPoint;
        }
        
        for (int n = range; n < depth; n++)
        {
            equity[k].mPoints[n].mPoint = series[k].mPoints[n].mPoint - series[k].mPoints[n - range].mPoint;
        }
    }
}

/**
 * Switch series to common denominator using comparison with start point (O[n] - O[0]) * Tick Cost in USD
 */
void getEquityMatrix(SSeries& series[], SSeries& equity[], int order, int depth, bool mean = true)
{
    for (int k = 0; k < order; k++)
    {
        double cost = getTickCost(series[k].mSymbol.mName);

        equity[k].mSymbol.mMean = 0;
        equity[k].mSymbol.mName = series[k].mSymbol.mName;
        series[k].mSymbol.mUnit = series[k].mSymbol.mUnit == 0 ? series[k].mPoints[0].mPoint : series[k].mSymbol.mUnit;
        equity[k].mPoints[0].mPoint = equity[k].mPoints[0].mPoint;

        for (int n = 1; n < depth; n++)
        {
            equity[k].mPoints[n].mPoint = (series[k].mPoints[n].mPoint - series[k].mSymbol.mUnit) * cost;
            equity[k].mSymbol.mMean += equity[k].mPoints[n].mPoint;
        }

        equity[k].mSymbol.mMean /= depth;
    }
    
    if (mean) 
    {
        for (int k = 0; k < order; k++)
        {
            for (int n = 0; n < depth; n++)
            {
                equity[k].mPoints[n].mPoint -= equity[k].mSymbol.mMean;
            }
        }
    }
}

/**
 * Switch series to abstract approximation log(O[n])
 */
void getLogMatrix(SSeries& series[], SSeries& equity[], int order, int depth)
{
    for (int k = 0; k < order; k++)
    {
        equity[k].mSymbol.mMean = 0;
        equity[k].mSymbol.mName = series[k].mSymbol.mName;
        
        for (int n = 0; n < depth; n++)
        {
            equity[k].mPoints[n].mPoint = MathLog(series[k].mPoints[n].mPoint);
            equity[k].mSymbol.mMean += equity[k].mPoints[n].mPoint;
        }

        equity[k].mSymbol.mMean /= depth;
    }
    
    for (int k = 0; k < order; k++)
    {
        for (int n = 0; n < depth; n++)
        {
            equity[k].mPoints[n].mPoint -= equity[k].mSymbol.mMean;
        }
    }
}

/**
 * Switch series to scaled chart from -1 to 1
 */
void getLimitMatrix(SSeries& series[], SSeries& equity[], int order, int depth)
{
    for (int k = 0; k < order; k++)
    {
        equity[k].mSymbol.mMean = 0;
        equity[k].mSymbol.mName = series[k].mSymbol.mName;
        equity[k].mPoints[0].mPoint = series[k].mPoints[0].mPoint;
        series[k].mSymbol.mUnit = series[k].mSymbol.mUnit == 0 ? series[k].mPoints[0].mPoint : series[k].mSymbol.mUnit;
    
        for (int n = 0; n < depth; n++)
        {
            equity[k].mPoints[n].mPoint = (series[k].mPoints[n].mPoint / series[k].mSymbol.mUnit - 1) * 100;
        }
    }
}