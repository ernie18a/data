//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "T3"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrOrange
#property indicator_width3  2
//---
enum enT3Type
  {
   t3_tillson, // Tim Tillson way of calculation
   t3_fulksmat // Fulks/Matulich way of calculation
  };
input int      inpT3Period=9;          // T3 period
input double   inpT3Hot   =0.3;        // T3 "hot"
input enT3Type inpT3Type  =t3_tillson; // T3 type
double  val[],valc[],levelUp[],levelDn[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
   //---- indicator buffers mapping
   SetIndexBuffer(0,levelUp,INDICATOR_DATA); 
   SetIndexBuffer(1,levelDn,INDICATOR_DATA); PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   //----
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   //----
   IndicatorSetString(INDICATOR_SHORTNAME,"T3 levels ("+(string)inpT3Period+")");
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i]     = iT3(close[i],inpT3Period,inpT3Hot,inpT3Type==t3_tillson,i,rates_total,false,0);
      levelUp[i] = iT3(val[i],inpT3Period,inpT3Hot,inpT3Type==t3_tillson,i,rates_total,(i>0 ? !(val[i]>levelDn[i-1]) : false),1);
      levelDn[i] = iT3(val[i],inpT3Period,inpT3Hot,inpT3Type==t3_tillson,i,rates_total,(i>0 ? !(val[i]<levelUp[i-1]) : false),2);
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _t3Instances     3
#define _t3InstancesSize 6
double workT3[][_t3Instances*_t3InstancesSize];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iT3(double price,double period,double hot,bool original,int r,int bars,bool copy=false,int instanceNo=0)
  {
   if(ArrayRange(workT3,0)!=bars) ArrayResize(workT3,bars);
   if(ArrayRange(workT3Coeffs,0)<(instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);
   if(workT3Coeffs[instanceNo][_period]!=period)
     {
      workT3Coeffs[instanceNo][_period]=period;
      workT3Coeffs[instanceNo][_c1] = -hot*hot*hot;
      workT3Coeffs[instanceNo][_c2] = 3*hot*hot+3*hot*hot*hot;
      workT3Coeffs[instanceNo][_c3] = -6*hot*hot-3*hot-3*hot*hot*hot;
      workT3Coeffs[instanceNo][_c4] = 1+3*hot+hot*hot*hot+3*hot*hot;
      if(original)
         workT3Coeffs[instanceNo][_alpha]=2.0/(1.0+period);
      else workT3Coeffs[instanceNo][_alpha]=2.0/(2.0+(period-1.0)/2.0);
     }
   //---
   int buffer=instanceNo*_t3InstancesSize;
   for(int k=0; k<6; k++) workT3[r][k+buffer]=(r>0) ? workT3[r-1][k+buffer]: price;
   if(!copy && r>0 && period>1)
     {
      workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
      workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
      workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
      workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
      workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
      workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
     }
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] +
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer]+
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer]+
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
  }
//+------------------------------------------------------------------+
