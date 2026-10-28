//+------------------------------------------------------------------+
//|                                                   PriceSpeed.mq5 |
//|                                    Copyright (c) 2019, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//+------------------------------------------------------------------+

#property copyright "Copyright (c) 2019, Marketeer"
#property link      "https://www.mql5.com/en/users/marketeer"
#property version   "3.1"
#property description "Calculates average and peak (efficient) speed of price in true and false directions, shows standard deviation for specified period. All values are in points per minute.\n"
#property description "Inspired by Average Speed indicator (https://www.mql5.com/en/code/1544) by Totom Sukopratomo, but thoroughly reworked and improved."

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   5

#property indicator_label1  "Average Speed"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

#property indicator_label2  "Peak True Speed"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Peak False Speed"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "Peak Deviation Up"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_DOT
#property indicator_width4  1

#property indicator_label5  "Peak Deviation Dn"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_style5  STYLE_DOT
#property indicator_width5  1

// input parameters
input int n = 3; // Averaging Bars
input ENUM_APPLIED_PRICE price = PRICE_CLOSE; // Price
input int m = 5; // Peak Deviation Period

// indicator buffers
double OutputBuffer1[];
double OutputBuffer2[];
double OutputBuffer3[];
double SmoothBuffer[];
double SmoothMirror[];

int OnInit()
{
  // indicator buffers mapping
  SetIndexBuffer(0, OutputBuffer1, INDICATOR_DATA);
  SetIndexBuffer(1, OutputBuffer2, INDICATOR_DATA);
  SetIndexBuffer(2, OutputBuffer3, INDICATOR_DATA);
  SetIndexBuffer(3, SmoothBuffer, INDICATOR_DATA);
  SetIndexBuffer(4, SmoothMirror, INDICATOR_DATA);
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  IndicatorSetString(INDICATOR_SHORTNAME, "PriceSpeed(" + (string)n + "," + (string)m + ")");

  return(0);
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
  int limit;
  
  if(prev_calculated == 0)
  {
    limit = n;
  }
  else
  {
    limit = prev_calculated - 1;
  }
  
  for(int i = limit; i < rates_total; i++)
  {
    double v = 0, // speed (point / minute)
           d = 0; // true distance (points)
    double f = 0; // false distance
    const int t = GetMinute(); // time (minute)
    double sumv = 0, sumw = 0, sumf = 0;
    for(int j = i - n + 1; j <= i && j < rates_total; j++)
    {
      d = (close[j] - close[j - 1]) / _Point;
      if(d > 0) // up candle
      {
        d = (high[j] - low[j]) / _Point;
        f = MathMin(low[j] - open[j], close[j] - high[j]) / _Point;
      }
      else // down candle
      {
        d = (low[j] - high[j]) / _Point;
        f = MathMax(high[j] - open[j], close[j] - low[j]) / _Point;
      }
      sumw += d / t;
      sumf += f / t;
      
      switch(price)
      {
        case PRICE_CLOSE:
          d = (close[j] - close[j - 1]) / _Point;
          break;

        case PRICE_HIGH:
          d = (high[j] - high[j - 1]) / _Point;
          break;

        case PRICE_LOW:
          d = (low[j] - low[j - 1]) / _Point;
          break;

        case PRICE_MEDIAN:
          d = ((high[j] + low[j]) / 2 - (high[j - 1] + low[j - 1]) / 2) / _Point;
          break;

        case PRICE_OPEN:
          d = (open[j] - open[j - 1]) / _Point;
          break;

        case PRICE_TYPICAL:
          d = ((high[j] + low[j] + close[j]) / 3 - (high[j - 1] + low[j - 1] + close[j - 1]) / 3) / _Point;
          break;

        case PRICE_WEIGHTED:
          d = ((high[j] + low[j] + close[j] + close[j]) / 4 - (high[j - 1] + low[j - 1] + close[j - 1] + close[j - 1]) / 4) / _Point;
          break;
      }
      v = d / t;
      sumv += v;
    }

    OutputBuffer1[i] = sumv / n;
    OutputBuffer2[i] = sumw / n;
    OutputBuffer3[i] = sumf / n;
  }

  int N = MathMax(1, m - 1);
  for(int i = limit; i < rates_total; i++)
  {
    SmoothBuffer[i] = 0;
    for(int j = i - m + 1; j >= 0 && j <= i && j < rates_total; j++)
    {
      SmoothBuffer[i] += OutputBuffer2[j] * OutputBuffer2[j];
    }
    SmoothBuffer[i] = sqrt(SmoothBuffer[i] / N);
    SmoothMirror[i] = -SmoothBuffer[i];
  }

  // return value of prev_calculated for next call
  return(rates_total);
}

//+------------------------------------------------------------------+

int GetMinute()
{
  return PeriodSeconds(_Period) / 60;
}
