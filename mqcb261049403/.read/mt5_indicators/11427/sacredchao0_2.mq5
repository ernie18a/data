//+------------------------------------------------------------------+
//|                                               sacredchao-0_2.mq5 |
//|                                        Copyleft 2014, Eristocrat |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyleft 2014, Eristocrat"
#property link      "http://eristocrat.has-no-homepage.net/"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 16
#property indicator_plots   12
//--- plot Jaws
#property indicator_label1  "Jaws"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Teeth
#property indicator_label2  "Teeth"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Lips
#property indicator_label3  "Lips"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot BullishDivergentBar
#property indicator_label4  "BullishDivergentBar"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  3
//--- plot BearishDivergentBar
#property indicator_label5  "BearishDivergentBar"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  3
//--- plot BullishSuperAO
#property indicator_label6  "BullishSuperAO"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrGreen
#property indicator_style6  STYLE_SOLID
#property indicator_width6  3
//--- plot BearishSuperAO
#property indicator_label7  "BearishSuperAO"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrRed
#property indicator_style7  STYLE_SOLID
#property indicator_width7  3
//--- plot BullishFractal
#property indicator_label8  "BullishFractal"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrGreen
#property indicator_style8  STYLE_SOLID
#property indicator_width8  3
//--- plot BearishFractal
#property indicator_label9  "BearishFractal"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrRed
#property indicator_style9  STYLE_SOLID
#property indicator_width9  3
//--- plot TrailingMaxHigh
#property indicator_label10  "TrailingMaxHigh"
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrViolet
#property indicator_style10  STYLE_DOT
#property indicator_width10  1
//--- plot TrailingMinLow
#property indicator_label11  "TrailingMinLow"
#property indicator_type11   DRAW_LINE
#property indicator_color11  clrViolet
#property indicator_style11  STYLE_DOT
#property indicator_width11  1
//plot AngulationDeviation
#property indicator_label12  "Angulation Deviation"
#property indicator_type12   DRAW_NONE
//--- input parameters
input int                InpJawsPeriod=13;               // Jaws period
input int                InpJawsShift=8;                 // Jaws shift
input int                InpTeethPeriod=8;               // Teeth period
input int                InpTeethShift=5;                // Teeth shift
input int                InpLipsPeriod=5;                // Lips period
input int                InpLipsShift=3;                 // Lips shift
input ENUM_MA_METHOD     InpMAMethod=MODE_SMMA;          // Moving average method
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_MEDIAN;   // Applied price

input int               InpATRPeriod=14;                 //ATR Period
input double            InpPendingAddATRFactor=0.2;      //ATR*Factor added to pending orders
input double            InpStopAddATRFactor=0.5;         //ATR*Factor added to trailing stop

input int                InpHLBars=3;                    // Trailing Highest High/Lowest Low of x bars

input color             InpAngulationColor=clrMagenta;   // Angulation color
input ENUM_LINE_STYLE   InpAngulationStyle=STYLE_DASHDOT;// Angulation style
input int               InpAngulationWidth=1;            // Angulation width
input string   InpURLArrowCode="http://www.mql5.com/en/docs/constants/objectconstants/wingdings"; // Find Arrowcodes here:
input int               InpBuDBArrowCode=236;            // Bullish Divergent Arrowcode
input int               InpBeDBArrowCode=238;            // Bearish Divergent Arrowcode
input int               InpBuSAOArrowCode=142;           // Bullish Super AO Arrowcode
input int               InpBeSAOArrowCode=142;           // Bearish Super AO Arrowcode
input int               InpBuFrcArrowCode=217;           // Bullish Fractal Arrowcode
input int               InpBeFrcArrowCode=218;           // Bearish Fractal Arrowcode
//--- indicator buffers
double         JawsBuffer[];
double         TeethBuffer[];
double         LipsBuffer[];
double         BullishDivergentBarBuffer[];
double         BearishDivergentBarBuffer[];
double         BullishSuperAOBuffer[];
double         BearishSuperAOBuffer[];
double         BullishFractalBuffer[];
double         BearishFractalBuffer[];
double         TrailingMaxHighBuffer[];
double         TrailingMinLowBuffer[];
double         AOBuffer[];
double         ATRBuffer[];
double         AngulationBuffer[];
double         UpFractalsBuffer[];
double         DownFractalsBuffer[];
//--- indicator handles
int gJawsHandle;
int gTeethHandle;
int gLipsHandle;
int gAOHandle;
int gATRHandle;
int gFractalsHandle;
//--- chart must have Bars 
int gBarsMin;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,JawsBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,TeethBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LipsBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,BullishDivergentBarBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,BearishDivergentBarBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,BullishSuperAOBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,BearishSuperAOBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,BullishFractalBuffer,INDICATOR_DATA);
   SetIndexBuffer(8,BearishFractalBuffer,INDICATOR_DATA);
   SetIndexBuffer(9,TrailingMaxHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(10,TrailingMinLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(11,AOBuffer,INDICATOR_DATA);
   SetIndexBuffer(12,ATRBuffer,INDICATOR_DATA);
   SetIndexBuffer(13,AngulationBuffer,INDICATOR_DATA);
   SetIndexBuffer(14,UpFractalsBuffer,INDICATOR_DATA);
   SetIndexBuffer(15,DownFractalsBuffer,INDICATOR_DATA);
//--- make it easy
   ArraySetAsSeries(JawsBuffer,true);
   ArraySetAsSeries(TeethBuffer,true);
   ArraySetAsSeries(LipsBuffer,true);
   ArraySetAsSeries(BullishDivergentBarBuffer,true);
   ArraySetAsSeries(BearishDivergentBarBuffer,true);
   ArraySetAsSeries(BullishSuperAOBuffer,true);
   ArraySetAsSeries(BearishSuperAOBuffer,true);
   ArraySetAsSeries(BullishFractalBuffer,true);
   ArraySetAsSeries(BearishFractalBuffer,true);
   ArraySetAsSeries(TrailingMaxHighBuffer,true);
   ArraySetAsSeries(TrailingMinLowBuffer,true);
   ArraySetAsSeries(AOBuffer,true);
   ArraySetAsSeries(ATRBuffer,true);
   ArraySetAsSeries(AngulationBuffer,true);
   ArraySetAsSeries(UpFractalsBuffer,true);
   ArraySetAsSeries(DownFractalsBuffer,true);
//--- setting a code from the Wingdings charset as property of PLOT_ARROW
   PlotIndexSetInteger(3,PLOT_ARROW,InpBuDBArrowCode);
   PlotIndexSetInteger(4,PLOT_ARROW,InpBeDBArrowCode);
   PlotIndexSetInteger(5,PLOT_ARROW,InpBuSAOArrowCode);
   PlotIndexSetInteger(6,PLOT_ARROW,InpBeSAOArrowCode);
   PlotIndexSetInteger(7,PLOT_ARROW,InpBuFrcArrowCode);
   PlotIndexSetInteger(8,PLOT_ARROW,InpBeFrcArrowCode);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpJawsPeriod-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpTeethPeriod-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpLipsPeriod-1);
//--- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,InpJawsShift);
   PlotIndexSetInteger(1,PLOT_SHIFT,InpTeethShift);
   PlotIndexSetInteger(2,PLOT_SHIFT,InpLipsShift);
//--- empty values
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(9,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(10,PLOT_EMPTY_VALUE,0.0);
//--- name for DataWindow 
   PlotIndexSetString(0,PLOT_LABEL,"Jaws("+string(InpJawsPeriod)+")");
   PlotIndexSetString(1,PLOT_LABEL,"Teeth("+string(InpTeethPeriod)+")");
   PlotIndexSetString(2,PLOT_LABEL,"Lips("+string(InpLipsPeriod)+")");
//--- get MA's handles
//--- Alligator
   gJawsHandle=iMA(NULL,0,InpJawsPeriod,0,InpMAMethod,InpAppliedPrice);
   gTeethHandle=iMA(NULL,0,InpTeethPeriod,0,InpMAMethod,InpAppliedPrice);
   gLipsHandle=iMA(NULL,0,InpLipsPeriod,0,InpMAMethod,InpAppliedPrice);
//--- Awesome oscillator
   gAOHandle=iAO(NULL,0);
//--- Average true range
   gATRHandle=iATR(NULL,0,InpATRPeriod);
//--- Fractals
   gFractalsHandle=iFractals(NULL,0);
//--- bars minimum for calculation   
   gBarsMin=MathMax(MathMax(InpJawsPeriod+InpJawsShift,InpTeethPeriod+InpTeethShift),InpLipsPeriod+InpLipsPeriod);
//--- initialization done
   return(INIT_SUCCEEDED);
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
//--- check for rates total
   if(rates_total<gBarsMin)
      return(0); // not enough bars for calculation
//--- declarations of local variables 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   int to_copy,limit,bar;
//---
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-gBarsMin; // starting index for calculating all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculating new bars
     }
   to_copy=limit+1;
//--- preparing buffer
   if(CopyBuffer(gJawsHandle,0,0,to_copy,JawsBuffer)<=0) return(0);
   if(CopyBuffer(gTeethHandle,0,0,to_copy,TeethBuffer)<=0) return(0);
   if(CopyBuffer(gLipsHandle,0,0,to_copy,LipsBuffer)<=0) return(0);
   if(CopyBuffer(gAOHandle,0,0,to_copy,AOBuffer)<=0) return(0);
   if(CopyBuffer(gATRHandle,0,0,to_copy,ATRBuffer)<=0) return(0);
   if(CopyBuffer(gFractalsHandle,UPPER_LINE,1,to_copy,UpFractalsBuffer)<=0) return(0);
   if(CopyBuffer(gFractalsHandle,LOWER_LINE,1,to_copy,DownFractalsBuffer)<=0) return(0);
//--- main loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- reset signals
      BullishDivergentBarBuffer[bar]=0.0;
      BearishDivergentBarBuffer[bar]=0.0;
      BullishSuperAOBuffer[bar]=0.0;
      BearishSuperAOBuffer[bar]=0.0;
      BullishFractalBuffer[bar]=0.0;
      BearishFractalBuffer[bar]=0.0;
      AngulationBuffer[bar]=0.0;
      //--- tmp values for angulation
      int angbars=0;
      double angpnow=0.0,angppast=0.0,anganow=0.0,angapast=0.0;
      //--- 1ST WISE MAN
      //--- bullish divergent bar under alligator and red AO
      //--- tba: for(bar+InpX < bar+InpX+1) (higher high/lower low for InpX bars)
      if(low[bar]<low[bar+1] && close[bar]>(high[bar]+low[bar])/2 && AOBuffer[bar]<AOBuffer[bar+1]
         && high[bar]<MathMin(JawsBuffer[bar+InpJawsShift],MathMin(LipsBuffer[bar+InpLipsShift],TeethBuffer[bar+InpTeethShift])))
        {
         //--- count bars until price crosses alligator         
         while(high[bar+angbars]<MathMax(JawsBuffer[bar+angbars+InpJawsShift],MathMax(LipsBuffer[bar+angbars+InpLipsShift],TeethBuffer[bar+angbars+InpTeethShift]))) angbars++;
         //--- get basevalues for angulation of price and alligator
         angppast=low[bar+angbars];
         angpnow=low[bar];
         //--- tba: (jaw*jfactor + teeth*tfactor + lips*lfactor)/(jfactor+tfactor+lfactor)
         angapast=NormalizeDouble((JawsBuffer[bar+angbars+InpJawsShift]+TeethBuffer[bar+angbars+InpTeethShift])/2,Digits());
         anganow=NormalizeDouble((JawsBuffer[bar+InpJawsShift]+TeethBuffer[bar+InpTeethShift])/2,Digits());
         //--- draw lines
         string patmp="PriceAngle"+string(bar),aatmp="AlligatorAngle"+string(bar);
         drawAngulationLine(patmp,time[bar+angbars],angppast,time[bar],angpnow);
         drawAngulationLine(aatmp,time[bar+angbars],angapast,time[bar],anganow);
         //--- not divided by zero
         if(angbars!=0)
            //--- calc angulation deviation in points/bar         
            AngulationBuffer[bar]=(anganow-angpnow-(angapast-angppast))/angbars/Point();
         //--- signal + safety as ATR*Factor e.g. 0.1 = 10%
         //tba: if(angulationinpoints > angulationthreshhold)          
         BullishDivergentBarBuffer[bar]=NormalizeDouble(high[bar]+(ATRBuffer[bar]*InpPendingAddATRFactor),Digits());
        }
      //--- bearish divergent bar over alligator and green AO
      if(high[bar]>high[bar+1] && close[bar]<(high[bar]+low[bar])/2 && AOBuffer[bar]>AOBuffer[bar+1]
         && low[bar]>MathMax(JawsBuffer[bar+InpJawsShift],MathMax(LipsBuffer[bar+InpLipsShift],TeethBuffer[bar+InpTeethShift])))
        {
         //---
         while(low[bar+angbars]>MathMin(JawsBuffer[bar+angbars+InpJawsShift],MathMin(LipsBuffer[bar+angbars+InpLipsShift],TeethBuffer[bar+angbars+InpTeethShift]))) angbars++;
         //---
         angppast=high[bar+angbars];
         angpnow=high[bar];
         angapast=NormalizeDouble((JawsBuffer[bar+angbars+InpJawsShift]+TeethBuffer[bar+angbars+InpTeethShift])/2,Digits());
         anganow=NormalizeDouble((JawsBuffer[bar+InpJawsShift]+TeethBuffer[bar+InpTeethShift])/2,Digits());
         //---
         string patmp="PriceAngle"+string(bar),aatmp="AlligatorAngle"+string(bar);
         drawAngulationLine(patmp,time[bar+angbars],angppast,time[bar],angpnow);
         drawAngulationLine(aatmp,time[bar+angbars],angapast,time[bar],anganow);
         //---
         if(angbars!=0)
            AngulationBuffer[bar]=(anganow-angpnow-(angapast-angppast))/angbars/Point();
         //---
         BearishDivergentBarBuffer[bar]=NormalizeDouble(low[bar]-(ATRBuffer[bar]*InpPendingAddATRFactor),Digits());
        }
      //--- 2ND WISE MAN
      //--- SuperAO signal, 3 green bars
      if(AOBuffer[bar]>AOBuffer[bar+1] && AOBuffer[bar+1]>AOBuffer[bar+2]
         && AOBuffer[bar+2]>AOBuffer[bar+3] && AOBuffer[bar+3]<AOBuffer[bar+4])
        {
         BullishSuperAOBuffer[bar]=NormalizeDouble(high[bar]+(ATRBuffer[bar]*InpPendingAddATRFactor),Digits());
        }
      //--- SuperAO, 3 red bars
      if(AOBuffer[bar]<AOBuffer[bar+1] && AOBuffer[bar+1]<AOBuffer[bar+2]
         && AOBuffer[bar+2]<AOBuffer[bar+3] && AOBuffer[bar+3]>AOBuffer[bar+4])
        {
         BearishSuperAOBuffer[bar]=NormalizeDouble(low[bar]-(ATRBuffer[bar]*InpPendingAddATRFactor),Digits());
        }
      //--- 3RD WISE MAN
      //--- tba: select above/below Teeth/jaws/lips/whole
      //--- UpFractal above Teeth
      if(UpFractalsBuffer[bar+3]!=EMPTY_VALUE && low[bar+3]>TeethBuffer[bar])
        {
         BullishFractalBuffer[bar+3]=NormalizeDouble(high[bar+3]+(ATRBuffer[bar]*InpPendingAddATRFactor),Digits());
        }
      //--- DownFractal below Teeth
      if(DownFractalsBuffer[bar+3]!=EMPTY_VALUE && high[bar+3]<TeethBuffer[bar])
        {
         BearishFractalBuffer[bar+3]=NormalizeDouble(low[bar+3]-(ATRBuffer[bar]*InpPendingAddATRFactor),Digits());
        }
      //--- TRAILING
      //--- max/min of high/low last x bars
      double highsbuf[],lowsbuf[];
      if(CopyHigh(NULL,0,bar,InpHLBars,highsbuf)<=0) return(0);
      TrailingMaxHighBuffer[bar]=NormalizeDouble(highsbuf[ArrayMaximum(highsbuf)]+(ATRBuffer[bar]*InpStopAddATRFactor),Digits());
      if(CopyLow(NULL,0,bar,InpHLBars,lowsbuf)<=0) return(0);
      TrailingMinLowBuffer[bar]=NormalizeDouble(lowsbuf[ArrayMinimum(lowsbuf)]-(ATRBuffer[bar]*InpStopAddATRFactor),Digits());
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| drawAngulationLine                                               |
//+------------------------------------------------------------------+
void drawAngulationLine(string name,datetime starttime,double startval,datetime stoptime,double stopval)
  {
   ObjectCreate(0,name,OBJ_TREND,0,starttime,startval,stoptime,stopval);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpAngulationColor);
   ObjectSetInteger(0,name,OBJPROP_STYLE,InpAngulationStyle);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,InpAngulationWidth);
   return;
  }
//+------------------------------------------------------------------+
