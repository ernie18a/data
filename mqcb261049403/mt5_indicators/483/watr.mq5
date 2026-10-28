//+------------------------------------------------------------------+
//|                                                        WATR.mq5  |
//|                      Written WizardSerg under article konkop in  |
//|                                        "Modern trading" #4/2001  |
//|                                  http://www.wizardserg.inweb.ru  |
//|                                              wizardserg@mail.ru  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Written WizardSerg under article konkop in <Modern trading> #4/2001"
//---- link to the website of the author
#property link      "http://www.wizardserg.inweb.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//----four buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- four plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Parameters of drawing the bullish indicator |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- dodger blue color is used as the color of a bullish candlestick
#property indicator_color1  DodgerBlue
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of the indicator 1 line is equal to 2
#property indicator_width1  2
//---- bullish indicator label display
#property indicator_label1  "Upper WATR"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- coral color is used as the color of the bearish indicator line
#property indicator_color2  Coral
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- thickness of line of the indicator 2 is equal to 2
#property indicator_width2  2
//---- bearish indicator label display
#property indicator_label2  "Lower WATR"
//+----------------------------------------------+
//|  Parameters of drawing the bullish indicator |
//+----------------------------------------------+
//---- drawing the indicator 3 as a label
#property indicator_type3   DRAW_ARROW
//---- aqua blue color is used as the color of a bullish candlestick
#property indicator_color3  Aqua
//---- the indicator 3 line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- thickness of the indicator 3 line is equal to 4
#property indicator_width3  4
//---- bullish indicator label display
#property indicator_label3  "Upper WATR"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 4 as a label
#property indicator_type4   DRAW_ARROW
//---- Magenta color is used as the color of the bearish indicator line
#property indicator_color4  Magenta
//---- the indicator 2 line is a continuous curve
#property indicator_style4  STYLE_SOLID
//---- thickness of the indicator 4 line is equal to 4
#property indicator_width4  4
//---- bearish indicator label display
#property indicator_label4  "Lower WATR"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int    WATR_K = 10;
input double WATR_M = 4.0;
input int    ATR=21;
input int    Shift=0; // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
// will be used as indicator buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
//----Declaration of variables for the indicators handles
int ATR_Handle;
//---- Declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
bool AntiTrendBar(const double &Open[],const double &Close[],int bar)
  {
//----
   bool res=(TrendUp(Close,bar) && (Close[bar]<Open[bar])) || (!TrendUp(Close,bar) && (Close[bar]>Open[bar]));
//----   
   return(res);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
double CalcIndicValue(double &ATRArray[],const double &Close[],int bar,bool trend)
  {
//----
   double res=Close[bar];
   if(trend)res -= (WATR_K*_Point + WATR_M*ATRArray[bar]);
   else     res += (WATR_K*_Point + WATR_M*ATRArray[bar]);
//----   
   return(res);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
bool TrendUp(const double &Close[],int bar)
  {
//----
   return((Close[bar+1]>ExtMapBufferUp[bar+1]) && (ExtMapBufferUp[bar+1]!=EMPTY_VALUE));
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- getting the handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");
//---- Initialization of variables of the start of data calculation
   StartBars=ATR;
//---- set ExtMapBufferUp dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Upper WATR");
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferUp,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ExtMapBufferDown dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Lower WATR");
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferDown,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ExtMapBufferUp1 dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtMapBufferUp1,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Upper WATR");
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferUp1,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- the indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,108);

//---- set ExtMapBufferDown1 dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtMapBufferDown1,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(3,PLOT_LABEL,"Lower WATR");
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferDown1,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- the indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,108);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"WATR(",WATR_K,", ",WATR_M,", ",ATR,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<StartBars) return(0);

//---- declarations of local variables 
   int limit,to_copy,bar;
   double iATR_[];

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(iATR_,true);

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-StartBars; // starting index for calculation of all bars
      to_copy=rates_total;
      ExtMapBufferUp[limit+1]=close[limit+1]-WATR_K*_Point;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
      to_copy=limit+1;
     }

//---- copy newly appeared data in the iATR_[] array
   if(CopyBuffer(ATR_Handle,0,0,to_copy,iATR_)<=0) return(0);

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      if(AntiTrendBar(open,close,bar))
        {
         ExtMapBufferUp[bar]=ExtMapBufferUp[bar+1];
         ExtMapBufferDown[bar]=ExtMapBufferDown[bar+1];
        }
      else
        {
         if(TrendUp(close,bar))
           {
            ExtMapBufferUp[bar]=CalcIndicValue(iATR_,close,bar,true);

            if(ExtMapBufferUp[bar]<ExtMapBufferUp[bar+1])
              {
               ExtMapBufferUp[bar]=ExtMapBufferUp[bar+1];
              }
            ExtMapBufferDown[bar]=EMPTY_VALUE;
           }
         else
           {
            ExtMapBufferDown[bar]=CalcIndicValue(iATR_,close,bar,false);
            ExtMapBufferDown1[bar]=ExtMapBufferDown[bar];

            if(ExtMapBufferDown[bar]>ExtMapBufferDown[bar+1])
              {
               ExtMapBufferDown[bar]=ExtMapBufferDown[bar+1];
              }
            ExtMapBufferUp[bar]=EMPTY_VALUE;
           }
        }
      // crossings with a price                 
      if(TrendUp(close,bar) && (close[bar]<ExtMapBufferUp[bar]))
        {
         ExtMapBufferDown[bar]=CalcIndicValue(iATR_,close,bar,false);
         ExtMapBufferUp[bar]=EMPTY_VALUE;
        }
      if((!TrendUp(close,bar)) && (close[bar]>ExtMapBufferDown[bar]))
        {
         ExtMapBufferUp[bar]=CalcIndicValue(iATR_,close,bar,true);
         ExtMapBufferDown[bar]=EMPTY_VALUE;
        }

      ExtMapBufferUp1[bar]=0.0;
      ExtMapBufferDown1[bar]=0.0;

      if(ExtMapBufferUp[bar+1]==EMPTY_VALUE && ExtMapBufferUp[bar]!=EMPTY_VALUE)
         ExtMapBufferUp1[bar]=ExtMapBufferUp[bar];

      if(ExtMapBufferDown[bar+1]==EMPTY_VALUE && ExtMapBufferDown[bar]!=EMPTY_VALUE)
         ExtMapBufferDown1[bar]=ExtMapBufferDown[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
