//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Volume weighted awesome oscillator"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrMediumSeaGreen,clrOrange,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

input ENUM_APPLIED_VOLUME inpVolume = VOLUME_TICK; // Volume to use

//
//--- indicator buffers
//
double val[],valc[]; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   //--- indicator short name assignment
         IndicatorSetString(INDICATOR_SHORTNAME,"Volume weighted AO");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
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
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price  = (high[i]+low[i])/2.0;
      double _volume = (inpVolume==VOLUME_TICK) ? (double)tick_volume[i] : (double)volume[i] ;
      val[i]  = iVwma(_price,_volume,5,i,rates_total,0)-iVwma(_price,_volume,34,i,rates_total,1);
      valc[i] =  (i>0) ? (val[i]>0) ? (val[i]>val[i-1]) ? 0 : 1 : (val[i]<val[i-1]) ? 2 : 3 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

double iVwma(double price, double volume, int period, int i, int bars, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 2
      struct sVwmaArrayStruct
         {
            double price;
            double volume;
            double sump;
            double sumv;
         };
      static sVwmaArrayStruct m_array[][_functionInstances];
      static int m_arraySize=0;
             if (m_arraySize<bars)
             {
                 int _res = ArrayResize(m_array,bars+500);
                 if (_res<=bars) return(0);
                     m_arraySize = _res;
             }

      //
      //---
      //
      
      if (volume==0) volume=1;
      m_array[i][¤].price =volume*price;
      m_array[i][¤].volume=volume;
      if (i>period)
            {
               m_array[i][¤].sump = m_array[i-1][¤].sump+m_array[i][¤].price-m_array[i-period][¤].price;
               m_array[i][¤].sumv = m_array[i-1][¤].sumv+volume             -m_array[i-period][¤].volume;
            }              
      else  {  m_array[i][¤].sump = m_array[i][¤].price; 
               m_array[i][¤].sumv = m_array[i][¤].volume; 
                  for(int k=1; k<period && i>=k; k++) 
                  {
                     m_array[i][¤].sump += m_array[i-k][¤].price;
                     m_array[i][¤].sumv += m_array[i-k][¤].volume; 
                  }         
            }                  
      return (m_array[i][¤].sump/m_array[i][¤].sumv);

   //
   //---
   //
            
   #undef ¤ #undef _functionInstances
}
//------------------------------------------------------------------