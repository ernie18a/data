//----------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2022"
#property link        "mladenfx@gmail.com"
//----------------------------------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "DI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_label2  "ADXm"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width2  2

//
//
//

input double inpAdxmPeriod = 14; // ADXm period
   enum enDouble
      {
         adxm_regular, // Regular ADXm
         adxm_double,  // ADXm of ADXm
      };
input enDouble inpDouble = adxm_regular; // ADXm calculating mode

//
//
//

double adxm[],adxmc[],di[];

//----------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,di   ,INDICATOR_DATA);
   SetIndexBuffer(1,adxm ,INDICATOR_DATA);
   SetIndexBuffer(2,adxmc,INDICATOR_COLOR_INDEX);
               
      //
      //
      //
      
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("ADXm experiment (%.2f,%s)",inpAdxmPeriod,StringSubstr(EnumToString(inpDouble),5)));
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//----------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------
//
//
//

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
   int limit = (prev_calculated>0) ? prev_calculated -1 : 0;
   
   //
   //
   //
   
   for (int i=limit; i<rates_total && !_StopFlag; i++)
      {
         if (inpDouble==adxm_double)
            {
               double _di;
               double _adxm    = iAdxm(close[i],high[i],low[i],inpAdxmPeriod,_di,i,rates_total,0);
                       adxm[i] = iAdxm(_adxm,_adxm,_adxm,inpAdxmPeriod,di[i],i,rates_total,1);
            }
         else adxm[i]  = iAdxm(close[i],high[i],low[i],inpAdxmPeriod,di[i],i,rates_total);
              adxmc[i] = (i>0) ? (adxm[i]>adxm[i-1]) ? 1 : (adxm[i]<adxm[i-1]) ? 2 : adxmc[i-1]: 0;
   }
   return (rates_total);
}

//----------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------
//
//
//

#define _adxmInstances 2
double iAdxm(double _close, double _high, double _low, double _period, double &_di, int i, int _bars, int instance=0)
{
   struct sDataStruct
      {
            double di;
            double adx;
            double close;
            double high;
            double low;
            double sdh;
            double sdl;
      };
   struct sWorkStruct { sDataStruct data[_adxmInstances]; };
   static sWorkStruct m_work[];
   static int         m_workSize = -1;
                  if (m_workSize<_bars) m_workSize = ArrayResize(m_work,_bars+500,2000);
                  
   //
   //
   //
   
   #define _max(_a,_b) ((_a)>(_b)?(_a):(_b))
   #define _min(_a,_b) ((_a)<(_b)?(_a):(_b))
   #define _abs(_a)    ((_a)>0.0?(_a):-(_a))
      
      //
      //
      //

         m_work[i].data[instance].close = _close;
         m_work[i].data[instance].high  = _high;
         m_work[i].data[instance].low   = _low;

            double hc = _high;
            double lc = _low;
            double cp = (i>0) ? m_work[i-1].data[instance].close : _close;
            double hp = (i>0) ? m_work[i-1].data[instance].high  : _high;
            double lp = (i>0) ? m_work[i-1].data[instance].low   : _low;
            double dh = (hc>hp) ? hc-hp : 0;
            double dl = (lp>lc) ? lp-lc : 0;

                       if (dh<dl) dh = 0; 
                  else if (dl<dh) dl = 0; 
                  else          { dh = dl = 0; } 

            double tr    = _max(hc,cp)-_min(lc,cp);
            double dhk   = (tr!=0) ? 100.0*dh/tr : 0;
            double dlk   = (tr!=0) ? 100.0*dl/tr : 0;
            double alpha = (_period>1) ? 2.0/(_period+1.0) : 1;
         
                  m_work[i].data[instance].sdh = (i>0) ? m_work[i-1].data[instance].sdh + alpha*(dhk-m_work[i-1].data[instance].sdh) : dhk;
                  m_work[i].data[instance].sdl = (i>0) ? m_work[i-1].data[instance].sdl + alpha*(dlk-m_work[i-1].data[instance].sdl) : dlk;
                  m_work[i].data[instance].di  = _di = m_work[i].data[instance].sdh - m_work[i].data[instance].sdl;

            double div  = m_work[i].data[instance].sdh + m_work[i].data[instance].sdl; div = _abs(div);
            double temp = (div!=0.0) ? 100.0*m_work[i].data[instance].di/div : 0;

          m_work[i].data[instance].adx = (i>0) ? m_work[i-1].data[instance].adx + alpha*(temp-m_work[i-1].data[instance].adx) : 0;
   return(m_work[i].data[instance].adx);

   //
   //
   //
   
   #undef _max #undef _min #undef _abs
}      
