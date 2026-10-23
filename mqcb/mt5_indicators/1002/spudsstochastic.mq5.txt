//+------------------------------------------------------------------+
//|                                              SpudsStochastic.mq5 | 
//|                               Copyright © 2012, Vladimir Hlystov |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Vladimir Hlystov"
#property link      "cmillion@narod.ru"
//---- description of the indicator
#property description "The composition of the indicator - 8 stochastic oscillators."
#property description "Parameters «slow» and «period %D» leave the default – 3."
#property description "Parameter %K will change from 6 to 24."
#property description "The result - 8 stochastics with parameters (6, 3, 3), (7, 3, 3), (8, 3, 3) … (24, 3, 3)."
#property description "All indicators are used only the main line."
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 10
#property indicator_buffers 10 
//---- 9 graphical plots are used in total
#property indicator_plots   9
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| The parameters of the boundary values ??of   |
//| the indicator                                |
//+----------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 100
//+----------------------------------------------+
//|  Levels drawing parameters                   |
//+----------------------------------------------+
//---- drawing the levels as lines
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
//---- selection of levels colors
#property indicator_color1  Silver
#property indicator_color2  Blue
#property indicator_color3  Blue
#property indicator_color4  Blue
#property indicator_color5  Yellow
#property indicator_color6  Red
#property indicator_color7  Red
#property indicator_color8  Red
//---- levels are dott-dash curves
#property indicator_style1 STYLE_DASHDOTDOT
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_style8 STYLE_DASHDOTDOT
//---- Bollinger Bands width is equal to 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1
//---- display the labels of Bollinger Bands levels
#property indicator_label1  "Стохастик 1"
#property indicator_label2  "Стохастик 2"
#property indicator_label3  "Стохастик 3"
#property indicator_label4  "Стохастик 4"
#property indicator_label5  "Стохастик 5"
#property indicator_label6  "Стохастик 6"
#property indicator_label7  "Стохастик 7"
#property indicator_label8  "Стохастик 8"
//---- drawing of the indicator as a three color histogram
#property indicator_type9 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the four color histogram
#property indicator_color9 Gray,Magenta,Teal
//---- Indicator line is a solid one
#property indicator_style9 STYLE_SOLID
//---- indicator line width is equal to 5
#property indicator_width9 5
//---- displaying the indicator label
#property indicator_label9 "Сигнал"
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input int LevelUp = 85; // level of overbought zone 
input int LevelDn = 15; // level of oversold zone 
input ENUM_MA_METHOD ma_method=MODE_SMA; // smoothing type
input ENUM_STO_PRICE price_field=STO_LOWHIGH; // stochastic calculation method
//+-----------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as Bollinger Bands indicator buffers
double LineBuffer1[],LineBuffer2[],LineBuffer3[],LineBuffer4[];
double LineBuffer5[],LineBuffer6[],LineBuffer7[],LineBuffer8[];
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double SignBuffer[],ColorSignBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//----Declaration of variables for storing the indicators handles
int STO_Handle[8];
int Signal;
//+------------------------------------------------------------------+   
//| Regression indicator initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=24+3+3+1;
   Signal=0;

//---- obtaining the indicators handles  
   STO_Handle[0]=iStochastic(NULL,0,6,3,3,ma_method,price_field);
   STO_Handle[1]=iStochastic(NULL,0,9,3,3,ma_method,price_field);
   STO_Handle[2]=iStochastic(NULL,0,12,3,3,ma_method,price_field);
   STO_Handle[3]=iStochastic(NULL,0,14,3,3,ma_method,price_field);
   STO_Handle[4]=iStochastic(NULL,0,16,3,3,ma_method,price_field);
   STO_Handle[5]=iStochastic(NULL,0,19,3,3,ma_method,price_field);
   STO_Handle[6]=iStochastic(NULL,0,21,3,3,ma_method,price_field);
   STO_Handle[7]=iStochastic(NULL,0,24,3,3,ma_method,price_field);
   if(STO_Handle[0]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic indicator");
   if(STO_Handle[1]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic indicator");
   if(STO_Handle[2]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic indicator");
   if(STO_Handle[3]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic indicator");
   if(STO_Handle[4]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic indicator");
   if(STO_Handle[5]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic indicator");
   if(STO_Handle[6]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic indicator");
   if(STO_Handle[7]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic indicator");

//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,LineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,LineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,LineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,LineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,LineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(5,LineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(6,LineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(7,LineBuffer8,INDICATOR_DATA);
//---- set the position, from which the levels drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(LineBuffer1,true);
   ArraySetAsSeries(LineBuffer2,true);
   ArraySetAsSeries(LineBuffer3,true);
   ArraySetAsSeries(LineBuffer4,true);
   ArraySetAsSeries(LineBuffer5,true);
   ArraySetAsSeries(LineBuffer6,true);
   ArraySetAsSeries(LineBuffer7,true);
   ArraySetAsSeries(LineBuffer8,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(8,SignBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SignBuffer,true);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(9,ColorSignBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(9,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorSignBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Spuds Stochastic(",EnumToString(ma_method),", ",EnumToString(price_field),")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- the number of the indicator 3 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,LevelUp);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LevelDn);
//---- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,Magenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,Gray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,Magenta);
//---- short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| Regression iteration function                                    | 
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
   if(BarsCalculated(STO_Handle[0])<rates_total
      || BarsCalculated(STO_Handle[1])<rates_total
      || BarsCalculated(STO_Handle[2])<rates_total
      || BarsCalculated(STO_Handle[3])<rates_total
      || BarsCalculated(STO_Handle[4])<rates_total
      || BarsCalculated(STO_Handle[5])<rates_total
      || BarsCalculated(STO_Handle[6])<rates_total
      || BarsCalculated(STO_Handle[7])<rates_total
      || rates_total<min_rates_total) return(RESET);
//---- declaration of local variables 
   int limit,to_copy,bar;

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars 

   to_copy=limit+1;

//--- copy newly appeared data in the array
   if(CopyBuffer(STO_Handle[0],MAIN_LINE,0,to_copy,LineBuffer1)<=0) return(RESET);
   if(CopyBuffer(STO_Handle[1],MAIN_LINE,0,to_copy,LineBuffer2)<=0) return(RESET);
   if(CopyBuffer(STO_Handle[2],MAIN_LINE,0,to_copy,LineBuffer3)<=0) return(RESET);
   if(CopyBuffer(STO_Handle[3],MAIN_LINE,0,to_copy,LineBuffer4)<=0) return(RESET);
   if(CopyBuffer(STO_Handle[4],MAIN_LINE,0,to_copy,LineBuffer5)<=0) return(RESET);
   if(CopyBuffer(STO_Handle[5],MAIN_LINE,0,to_copy,LineBuffer6)<=0) return(RESET);
   if(CopyBuffer(STO_Handle[6],MAIN_LINE,0,to_copy,LineBuffer7)<=0) return(RESET);
   if(CopyBuffer(STO_Handle[7],MAIN_LINE,0,to_copy,LineBuffer8)<=0) return(RESET);

//---- first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SignBuffer[bar]=EMPTY_VALUE;
      ColorSignBuffer[bar]=0;

      if((LineBuffer1[bar+1]>LevelUp && LineBuffer2[bar+1]>LevelUp && LineBuffer3[bar+1]>LevelUp && LineBuffer4[bar+1]>LevelUp
         && LineBuffer5[bar+1]>LevelUp && LineBuffer6[bar+1]>LevelUp && LineBuffer7[bar+1]>LevelUp && LineBuffer8[bar+1]>LevelUp)
         || (LineBuffer1[bar+1]<LevelDn && LineBuffer2[bar+1]<LevelDn && LineBuffer3[bar+1]<LevelDn && LineBuffer4[bar+1]<LevelDn
         && LineBuffer5[bar+1]<LevelDn && LineBuffer6[bar+1]<LevelDn && LineBuffer7[bar+1]<LevelDn && LineBuffer8[bar+1]<LevelDn))
        {
         Signal=0;
        }

      if((LineBuffer1[bar]>LevelDn && LineBuffer2[bar]>LevelDn && LineBuffer3[bar]>LevelDn && LineBuffer4[bar]>LevelDn
         && LineBuffer5[bar]>LevelDn && LineBuffer6[bar]>LevelDn && LineBuffer7[bar]>LevelDn && LineBuffer8[bar]>LevelDn)
         && (LineBuffer1[bar+1]<LevelDn || LineBuffer2[bar+1]<LevelDn || LineBuffer3[bar+1]<LevelDn || LineBuffer4[bar+1]<LevelDn
         || LineBuffer5[bar+1]<LevelDn || LineBuffer6[bar+1]<LevelDn || LineBuffer7[bar+1]<LevelDn || LineBuffer8[bar+1]<LevelDn))
        {
         if(!Signal)
           {
            SignBuffer[bar]=100;
            ColorSignBuffer[bar]=2;
            Signal=+1;
           }
        }

      if((LineBuffer1[bar]<LevelUp && LineBuffer2[bar]<LevelUp && LineBuffer3[bar]<LevelUp && LineBuffer4[bar]<LevelUp
         && LineBuffer5[bar]<LevelUp && LineBuffer6[bar]<LevelUp && LineBuffer7[bar]<LevelUp && LineBuffer8[bar]<LevelUp)
         && (LineBuffer1[bar+1]>LevelUp || LineBuffer2[bar+1]>LevelUp || LineBuffer3[bar+1]>LevelUp || LineBuffer4[bar+1]>LevelUp
         || LineBuffer5[bar+1]>LevelUp || LineBuffer6[bar+1]>LevelUp || LineBuffer7[bar+1]>LevelUp || LineBuffer8[bar+1]>LevelUp))
        {
         if(!Signal)
           {
            SignBuffer[bar]=100;
            ColorSignBuffer[bar]=1;
            Signal=-1;
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
