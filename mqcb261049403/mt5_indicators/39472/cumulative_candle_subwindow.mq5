//+------------------------------------------------------------------+
//|                                  Cumulative candle subwindow.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot High
#property indicator_label1  "Cumulative"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrLavender,clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//--- indicator buffers
double   HighBuffer[];
double   LowBuffer[];
double   ColorColors[];
//---
double   m_high=0.0;
double   m_low=0.0;
int      m_type=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,HighBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ColorColors,INDICATOR_COLOR_INDEX);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//---
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
//---
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      limit=0;
      m_high=high[limit];
      m_low=low[limit];
      m_type=(open[limit]<close[limit])?1:-1;
     }
   for(int i=limit; i<rates_total; i++)
     {
      int current_type=(open[i]<close[i])?1:-1;
      if(m_type!=current_type)
        {
         m_high=high[i];
         m_low=low[i];
         m_type=current_type;
        }
      else
        {
         if(high[i]>m_high)
            m_high=high[i];
         if(low[i]<m_low)
            m_low=low[i];
         m_type=current_type;
        }
      //---
      HighBuffer[i]=m_high;
      LowBuffer[i]=m_low;
      if(m_type==1)
        {
         ColorColors[i]=0.0;
        }
      else
        {
         ColorColors[i]=1.0;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
