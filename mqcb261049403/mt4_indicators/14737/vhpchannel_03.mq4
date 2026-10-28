//+------------------------------------------------------------------+
//|                                               VHPChannel_03.mq4  |
//+------------------------------------------------------------------+
#property description "VHPChannel_03"
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//---- plot ExtAMABuffer
#property indicator_label1  "VHPChannel_03"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBisque
#property indicator_style2  3
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrPeachPuff
#property indicator_width3  2
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrPeachPuff
#property indicator_width4  2
//--- input parameters
input int InpHPPeriodFast=21;   // HP Fast Period (4...32)
input int InpHPPeriodSlow=100;  // HP Slow Period (48...256)
input color FontColor=clrYellow;// color of text label
//--- indicator buffers
double HP[],HPSlow[],Dev1[],Dev2[];
//--- global variables
int HPPeriodFast,HPPeriodSlow;
double Lambda,Lambda2;
string ShortName;
//----- for spread--
#define SPREAD_BUF_SIZE        32
#define SPREAD_BUF_MAX_IDX     (SPREAD_BUF_SIZE - 1)

double  SpreadBuf[SPREAD_BUF_SIZE];
int     SpreadBufIdx;
//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check for input values
   if(InpHPPeriodFast<4 || InpHPPeriodFast>32)
     {
      printf("Input parameter InpHPPeriodFast has incorrect value (%d). Indicator will use value 21 for calculations.",InpHPPeriodFast);
      HPPeriodFast=21;
     }
   else HPPeriodFast=InpHPPeriodFast;
   if(InpHPPeriodSlow<48 || InpHPPeriodSlow>256)
     {
      printf("Input parameter InpHPPeriodSlow has incorrect value (%d). Indicator will use value 144 for calculations.",InpHPPeriodSlow);
      HPPeriodSlow=144;
     }
   else HPPeriodSlow=InpHPPeriodSlow;
//--- indicator buffers mapping
   SetIndexBuffer(0,HP,INDICATOR_DATA);
   ArraySetAsSeries(HP,true);
   SetIndexBuffer(1,HPSlow,INDICATOR_DATA);
   ArraySetAsSeries(HPSlow,true);
   SetIndexBuffer(2,Dev1,INDICATOR_DATA);
   ArraySetAsSeries(Dev1,true);
   SetIndexBuffer(3,Dev2,INDICATOR_DATA);
   ArraySetAsSeries(Dev2,true);
//--- set shortname and change label
   ShortName="VHPChannel("+IntegerToString(HPPeriodFast)+","+IntegerToString(HPPeriodSlow)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);
   PlotIndexSetString(0,PLOT_LABEL,"HP");
   PlotIndexSetString(1,PLOT_LABEL,"HPSlow");
   PlotIndexSetString(2,PLOT_LABEL,"Dev1");
   PlotIndexSetString(3,PLOT_LABEL,"Dev2");
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//
   Lambda = 0.0625 / MathPow(MathSin(M_PI / HPPeriodFast), 4);   // коэфф. сглаживания быстрой HP
   Lambda2 = 0.0625 / MathPow(MathSin(M_PI / HPPeriodSlow), 4);  // коэфф. сглаживания медленной HP            

   ObjectsDeleteAll(0,"VHPChannel");
   WindowRedraw();
   Sleep(25);
   ObjectCreate(0,ShortName,OBJ_LABEL,0,0,0);
   Print("ObjectCreate(0, ShortName, OBJ_LABEL, 0, 0, 0)","   ",ShortName);
   ObjectSetInteger(0,ShortName,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0,ShortName,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,ShortName,OBJPROP_XDISTANCE,52);
   ObjectSetInteger(0,ShortName,OBJPROP_YDISTANCE,18);
   ObjectSetInteger(0,ShortName,OBJPROP_FONTSIZE,11);
   ObjectSetInteger(0,ShortName,OBJPROP_COLOR,FontColor);
   ObjectSetInteger(0,ShortName,OBJPROP_SELECTABLE,true);
   ObjectSetString(0,ShortName,OBJPROP_FONT,"Tahoma");

   return(0);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,"VHPChannel");
  }
//+------------------------------------------------------------------+
//| Indicator iteration function                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[])
  {
   int i;
   double InpDat[],disp,dev,val;

   if(rates_total < HPPeriodSlow + 1) return(0);
   if(rates_total!=prev_calculated)
     {
      i=Bars(Symbol(),0)-HPPeriodSlow;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,i);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,i);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,i);
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,i);
     }
   ArraySetAsSeries(Close,true);
   ArrayResize(InpDat,HPPeriodSlow);
   ArraySetAsSeries(InpDat,true);
   for(i=0; i<HPPeriodSlow; i++) InpDat[i]=Close[i];
//-----------------------------------HP fast-------------
   HPF(HPPeriodSlow,Lambda,InpDat,HP);
//-----------------------------------HP slow-------------
   HPF(HPPeriodSlow,Lambda2,HP,HPSlow);
//-----------------------------------Std    -------------
   disp=0.0;
   for(i= 0; i<HPPeriodSlow; i++) disp+=(HP[i]-HPSlow[i])*(HP[i]-HPSlow[i]);
   disp = disp/(HPPeriodSlow-1);
   dev=MathSqrt(disp)*2.0;
   for(i=0; i<HPPeriodSlow; i++)
     {
      Dev1[i] = HPSlow[i] + dev;
      Dev2[i] = HPSlow[i] - dev;
     }
//-------------------------------------------------------
   val=dev/HPSlow[0] *200;

   SpreadBuf[SpreadBufIdx++]=Ask-Bid;
   SpreadBufIdx &=SPREAD_BUF_MAX_IDX;
   double sprd=0;
   for(int n = 0; n < SPREAD_BUF_SIZE; n++)
      sprd += SpreadBuf[n];
   sprd/=(double)SPREAD_BUF_SIZE;
   string s="Spread = "+DoubleToString(sprd,_Digits);
//    ObjectSetString(0, ShortName, OBJPROP_TEXT, "Channel=" + DoubleToString(val, 2) + "%");
   ObjectSetString(0,ShortName,OBJPROP_TEXT,s+"    Channel="+DoubleToString(val,2)+"%");
//ChartRedraw();
   WindowRedraw();

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Hodrick-Prescott Filter                                          |
//+------------------------------------------------------------------+
void HPF(int nobs,double lambda,double &x[],double &y[])
  {
   double a[],b[],c[],H1=0,H2=0,H3=0,H4=0,H5=0,HH1=0,HH2=0,HH3=0,HH5=0,HB=0,HC=0,Z=0;
   int i;

   ArrayResize(a,nobs);
   ArrayResize(b,nobs);
   ArrayResize(c,nobs);

   ZeroMemory(a);
   ZeroMemory(b);
   ZeroMemory(c);

   a[0] = 1.0 + lambda;
   b[0] = -2.0*lambda;
   c[0] = lambda;
   for(i= 1; i<nobs-2; i++)
     {
      a[i] = 6.0*lambda + 1.0;
      b[i] = -4.0*lambda;
      c[i] = lambda;
     }
   a[1]=5.0*lambda+1;
   a[nobs - 1] = 1.0 + lambda;
   a[nobs - 2] = 5.0*lambda + 1.0;
   b[nobs - 2] = -2.0*lambda;
   b[nobs - 1] = 0.0;
   c[nobs - 2] = 0.0;
   c[nobs - 1] = 0.0;
//--- forward
   for(i=0; i<nobs; i++)
     {
      Z=a[i]-H4*H1-HH5*HH2;
      HB=b[i];
      HH1= H1;
      H1 =(HB-H4*H2)/Z;
      b[i]=H1;
      HC=c[i];
      HH2= H2;
      H2 = HC/Z;
      c[i] = H2;
      a[i] = (x[i] - HH3*HH5 - H3*H4) / Z;
      HH3= H3;
      H3 = a[i];
      H4 = HB - H5*HH1;
      HH5= H5; H5 = HC;
     }
//Backward 
   H2 = 0;
   H1 = a[nobs - 1];
   y[nobs-1]=H1;
   for(i=nobs-2; i>=0; i--)
     {
      y[i]=a[i]-b[i] *H1-c[i] *H2;
      H2 = H1;
      H1 = y[i];
     }
  }
//-----------------------------------------------------------------------------
