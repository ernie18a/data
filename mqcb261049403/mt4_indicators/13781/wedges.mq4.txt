//+------------------------------------------------------------------+
//|                                                       Wedges.mq4 |
//| Wedges v1.0                               Copyright 2015, fxborg |
//|                                   http://fxborg-labo.hateblo.jp/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, fxborg"
#property link      "http://fxborg-labo.hateblo.jp/"
#property version   "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_LINE
#property indicator_type5 DRAW_LINE
//---
#property indicator_color1 LightSeaGreen
#property indicator_color2 LightSeaGreen
#property indicator_color3 DarkGray
#property indicator_color4 DarkGray
#property indicator_color5 Gold
//---
#property indicator_label1 "Wedge"
#property indicator_label2 "Wedge"
#property indicator_label3 "Upper Line"
#property indicator_label4 "Lower Line"
#property indicator_label5 "Trend Line"
//---
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
//---
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_SOLID
//--- input parameters
input int InpCalcPeriod=100;     // Calculation period
input int InpMaxKeepPeriod=60;   // Maximum Keep period
input string _="1: line only, 2: set buffer ,3:both";
input int InpWedgeLineMode=3;   // WedgeLineMode
input double InpDeviations=1.0; // High Low Bands Deviations
input double InpLineFilter=1.2; // Line Filter Deviations 
input  double InpReversalNoiseFilter=5;  // NoiseFilter (Minimam Reversal Spread) 
//---
double RevNoiseFilter=InpReversalNoiseFilter*Point;
int    ReversalPeriod=6;
int    CalcPeriod=InpCalcPeriod*3;
//---
int min_rates_total;
//--- indicator buffers
double WedgeH_Buffer[];
double WedgeL_Buffer[];
double TopBuffer[];
double BtmBuffer[];
double HighBuffer[];
double LowBuffer[];
double TrendBuffer[];
//---- for calc 
double StdDevBuffer[];
double ScoreH_Buffer[];
double ScoreL_Buffer[];
double SlopeA_Buffer[];
double SlopeB_Buffer[];
double CalcWedgeH_Buffer[];
double CalcWedgeL_Buffer[];
//+------------------------------------------------------------------+
//|  Point Type                                                      |
//+------------------------------------------------------------------+
struct Point_Type
  {
   int               pos;
   double            point;
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=1+CalcPeriod+ReversalPeriod+1;
//--- indicator buffers mapping
   IndicatorBuffers(14);
//--- indicator buffers
   SetIndexBuffer(0,WedgeH_Buffer);
   SetIndexBuffer(1,WedgeL_Buffer);
   SetIndexBuffer(2,HighBuffer);
   SetIndexBuffer(3,LowBuffer);
   SetIndexBuffer(4,TrendBuffer);
   SetIndexBuffer(5,TopBuffer);
   SetIndexBuffer(6,BtmBuffer);
   SetIndexBuffer(7,SlopeA_Buffer);
   SetIndexBuffer(8,SlopeB_Buffer);
   SetIndexBuffer(9,StdDevBuffer);
   SetIndexBuffer(10,ScoreH_Buffer);
   SetIndexBuffer(11,ScoreL_Buffer);
   SetIndexBuffer(12,CalcWedgeH_Buffer);
   SetIndexBuffer(13,CalcWedgeL_Buffer);
//   SetIndexArrow(5,159);
//   SetIndexArrow(6,159);
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   SetIndexEmptyValue(3,0);
   SetIndexEmptyValue(4,0);
   SetIndexEmptyValue(5,0);
   SetIndexEmptyValue(6,0);
   SetIndexEmptyValue(7,EMPTY_VALUE);
   SetIndexEmptyValue(8,EMPTY_VALUE);
   SetIndexEmptyValue(9,EMPTY_VALUE);
   SetIndexEmptyValue(10,EMPTY_VALUE);
   SetIndexEmptyValue(11,EMPTY_VALUE);
   SetIndexEmptyValue(12,0);
   SetIndexEmptyValue(13,0);
//---
   SetIndexDrawBegin(0,min_rates_total);
   SetIndexDrawBegin(1,min_rates_total);
   SetIndexDrawBegin(2,min_rates_total);
   SetIndexDrawBegin(3,min_rates_total);
   SetIndexDrawBegin(4,min_rates_total);
   SetIndexDrawBegin(5,min_rates_total);
   SetIndexDrawBegin(6,min_rates_total);
//---
   string short_name="Wedges v1.0("+IntegerToString(InpCalcPeriod)+")";
   IndicatorShortName(short_name);
//---
   return(INIT_SUCCEEDED);
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
//---
   int i,j,k,first;
//--- check for bars count
   if(rates_total<=min_rates_total)
      return(0);
//--- indicator buffers
   ArraySetAsSeries(WedgeH_Buffer,false);
   ArraySetAsSeries(WedgeL_Buffer,false);
   ArraySetAsSeries(HighBuffer,false);
   ArraySetAsSeries(LowBuffer,false);
   ArraySetAsSeries(TrendBuffer,false);
//--- calc buffers
   ArraySetAsSeries(TopBuffer,false);
   ArraySetAsSeries(BtmBuffer,false);
   ArraySetAsSeries(SlopeA_Buffer,false);
   ArraySetAsSeries(SlopeB_Buffer,false);
   ArraySetAsSeries(ScoreH_Buffer,false);
   ArraySetAsSeries(ScoreL_Buffer,false);
   ArraySetAsSeries(StdDevBuffer,false);
   ArraySetAsSeries(CalcWedgeH_Buffer,false);
   ArraySetAsSeries(CalcWedgeL_Buffer,false);
//--- rate data
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(time,false);
//+----------------------------------------------------+
//|Init Buffeer                                        |
//+----------------------------------------------------+
   first=rates_total-InpCalcPeriod+2-1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   else
     {
      for(i=0; i<first; i++)
        {
         BtmBuffer[i]=0;
         TopBuffer[i]=0;
        }
     }
//+----------------------------------------------------+
//|Set Top Btm                                         |
//+----------------------------------------------------+
   for(i=first; i<rates_total-1 && !IsStopped(); i++)
     {
      //--- find top and bottom point 
      if(low[i-2]<MathMin(MathMax(low[i-5],low[i-4]),low[i-1]) && low[i-2]<=low[i-3] && low[i-2]+RevNoiseFilter<close[i-1])
         BtmBuffer[i-2]=low[i-2];
      if(high[i-2]>MathMax(MathMin(high[i-5],high[i-4]),high[i-1]) && high[i-2]>=high[i-3] && high[i-2]-RevNoiseFilter>close[i-1])
         TopBuffer[i-2]=high[i-2];
     }
//+----------------------------------------------------+
//|Init                                                |
//+----------------------------------------------------+
   first=rates_total-InpCalcPeriod+2-1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   else
     {
      for(i=0; i<first; i++)
        {
         TrendBuffer[i]=0.0;
         HighBuffer[i]=0.0;
         LowBuffer[i]=0.0;
         WedgeH_Buffer[i]=0;
         WedgeL_Buffer[i]=0;
        }
     }
//+----------------------------------------------------+
//|Main loop                                           |
//+----------------------------------------------------+
   for(i=first; i<rates_total-1 && !IsStopped(); i++)
     {
      TrendBuffer[i]=0;
      SlopeA_Buffer[i]=EMPTY_VALUE;
      SlopeB_Buffer[i]=EMPTY_VALUE;
      StdDevBuffer[i]=EMPTY_VALUE;
      //--- calc trend line
      double price[];
      ArrayResize(price,InpCalcPeriod);
      int sz=0;
      double sum=0.0;
      //---  set HLC/3 data
      for(j=InpCalcPeriod-1;j>=0;j--)
        {
         price[sz]=(high[i-j]+low[i-j]+close[i-j])/3;
         sz++;
        }
      //--- 
      double slope_price,slope_height;
      calc_regression(slope_price,slope_height,InpCalcPeriod,price);
      SlopeA_Buffer[i]=slope_price;
      SlopeB_Buffer[i]=slope_height;
      //--- draw line , calc deviation
      for(j=InpCalcPeriod-1;j>=0;j--)
        {
         TrendBuffer[i-j]=slope_price-(slope_height*j);
         sum+=MathPow(high[i-j]-TrendBuffer[i-j],2);
         sum+=MathPow(low[i-j]-TrendBuffer[i-j],2);
        }
      //--- 
      TrendBuffer[i-InpCalcPeriod]=0;
      StdDevBuffer[i]=MathSqrt(sum/InpCalcPeriod*2);
      //--- 
      bool cancel=false;
      Point_Type UpPoints[];
      Point_Type DnPoints[];
      int top_i=-1;
      int btm_i=-1;
      double new_top,new_btm,top_angle,btm_angle;
      //---
      int upcnt=0,dncnt=0;
      int maxcnt=InpCalcPeriod;
      ArrayResize(UpPoints,0,maxcnt);
      //--- set top points            
      for(j=(i-maxcnt)+1;j<i;j++)
        {
         if(TopBuffer[j]>0)
           {
            upcnt++;
            ArrayResize(UpPoints,upcnt,maxcnt);
            UpPoints[upcnt-1].point=TopBuffer[j]/_Point;
            UpPoints[upcnt-1].pos=j;
           }
        }
      ArrayResize(DnPoints,0,maxcnt);
      //--- set bottom points           
      for(j=(i-maxcnt)+1;j<i;j++)
        {
         if(BtmBuffer[j]>0)
           {
            dncnt++;
            ArrayResize(DnPoints,dncnt,maxcnt);
            DnPoints[dncnt-1].point=BtmBuffer[j]/_Point;
            DnPoints[dncnt-1].pos=j;
           }
        }
      //--- draw high low line
      for(j=InpCalcPeriod-1;j>=0;j--)
        {
         HighBuffer[i-j]=TrendBuffer[i-j]+StdDevBuffer[i]*InpDeviations;
         LowBuffer[i-j]=TrendBuffer[i-j]-StdDevBuffer[i]*InpDeviations;
        }
      HighBuffer[i-InpCalcPeriod]=0;
      LowBuffer[i-InpCalcPeriod]=0;
      //--- check atr filter
      cancel=atr_filter(14,25,50,rates_total-i);
      //---
      if(!cancel)
        {
         //--- 
         if(upcnt>0)
           {
            //--- calc wedges line (upper) 
            if(better_line(top_i,new_top,top_angle,UpPoints,SlopeA_Buffer[i],SlopeB_Buffer[i],StdDevBuffer[i],i,1))
              {
               double score;
               bool best_score=true;
               //--- check deviation filter
               if(CalcWedgeH_Buffer[i-1]!=0 && 
                  (CalcWedgeH_Buffer[i-1]<HighBuffer[i-1]) && 
                  (CalcWedgeH_Buffer[i-1]>LowBuffer[i-1]))
                 {
                  //--- check high score 
                  if(calc_score(score,UpPoints,top_i,high[top_i]/_Point,top_angle/_Point))
                    {
                     ScoreH_Buffer[i]=score;
                     for(k=1;k<InpMaxKeepPeriod;k++)
                       {
                        //--- if not best score then
                        if((ScoreH_Buffer[i-k]!=EMPTY_VALUE) && score>ScoreH_Buffer[i-k])
                          {
                           best_score=false;
                           break;
                          }
                       }
                    }
                 }
               if(best_score)
                 {
                  //--- best score then update
                  for(j=top_i;j<=i;j++) CalcWedgeH_Buffer[j]=new_top-(top_angle*(i-j));
                  CalcWedgeH_Buffer[top_i-1]=0;
                  //--- set buffer by setting
                  if(InpWedgeLineMode==2 || InpWedgeLineMode==3)
                     for(j=top_i-1;j<=i;j++) WedgeH_Buffer[j]=CalcWedgeH_Buffer[j];
                  //--- draw line by setting
                  if(InpWedgeLineMode==1 || InpWedgeLineMode==3)
                    {
                     cleaningObj("Wedge_H");
                     ObjectCreate("Wedge_H"+IntegerToString(1),OBJ_TREND,0,time[top_i],high[top_i],time[i],new_top);
                     ObjectSet("Wedge_H"+IntegerToString(1),OBJPROP_COLOR,LightSeaGreen);
                     ObjectSet("Wedge_H"+IntegerToString(1),OBJPROP_WIDTH,2);
                    }
                 }
              }
           }
         //---            
         if(dncnt>0)
           {
            //--- calc wedges line (upper) 
            if(better_line(btm_i,new_btm,btm_angle,DnPoints,SlopeA_Buffer[i],SlopeB_Buffer[i],StdDevBuffer[i],i,-1))
              {
               double score;
               bool best_score=true;
               //--- check deviation filter
               if(CalcWedgeL_Buffer[i-1]!=0 && 
                  (CalcWedgeL_Buffer[i-1]>LowBuffer[i-1]) && 
                  (CalcWedgeL_Buffer[i-1]<HighBuffer[i-1]))
                 {
                  //--- check high score 
                  if(calc_score(score,DnPoints,btm_i,low[btm_i]/_Point,btm_angle/_Point))
                    {
                     ScoreL_Buffer[i]=score;
                     for(k=1;k<InpMaxKeepPeriod;k++)
                       {
                        //--- if not best score then
                        if((ScoreL_Buffer[i-k]!=EMPTY_VALUE) && score>ScoreL_Buffer[i-k])
                          {
                           best_score=false;
                           break;
                          }
                       }
                    }
                 }
               if(best_score)
                 {
                  //--- best score then update
                  for(j=btm_i;j<=i;j++)CalcWedgeL_Buffer[j]=new_btm-(btm_angle*(i-j));
                  CalcWedgeL_Buffer[btm_i-1]=0;
                  //--- set buffer by setting
                  if(InpWedgeLineMode==2 || InpWedgeLineMode==3)
                     for(j=btm_i-1;j<=i;j++) WedgeL_Buffer[j]=CalcWedgeL_Buffer[j];
                  //--- draw line by setting
                  if(InpWedgeLineMode==1 || InpWedgeLineMode==3)
                    {
                     cleaningObj("Wedge_L");
                     ObjectCreate("Wedge_L"+IntegerToString(1),OBJ_TREND,0,time[btm_i],low[btm_i],time[i],new_btm);
                     ObjectSet("Wedge_L"+IntegerToString(1),OBJPROP_COLOR,LightSeaGreen);
                     ObjectSet("Wedge_L"+IntegerToString(1),OBJPROP_WIDTH,2);
                    }
                 }
              }
           }
        }
      //--- Keep Wedges Line  
      if(CalcWedgeH_Buffer[i-2]>0 && CalcWedgeH_Buffer[i-1]>0)
        {
         CalcWedgeH_Buffer[i]=CalcWedgeH_Buffer[i-1]+(CalcWedgeH_Buffer[i-1]-CalcWedgeH_Buffer[i-2]);
         if(InpWedgeLineMode==2 || InpWedgeLineMode==3)
            WedgeH_Buffer[i]=CalcWedgeH_Buffer[i];
        }
      //--- Keep Wedges Line  
      if(CalcWedgeL_Buffer[i-2]>0 && CalcWedgeL_Buffer[i-1]>0)
        {
         CalcWedgeL_Buffer[i]=CalcWedgeL_Buffer[i-1]+(CalcWedgeL_Buffer[i-1]-CalcWedgeL_Buffer[i-2]);
         if(InpWedgeLineMode==2 || InpWedgeLineMode==3)
            WedgeL_Buffer[i]=CalcWedgeL_Buffer[i];
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+----------------------------------------------------+
//| random func                                        |
//+----------------------------------------------------+
bool random(int x)
  {
   int ran=MathRand();
   bool res=(MathMod(ran,x)==0);
   return(res);
  }
//+----------------------------------------------------+
//| Regression                                         |
//+----------------------------------------------------+
void calc_regression(double  &a,double  &b,int span,double  &price[])
  {
//--- 
   double sumy=0.0; double sumx=0.0; double sumxy=0.0; double sumx2=0.0;
   int x;
   int cnt=0;
//--- 
   for(x=1; x<=span; x++)
     {
      //---
      if(price[x-1]==0)continue;
      sumx+=x;
      sumx2+= x*x;
      sumy += price[x-1];
      sumxy+= price[x-1]*x;
      cnt++;
     }
//---
   double c=sumx2*cnt-sumx*sumx;
   if(c==0.0)
     {
      b=0.0;
      a=sumy/cnt;
     }
   else
     {
      b=(sumxy*cnt-sumx*sumy)/c;
      a=(sumy-sumx*b)/cnt;
      a+=b*span;
     }
  }
//+----------------------------------------------------+
//| angle_line                                         |
//+----------------------------------------------------+
bool angle_line(int  &from_pos,double &a,
                double &b,
                const Point_Type  &points[],
                int test_pos,
                double test_price,
                int last_pos,
                double limit_high,double limit_low,int dir)

  {
//--- init
   int p_sz=ArraySize(points);
   if(p_sz < 5) return (false);
   int maxcnt=0;
   double angles[][2];
//--- calc angles
   int cnt=calc_angles(angles,points,p_sz,test_pos,test_price);
   if(cnt==0)return (false);
//--- sort data
   if(dir==1) ArraySort(angles,WHOLE_ARRAY,0,MODE_DESCEND);
   else ArraySort(angles);
//--- calc mean
   double sum=0.0;
   for(int j=0; j<cnt; j++)sum+=angles[j][0];
   double mean=sum/cnt;
//--- calc deviation
   sum=0.0;
   for(int j=0; j<cnt; j++)sum+=MathPow(angles[j][0]-mean,2);
   double StdDev=MathSqrt(sum/cnt)*InpLineFilter;
//--- check filter
   int idx=0;
   bool ok=false;
   for(int j=0;j<cnt;j++)
     {
      //--- 
      idx=j;
      //--- check deviation
      if((dir==1 && angles[j][0]<mean+StdDev) || (dir==-1 && angles[j][0]>mean-StdDev))
        {
         //--- check high low limit
         double chk_a=(test_price+(last_pos-test_pos)*angles[j][0])*_Point;
         if((chk_a<limit_high) && (chk_a>limit_low))
           {
            ok=true;
            break;
           }
        }
     }
   if(!ok) return (false);
//--- set result
   a=(test_price+(last_pos-test_pos)*angles[idx][0])*_Point;
   b=angles[idx][0] * _Point;
   from_pos=(int)MathMin(test_pos,angles[idx][1]);
   return(true);
//--- 
  }
//+------------------------------------------------------------------+
//| calculating the slope angle of to all vertex from starting points|
//+------------------------------------------------------------------+
int calc_angles(double  &angles[][2],const Point_Type  &points[],int p_sz,int pos,double price)
  {
   string s="";
   ArrayResize(angles,0,p_sz);
   int cnt=0;
   for(int j=0;j<p_sz;j++)
     {
      int x=points[j].pos-pos;
      if(x==0)continue;
      double y=points[j].point-price;
      cnt++;
      ArrayResize(angles,cnt,p_sz);
      angles[cnt-1][0]=y/x;
      angles[cnt-1][1]=points[j].pos;
     }
   return (cnt);
  }
//+------------------------------------------------------------------+
//| better_line                                                      |
//+------------------------------------------------------------------+
bool better_line(int  &from_pos,double &a,
                 double &b,
                 const Point_Type  &points[],
                 double slope_price,
                 double slope_height,
                 double slope_dev,
                 int last_pos,
                 int dir)

  {
//--- init 
   int p_sz=ArraySize(points);
   if(p_sz < 5) return (false);
   double distance[][2];
   ArrayResize(distance,0,p_sz);
   int cnt=0;
   int j;
//---  
   for(j=0;j<p_sz;j++)
     {
      //---  
      int x=last_pos-points[j].pos;
      if(x==0)continue;
      //---  base price
      double base_price=(slope_price -(x*slope_height))/_Point;
      //---  distance
      double dist=(points[j].point-base_price);
      //---  check distance by StdDev
      if((dist*dir)>slope_dev*0.5/_Point)
        {
         cnt++;
         ArrayResize(distance,cnt,p_sz);
         distance[cnt-1][0]= dist;
         distance[cnt-1][1]= j;
        }
     }
//---  
   if(cnt==0)return(false);
   if(dir>0)ArraySort(distance,WHOLE_ARRAY,0,MODE_DESCEND);
   else  ArraySort(distance);
//---  
   for(j=0;j<MathMin(cnt,5);j++)
     {
      //---  
      int test_pos;
      int pos=(int)distance[j][1];
      double test_a,test_b;
      double limit_high,limit_low;
      //---  
      if(dir==1)
        {
         limit_high=slope_price+slope_dev*InpDeviations;
         limit_low=slope_price-slope_dev*2;
        }
      else
        {
         limit_high=slope_price+slope_dev*2;
         limit_low=slope_price-slope_dev*InpDeviations;
        }
      //---  
      if(angle_line(test_pos,test_a,test_b,points,points[pos].pos,points[pos].point,last_pos,limit_high,limit_low,dir))
        {
         from_pos=test_pos;
         a=test_a;
         b=test_b;
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Delete all objects with given prefix                             |
//+------------------------------------------------------------------+
void cleaningObj(string Prefix)
  {
   int L = StringLen(Prefix);
   int i = 0;
   while(i<ObjectsTotal())
     {
      string ObjName=ObjectName(i);
      if(StringSubstr(ObjName,0,L)!=Prefix)
        {
         i++;
         continue;
        }
      ObjectDelete(ObjName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool calc_score(double  &score,const Point_Type  &points[],int test_pos,double test_price,double mean)
  {
   int  p_sz=ArraySize(points);
   if(p_sz < 5) return (false);
   int maxcnt=0;
   double angles[][2];
   int cnt=calc_angles(angles,points,p_sz,test_pos,test_price);
   if(cnt<4)return (false);

   double sum=0.0;
   for(int j=0; j<cnt; j++)
     {
      sum+=MathPow(angles[j][0]-mean,2);
     }
//---
   score=MathSqrt(sum/cnt);
//---
   return (true);
  }
//+------------------------------------------------------------------+
//| atr_filter                                                       |
//+------------------------------------------------------------------+
bool atr_filter(int sig,int fast,int slow,int pos)
  {
   double atr1sig=iCustom(Symbol(),PERIOD_CURRENT,"ATR_3LWMA",sig,fast,slow,0,pos+1);
   double atr1fast=iCustom(Symbol(),PERIOD_CURRENT,"ATR_3LWMA",sig,fast,slow,1,pos+1);
   double atr0sig=iCustom(Symbol(),PERIOD_CURRENT,"ATR_3LWMA",sig,fast,slow,0,pos);
   double atr0fast=iCustom(Symbol(),PERIOD_CURRENT,"ATR_3LWMA",sig,fast,slow,1,pos);
   double atr0slow=iCustom(Symbol(),PERIOD_CURRENT,"ATR_3LWMA",sig,fast,slow,2,pos);
   if(atr0slow<atr0fast && atr0fast<atr0sig && atr1fast<atr0fast)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
