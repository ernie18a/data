//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "VHF adaptive ADXm"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "DI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_label2  "ADXm"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width2  2
//
//--- input parameters
//
input int    inpAdxmPeriod = 14;   // ADXm period
input bool   inpAdaptive   = true; // VHF adaptive ADXm? 
//
//--- buffers declarations
//
double adxm[],adxmc[],di[],vhfDiff[],vhfNoise[];
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
   //--- indicator buffers mapping
      SetIndexBuffer(0,di      ,INDICATOR_CALCULATIONS);
      SetIndexBuffer(1,adxm    ,INDICATOR_DATA);
      SetIndexBuffer(2,adxmc   ,INDICATOR_COLOR_INDEX);
      SetIndexBuffer(3,vhfDiff ,INDICATOR_CALCULATIONS);
      SetIndexBuffer(4,vhfNoise,INDICATOR_CALCULATIONS);
   
   //---
      IndicatorSetString(INDICATOR_SHORTNAME,(inpAdaptive?"VHF adaptive ":" ")+"ADXm ("+(string)inpAdxmPeriod+")");
      return (INIT_SUCCEEDED);
  }
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason)
  {
  }
//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
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
   #define _abs(_a)    ((_a)>0.0?(_a):-(_a))
   #define _max(_a,_b) ((_a)>(_b)?(_a):(_b))
   #define _min(_a,_b) ((_a)<(_b)?(_a):(_b))
   
   //
   //---
   //
   
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double period = inpAdxmPeriod;
      if (inpAdaptive)
      {
            vhfDiff[i] = (i>0) ? (close[i]>close[i-1]) ? close[i]-close[i-1] : close[i-1]-close[i] : 0;
            if (i>=inpAdxmPeriod)
                    vhfNoise[i] = vhfNoise[i-1]-vhfDiff[i-inpAdxmPeriod]+vhfDiff[i];
            else  { vhfNoise[i] = 0; for(int k=0; k<inpAdxmPeriod && (i-k)>=0; k++) vhfNoise[i] += vhfDiff[i-k]; }
   
            //
            //----
            //
         
            int start = (i>=inpAdxmPeriod) ? i-inpAdxmPeriod+1 : 0;
            double HCP = close[ArrayMaximum(close,start,inpAdxmPeriod)];
            double LCP = close[ArrayMinimum(close,start,inpAdxmPeriod)];
            double vhf = (vhfNoise[i]!=0) ? (HCP-LCP)/vhfNoise[i] : 0;
               if (vhf!=0) period = inpAdxmPeriod*vhf*2.0;
      }               
      
      double _di;
         adxm[i]  = iAdxm(close[i],high[i],low[i],period,_di,i); di[i] = _di;
         adxmc[i] = (i>0) ?(adxm[i]>adxm[i-1]) ? 1 :(adxm[i]<adxm[i-1]) ? 2 : adxmc[i-1]: 0;
   }
   return (i);
  }

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
#define _adxmInstances 1
#define _adxmInstancesSize 8
#define _adxmRingSize 6
double  _adxmWork[_adxmRingSize][_adxmInstances*_adxmInstancesSize];
#define _adxmSdh   0
#define _adxmSdl   1
#define _adxmSdx   2
#define _adxmClose 3
#define _adxmHigh  4
#define _adxmLow   5
#define _adxmDi    6
#define _adxmAdx   7
//
//
//
double iAdxm(double _close, double _high, double _low, double _period, double &_di, int i, int instance=0)
{
   int _indC = (i  )%_adxmRingSize;
   int _indP = (i-1)%_adxmRingSize;
   int _inst = instance*_adxmInstancesSize;

      _adxmWork[_indC][_inst+_adxmClose]=_close;
      _adxmWork[_indC][_inst+_adxmHigh] =_high;
      _adxmWork[_indC][_inst+_adxmLow]  =_low;

      //
      //
      //

      double hc = _adxmWork[_indC][_inst+_adxmHigh];
      double lc = _adxmWork[_indC][_inst+_adxmLow ];
      double cp = (i>0) ? _adxmWork[_indP][_inst+_adxmClose] : _adxmWork[_indC][_inst+_adxmClose];
      double hp = (i>0) ? _adxmWork[_indP][_inst+_adxmHigh ] : _adxmWork[_indC][_inst+_adxmHigh ];
      double lp = (i>0) ? _adxmWork[_indP][_inst+_adxmLow  ] : _adxmWork[_indC][_inst+_adxmLow  ];
      double dh = (hc>hp) ? hc-hp : 0;
      double dl = (lp>lc) ? lp-lc : 0;

         if(dh==dl) {dh=0; dl=0;} else if(dh<dl) dh=0; else if(dl<dh) dl=0;


      double tr    = _max(hc,cp)-_min(lc,cp);
      double dhk   = (tr!=0) ? 100.0*dh/tr : 0;
      double dlk   = (tr!=0) ? 100.0*dl/tr : 0;
      double alpha = 2.0/(_period+1.0);

         _adxmWork[_indC][_inst+_adxmSdh] = (i>0) ? _adxmWork[_indP][_inst+_adxmSdh] + alpha*(dhk-_adxmWork[_indP][_inst+_adxmSdh]) : dhk;
         _adxmWork[_indC][_inst+_adxmSdl] = (i>0) ? _adxmWork[_indP][_inst+_adxmSdl] + alpha*(dlk-_adxmWork[_indP][_inst+_adxmSdl]) : dlk;
         _adxmWork[_indC][_inst+_adxmDi]  = _adxmWork[_indC][_inst+_adxmSdh] - _adxmWork[_indC][_inst+_adxmSdl];

      double div  = _adxmWork[_indC][_inst+_adxmSdh]+_adxmWork[_indC][_inst+_adxmSdl]; div = _abs(div);
      double temp = (div!=0.0) ? 100.0*_adxmWork[_indC][_inst+_adxmDi]/div : 0;

          //
          //
          //
          
          _adxmWork[_indC][_inst+_adxmAdx] = (i>0) ? _adxmWork[_indP][_inst+_adxmAdx]+alpha*(temp-_adxmWork[_indP][_inst+_adxmAdx]) : 0;
      _di=_adxmWork[_indC][_inst+_adxmDi];
   return(_adxmWork[_indC][_inst+_adxmAdx]);
   
   //
   //
   //
   
   #undef _adxmSdh
   #undef _adxmSdl
   #undef _adxmSdx
   #undef _adxmClose
   #undef _adxmHigh
   #undef _adxmLow
   #undef _adxmDi
   #undef _adxmAdx
}
//+------------------------------------------------------------------+
