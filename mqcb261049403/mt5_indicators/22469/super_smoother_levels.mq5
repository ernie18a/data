//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "shadow"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_width1  6
#property indicator_label2  "up level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "down level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Super smoother"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrLimeGreen,clrOrange
#property indicator_width4  2
//---
input int inpSsmPeriod=14; // Super smoother period
double  val[],valc[],vals[],levelUp[],levelDn[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
   //---- indicator buffers mapping
   SetIndexBuffer(0,vals,INDICATOR_DATA); 
   SetIndexBuffer(1,levelUp,INDICATOR_DATA); 
   SetIndexBuffer(2,levelDn,INDICATOR_DATA);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
   //----
   IndicatorSetString(INDICATOR_SHORTNAME,"Super smoother levels ("+(string)inpSsmPeriod+")");
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
      val[i]     = iSuperSmoother(close[i],inpSsmPeriod,i,false,0);
      levelUp[i] = iSuperSmoother(val[i]  ,inpSsmPeriod,i,(i>0 ? !(val[i]>levelDn[i-1]) : false),1);
      levelDn[i] = iSuperSmoother(val[i]  ,inpSsmPeriod,i,(i>0 ? !(val[i]<levelUp[i-1]) : false),2);
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
      vals[i]    = val[i];
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _ssmInstances 3
#define _ssmInstancesSize 2
#define _ssmRingSize 10
double workSsm[_ssmRingSize][_ssmInstances*_ssmInstancesSize];
#define _price 0
#define _ssm   1
double workSsmCoeffs[][4];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
//
//---
//
double iSuperSmoother(double price, double period, int i, bool copy=false, int instance=0)
{
   int _indP = (i-1)%_ssmRingSize;
   int _indC = (i  )%_ssmRingSize;
   int _inst = instance*_ssmInstancesSize;
   
   //
   //--
   //
   
      if(!copy && i>1 && period>1)
      {
         if(ArrayRange(workSsmCoeffs,0)<(instance+1)) { ArrayResize(workSsmCoeffs,instance+1); workSsmCoeffs[instance][_period]=-99; }
         if(workSsmCoeffs[instance][_period]!=period)
         {
            double a1 = MathExp(-1.414*M_PI/period);
            double b1 = 2.0*a1*MathCos(1.414*M_PI/period);
               workSsmCoeffs[instance][_c2]     = b1;
               workSsmCoeffs[instance][_c3]     = -a1*a1;
               workSsmCoeffs[instance][_c1]     = 1.0 - workSsmCoeffs[instance][_c2] - workSsmCoeffs[instance][_c3];
               workSsmCoeffs[instance][_period] = period;
         }
         int _indO = (i-2)%_ssmRingSize;
            workSsm[_indC][_inst+_price] = price;
            workSsm[_indC][_inst+_ssm]   = workSsmCoeffs[instance][_c1]*(price+workSsm[_indP][_inst+_price])/2.0 + 
                                           workSsmCoeffs[instance][_c2]*       workSsm[_indP][_inst+_ssm]                                + 
                                           workSsmCoeffs[instance][_c3]*       workSsm[_indO][_inst+_ssm];
      }                                      
      else for(int k=0; k<_ssmInstancesSize; k++) workSsm[_indC][_inst+k] = (i>0) ? workSsm[_indP][_inst+k] : price;
   return(workSsm[_indC][_inst+_ssm]);
   
   //
   //---
   //
   
   #undef _period
   #undef _c1
   #undef _c2
   #undef _c3
   #undef _ssm
   #undef _price
}
//+------------------------------------------------------------------+
