//----------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2022"
#property link        "mladenfx@gmail.com"
//----------------------------------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_label1  "DI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_label2  "ADXm"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2
#property indicator_label3  "ADXm down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSandyBrown
#property indicator_width3  2
#property indicator_label4  "ADXm down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSandyBrown
#property indicator_width4  2
#property strict

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

double adxm[],adxmda[],adxmdb[],adxmc[],di[];

//----------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------
//
//
//

int OnInit()
{
   IndicatorBuffers(5);
      SetIndexBuffer(0,di    ,INDICATOR_DATA);
      SetIndexBuffer(1,adxm  ,INDICATOR_DATA);
      SetIndexBuffer(2,adxmda,INDICATOR_DATA);
      SetIndexBuffer(3,adxmdb,INDICATOR_DATA);
      SetIndexBuffer(4,adxmc ,INDICATOR_CALCULATIONS);
              
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
   int limit = (prev_calculated>0) ? rates_total-prev_calculated : rates_total-1;
  
   //
   //
   //
  
   if (adxmc[limit]==2) iCleanPoint(limit,rates_total,adxmda,adxmdb);
   for (int i=limit, r=rates_total-i-1; i>=0 && !_StopFlag; i--, r++)
      {
         if (inpDouble==adxm_double)
            {
               double _di;
               double _adxm    = iAdxm(close[i],high[i],low[i],inpAdxmPeriod,_di,r,rates_total,0);
                       adxm[i] = iAdxm(_adxm,_adxm,_adxm,inpAdxmPeriod,di[i],r,rates_total,1);
            }
         else adxm[i]  = iAdxm(close[i],high[i],low[i],inpAdxmPeriod,di[i],r,rates_total);
              adxmc[i] = (r>0) ? (adxm[i]>adxm[i+1]) ? 1 : (adxm[i]<adxm[i+1]) ? 2 : adxmc[i+1]: 0;
         if  (adxmc[i]==2) iPlotPoint(i,rates_total,adxmda,adxmdb,adxm); else adxmda[i] = adxmdb[i] = EMPTY_VALUE;     
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

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//

void iCleanPoint(int i, int bars,double& first[],double& second[])
{
   if (i>=bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void iPlotPoint(int i, int bars,double& first[],double& second[],double& from[])
{
   if (i>=bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}
