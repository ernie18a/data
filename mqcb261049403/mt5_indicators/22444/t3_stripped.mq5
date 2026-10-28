//------------------------------------------------------------------
#property copyright   "© mladen"
#property link        "mladenfx@gmail.com"
#property description "T3 stripped"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers  16
#property indicator_plots    11
#property indicator_label1   "Fill 1"
#property indicator_type1    DRAW_FILLING
#property indicator_color1   C'0,205,126',C'155,0,126'
#property indicator_label2   "Fill 2"
#property indicator_type2    DRAW_FILLING
#property indicator_color2   C'0,180,126',C'180,0,126'
#property indicator_label3   "Fill 3"
#property indicator_type3    DRAW_FILLING
#property indicator_color3   C'0,155,126',C'205,0,126'
#property indicator_label4   "Fill 4"
#property indicator_type4    DRAW_FILLING
#property indicator_color4   C'0,155,126',C'205,0,126'
#property indicator_label4   "Fill 5"
#property indicator_type5    DRAW_FILLING
#property indicator_color5   C'0,155,126',C'205,0,126'
#property indicator_label6   "T3 step 1"
#property indicator_type6    DRAW_LINE
#property indicator_color6   clrGray
#property indicator_label7   "T3 step 2"
#property indicator_type7    DRAW_LINE
#property indicator_color7   clrGray
#property indicator_label8   "T3 step 3"
#property indicator_type8    DRAW_LINE
#property indicator_color8   clrGray
#property indicator_label9   "T3 step 4"
#property indicator_type9    DRAW_LINE
#property indicator_color9   clrGray
#property indicator_label10  "T3 step 5"
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrGray
#property indicator_label11  "T3 step 6"
#property indicator_type11   DRAW_LINE
#property indicator_color11  clrGray
//
//--- input parameters
//
enum enT3Type
  {
   t3_tillson, // Tim Tillson way of calculation
   t3_fulksmat // Fulks / Matulich way of calculation
  };
input double             inpPeriod = 14;          // Period
input double             inpHot    = 0.7;         // Hot
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price
input enT3Type           inpT3Type = t3_fulksmat; // T3 type
//
//--- indicator buffers
//
double t3_1u[],t3_1d[],t3_2u[],t3_2d[],t3_3u[],t3_3d[],t3_4u[],t3_4d[],t3_5u[],t3_5d[],t3_1[],t3_2[],t3_3[],t3_4[],t3_5[],t3_6[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0,t3_1u ,INDICATOR_DATA);
   SetIndexBuffer(1,t3_1d ,INDICATOR_DATA);
   SetIndexBuffer(2,t3_2u ,INDICATOR_DATA);
   SetIndexBuffer(3,t3_2d ,INDICATOR_DATA);
   SetIndexBuffer(4,t3_3u ,INDICATOR_DATA);
   SetIndexBuffer(5,t3_3d ,INDICATOR_DATA);
   SetIndexBuffer(6,t3_4u ,INDICATOR_DATA);
   SetIndexBuffer(7,t3_4d ,INDICATOR_DATA);
   SetIndexBuffer(8,t3_5u ,INDICATOR_DATA);
   SetIndexBuffer(9,t3_5d ,INDICATOR_DATA);
   SetIndexBuffer(10,t3_1 ,INDICATOR_DATA);
   SetIndexBuffer(11,t3_2 ,INDICATOR_DATA);
   SetIndexBuffer(12,t3_3 ,INDICATOR_DATA);
   SetIndexBuffer(13,t3_4 ,INDICATOR_DATA);
   SetIndexBuffer(14,t3_5 ,INDICATOR_DATA);
   SetIndexBuffer(15,t3_6 ,INDICATOR_DATA);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{ 
   int i=MathMax(prev_calculated-1,0); for (; i<rates_total  && !_StopFlag; i++)
   {
      double laga,lagb,lagc,lagd,lage,lagf; 
         iT3(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,inpHot,inpT3Type==t3_tillson,laga,lagb,lagc,lagd,lage,lagf,i);
            t3_1[i]  = laga;
            t3_2[i]  = lagb;
            t3_3[i]  = lagc;
            t3_4[i]  = lagd;
            t3_5[i]  = lage;
            t3_6[i]  = lagf;
            t3_1u[i] = laga;
            t3_1d[i] = lagb;
            t3_2u[i] = lagb;
            t3_2d[i] = lagc;
            t3_3u[i] = lagc;
            t3_3d[i] = lagd;
            t3_4u[i] = lagd;
            t3_4d[i] = lage;
            t3_5u[i] = lage;
            t3_5d[i] = lagf;
   }
   return(i);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _t3Instances 1
#define _t3InstancesSize 6
#define _t3RingSize 5
double workT3[_t3RingSize][_t3Instances*_t3InstancesSize];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5
//
//
//
void iT3(double price, double period, double hot, bool original, double& lev0, double& lev1, double& lev2, double& lev3, double& lev4, double& lev5, int i, int instance=0)
{
   int _indP = (i-1)%_t3RingSize;
   int _indC = (i  )%_t3RingSize;
   int _inst = instance*_t3InstancesSize;
   
   //
   //--
   //
   
   if(ArrayRange(workT3Coeffs,0)<(instance+1)) { ArrayResize(workT3Coeffs,instance+1); workT3Coeffs[instance][_period]=-99; }
   if(workT3Coeffs[instance][_period]!=period)
   {
         workT3Coeffs[instance][_period] = period;
         workT3Coeffs[instance][_c1]     = -hot*hot*hot;
         workT3Coeffs[instance][_c2]     = 3*hot*hot+3*hot*hot*hot;
         workT3Coeffs[instance][_c3]     = -6*hot*hot-3*hot-3*hot*hot*hot;
         workT3Coeffs[instance][_c4]     = 1+3*hot+hot*hot*hot+3*hot*hot;
         workT3Coeffs[instance][_alpha]  = (original) ? 2.0/(1.0+period) : 2.0/(2.0+(period-1.0)/2.0);
   }
   for(int k=0; k<_t3InstancesSize; k++) workT3[_indC][k+_inst]=(i>0) ? workT3[_indP][k+_inst]: price;
   if(i>0 && period>1)
   {
      workT3[_indC][  _inst] = workT3[_indP][  _inst]+workT3Coeffs[instance][_alpha]*(price                 -workT3[_indP][  _inst]);
      workT3[_indC][1+_inst] = workT3[_indP][1+_inst]+workT3Coeffs[instance][_alpha]*(workT3[_indC][0+_inst]-workT3[_indP][1+_inst]);
      workT3[_indC][2+_inst] = workT3[_indP][2+_inst]+workT3Coeffs[instance][_alpha]*(workT3[_indC][1+_inst]-workT3[_indP][2+_inst]);
      workT3[_indC][3+_inst] = workT3[_indP][3+_inst]+workT3Coeffs[instance][_alpha]*(workT3[_indC][2+_inst]-workT3[_indP][3+_inst]);
      workT3[_indC][4+_inst] = workT3[_indP][4+_inst]+workT3Coeffs[instance][_alpha]*(workT3[_indC][3+_inst]-workT3[_indP][4+_inst]);
      workT3[_indC][5+_inst] = workT3[_indP][5+_inst]+workT3Coeffs[instance][_alpha]*(workT3[_indC][4+_inst]-workT3[_indP][5+_inst]);
   }
   lev0 = workT3[_indC][_inst ];
   lev1 = workT3[_indC][_inst+1];
   lev2 = workT3[_indC][_inst+2];
   lev3 = workT3[_indC][_inst+3];
   lev4 = workT3[_indC][_inst+4];
   lev5 = workT3[_indC][_inst+5];
   
   //
   //---
   //
   
   #undef _period
   #undef _c1
   #undef _c2
   #undef _c3
   #undef _c4
   #undef _alpha
}
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   switch(tprice)
     {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
     }
   return(0);
  }
//------------------------------------------------------------------
