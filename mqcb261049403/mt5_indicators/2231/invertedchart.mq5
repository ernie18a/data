//+------------------------------------------------------------------+
//|                                                InvertedChart.mq5 |
//|                                                        J.S. 2013 |
//|                                     http://www.eselstreckdich.de |
//+------------------------------------------------------------------+
#property copyright "J.S. 2013"
#property link      "http://www.eselstreckdich.de"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_label1 ""
#property indicator_plots 1
#property indicator_type1 DRAW_COLOR_CANDLES
#property indicator_width1 3
input color raise=Blue;
input color fall=Red;
input color doji=DarkGray;
double buffer_open[],buffer_high[],buffer_low[],buffer_close[]; //Buffers for data
double buffer_color_line[];    //Buffer for color indexes
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- assign the arrays with the indicator's buffers
   SetIndexBuffer(3,buffer_open,INDICATOR_DATA);
   SetIndexBuffer(1,buffer_high,INDICATOR_DATA);
   SetIndexBuffer(2,buffer_low,INDICATOR_DATA);
   SetIndexBuffer(0,buffer_close,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- assign the array with color indexes with the indicator's color indexes buffer
   SetIndexBuffer(4,buffer_color_line,INDICATOR_COLOR_INDEX);
//--- define the number of color indexes, used for a graphic plot
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);
//--- set color for each index
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,raise);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,fall);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,doji);
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
   for(int i=prev_calculated;i<=rates_total-1;i++)
     {
      //--- Set data for plotting
      buffer_open[i]=-open[i];  //Open price
      buffer_high[i]=-high[i];  //High price
      buffer_low[i]=-low[i];    //Low price
      buffer_close[i]=-close[i];//Close price
      buffer_color_line[i]=2;   //colorize candle
      if(buffer_close[i]>buffer_open[i]) buffer_color_line[i]=0;
      if(buffer_close[i]<buffer_open[i]) buffer_color_line[i]=1;
     }
   return(rates_total-1); //Return the number of calculated bars, 
                          //Subtract 1 for the last bar recalculation
  }
//+------------------------------------------------------------------+
