//+------------------------------------------------------------------+
//|                                                    FastFrAMA.mqh |
//|                                  Copyright 2013, Roman Pritulyak |
//|                                                    c1664@mail.ru |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+    
//| FastFrAMA calculation class                                      | 
//+------------------------------------------------------------------+  
class CFRAMA
  {
protected:
   double            m_min_near;
   double            m_max_near;
   double            m_min_far;
   double            m_max_far;
   double            m_min_all;
   double            m_max_all;

   //Main FrAMA function
public:
   double            FRAMASeries(uint begin,uint prev_calculated,uint rates_total,int period,double price,
                                 const double &low[],const double &high[],uint bar);

   //Auxillary functions
protected:
   double            LOWEST(int StartPos,int Depth,const double &low[]);
   double            HIGHEST(int StartPos,int Depth,const double &high[]);
   double            ALFA_CALC(int &period);
  };
//+------------------------------------------------------------------+
//| FastFrAMA main calculation function                              |
//+------------------------------------------------------------------+
double CFRAMA::FRAMASeries(uint begin,uint prev_calculated,uint rates_total,int period,double price,
                           const double &low[],const double &high[],uint bar)
  {

//Declaring local variables
   static uint bar_prev=0;
   static double ALFA,frama;
   static double frama_prev=EMPTY_VALUE;

//Checking for data
   if((int)rates_total<2*period || begin>=rates_total-1)
      return(EMPTY_VALUE);
   if(bar<begin)
      return(EMPTY_VALUE);
   if((int)bar<2*period)
      return(price);

//First call processing
   if(frama_prev==EMPTY_VALUE)
     {
      m_min_near=LOWEST(bar,period,low);
      m_max_near=HIGHEST(bar,period,high);
      m_min_far=LOWEST(bar-period,period,low);
      m_max_far=HIGHEST(bar-period,period,high);
      m_min_all=MathMin(m_min_near,m_min_far);
      m_max_all=MathMax(m_max_near,m_max_far);
      frama_prev=frama=price;
      bar_prev=bar;
      return(price);
     }

//Processing new bar appearence
   if(bar_prev<bar)
     {
      if(low[bar-period]==m_min_near)
         m_min_near=LOWEST(bar,period,low);
      if(high[bar-period]==m_max_near)
         m_max_near=HIGHEST(bar,period,high);
      if(low[bar-period]<m_min_far)
         m_min_far=low[bar-period];
      else
      if(low[bar-2*period]==m_min_far)
         m_min_far=LOWEST(bar-period,period,low);
      if(high[bar-period]>m_max_far)
         m_max_far=high[bar-period];
      else
      if(high[bar-2*period]==m_max_far)
         m_max_far=HIGHEST(bar-period,period,high);
      m_min_all=MathMin(m_min_near,m_min_far);
      m_max_all=MathMax(m_max_near,m_max_far);
      ALFA=ALFA_CALC(period);
      frama_prev=frama;
      bar_prev=bar;
     }

//Main calculations
   if(low[bar]<m_min_near)
     {
      m_min_near=low[bar];
      m_min_all=MathMin(m_min_near,m_min_far);
      ALFA=ALFA_CALC(period);
     }
   if(high[bar]>m_max_near)
     {
      m_max_near=high[bar];
      m_max_all=MathMax(m_max_near,m_max_far);
      ALFA=ALFA_CALC(period);
     }
   frama=ALFA*price+(1-ALFA)*frama_prev;
   return(frama);
  }
//+------------------------------------------------------------------+
//| Function for finding the lowest low                              |
//+------------------------------------------------------------------+
double CFRAMA::LOWEST(int StartPos,int Depth,const double &low[])
  {
   double res=low[StartPos];
   for(int i=StartPos-Depth+1;i<StartPos;i++)
      if(low[i]<res)
         res=low[i];
   return(res);
  }
//+------------------------------------------------------------------+
//| Function for finding the highest high                            |
//+------------------------------------------------------------------+
double CFRAMA::HIGHEST(int StartPos,int Depth,const double &high[])
  {
   double res=high[StartPos];
   for(int i=StartPos-Depth+1;i<StartPos;i++)
      if(high[i]>res)
         res=high[i];
   return(res);
  }
//+------------------------------------------------------------------+
//| Function for finding the highest high                            |
//+------------------------------------------------------------------+
double CFRAMA::ALFA_CALC(int &period)
  {
   double N1,N2,N3,D;
   N1=(m_max_near-m_min_near)/period;
   N2=(m_max_far-m_min_far)/period;
   N3=(m_max_all-m_min_all)/(2*period);
   D=(MathLog(N1+N2)-MathLog(N3))/MathLog(2.0);
   return(MathExp(-4.6*(D-1.0)));
  }
//+------------------------------------------------------------------+
//| Function for calculating desired applied price                   |
//+------------------------------------------------------------------+
double PriceSeries
(uint applied_price,uint bar,const double &Open[],const double &Low[],const double &High[],
 const double &Close[])
  {
   switch(applied_price)
     {
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      case 10:
         if(Close[bar]>Open[bar]) return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar]) return(Low[bar]);
            else return(Close[bar]);
           }
      case 11:
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar]) return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
      case 12:
        {
         double res=High[bar]+Low[bar]+Close[bar];
         if(Close[bar]<Open[bar]) res=(res+Low[bar])/2;
         if(Close[bar]>Open[bar]) res=(res+High[bar])/2;
         if(Close[bar]==Open[bar]) res=(res+Close[bar])/2;
         return(((res-Low[bar])+(res-High[bar]))/2);
        }
      case 13: return((Close[bar]*5+Open[bar]*2+High[bar]+Low[bar])/9);
      default: return(Close[bar]);
     }
  }
//+------------------------------------------------------------------+
