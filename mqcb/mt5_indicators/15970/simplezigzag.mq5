//+------------------------------------------------------------------+
//|                                                 SimpleZigZag.mq5 |
//|                                        Copyright 2016, Oschenker |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Oschenker"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property icon "RedValue_70x70.ico"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

// plot MyZigZag
#property indicator_label1  "MyZigZag"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

// input parameters
input int   ScaleMN  = 800; // Typical retracement size for MN
input int   ScaleW1  = 700; // Typical retracement size for W1
input int   ScaleD1  = 700; // Typical retracement size for D1
input int   ScaleH4  = 500; // Typical retracement size for H4
input int   ScaleH1  = 100; // Typical retracement size for H1
input int   ScaleM30 = 90; // Typical retracement size for M30
input int   ScaleM15 = 50; // Typical retracement size for M15
input int   ScaleM5  = 50; // Typical retracement size for M5
input int   ScaleM1  = 10; // Typical retracement size for M1

int            Goal;
int            LastExtrBar;

// indicator buffers
double         ZZPoints[];

// other parameters
double         Scale;
double         LLow;
double         LHigh;
double         PLow;
double         PHigh;

string         com;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // indicator buffers mapping
   SetIndexBuffer(0, ZZPoints, INDICATOR_DATA);

   // set short name and digits   
   PlotIndexSetString(0,PLOT_LABEL,"SimpleZigZag("+(string)Scale+")");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
      
   // set plot empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   
   // setup Scale value
   switch(_Period)
     {
      case  PERIOD_M1:
         Scale = ScaleM1 * Point();
        break;
      case  PERIOD_M5:
         Scale = ScaleM5 * Point();
        break;
      case  PERIOD_M15:
         Scale = ScaleM15 * Point();
        break;
      case  PERIOD_M30:
         Scale = ScaleM30 * Point();
        break;
      case  PERIOD_H1:
         Scale = ScaleH1 * Point();
        break;
      case  PERIOD_H4:
         Scale = ScaleH4 * Point();
        break;
      case  PERIOD_D1:
         Scale = ScaleD1 * Point();
        break;
      case  PERIOD_W1:
         Scale = ScaleW1 * Point();
        break;
      case  PERIOD_MN1:
         Scale = ScaleMN * Point();
        break;
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // remove comments, if any
   ChartSetString( 0, CHART_COMMENT, "");
   Scale = 0;
  }  

  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int        rates_total,
                const int        prev_calculated,
                const datetime   &time[],
                const double     &open[],
                const double     &high[],
                const double     &low[],
                const double     &close[],
                const long       &tick_volume[],
                const long       &volume[],
                const int        &spread[])
  {
   int Start;
   if(rates_total < 3) return(0);
   
   if(prev_calculated == 0)  // in case there is no previous calculations
     {
      ArrayInitialize(ZZPoints,0.0); // initialize buffer with zero volues

      Start = 2;
      if(low[0] < high[1])
             {
              PLow = LLow = low[0];
              PHigh = LHigh = high[1];
              Goal     = 1;
             }
      else
             {
              PHigh = LHigh = high[0];
              PLow = LLow  = low[1];
              Goal     = 2;
             }      
     }
   else Start = prev_calculated + 1;

   // searching for Last High and Last Low
   for(int bar = Start; bar < rates_total - 1; bar++)
     {
      switch(Goal)
           {

            case 1 : // Last was a low - goal is high
                if(low[bar] <= LLow)
                     {
                      LLow = low[bar];
                      ZZPoints[LastExtrBar] = 0;
                      LastExtrBar = bar;
                      ZZPoints[LastExtrBar] = LLow;
                      break;
                     }
                if(high[bar] > (LLow + Scale))
                     {
                      PHigh = LHigh;
                      LHigh = high[bar];
                      LastExtrBar = bar;
                      ZZPoints[LastExtrBar] = LHigh;
                      Goal = 2;
                     }
                break;

            case 2: // Last was a high - goal is low
                   if(high[bar] >= LHigh)
                     {
                      LHigh = high[bar];
                      ZZPoints[LastExtrBar] = 0;
                      LastExtrBar = bar;
                      ZZPoints[LastExtrBar] = LHigh;
                      break;

                     }
                   if(low[bar] < (LHigh - Scale))
                     {
                      PLow = LLow;
                      LLow  = low[bar];
                      LastExtrBar = bar;
                      ZZPoints[LastExtrBar] = LLow;
                      Goal = 1;
                     }
                   break;
           }
     }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
