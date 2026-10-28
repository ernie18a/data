#include <AIV/Resources.mqh>

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

void setupSeries(SSeries& series[], const int rows, const int cols)
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

void setupMatrix(SMatrix& series[], const int rows, const int cols)
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

int getMinIndex(SSeries& series[], const int order)
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

void getReturnsMatrix(SSeries& series[], SSeries& equity[], const int order, const int depth)
{
    for (int k = 0; k < order; k++)
    {
        equity[k].mPoints[0].mPoint = (series[k].mPoints[1].mPoint - series[k].mPoints[0].mPoint) / series[k].mPoints[0].mPoint;
        
        for (int n = 1; n < depth; n++)
        {
            equity[k].mPoints[n].mPoint = (series[k].mPoints[n].mPoint - series[k].mPoints[n - 1].mPoint) / series[k].mPoints[n - 1].mPoint;
        }
    }
}

void getEquityMatrix(SSeries& series[], SSeries& equity[], const int order, const int depth, const bool mean)
{
    int minIndex = getMinIndex(series, order);

    for (int k = 0; k < order; k++)
    {
        double cost = getTickCost(series[k].mSymbol.mName);

        equity[k].mSymbol.mMean = 0;
        series[k].mSymbol.mUnit = series[k].mSymbol.mUnit == 0 ? series[k].mPoints[0].mPoint : series[k].mSymbol.mUnit;

        for (int n = 0; n < depth; n++)
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

void getLogMatrix(SSeries& series[], SSeries& equity[], const int order, const int depth, const bool mean)
{
    for (int k = 0; k < order; k++)
    {
        equity[k].mSymbol.mMean = 0;
        
        for (int n = 0; n < depth; n++)
        {
            equity[k].mPoints[n].mPoint = MathLog(series[k].mPoints[n].mPoint);
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

void getLimitMatrix(SSeries& series[], SSeries& equity[], const int order, const int depth, const bool mean)
{
    for (int k = 0; k < order; k++)
    {
        double min =  1000000;
        double max = -1000000;
        
        for (int n = 0; n < depth; n++)
        {
            if (series[k].mPoints[n].mPoint > max) max = series[k].mPoints[n].mPoint;
            if (series[k].mPoints[n].mPoint < min) min = series[k].mPoints[n].mPoint;
        }
        
        equity[k].mSymbol.mUnit = min;
        equity[k].mSymbol.mOrder = max - min;
    }
    
    if (mean) 
    {
        for (int k = 0; k < order; k++)
        {
            for (int n = 0; n < depth; n++)
            {
                equity[k].mPoints[n].mPoint = (series[k].mPoints[n].mPoint - equity[k].mSymbol.mUnit) / equity[k].mSymbol.mOrder;
            }
        }
    }
}