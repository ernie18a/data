//+------------------------------------------------------------------+
//|                                                ReverseSymbol.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Reverse Symbol"
//---- indicator version
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- 6 buffers are used for calculation and drawing the indicator
#property indicator_buffers 6
//---- 2 plots are used
#property indicator_plots   2
//---- color candlesticks are used as an indicator
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  Green, Magenta
//---- displaying the indicator label
#property indicator_label2  "ReverseSymbol Open;ReverseSymbol High;ReverseSymbol Low;ReverseSymbol Close"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input color BidColor=Red;                   // Bid line color
input ENUM_LINE_STYLE BidStyle=STYLE_SOLID; // Bid line style
input int IndicatorDigits=3;                // Indicator display accuracy format
input double ratio=1.0;                     // Compensation factor 
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtBuffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Declaration of the integer variables for the start of data calculation
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
   SetIndexBuffer(0,ExtBuffer,INDICATOR_CALCULATIONS);

//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- set dynamic array as as a color index buffer   
   SetIndexBuffer(5,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBars);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,IndicatorDigits);

//---- currency name is reversed only for the lines consisting of six letters
   string CrossIndex_,Symb=Symbol();
   if(StringLen(Symbol())==6) CrossIndex_=StringSubstr(Symb,3,3)+StringSubstr(Symb,0,3);
   else                       CrossIndex_=Symb;

//---- name for the data window and the label for sub-windows
   string short_name;
   StringConcatenate(short_name,"ReverseSymbol(",CrossIndex_,",",StringSubstr(EnumToString(_Period),7,-1),"x",ratio,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);

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

//---- Declaration of integer variables
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ExtOpenBuffer [bar]=ratio/open[bar];
      ExtCloseBuffer[bar]=ratio/close[bar];
      ExtHighBuffer [bar]=ratio/low[bar];
      ExtLowBuffer  [bar]=ratio/high[bar];
      ExtBuffer[bar]=ExtCloseBuffer[bar];

      //--- candlesticks coloring
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else                                       ExtColorBuffer[bar]=1.0;
     }

//---- Bid line shift parameters     
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtCloseBuffer[rates_total-1]);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
