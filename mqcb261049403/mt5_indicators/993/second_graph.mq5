//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input string symbol1="EURUSD";
int i;
//--- indicator buffers
double        ind1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ind1,INDICATOR_DATA);
//---
   return(0);
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
   ArraySetAsSeries(time,true);ArraySetAsSeries(open,true);ArraySetAsSeries(high,true);ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);ArraySetAsSeries(tick_volume,true);ArraySetAsSeries(volume,true);ArraySetAsSeries(spread,true);

   ArraySetAsSeries(ind1,true);
   MqlRates rates1[]; ArraySetAsSeries(rates1,true);

   if(prev_calculated<rates_total)
     {
      for(i=0;i<rates_total;i++)
        {
         CopyRates(symbol1,0,time[i],1,rates1);
         ind1[i]=rates1[0].close;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
