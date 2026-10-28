//+---------------------------------------------------------------------+
//|                                                      ChannelAnt.mq5 | 
//|                                          Copyright © 2013, Stajer59 | 
//|                                        http://www.stajer59.ucoz.ru/ | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "CCopyright © 2013, Stajer59"
#property link "http://www.stajer59.ucoz.ru"
#property description ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 11
#property indicator_buffers 11 
//---- 9 graphical plots are used in total
#property indicator_plots   11
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue-violet color is used as the color of the indicator line
#property indicator_color1 BlueViolet
//---- the indicator line is a dash-dotted curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "ChannelAnt"

//+--------------------------------------------+
//|  Levels indicator drawing parameters       |
//+--------------------------------------------+
//---- drawing the levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
#property indicator_type9   DRAW_LINE
#property indicator_type10   DRAW_LINE
#property indicator_type11   DRAW_LINE
//---- selection of levels colors
#property indicator_color2  Indigo
#property indicator_color3  DarkSlateGray
#property indicator_color4  Purple
#property indicator_color5  Red
#property indicator_color6  Blue
#property indicator_color7  Blue
#property indicator_color8  Red
#property indicator_color9  Purple
#property indicator_color10 DarkSlateGray
#property indicator_color11 Indigo

//---- levels are dott-dash curves
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_style8 STYLE_SOLID
#property indicator_style9 STYLE_DASHDOTDOT
#property indicator_style10 STYLE_SOLID
#property indicator_style11 STYLE_DASHDOTDOT
//---- levels width is equal to 1
#property indicator_width2  1
#property indicator_width3  2
#property indicator_width4  1
#property indicator_width5  2
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  2
#property indicator_width9  1
#property indicator_width10 2
#property indicator_width11 1
//---- display levels labels
#property indicator_label2  "+5 Level"
#property indicator_label3  "+4 Level"
#property indicator_label4  "+3 Level"
#property indicator_label5  "+2 Level"
#property indicator_label6  "+1 Level"
#property indicator_label7  "-1 Level"
#property indicator_label8  "-2 Level"
#property indicator_label9  "-3 Level"
#property indicator_label10 "-4 Level"
#property indicator_label11 "-5 Level"

//+-----------------------------------+
//|  Averaging classes description    |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMAn class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_SMA; //first smoothing method
input int Length1=40; //first smoothing depth                    
input int Phase1=15; //first smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input Smooth_Method MA_Method2=MODE_JJMA; //second smoothing method
input int Length2=20; //second smoothing depth 
input int Phase2=100;  //second smoothing parameter,
                       // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period

input double Deviation=1; //expansion ratio

input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in pointsх
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double X2MA[];

//---- declaration of dynamic arrays that will further be 
// used as levels indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[],ExtLineBuffer7[],ExtLineBuffer8[];
double ExtLineBuffer9[],ExtLineBuffer10[];

//---- Declaration of the average vertical shift value variable
double dPriceShift;
//---- Declaration of integer variables of data starting point
int StartBars,StartBars1,StartBars2;
//+------------------------------------------------------------------+   
//| X2MA Channel indicator initialization function                   | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   StartBars1=XMA1.GetStartBars(MA_Method1, Length1, Phase1)+1;
   StartBars2=StartBars1+XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   StartBars=StartBars1+StartBars2;

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);

//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,X2MA,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"X2MA");
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLineBuffer8,INDICATOR_DATA);
   SetIndexBuffer(9,ExtLineBuffer9,INDICATOR_DATA);
   SetIndexBuffer(10,ExtLineBuffer10,INDICATOR_DATA);
//---- set the position, from which the levels drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(9,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(10,PLOT_DRAW_BEGIN,StartBars);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(9,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(10,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of variable for indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"ChannelAnt(",
                     ", ",Smooth1,", ",Smooth2,Length1,", ",Length2,", ",DoubleToString(Deviation,4),")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| X2MA Channel iteration function                                  | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<StartBars) return(0);

//---- declaration of variables with a floating point  
   double price_,x1xma,x2xma,Dev1,Dev2,Dev3,Dev4,Dev5,Dev6,Dev7,Dev8,Dev9,Dev10;
//---- Declaration of integer variables and getting the bars already calculated
   int first1,first2,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first1=0; // starting index for calculation of all bars for the average
      first2=StartBars; // starting index for calculation of all bars for the channel
     }
   else
     {
      first1=prev_calculated-1; // starting index for calculation of the new bars for the average
      first2=first1; // starting index for calculation of the new bars for the channel
     }

//---- Main calculation loop of the indicator
   for(bar=first1; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Calling the PriceSeries function to get the input price price_
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- Two calls of the XMASeries function. 
      //---- The 'begin' parameter is increased by StartBars1 in the second call, as к. another XMA smoothing  
      x1xma = XMA1.XMASeries( 0, prev_calculated, rates_total, MA_Method1, Phase1, Length1, price_, bar, false);
      x2xma = XMA2.XMASeries(StartBars1, prev_calculated, rates_total, MA_Method2, Phase2, Length2,  x1xma, bar, false);
      //----       
      X2MA[bar]=x2xma+dPriceShift;
     }

//---- main calculation loop of the levels
   for(bar=first2; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Calling the PriceSeries function to get the input price price_
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- calculation of the half of the channel for each couple of levels
      Dev1=1+Deviation*0.736/100;
      Dev2=1+Deviation*0.618/100;
      Dev3=1+Deviation*0.500/100;      
      Dev4=1+Deviation*0.382/100; 
      Dev5=1+Deviation*0.191/100;
      //---- calculation of the half of the channel for each couple of levels
      Dev6=1-Deviation*0.191/100;
      Dev7=1-Deviation*0.382/100;
      Dev8=1-Deviation*0.500/100;
      Dev9=1-Deviation*0.618/100;
      Dev10=1-Deviation*0.736/100;
      
      //---- Levels calculation and indicator buffers initialization
      ExtLineBuffer1[bar]=X2MA[bar]*Dev1;
      ExtLineBuffer2[bar]=X2MA[bar]*Dev2;
      ExtLineBuffer3[bar]=X2MA[bar]*Dev3;
      ExtLineBuffer4[bar]=X2MA[bar]*Dev4;
      ExtLineBuffer5[bar]=X2MA[bar]*Dev5;     
      //---- Levels calculation and indicator buffers initialization
      ExtLineBuffer6[bar]=X2MA[bar]*Dev6;
      ExtLineBuffer7[bar]=X2MA[bar]*Dev7;
      ExtLineBuffer8[bar]=X2MA[bar]*Dev8;
      ExtLineBuffer9[bar]=X2MA[bar]*Dev9;
      ExtLineBuffer10[bar]=X2MA[bar]*Dev10;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
