//+------------------------------------------------------------------+
//|                                         SpreadCandlesCreator.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Spread Candles Creator"
//---- indicator version
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- six buffers are used for calculation of drawing of the indicator
#property indicator_buffers 6
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Spread Line indicator drawing parameters    |
//+----------------------------------------------+
//---- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color1  Blue
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "Spread Line"
//+----------------------------------------------+
//|  SpreadCandle indicator drawing parameters   |
//+----------------------------------------------+
//---- color candlesticks are used as an indicator
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  Red,Lime
//---- displaying the indicator label
#property indicator_label2  "SpreadOpen; SpreadHigh; SpreadLow; SpreadClose"
//+--------------------------------------+
//|  Indicator window borders parameters |
//+--------------------------------------+
#property indicator_minimum 0
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input color BidColor=Gray;                  // Last spread line color
input ENUM_LINE_STYLE BidStyle=STYLE_SOLID; // Last spread line style
input bool Recount=true;                    // History deletion flag
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtBuffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];

int prev_calculated_old=0,lastbar=-1,spread_high,spread_low;
//---- declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBars=1;
   //---- set dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtCloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);     
//---- set dynamic array as as a color index buffer   
   SetIndexBuffer(5,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicators drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBars);
//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"Spread Candles Creator("+string(Recount)+")");  
//---- Bid line drawing parameters   
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,BidColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,BidStyle);
//----   
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

//---- declaration of integer variables
   int first,bar,prev_calculated_,spread0;
   
   if(Recount) prev_calculated_=prev_calculated;
   else prev_calculated_=prev_calculated_old;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated_>rates_total || prev_calculated_<=0) // checking for the first start of the indicator calculation
      first=1;                    // starting index for calculation of all bars
   else first=prev_calculated_-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {  
        if(spread[bar]) spread0=spread[bar];
        else spread0=spread[bar-1];
        
        if(lastbar!=bar)
          {
           ExtOpenBuffer[bar]=spread0;
           spread_high=spread0;
           spread_low=spread0;
          }
        else
          {
           spread_high=int(MathMax(spread_high,spread0));
           spread_low=int(MathMin(spread_low,spread0));
          }
          
         ExtCloseBuffer[bar]=spread0;
         ExtHighBuffer [bar]=spread_high;
         ExtLowBuffer  [bar]=spread_low;
         ExtBuffer[bar]=spread0;
         
         lastbar=bar;
   
      //--- candlesticks coloring
      if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else                                       ExtColorBuffer[bar]=1.0;
     }
     
    prev_calculated_old=rates_total;
    
//---- Bid line shift parameters     
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtCloseBuffer[rates_total-1]);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
