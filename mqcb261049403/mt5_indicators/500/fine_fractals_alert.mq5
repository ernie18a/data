//+------------------------------------------------------------------+
//|                                          Fine Fractals Alert.mq5 |
//|                                     Copyright © 2009 Denis Orlov |
//|                                    http://denis-or-love.narod.ru |
//+------------------------------------------------------------------+
#property description "Fine Fractals"
//---- author of the indicator
#property copyright "Copyright © 2009 Denis Orlov"
//---- link to the website of the author
#property link      "http://denis-or-love.narod.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Upper indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color1  Magenta
//---- thickness of the indicator 1 line is equal to 1
#property indicator_width1  1
//---- indicator bullish label display
#property indicator_label1  "Up Fractal"
//+----------------------------------------------+
//|  Lower indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- blue color is used for the indicator bullish line
#property indicator_color2  Blue
//---- thickness of the indicator 2 line is equal to 1
#property indicator_width2  1
//---- bearish indicator label display
#property indicator_label2 "Down Fractal"

//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input bool Fine=true;//Sensibility 
input bool FlatShift=true;//Shift
input uint AlertCount=0;//Number of alerts
input int  UpLable=164;//Upper fractal label
input int  DnLable=164;//Lower fractal label
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//----
int StartBars;
int FRA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   StartBars=6;
//---- getting handle of the ATR indicator
   FRA_Handle=iFractals(NULL,0);
   if(FRA_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Up Fractal");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Down Fractal");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for tooltips 
   string short_name="Fine Fractals";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
   if(BarsCalculated(FRA_Handle)<rates_total || rates_total<StartBars) return(0);

//---- declarations of local variables 
   int to_copy,limit;
   double HP1,HP2,HP3,HPi,LP1,LP2,LP3,LPi,res,UpFractal[],DnFractal[];
   static uint UpCount,DnCount;

//---- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      to_copy=rates_total; // calculated number of all copied data
      limit=rates_total-StartBars-1; // starting index for calculation of all bars
     }
   else
     {
      to_copy=rates_total-prev_calculated+5; // calculated number of new copied data only
      limit=rates_total-prev_calculated+2; // starting index for calculation of new bars
     }

//---- copy the newly appeared data into the UpFractal and DnFractal arrays
   if(CopyBuffer(FRA_Handle,0,0,to_copy,UpFractal)<=0) return(0);
   if(CopyBuffer(FRA_Handle,1,0,to_copy,DnFractal)<=0) return(0);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(UpFractal,true);
   ArraySetAsSeries(DnFractal,true);

//---- main indicator calculation loop
   for(int bar=2; bar<=limit && !IsStopped(); bar++)
     {
      HP1=high[bar+1];
      HP2=high[bar];
      HP3=high[bar-1];
      HPi=high[bar-2];
      LP1=low[bar+1];
      LP2=low[bar];
      LP3=low[bar-1];
      LPi=low[bar-2];

      res=UpFractal[bar];
      if(res==0.0 && Fine)//increased sensibility
         if(HP1<HP2 && HP2>HP3 && (LP2>=LP3 || HP2>HPi)) res=HP2;

      if(FlatShift && res!=0.0) while(high[bar]==high[bar+1]) bar++;
      SellBuffer[bar]=res;

      res=DnFractal[bar];
      if(res==0.0 && Fine)//increased sensibility
         if(LP1>LP2 && LP2<LP3 && (HP2<=HP3 || LP2<LPi)) res=LP2;

      if(FlatShift && res!=0.0) while(low[bar]==low[bar+1]) bar++;
      BuyBuffer[bar]=res;
     }

//---- alerts counters reset to zeros
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
     }

   res=SellBuffer[2];
//---- submission of an alert for the upper fractal
   if(UpCount<AlertCount && res!=EMPTY_VALUE && res!=0.0)
     {
      UpCount++;
      Alert("New upper fractal "+DoubleToString(res,_Digits));
     }

   res=BuyBuffer[2];
//---- submission of an alert for the upper fractal 
   if(DnCount<AlertCount && res!=EMPTY_VALUE && res!=0.0)
     {
      DnCount++;
      Alert("New lower fractal "+DoubleToString(res,_Digits));
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
