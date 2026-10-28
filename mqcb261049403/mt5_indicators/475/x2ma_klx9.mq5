/*
* Place the SmoothAlgorithms.mqh file
* to the terminal_data_folder\MQL5\Include
*/
//+------------------------------------------------------------------+
//|                                                    X2MA_KLx9.mq5 | 
//|                                 Copyright 2011, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "X2MA Keltner Channel"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 9
#property indicator_buffers 9 
//---- 9 graphical plots are used in total
#property indicator_plots   9
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use blue violet color for the indicator line
#property indicator_color1 BlueViolet
//---- the indicator line is a dash-dotted curve
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying a label of the indicator
#property indicator_label1  "X2MA"

//+--------------------------------------------+
//|  Levels indicator drawing parameters       |
//+--------------------------------------------+
//---- drawing Keltner Channels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
#property indicator_type9   DRAW_LINE
//---- selection of Keltner Channels colors
#property indicator_color2  DarkSlateGray
#property indicator_color3  Purple
#property indicator_color4  Red
#property indicator_color5  Blue
#property indicator_color6  Blue
#property indicator_color7  Red
#property indicator_color8  Purple
#property indicator_color9  DarkSlateGray
//---- Keltner Channels are dott-dash curves
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_style8 STYLE_DASHDOTDOT
#property indicator_style9 STYLE_DASHDOTDOT
//---- Keltner Channels width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1
#property indicator_width9  1
//---- display of Keltner Channels labels
#property indicator_label2  "+4Sigma"
#property indicator_label3  "+3Sigma"
#property indicator_label4  "+2Sigma"
#property indicator_label5  "+1Sigma"
#property indicator_label6  "-1Sigma"
#property indicator_label7  "-2Sigma"
#property indicator_label8  "-3Sigma"
#property indicator_label9  "-4Sigma"

//+-----------------------------------+
//|  Smoothings classes description   |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of variables of the CXMA and CStdDeviation classes 
//---- from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
CStdDeviation STD;
//+-----------------------------------+
//|  enumerations declaration         |
//+-----------------------------------+
enum Applied_price_ // Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_SMA;  // First smoothing method
input int Length1=40;                     // First smoothing depth                    
input int Phase1=15;                      // First smoothing parameter
                                          // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method MA_Method2=MODE_JJMA; // Second smoothing method
input int Length2=20;                     // Second smoothing depth 
input int Phase2=100;                     // Second smoothing parameter
                                          // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input int KeltnerPeriod=20;               // Keltner smoothing period
input double Ratio1 = 1.0;                // First level ratio
input double Ratio2 = 2.0;                // Second level ratio
input double Ratio3 = 3.0;                // Third level ratio
input double Ratio4 = 4.0;                // Fourth level ratio

input Applied_price_ IPC=PRICE_CLOSE;     // Price constant
/* , used for the indicator calculation (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0;                        // Horizontal shift of the indicator in bars
input int PriceShift=0;                   // Vertical shift of the indicator in points
//+-----------------------------------+

//---- declaration of a dynamic array that
//---- will be used as an indicator buffer
double X2MA[];

//---- declaration of dynamic arrays that
// will be used as Keltner Channels indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[],ExtLineBuffer7[],ExtLineBuffer8[];

//---- declaration of the average vertical shift value variable
double dPriceShift;
//---- declaration of the integer variables for the start of data calculation
int StartBars,StartBars1,StartBars2;
//+------------------------------------------------------------------+
//| calculation of the half of the Keltner Channel width             |
//+------------------------------------------------------------------+ 
double GetKeltner(int period,int bar,const double &High[],const double &Low[])
  {
//----
   double Resalt,sum=0;
   for(int iii=0; iii<period; iii++)
      sum+=High[bar-iii] - Low[bar-iii];
   Resalt = sum / period;
   return(Resalt);
//----
  }
//+------------------------------------------------------------------+   
//| X2MA Keltner Channel indicator initialization function           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   StartBars1=XMA1.GetStartBars(MA_Method1, Length1, Phase1)+1;
   StartBars2=StartBars1+XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   StartBars=MathMax(StartBars2,KeltnerPeriod);

//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
   XMA2.XMALengthCheck("KeltnerPeriod", KeltnerPeriod);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);

//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,X2MA,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"X2MA");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLineBuffer8,INDICATOR_DATA);
//---- set the position, from which the Keltner Channels drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,StartBars);
//---- create labels to display in Data Window
   PlotIndexSetString(1,PLOT_LABEL,"+4Sigma");
   PlotIndexSetString(2,PLOT_LABEL,"+3Sigma");
   PlotIndexSetString(3,PLOT_LABEL,"+2Sigma");
   PlotIndexSetString(4,PLOT_LABEL,"+1Sigma");
   PlotIndexSetString(5,PLOT_LABEL,"-1Sigma");
   PlotIndexSetString(6,PLOT_LABEL,"-2Sigma");
   PlotIndexSetString(7,PLOT_LABEL,"-3Sigma");
   PlotIndexSetString(8,PLOT_LABEL,"-4Sigma");
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MA Keltner Channel(",
                     Length1,", ",Length2,", ",KeltnerPeriod,", ",Smooth1,", ",Smooth2,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| X2MA Keltner Channel iteration function                          | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
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

//---- declaration of variables with a floating point  
   double price_,x1xma,x2xma,Keltner1,Keltner2,Keltner3,Keltner4,Keltner;
//---- declaration of integer variables and getting calculated bars
   int first1,first2,bar;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first1=0;                                          // starting index for calculation of all bars for the average
      first2=StartBars;                                  // starting index for calculation of all bars for the average
     }
   else
     {
      first1=prev_calculated-1;                          // starting index for calculation of the new bars for the average
      first2=first1;                                     // starting index for calculation of the new bars for the channel
     }

//---- main indicator calculation loop
   for(bar=first1; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- two calls of the XMASeries method
      //---- the 'begin' parameter is increased by StartBars1 in the second call, as it is another XMA smoothing  
      x1xma = XMA1.XMASeries( 0, prev_calculated, rates_total, MA_Method1, Phase1, Length1, price_, bar, false);
      x2xma = XMA2.XMASeries(StartBars1, prev_calculated, rates_total, MA_Method2, Phase2, Length2,  x1xma, bar, false);
      //----       
      X2MA[bar]=x2xma+dPriceShift;
     }

//---- main cycle of the Keltner Channels calculation
   for(bar=first2; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- call of the GetKeltner function to get the half of the Keltner Channel width
      Keltner=GetKeltner(KeltnerPeriod,bar,high,low);

      //---- calculation of the half of the channel for each couple of levels
      Keltner1=Ratio1*Keltner;
      Keltner2=Ratio2*Keltner;
      Keltner3=Ratio3*Keltner;
      Keltner4=Ratio4*Keltner;

      //---- Keltner Channels calculation and indicator buffers initialization
      ExtLineBuffer1[bar]=X2MA[bar]+Keltner4+dPriceShift;
      ExtLineBuffer2[bar]=X2MA[bar]+Keltner3+dPriceShift;
      ExtLineBuffer3[bar]=X2MA[bar]+Keltner2+dPriceShift;
      ExtLineBuffer4[bar]=X2MA[bar]+Keltner1+dPriceShift;
      ExtLineBuffer5[bar]=X2MA[bar]-Keltner1+dPriceShift;
      ExtLineBuffer6[bar]=X2MA[bar]-Keltner2+dPriceShift;
      ExtLineBuffer7[bar]=X2MA[bar]-Keltner3+dPriceShift;
      ExtLineBuffer8[bar]=X2MA[bar]-Keltner4+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
