//+------------------------------------------------------------------+
//|                                               VolatilityStop.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1

//--- plot VStop
#property indicator_label1  "VStop"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  C'0x00,0x96,0x88',C'0xF4,0x43,0x36',clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- input parameters
input uint                 InpPeriod      =  20;            // Length
input ENUM_APPLIED_PRICE   InpPrice       =  PRICE_CLOSE;   // Source
input double               InpMultiplier  =  1.75;          // Multiplier

//--- indicator buffers
double         ExtBufferVStop[];
double         ExtBufferColors[];
double         ExtBufferATR[];
double         ExtBufferSRC[];

//--- global variables
int            ExtPeriod;
double         ExtMultiplier;
int            ExtHandleATR;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBufferVStop,INDICATOR_DATA);
   SetIndexBuffer(1,ExtBufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ExtBufferATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtBufferSRC,INDICATOR_CALCULATIONS);
   
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,158);
   
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(ExtBufferVStop,true);
   ArraySetAsSeries(ExtBufferColors,true);
   ArraySetAsSeries(ExtBufferATR,true);
   ArraySetAsSeries(ExtBufferSRC,true);
   
//--- setting the parameters and short name for the indicator
   ExtPeriod    =int(InpPeriod<2 ? 2 : InpPeriod);
   ExtMultiplier=(InpMultiplier<0.25 ? 0.25 : InpMultiplier);
   
   string shortname=StringFormat("VStop %u %s %.2f",ExtPeriod,AppliedPriceDescription(InpPrice),ExtMultiplier);
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- creating an ATR indicator handle
   ResetLastError();
   ExtHandleATR=iATR(NULL,PERIOD_CURRENT,ExtPeriod);
   if(ExtHandleATR==INVALID_HANDLE)
     {
      PrintFormat("The iATR(%d) object was not created: Error %d",ExtPeriod, GetLastError());
      return INIT_FAILED;
     }
//--- success
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
//--- checking for the minimum number of bars for calculation
   if(rates_total<ExtPeriod)
      return 0;
      
//--- setting predefined indicator arrays as timeseries
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low,  true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   
//--- checking and calculating the number of bars to be calculated
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-ExtPeriod-2;
      ArrayInitialize(ExtBufferVStop,EMPTY_VALUE);
      ArrayInitialize(ExtBufferColors,2);
      ArrayInitialize(ExtBufferATR,0);
      ArrayInitialize(ExtBufferSRC,0);
     }
     
//--- calculate RAW data
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(ExtHandleATR,0,0,count,ExtBufferATR);
   if(copied!=count)
      return 0;

//--- calculation Volatility Stop
   for(int i=limit; i>=0; i--)
     {
      double price=GetPriceSRC(i, open, high, low, close);
      double stop=ExtBufferVStop[i+1];
      double upper=price+ExtMultiplier*ExtBufferATR[i];
      double lower=price-ExtMultiplier*ExtBufferATR[i];
      ExtBufferColors[i]=2;

      if(price>ExtBufferVStop[i+1])
        {
         stop=fmax(ExtBufferVStop[i+1], lower);
         ExtBufferColors[i]=0;
        }
      else if(price<ExtBufferVStop[i+1])
        {
         stop=fmin(ExtBufferVStop[i+1], upper);
         ExtBufferColors[i]=1;
        }

      if(ExtBufferColors[i]!=ExtBufferColors[i+1])
         stop=(ExtBufferColors[i]==0 ? lower : ExtBufferColors[i]==1 ? upper : price);

      ExtBufferVStop[i]=stop;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает цену                                                  |
//+------------------------------------------------------------------+
double GetPriceSRC(const int index, const double &open[], const double &high[], const double &low[], const double &close[])
  {
   switch(InpPrice)
     {
      case PRICE_OPEN      : return open[index];
      case PRICE_HIGH      : return high[index];
      case PRICE_LOW       : return low[index];
      case PRICE_CLOSE     : return close[index];
      case PRICE_MEDIAN    : return (high[index] + low[index]) / 2.0;
      case PRICE_TYPICAL   : return (high[index] + low[index] + close[index]) / 3.0;
      case PRICE_WEIGHTED  : return (high[index] + low[index] + close[index] + close[index] )/4;
      default: return 0;
     }
  }
//+------------------------------------------------------------------+
//| Возвращает описание цены расчёта                                 |
//+------------------------------------------------------------------+
string AppliedPriceDescription(const ENUM_APPLIED_PRICE price)
  {
   string res=StringSubstr(EnumToString(price),6);
   if(res.Lower())
      res.SetChar(0,ushort(res.GetChar(0)-32));
   return res;
  }
//+------------------------------------------------------------------+
