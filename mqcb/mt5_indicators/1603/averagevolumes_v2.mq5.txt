//------------------------------------------------------------------------------------
//                                                               AverageVolumes_v2.mq5
//                                                       Averaged value of the volumes
//                                                         victorg, www.mql5.com, 2013
//------------------------------------------------------------------------------------
#property copyright "Copyright 2013, victorg."
#property link      "https://www.mql5.com/ru/users/victorg"
#property version   "2.00"
#property description "Averaged value of the volumes."
#property description "victorg, www.mql5.com, 2013."
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_color1  clrDarkGreen
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_color2  clrLightSeaGreen
#property indicator_minimum 0
enum vmode {Tick_Volume,Real_Volume};
input int   inpNumAver = 12;                //Number of weeks for averaging
input vmode inpVolMod  = Tick_Volume;       //Volume mode
input bool  inpMedian  = false;             //Median filtering
double VBuf[],VHBuf[],Volume[],MFilt[];
int Count[],NumAver,PSeconds,Len,Shift;
datetime OldDay;
//------------------------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------------------------
int OnInit()
  {
  string str;

  if(inpNumAver<2)NumAver=2; else NumAver=inpNumAver;
  PSeconds=PeriodSeconds(_Period);          // Number of seconds in this period
  Len=604800/PSeconds; if(Len<1)Len=1;      // Number of bars for one week
  ArrayResize(Volume,Len); ArrayResize(Count,Len);
  if(inpMedian==true)ArrayResize(MFilt,Len);
  Shift=172800/PSeconds;                    // Number of bars for two days
  SetIndexBuffer(0,VHBuf,INDICATOR_DATA);   // For histogram
  SetIndexBuffer(1,VBuf,INDICATOR_DATA);    // For line
  PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
  PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
  IndicatorSetInteger(INDICATOR_DIGITS,2);
  str="AvrVolumes ("+(string)NumAver+")";
  if(inpVolMod==Tick_Volume)str+=" TickVolume";
  else if(inpVolMod==Real_Volume)str+=" RealVolume";
  IndicatorSetString(INDICATOR_SHORTNAME,str);
  OldDay=0;
  return(0);
  }
//------------------------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------------------------
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
  int i,k,m,n,rt,sp[1],max,min;
  double a,b;
  datetime dt;
  
  if(rates_total<Len)return(0);
  rt=rates_total-1;
  dt=time[rt]/86400;                        // Number of the day
//------- stat
  if(prev_calculated<=0||dt!=OldDay)        // If first start or new day
    {
    OldDay=dt;
    m=TerminalInfoInteger(TERMINAL_MAXBARS);
    n=Len*NumAver; if(n>m)n=m;
    CopySpread(_Symbol,_Period,n-1,1,sp);   // Request to download and prepare data
    m=0; ArrayInitialize(Volume,0); ArrayInitialize(Count,0);
    for(i=rt;i>0;i--)
      {
      k=(int)(time[i]%604800)/PSeconds;
      if(inpVolMod==Tick_Volume)Volume[k]+=(double)tick_volume[i];
      else if(inpVolMod==Real_Volume)Volume[k]+=(double)volume[i];
      Count[k]++; if(Count[k]>m)m=Count[k]; if(Count[k]>NumAver)break;
      }
    for(i=0;i<Len;i++) if(Count[i]>1)Volume[i]/=Count[i];
    PlotIndexSetString(1,PLOT_LABEL,(string)(m-1)+" week average");
    if(inpMedian==true&&Len>2)              //Median filtering
      {
      if(Volume[0]<Volume[1])max=1; else max=0;
      for(i=2;i<Len;i++)
        {
        min=2*i-3-max;
        if(Volume[i]<Volume[min]){max=i-1; MFilt[max]=Volume[min];}
        else if(Volume[i]>Volume[max]){MFilt[i-1]=Volume[max]; max=i;}
        else {MFilt[i-1]=Volume[i]; max=min+1;}
        }
      k=Len-1;
      if(Volume[k]<Volume[0]){a=Volume[k]; b=Volume[0];} // For end point
      else {a=Volume[0]; b=Volume[k];}
      if(Volume[k-1]<a)MFilt[k]=a;
      else if(Volume[k-1]>b)MFilt[k]=b;
      else MFilt[k]=Volume[k-1];
      if(Volume[0]<Volume[1]){a=Volume[0]; b=Volume[1];} // For start point
      else {a=Volume[1]; b=Volume[0];}
      if(Volume[k]<a)MFilt[0]=a;
      else if(Volume[k]>b)MFilt[0]=b;
      else MFilt[0]=Volume[k];
      ArrayCopy(Volume,MFilt,0,0);          // Copy result
      }
    }
//------- draw
  if(rates_total!=prev_calculated)          // Is new bars
    {
    n=rates_total-Len; if(n<1)n=1;
    for(i=n;i<rt;i++)
      {
      k=(int)(time[i]%604800)/PSeconds;
      m=i-Shift; if(m>=0)VBuf[m]=Volume[k];
      if(inpVolMod==Tick_Volume)VHBuf[i]=(double)tick_volume[i];
      else if(inpVolMod==Tick_Volume)VHBuf[i]=(double)volume[i];
      }
    PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,n);
    PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,n-Shift);
    k=(int)(time[rt]%604800)/PSeconds;
    for(i=rt-Shift;i<rates_total;i++)
      {
      VBuf[i]=Volume[k];
      k++; if(k>=Len)k=0;
      }
    }
  if(inpVolMod==Tick_Volume)VHBuf[rt]=(double)tick_volume[rt];
  else if(inpVolMod==Tick_Volume)VHBuf[rt]=(double)volume[rt];
  return(rates_total);
  }
//------------------------------------------------------------------------------------
