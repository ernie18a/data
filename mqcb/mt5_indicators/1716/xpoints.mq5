//+------------------------------------------------------------------+
//|                                                      XPoints.mq5 |
//|                               Copyright © 2007, RedPlumSoft, Inc |
//|                                       http://www.redplumsoft.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, RedPlumSoft, Inc"
#property link      "http://www.redplumsoft.com"
#property description "The indicator predicts possible reversal points"
//---- Indicator version number
#property version   "1.00"
//---- Indicator drawn in the main window
#property indicator_chart_window 
//---- The number of indicator buffers is 5
#property indicator_buffers 5 
//---- 5 graphical constructions used
#property indicator_plots   5
//+------------------------------------------------+
//|  Indicator drawing parameters                  |
//+------------------------------------------------+
//---- Indicator drawn as a line
#property indicator_type1   DRAW_LINE
//---- The color of the indicator line is blue-violet
#property indicator_color1 clrBlueViolet
//---- The indicator line is a solid curve
#property indicator_style1  STYLE_SOLID
//---- The width of the indicator line is 2
#property indicator_width1  2
//---- Display of the indicator label
#property indicator_label1  "XPoints Middle"

//+-----------------------------------------------+
//|  Parameters for drawing levels                |
//+-----------------------------------------------+
//---- Drawing Bollinger levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- Selecting the color of the levels
#property indicator_color2  clrDeepSkyBlue
#property indicator_color3  clrRed
//---- Levels - solid lines
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- The width of the levels is 2
#property indicator_width2  2
#property indicator_width3  2
//---- Showing the labels of the levels
#property indicator_label2  "XPoints Upper"
#property indicator_label3  "XPoints Lower"

//+----------------------------------------------+
//|  Parameters for drawing the bullish indicator|
//+----------------------------------------------+
//---- Drawing the indicator 4 as a character
#property indicator_type4   DRAW_ARROW
//---- The color of the bullish indicator is green
#property indicator_color4  clrLime
//---- The line width of the indicator 4 is 4
#property indicator_width4  4
//---- Showing the bearish label of the indicator
#property indicator_label4 "XPoints Buy"

//+----------------------------------------------+
//|  Parameters for drawing the bearish indicator|
//+----------------------------------------------+
//---- Drawing the indicator 5 as a character
#property indicator_type5   DRAW_ARROW
//---- The color of the bearish indicator is pink
#property indicator_color5  clrMagenta
//---- The width of the indicator 5 line is 4
#property indicator_width5  4
//---- Showing the bearish label of the indicator
#property indicator_label5  "XPoints Sell"
//+-----------------------------------------------+
//|  Declaring the enumerations                   |
//+-----------------------------------------------+
enum Hour1 //Type of the constant
  {
   H00 = 0,     //0
   H01,         //1
   H02,         //2
   H03,         //3
   H04,         //4
   H05,         //5
   H06,         //6
   H07,         //7
   H08,         //8
   H09,         //9
   H10,         //10
   H11,         //11
   H12,         //12
   H13,         //13
   H14,         //14
   H15,         //15
   H16,         //16
   H17,         //17
   H18,         //18
   H19,         //19
   H20,         //20
   H21,         //21
   H22,         //22
   H23          //23
  };
//+-----------------------------------------------+
//|  Declaring enumerations                       |
//+-----------------------------------------------+
enum Hour2 //Type of constant
  {
   H_01=1,       //1
   H_02,         //2
   H_03,         //3
   H_04,         //4
   H_05,         //5
   H_06,         //6
   H_07,         //7
   H_08,         //8
   H_09,         //9
   H_10,         //10
   H_11,         //11
   H_12,         //12
   H_13,         //13
   H_14,         //14
   H_15,         //15
   H_16,         //16
   H_17,         //17
   H_18,         //18
   H_19,         //19
   H_20,         //20
   H_21,         //21
   H_22,         //22
   H_23,         //23
   H_24          //24
  };
//+-----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                   |
//+-----------------------------------------------+
input uint   iper=3;        // Period for constructing the channel
input double ixrate=1.5;    // Minimal ratio
input uint   ixsize=5;      // Minimal bar height (High-Low) in points
input uint   ixslope=0;     // Minimal increase of the next bar in points
input uint   ixminupdn=10;  // Minimal channel width in points

input Hour1  ixhour1=H09;   // Minimal hour staring with which signals are allowed
input Hour2  ixhour2=H_19;  // Maximal hour up to which signals are allowed
input uint   ixindent=15;   // Shift of the signal from the chart in points

input int    Shift=0;       // Horizontal shift of the indicator in bars
//+------------------------------------------------+

//---- Declaring dynamic arrays that will be further 
// used as indicator buffers
double BfXB[],BfXS[];
double BufD[],BufU[],BufM[];

//---- Declaring integer variables of data calculation start
int min_rates_total;
int xrate,xsize,AtrPeriod;
double xindent,xhour2;
//+------------------------------------------------------------------+
//| GetRange function                                                |
//+------------------------------------------------------------------+     
double GetRange(int index,const double &Low[],const double &High[],uint Len)
  {
//----
   double AvgRange=0.0;
   for(int count=index; count<int(index+Len); count++) AvgRange+=MathAbs(High[count]-Low[count]);
//----
   return(AvgRange/Len);
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   AtrPeriod=10;
   min_rates_total=int(MathMax(iper,AtrPeriod)+1);

   if(ixrate<1) xrate=1; else xrate=int(ixrate);
   if(ixsize<3) xsize=3; else xsize=int(ixsize);
   if(ixindent<3) xindent=3; else xindent=ixindent;
   xhour2=ixhour2;
   if(xhour2<=int(ixhour1)) xhour2=ixhour1+1;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,BufM,INDICATOR_DATA);
//---- Shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BufM,true);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,BufU,INDICATOR_DATA);
   SetIndexBuffer(2,BufD,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- Drawing of empty values is forbidden
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BufU,true);
   ArraySetAsSeries(BufD,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,BfXB,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- Indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,233);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BfXB,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(4,BfXS,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- Inddicator symmbol
   PlotIndexSetInteger(4,PLOT_ARROW,234);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BfXS,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"XPoints");

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime  &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(0);

//---- indexing elements in arrays as in timeseries
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);

//---- Declaring floating point variables  
   double MaxP,MinP,ArrowB,ArrowS,xrate1;
   double HeightHL0,HeightHL1,HeightCO0,HeightCO1,HeightUD;
   double CenterHL0,CenterHL1,CenterCO0,CenterCO1;

//---- Declaration of integer variables and getting the bars already calculated
   int limit,bar;
//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BfXB[bar]=0.0;
      BfXS[bar]=0.0;


      MinP=Low[ArrayMinimum(Low,bar,iper)];
      MaxP=High[ArrayMaximum(High,bar,iper)];

      BufD[bar]=MinP;
      BufU[bar]=MaxP;
      BufM[bar]=(MinP+MaxP)/2;

      HeightUD=(MaxP-MinP)/_Point;
      if(HeightUD<ixminupdn) continue;

      //---- check time
      MqlDateTime tm;
      TimeToStruct(Time[bar],tm);
      if(tm.hour<ixhour1 || tm.hour>xhour2) continue;

      //---- arrow positions
      ArrowB=Low[bar]-xindent*_Point;
      ArrowS=High[bar]+xindent*_Point;

      //---- signal measurements
      HeightHL0=(High[bar+0]-Low[bar+0])/_Point;
      HeightHL1=(High[bar+1]-Low[bar+1])/_Point;

      HeightCO0=(Close[bar+0]-Open[bar+0])/_Point;
      HeightCO1=(Close[bar+1]-Open[bar+1])/_Point;

      CenterHL0=(High[bar+0]+Low[bar+0])/2;
      CenterHL1=(High[bar+1]+Low[bar+1])/2;

      CenterCO0=(Open[bar+0]+Close[bar+0])/2;
      CenterCO1=(Open[bar+1]+Close[bar+1])/2;

      //---- check if X-_Point      
      if(HeightHL1<xsize) continue;

      xrate1=HeightCO1/HeightHL1;
      if(MathAbs(xrate1)>1/xrate) continue;

      //---- check if there is a trend    
      if(
         Low[bar+1]<=BufD[bar+1]
         && High[bar+1]<BufU[bar+1]
         && Low[bar+0]>=Low[bar+1]+ixslope*_Point

         && (CenterCO1<=BufM[bar+1]
         || CenterCO0 >= CenterCO1+ixslope*_Point
         || CenterHL0 >= CenterHL1+ixslope*_Point)
         )
         BfXB[bar]=ArrowB-GetRange(bar,Low,High,AtrPeriod)/2.0;

      if(
         High[bar+1]>=BufU[bar+1]
         && Low[bar+1]>BufD[bar+1]
         && High[bar+0]<=High[bar+1]-ixslope*_Point

         && (CenterCO1>=BufM[bar+1]
         || CenterCO0 <= CenterCO1-ixslope*_Point
         || CenterHL0 <= CenterHL1-ixslope*_Point)
         )
         BfXS[bar]=ArrowS+GetRange(bar,Low,High,AtrPeriod)/2.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
