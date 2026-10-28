//+------------------------------------------------------------------+
//|                                                 ZZVolatility.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.01"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2

//--- plot VStop
#property indicator_label1  "ZZV"
#property indicator_type1   DRAW_COLOR_SECTION
#property indicator_color1  clrBlue, clrRed,clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label2  "VStop"
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_color2  C'0x00,0x96,0x88',C'0xF4,0x43,0x36',clrGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input uint                 InpPeriod      =  20;            // Length
input ENUM_APPLIED_PRICE   InpPrice       =  PRICE_CLOSE;   // Source
input double               InpMultiplier  =  1.75;          // Multiplier
input bool                 InpZZonly      =  true;           // ZZ only
//--- indicator buffers
double         ExtBufferZZ[];
double         ExtBufferColorsZZ[];
double         ExtBufferVStop[];
double         ExtBufferColors[];
double         ExtBufferATR[];

//--- global variables
int            index;
int            ExtPeriod;
double         ExtMultiplier;
int            ExtHandleATR;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, ExtBufferZZ, INDICATOR_DATA);
   SetIndexBuffer(1, ExtBufferColorsZZ, INDICATOR_COLOR_INDEX);
   if(!InpZZonly)
      SetIndexBuffer(2, ExtBufferVStop, INDICATOR_DATA);
   else
      SetIndexBuffer(2, ExtBufferVStop, INDICATOR_CALCULATIONS);

   SetIndexBuffer(3, ExtBufferColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4, ExtBufferATR, INDICATOR_CALCULATIONS);

//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);

   if(!InpZZonly)
     {
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_COLOR_ARROW);
      PlotIndexSetInteger(1, PLOT_ARROW, 159);
     }
   else
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);

//--- setting the parameters and short name for the indicator
   ExtPeriod    = int(InpPeriod < 2 ? 2 : InpPeriod);
   ExtMultiplier = (InpMultiplier < 0.25 ? 0.25 : InpMultiplier);

   string shortname = StringFormat("ZZVol %u %s %.2f", ExtPeriod, AppliedPriceDescription(InpPrice), ExtMultiplier);
   IndicatorSetString(INDICATOR_SHORTNAME, shortname);

//--- creating an ATR indicator handle
   ResetLastError();
   ExtHandleATR = iATR(NULL, PERIOD_CURRENT, ExtPeriod);
   if(ExtHandleATR == INVALID_HANDLE)
     {
      PrintFormat("The iATR(%d) object was not created: Error %d", ExtPeriod, GetLastError());
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
   if(rates_total < ExtPeriod)
      return 0;

//--- checking and calculating the number of bars to be calculated
   int limit = prev_calculated;
   if(prev_calculated <= 0)
     {
      if(CopyBuffer(ExtHandleATR, 0, 0, rates_total, ExtBufferATR) <= 0)
         return(0);

      limit = ExtPeriod + 2;
      index = limit;

      ArrayInitialize(ExtBufferZZ, 0);
      ArrayInitialize(ExtBufferVStop, 0);
     }
   else
      if(prev_calculated != rates_total)
         if(CopyBuffer(ExtHandleATR, 0, 0, rates_total - limit, ExtBufferATR) <= 0)
            return(rates_total);

//--- calculation Volatility Stop
   for(int i = limit - 1; i < rates_total - 1; i++)
     {
      double price = GetPriceSRC(i, open, high, low, close);
      ExtBufferZZ[i] = 0;
      ExtBufferVStop[i] = 0;
      ExtBufferColors[i] = 2;
      ExtBufferColorsZZ[i] = 2;
      bool coup = true;

      if(price > ExtBufferVStop[i - 1])
        {
         double lower = price - ExtMultiplier * ExtBufferATR[i];
         if(ExtBufferColors[i - 1] != 0)
           {
            ExtBufferVStop[i] = lower;
            coup = false;
           }
         else
            ExtBufferVStop[i] = fmax(ExtBufferVStop[i - 1], lower);

         ExtBufferColors[i] = 0;
         ExtBufferColorsZZ[i] = 0;

         if(ExtBufferZZ[index] < high[i])
           {
            if(coup)
               ExtBufferZZ[index] = 0;
            index = i;
            ExtBufferZZ[index] = high[i];
           }
        }
      else
         if(price < ExtBufferVStop[i - 1])
           {
            double upper = price + ExtMultiplier * ExtBufferATR[i];
            if(ExtBufferColors[i - 1] != 1)
              {
               ExtBufferVStop[i] = upper;
               coup = false;
              }
            else
               ExtBufferVStop[i] = fmin(ExtBufferVStop[i - 1], upper);

            ExtBufferColors[i] = 1;
            ExtBufferColorsZZ[i] = 1;

            if(ExtBufferZZ[index] > low[i])
              {
               if(coup)
                  ExtBufferZZ[index] = 0;
               index = i;
               ExtBufferZZ[index] = low[i];
              }
           }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает цену                                                  |
//+------------------------------------------------------------------+
double GetPriceSRC(const int i, const double &open[], const double &high[], const double &low[], const double &close[])
  {
   switch(InpPrice)
     {
      case PRICE_OPEN      :
         return open[i];
      case PRICE_HIGH      :
         return high[i];
      case PRICE_LOW       :
         return low[i];
      case PRICE_CLOSE     :
         return close[i];
      case PRICE_MEDIAN    :
         return (high[i] + low[i]) / 2.0;
      case PRICE_TYPICAL   :
         return (high[i] + low[i] + close[i]) / 3.0;
      case PRICE_WEIGHTED  :
         return (high[i] + low[i] + close[i] + close[i]) / 4;
      default:
         return 0;
     }
  }
//+------------------------------------------------------------------+
//| Возвращает описание цены расчёта                                 |
//+------------------------------------------------------------------+
string AppliedPriceDescription(const ENUM_APPLIED_PRICE price)
  {
   string res = StringSubstr(EnumToString(price), 6);
   if(res.Lower())
      res.SetChar(0, ushort(res.GetChar(0) - 32));
   return res;
  }
//+------------------------------------------------------------------+
