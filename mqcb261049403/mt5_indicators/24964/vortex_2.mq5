//+------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Vortex"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'228,228,255',C'255,228,228'
#property indicator_label2  "Vortex +"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrCrimson
#property indicator_width2  2
#property indicator_label3  "Vortex -"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDodgerBlue,clrCrimson
#property indicator_width3  1

//
//--- input parameters
//

input int  inpPeriod=32; // Vortex period

//
//--- buffers declarations
//

double fillu[],filld[],valp[],valpc[],valm[],valmc[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
      SetIndexBuffer(0,fillu,INDICATOR_DATA);
      SetIndexBuffer(1,filld,INDICATOR_DATA);
      SetIndexBuffer(2,valp,INDICATOR_DATA);
      SetIndexBuffer(3,valpc,INDICATOR_COLOR_INDEX);
      SetIndexBuffer(4,valm,INDICATOR_DATA);
      SetIndexBuffer(5,valmc,INDICATOR_COLOR_INDEX);
         PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Vortex ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

struct sVortex
{
   double rng;
   double mp;
   double mm;
   double sumrng;
   double summp;
   double summm;
};
sVortex m_array[];

//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   static int m_arraySize = -1;
          if (m_arraySize<rates_total) 
            { m_arraySize=ArrayResize(m_array,rates_total+500); if (m_arraySize<rates_total) return(prev_calculated); }

   //
   //---
   //
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (i>0)
      {
         m_array[i].rng = (high[i]>close[i-1] ? high[i] : close[i-1])- (low[i]<close[i-1] ? low[i] : close[i-1]);
         m_array[i].mp  = (high[i]>low[i-1])  ? high[i] - low[i-1] : low[i-1]-high[i];
         m_array[i].mm  = (low[i]>high[i-1])  ? low[i] - high[i-1] : high[i-1]-low[i];
         
         //
         //
         //
         
         if (i>inpPeriod)
         {
            m_array[i].sumrng = m_array[i-1].sumrng + m_array[i].rng - m_array[i-inpPeriod].rng;
            m_array[i].summp  = m_array[i-1].summp  + m_array[i].mp  - m_array[i-inpPeriod].mp;
            m_array[i].summm  = m_array[i-1].summm  + m_array[i].mm  - m_array[i-inpPeriod].mm;
         }
         else
         {
            m_array[i].summp = 
            m_array[i].summm = 
            m_array[i].sumrng = 0;
               for (int k=0; k<inpPeriod && i>=k; k++)
               {
                  m_array[i].sumrng += m_array[i-k].rng;
                  m_array[i].summp  += m_array[i-k].mp;
                  m_array[i].summm  += m_array[i-k].mm;
               }
         }
      }
      else { m_array[i].rng = high[i]-low[i]; m_array[i].mp = m_array[i].mm = m_array[i].summp = m_array[i].summm = high[i]-low[i]; }

      //
      //---
      //
            
      if(m_array[i].sumrng!=0)
      {
         valp[i] = m_array[i].summp/m_array[i].sumrng;
         valm[i] = m_array[i].summm/m_array[i].sumrng;
      }
      else valp[i]  = valm[i] = 0;        
           valpc[i] = (valp[i]>valm[i]) ? 1 : 2;
           valmc[i] = (valp[i]>valm[i]) ? 1 : 2;
           fillu[i] = valp[i];
           filld[i] = valm[i];
     }
   return (i);
}
//------------------------------------------------------------------