//+--------------------------------------------------------------------------+
//|                                                  X4Period_RVI_Arrows.mq5 |
//|                                        Copyright © 2005, transport_david | 
//| http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/ | 
//+--------------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2005, transport_david"
//--- a link to the website of the author
#property link      "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- eight buffers are used for the calculation and drawing of the indicator
#property indicator_buffers 8
//--- eight graphical plots are used
#property indicator_plots   8
//+----------------------------------------------+
//| Parameters of drawing a bearish indicator 1  |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//--- pink is used for the color of the bearish indicator line
#property indicator_color1  clrDeepPink
//--- indicator 1 line width is equal to 1
#property indicator_width1  1
//--- display of the indicator bullish label
#property indicator_label1  "X4Period_RVI_Arrows Sell 1"
//+----------------------------------------------+
//| Parameters of drawing a bullish indicator 1  |
//+----------------------------------------------+
//--- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- green color is used as the color of the indicator bullish line
#property indicator_color2  clrDodgerBlue
//--- indicator 2 line width is equal to 1
#property indicator_width2  1
//--- display of the bearish indicator label
#property indicator_label2 "X4Period_RVI_Arrows Buy 1"
//+----------------------------------------------+
//| Parameters of drawing a bearish indicator 2  |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//--- pink is used for the color of the bearish indicator line
#property indicator_color3  clrDeepPink
//--- indicator 3 line width is equal to 1
#property indicator_width3  1
//--- display of the indicator bullish label
#property indicator_label3  "X4Period_RVI_Arrows Sell 2"
//+----------------------------------------------+
//| Parameters of drawing a bullish indicator 2  |
//+----------------------------------------------+
//--- drawing indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- green color is used as the color of the indicator bullish line
#property indicator_color4  clrDodgerBlue
//--- indicator 4 line width is equal to 1
#property indicator_width4  1
//--- display of the bearish indicator label
#property indicator_label4 "X4Period_RVI_Arrows Buy 2"
//+----------------------------------------------+
//| Parameters of drawing a bearish indicator 3  |
//+----------------------------------------------+
//--- drawing the indicator 5 as a symbol
#property indicator_type5   DRAW_ARROW
//--- pink is used for the color of the bearish indicator line
#property indicator_color5  clrDeepPink
//--- indicator 5 line width is equal to 1
#property indicator_width5  1
//--- display of the indicator bullish label
#property indicator_label5  "X4Period_RVI_Arrows Sell 3"
//+----------------------------------------------+
//| Parameters of drawing a bullish indicator 3  |
//+----------------------------------------------+
//--- drawing the indicator 6 as a symbol
#property indicator_type6   DRAW_ARROW
//---- green color is used as the color of the indicator bullish line
#property indicator_color6  clrDodgerBlue
//--- indicator 6 line width is equal to 1
#property indicator_width6  1
//--- display of the bearish indicator label
#property indicator_label6 "X4Period_RVI_Arrows Buy 3"
//+----------------------------------------------+
//| Parameters of drawing a bearish indicator 4  |
//+----------------------------------------------+
//--- drawing the indicator 7 as a symbol
#property indicator_type7   DRAW_ARROW
//--- pink is used for the color of the bearish indicator line
#property indicator_color7  clrDeepPink
//--- indicator 7 line width is equal to 1
#property indicator_width7  1
//--- display of the indicator bullish label
#property indicator_label7  "X4Period_RVI_Arrows Sell 4"
//+----------------------------------------------+
//| Parameters of drawing a bullish indicator 4  |
//+----------------------------------------------+
//--- drawing the indicator 8 as a symbol
#property indicator_type8   DRAW_ARROW
//---- green color is used as the color of the indicator bullish line
#property indicator_color8  clrDodgerBlue
//--- indicator 8 line width is equal to 1
#property indicator_width8  1
//--- display of the bearish indicator label
#property indicator_label8 "X4Period_RVI_Arrows Buy 4"
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET 0   // a constant for retuning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint RVIperiod1=7;     // Period 1
input uint RVIperiod2=12;    // Period 2
input uint RVIperiod3=18;    // Period 3
input uint RVIperiod4=32;    // Period 4
input uint Size=2;           // Vertical distance between the icons
//+----------------------------------------------+
//--- declaring dynamic arrays that further
//--- will be used as indicator buffers
double SellBuffer1[],BuyBuffer1[];
double SellBuffer2[],BuyBuffer2[];
double SellBuffer3[],BuyBuffer3[];
double SellBuffer4[],BuyBuffer4[];
//--- declaration of integer variables for the indicators handles
int ATR_Handle,RVI_Handle[4];
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of global variables 
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,RVIperiod1));
   min_rates_total=int(MathMax(min_rates_total,RVIperiod2));
   min_rates_total=int(MathMax(min_rates_total,RVIperiod3));
   min_rates_total=int(MathMax(min_rates_total,RVIperiod4));
//--- Getting the handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }
//---- getting handle of the iRVI 1 indicator
   RVI_Handle[0]=iRVI(NULL,0,RVIperiod1);
   if(RVI_Handle[0]==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the iRVI 1 calculator");
      return(INIT_FAILED);
     }
//---- getting handle of the iRVI 2 indicator
   RVI_Handle[1]=iRVI(NULL,0,RVIperiod2);
   if(RVI_Handle[1]==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the iRVI 2 calculator");
      return(INIT_FAILED);
     }
//---- getting handle of the iRVI 3 indicator
   RVI_Handle[2]=iRVI(NULL,0,RVIperiod3);
   if(RVI_Handle[2]==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the iRVI 3 calculator");
      return(INIT_FAILED);
     }
//---- getting handle of the iRVI 4 indicator
   RVI_Handle[3]=iRVI(NULL,0,RVIperiod4);
   if(RVI_Handle[3]==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the iRVI 4 calculator");
      return(INIT_FAILED);
     }
//--- set dynamic arrays as indicator buffers
   InitTsIndArrBuffer(0,0,SellBuffer1,0.0,min_rates_total);
   InitTsIndArrBuffer(1,1,BuyBuffer1,0.0,min_rates_total);
   InitTsIndArrBuffer(2,2,SellBuffer2,0.0,min_rates_total);
   InitTsIndArrBuffer(3,3,BuyBuffer2,0.0,min_rates_total);
   InitTsIndArrBuffer(4,4,SellBuffer3,0.0,min_rates_total);
   InitTsIndArrBuffer(5,5,BuyBuffer3,0.0,min_rates_total);
   InitTsIndArrBuffer(6,6,SellBuffer4,0.0,min_rates_total);
   InitTsIndArrBuffer(7,7,BuyBuffer4,0.0,min_rates_total);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows
   string short_name="X4Period_RVI_Arrows";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Initialization of time series indicator buffer                   |
//+------------------------------------------------------------------+  
void InitTsIndArrBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//--- selecting symbol for drawing
   PlotIndexSetInteger(Plot,PLOT_ARROW,159);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//---
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
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(RVI_Handle[0])<rates_total
      || BarsCalculated(RVI_Handle[1])<rates_total
      || BarsCalculated(RVI_Handle[2])<rates_total
      || BarsCalculated(RVI_Handle[3])<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- declarations of local variables 
   int to_copy,limit,bar;
   double RVI1[],RVI2[],RVI3[],RVI4[],ATR[];
   double SIGN1[],SIGN2[],SIGN3[],SIGN4[];
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
   to_copy=limit+1;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(RVI_Handle[0],0,0,to_copy,RVI1)<=0) return(RESET);
   if(CopyBuffer(RVI_Handle[1],0,0,to_copy,RVI2)<=0) return(RESET);
   if(CopyBuffer(RVI_Handle[2],0,0,to_copy,RVI3)<=0) return(RESET);
   if(CopyBuffer(RVI_Handle[3],0,0,to_copy,RVI4)<=0) return(RESET);  
   if(CopyBuffer(RVI_Handle[0],1,0,to_copy,SIGN1)<=0) return(RESET);
   if(CopyBuffer(RVI_Handle[1],1,0,to_copy,SIGN2)<=0) return(RESET);
   if(CopyBuffer(RVI_Handle[2],1,0,to_copy,SIGN3)<=0) return(RESET);
   if(CopyBuffer(RVI_Handle[3],1,0,to_copy,SIGN4)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(RVI1,true);
   ArraySetAsSeries(RVI2,true);
   ArraySetAsSeries(RVI3,true);
   ArraySetAsSeries(RVI4,true);
   ArraySetAsSeries(SIGN1,true);
   ArraySetAsSeries(SIGN2,true);
   ArraySetAsSeries(SIGN3,true);
   ArraySetAsSeries(SIGN4,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer1[bar]=0.0;
      SellBuffer1[bar]=0.0;
      BuyBuffer2[bar]=0.0;
      SellBuffer2[bar]=0.0;
      BuyBuffer3[bar]=0.0;
      SellBuffer3[bar]=0.0;
      BuyBuffer4[bar]=0.0;
      SellBuffer4[bar]=0.0;
      //---
      if(RVI1[bar]<SIGN1[bar]) SellBuffer1[bar]=high[bar]+ATR[bar]*(Size+1)/8;
      if(RVI1[bar]>SIGN1[bar]) BuyBuffer1[bar]=low[bar]-ATR[bar]*(Size+1)/8;
      //---
      if(RVI2[bar]<SIGN2[bar]) SellBuffer2[bar]=high[bar]+ATR[bar]*(2*Size+1)/8;
      if(RVI2[bar]>SIGN2[bar]) BuyBuffer2[bar]=low[bar]-ATR[bar]*(2*Size+1)/8;
      //---
      if(RVI3[bar]<SIGN3[bar]) SellBuffer3[bar]=high[bar]+ATR[bar]*(3*Size+1)/8;
      if(RVI3[bar]>SIGN3[bar]) BuyBuffer3[bar]=low[bar]-ATR[bar]*(3*Size+1)/8;
      //---
      if(RVI4[bar]<SIGN4[bar]) SellBuffer4[bar]=high[bar]+ATR[bar]*(4*Size+1)/8;
      if(RVI4[bar]>SIGN4[bar]) BuyBuffer4[bar]=low[bar]-ATR[bar]*(4*Size+1)/8;
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
