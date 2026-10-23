//------------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2022"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  1
#property indicator_plots    1
#property indicator_label1   "Elegant oscillator"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrDeepPink
#property indicator_width1   2
#property strict

//
//
//

input int                inpBandEdge         = 20;          // Band edge
input int                inpOscillatorPeriod = 50;          // Oscillator period
input ENUM_APPLIED_PRICE inpPrice            = PRICE_CLOSE; // Price

//
//
//

double val[];
struct sGlobalStruct
{
   int    bandEdge;
   int    oscillatorPeriod;
   double sc1;
   double sc2;
   double sc3;
};
sGlobalStruct global;

//------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);

      //
      //
      //
      
         global.bandEdge         = MathMax(inpBandEdge,1);
         global.oscillatorPeriod = MathMax(inpOscillatorPeriod,1);
         double a1 =        MathExp(-1.414*M_PI/(global.bandEdge));
         double b1 = 2.0*a1*MathCos( 1.414*M_PI/(global.bandEdge));
               global.sc2 = b1;
               global.sc3 = -a1*a1;
               global.sc1 = 1.0 - global.sc2 - global.sc3;
   
      //
      //
      //

   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Elegant oscillator (%i,%i)",inpBandEdge,inpOscillatorPeriod));
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
{
   int limit = (prev_calculated>0) ? rates_total-prev_calculated : rates_total-1;


   //
   //
   //

      struct sWorkStruct
            {
               double price;
               double deriv;
               double deriv2;
               double derivSum2;
               double ifish;
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<=rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      for (int i=limit, r=rates_total-i-1; i>=0 && !_StopFlag; i--, r++)
         {
            m_work[r].price  = iGetPrice(inpPrice,open[i],high[i],low[i],close[i]);
            m_work[r].deriv  = (r>1) ? m_work[r].price-m_work[r-2].price : m_work[r].price-m_work[0].price;
            m_work[r].deriv2 = m_work[r].deriv*m_work[r].deriv;
               if (r>global.oscillatorPeriod)
                     {  m_work[r].derivSum2 = m_work[r-1].derivSum2 + m_work[r].deriv2 - m_work[r-global.oscillatorPeriod].deriv2; }
               else  {  m_work[r].derivSum2 = m_work[r].deriv2; for (int k=1; k<global.oscillatorPeriod && r>=k; k++) m_work[r].derivSum2 += m_work[r-k].deriv2; }
                  
               //
               //
               //

               double _rms = MathSqrt(m_work[r].derivSum2/(double)global.oscillatorPeriod);
                  m_work[r].ifish = (_rms) ? (MathExp(2.0*(m_work[r].deriv/_rms))-1.0)/(MathExp(2.0*(m_work[r].deriv/_rms))+1.0) : 0;
               val[i] = (r>1) ? global.sc1*(m_work[r].ifish+m_work[r-1].ifish)/2.0 + global.sc2*val[i+1] + global.sc3*val[i+2] : 0;
         }

   //
   //
   //

   return(rates_total);
}

//-----------------------------------------------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------------------------------------------
//
//
//

double iGetPrice(ENUM_APPLIED_PRICE price,double open, double high, double low, double close)
{
   switch (price)
   {
      case PRICE_CLOSE:     return(close);
      case PRICE_OPEN:      return(open);
      case PRICE_HIGH:      return(high);
      case PRICE_LOW:       return(low);
      case PRICE_MEDIAN:    return((high+low)/2.0);
      case PRICE_TYPICAL:   return((high+low+close)/3.0);
      case PRICE_WEIGHTED:  return((high+low+close+close)/4.0);
   }
   return(0);
}
