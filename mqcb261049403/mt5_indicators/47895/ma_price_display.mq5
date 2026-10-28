/********************************************************************\
|                                               MA Price display.mq5 |
|                                            © 2024, Alexey Viktorov |
|                       https://www.mql5.com/ru/users/alexeyvik/news |
\********************************************************************/
#property copyright "© 2024, Alexey Viktorov"
#property link      "https://www.mql5.com/ru/users/alexeyvik/news"
#property version   "1.00"
//#property indicator_separate_window
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "MA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrOlive, clrGold
#property indicator_width1  2
#property indicator_label2  "MA price;Close price"
#property indicator_type2   DRAW_COLOR_HISTOGRAM2
#property indicator_style2  STYLE_DOT
#property indicator_color2  clrRed, clrBlue
#property indicator_width2  1
//---
input int                 MA_Period  = 100;
input ENUM_MA_METHOD      MA_Method  = MODE_EMA;
input ENUM_APPLIED_PRICE  MA_Price   = PRICE_CLOSE;
//---
int handle_MA;
double buff_MA[],
       clr_MA[],
       buff_PR_H[],
       buff_PR_L[],
       clrPR[];
/********************************************************************\
|           Custom indicator initialization function                 |
\********************************************************************/
int OnInit()
 {
//---
  SetIndexBuffer(0, buff_MA, INDICATOR_DATA);
  SetIndexBuffer(1, clr_MA, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(2, buff_PR_H, INDICATOR_DATA);
  SetIndexBuffer(3, buff_PR_L, INDICATOR_DATA);
  SetIndexBuffer(4, clrPR, INDICATOR_COLOR_INDEX);
  handle_MA = iMA(_Symbol, PERIOD_CURRENT, MA_Period, 0, MA_Method, MA_Price);
  return(INIT_SUCCEEDED);
 }/******************************************************************/

/********************************************************************\
|              Custom indicator iteration function                   |
\********************************************************************/
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
  int i = prev_calculated == 0 ? 0 : rates_total-1,
      copy = CopyBuffer(handle_MA, 0, 0, rates_total, buff_MA);
  while(i < rates_total && !IsStopped())
   {
    clr_MA[i] = 0;
    clrPR[i] = 0;
    if(close[i] >= buff_MA[i])
     {
      buff_PR_H[i] = close[i];
      buff_PR_L[i] = buff_MA[i];
      clr_MA[i] = 1;
      clrPR[i] = 1;
     }
    if(close[i] < buff_MA[i])
     {
      buff_PR_L[i] = close[i];
      buff_PR_H[i] = buff_MA[i];
     }
    i++;
   }
  return(rates_total);
 }/******************************************************************

/********************************************************************\
|                  Expert deinitialization function                  |
\********************************************************************/
void OnDeinit(const int reason)
 {
  Comment("");
 }/******************************************************************/
