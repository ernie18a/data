//+------------------------------------------------------------------+
//|                                                  BrainTrend2.mq5 |
//|                               Copyright © 2005, BrainTrading Inc |
//|                                      http://www.braintrading.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, BrainTrading Inc."
//---- link to the website of the author
#property link      "http://www.braintrading.com/"
//---- indicator version
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- five buffers are used for calculation and drawing the indicator
#property indicator_buffers 5
//---- only one plot is used
#property indicator_plots   1
//---- color candlesticks are used as an indicator
#property indicator_type1   DRAW_COLOR_CANDLES
//---- displaying the indicator label
#property indicator_label1  "Flat; UpTend; DownTrend;"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int ATR_Period=7;
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//----
bool   river=true,river_;
int    glava,glava_,StartBars;
double dartp,cecf,Emaxtra,Emaxtra_,Values_[],Values[];
//----
color ExtColor[3]={CLR_NONE,Lime,Magenta};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   dartp=7.0;
   cecf=0.7;
   StartBars=ATR_Period+2;

//---- memory distribution for variables' arrays   
   if(ArrayResize(Values,ATR_Period)<ATR_Period)
      Print("Failed to distribute the memory for Values array");
   if(ArrayResize(Values_,ATR_Period)<ATR_Period)
      Print("Failed to distribute the memory for Values array_");

//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- set ExtColorsBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);
//---- set colors quantity 3 for the color buffer
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);
//---- set colors for the color buffer
   for(int i=0; i<3; i++)
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,i,ExtColor[i]);
//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="BrainTrend1";
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
   if(rates_total<StartBars) return(0);

//---- declarations of local variables    
   int bar,J,limit,Curr;
   double ATR,widcha,TR,Spread;
   double Weight,Series1,High,Low;

//---- calculate the limit starting index for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-StartBars; // starting index for calculation of all bars
      Emaxtra=close[limit+1];
      glava=0;
      double T_Series2=close[limit+2];
      double T_Series1=close[limit+1];
      if(T_Series2>T_Series1)
         river=true;
      else river=false;

      TR=spread[limit]+high[limit]-low[limit];

      if(MathAbs(spread[limit]+high[limit]-T_Series1)>TR)
         TR=MathAbs(spread[limit]+high[limit]-T_Series1);

      if(MathAbs(low[limit]-T_Series1)>TR)
         TR=MathAbs(low[limit]-T_Series1);

      ArrayInitialize(Values,TR);
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(spread,true);
   ArraySetAsSeries(Values,true);
   ArraySetAsSeries(Values_,true);

//---- restore values of the variables
   glava=glava_;
   Emaxtra=Emaxtra_;
   river=river_;
   ArrayCopy(Values,Values_,0,WHOLE_ARRAY);

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0)
        {
         glava_=glava;
         Emaxtra_=Emaxtra;
         river_=river;
         ArrayCopy(Values_,Values,0,WHOLE_ARRAY);
        }

      ExtOpenBuffer[bar]=0.0;
      ExtHighBuffer[bar]=0.0;
      ExtLowBuffer[bar]=0.0;
      ExtCloseBuffer[bar]=0.0;
      ExtColorsBuffer[bar]=0;

      Spread=spread[bar]*_Point;

      High=high[bar];
      Low=low[bar];
      Series1=close[bar+1];
      TR=Spread+High-Low;

      if(MathAbs(Spread+High-Series1)>TR)
         TR=MathAbs(Spread+High-Series1);

      if(MathAbs(Low-Series1)>TR)
         TR=MathAbs(Low-Series1);

      Values[glava]=TR;

      ATR=0;
      Weight=ATR_Period;
      Curr=glava;

      for(J=0; J<=ATR_Period-1; J++)
        {
         ATR+=Values[Curr]*Weight;
         Weight-=1.0;
         Curr--;
         if(Curr==-1) Curr=ATR_Period-1;
        }

      ATR=2.0*ATR/(dartp *(dartp+1.0));
      glava++;

      if(glava==ATR_Period) glava=0;

      widcha=cecf*ATR;

      if(river && Low<Emaxtra-widcha)
        {
         river=false;
         Emaxtra=Spread+High;
        }

      if(!river && Spread+High>Emaxtra+widcha)
        {
         river=true;
         Emaxtra=Low;
        }

      if(river && Low>Emaxtra)
        {
         Emaxtra=Low;
        }

      if(!river && Spread+High<Emaxtra)
        {
         Emaxtra=Spread+High;
        }

      if(river)
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtHighBuffer[bar]=High;
         ExtLowBuffer[bar]=Low;
         ExtCloseBuffer[bar]=close[bar];
         ExtColorsBuffer[bar]=1;
        }
      else
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtHighBuffer[bar]=High;
         ExtLowBuffer[bar]=Low;
         ExtCloseBuffer[bar]=close[bar];
         ExtColorsBuffer[bar]=2;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
