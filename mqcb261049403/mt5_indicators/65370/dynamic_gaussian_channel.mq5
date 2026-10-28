//+------------------------------------------------------------------+
//|                                     Dynamic Gaussian Channel.mq5 |
//|                              Copyright 2025, Temirgali Orazbayev |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Temirgali Orazbayev"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_label1  "Dynamic resistence level"
#property indicator_type1   DRAW_LINE
#property indicator_width1  1
#property indicator_label2  "Dynamic median level"
#property indicator_type2   DRAW_LINE
#property indicator_width2  1
#property indicator_label3  "Dynamic support level"
#property indicator_type3   DRAW_LINE
#property indicator_width3  1

input int             InpPeriod        = 20;                              // Calculate period
input color           ResistenceColor  = clrMidnightBlue;                 // Resistence line color
input ENUM_LINE_STYLE ResistenceStyle  = STYLE_SOLID;                     // Resistence line style
input color           MediumColor      = clrMidnightBlue;                 // Medium line color
input ENUM_LINE_STYLE MediumStyle      = STYLE_DASHDOTDOT;                // Medium line style
input color           SupportColor     = clrMidnightBlue;                 // Support line color
input ENUM_LINE_STYLE SupportStyle     = STYLE_SOLID;                     // Support line style

double Medium[], Resistence[], Support[];
double gaussian_weights_5[6];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Init(void)
    {
     double sum = 0.0;
     for(int i = 0; i <= 5; i++)
         {
          gaussian_weights_5[i] = MathExp(-i*i*9.0/((5+1)*(5+1)));
          sum += gaussian_weights_5[i];
         }
     for(int i = 0; i <= 5; i++)
         {
          gaussian_weights_5[i] /= sum;
         }
    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Price(int             price_mode,
                int          index,
                const double &open[],
                const double &low[],
                const double &high[],
                const double &close[])
    {
     switch(price_mode)
         {
          case PRICE_LOW:
               return low[index];
          case PRICE_HIGH:
               return high[index];
          default:
               return close[index];
         }
    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Smooth(int            index,
                int          price_mode,
                const double &open[],
                const double &low[],
                const double &high[],
                const double &close[])
    {
     if(index < 5)
          return 0.0;

     double result = 0.0;
     for(int i = 0; i <= 5; i++)
         {
          int idx = index - i;
          result += gaussian_weights_5[i] * Price(price_mode, idx, open, low, high, close);
         }
     return result;
    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
    {
     Init();

     SetIndexBuffer(0,      Medium,           INDICATOR_DATA);
     PlotIndexSetInteger(0, PLOT_LINE_COLOR,  MediumColor);
     PlotIndexSetInteger(0, PLOT_LINE_STYLE,  MediumStyle);
     SetIndexBuffer(1,      Resistence,       INDICATOR_DATA);
     PlotIndexSetInteger(1, PLOT_DRAW_TYPE,   DRAW_LINE);
     PlotIndexSetInteger(1, PLOT_LINE_COLOR,  ResistenceColor);
     PlotIndexSetInteger(1, PLOT_LINE_STYLE,  ResistenceStyle);
     SetIndexBuffer(2,      Support,          INDICATOR_DATA);
     PlotIndexSetInteger(2, PLOT_DRAW_TYPE,   DRAW_LINE);
     PlotIndexSetInteger(2, PLOT_LINE_COLOR,  SupportColor);
     PlotIndexSetInteger(2, PLOT_LINE_STYLE,  SupportStyle);
     string shortname;
     StringConcatenate(shortname, "Dynamic Gaussian Channel (", InpPeriod, ")");
     IndicatorSetString(INDICATOR_SHORTNAME, shortname);
     IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

     return INIT_SUCCEEDED;
    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int      rates_total,
                const int      prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
    {
    int rates = int(InpPeriod + 5);
     if(rates_total < rates)
          return 0;

     int start = (prev_calculated == 0) ? rates : prev_calculated;

     for(int bar = start; bar < rates_total; bar++)
         {
          if(bar - InpPeriod < 5)
               continue;

          double max_val = -DBL_MAX;
          double min_val = DBL_MAX;

          for(int i = 0; i < (int)InpPeriod; i++)
              {
               int idx = bar - i;
               if(idx < 5)
                    break;

               double smoothed_high = Smooth(idx, PRICE_HIGH, open, low, high, close);
               double smoothed_low  = Smooth(idx, PRICE_LOW, open, low, high, close);

               if(smoothed_high > max_val)
                   {
                    max_val = smoothed_high;
                   }
               if(smoothed_low < min_val)
                   {
                    min_val = smoothed_low;
                   }
              }
          Resistence[bar] = max_val;
          Support[bar]    = min_val;
          Medium[bar]     = (max_val + min_val) / 2.0;
         }
     return rates_total;
    }
//+------------------------------------------------------------------+