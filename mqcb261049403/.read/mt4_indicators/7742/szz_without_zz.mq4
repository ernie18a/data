//+------------+-----------------------------------------------------+
//| v.05.01.08 |                                  SZZ_without_ZZ.mq4 |
//|            |              Bookkeeper, 2008, yuzefovich@gmail.com |
//+------------+-----------------------------------------------------+
// Данный индикатор предназначен только для использования в SZZReader.
// The given indicator is intended for use in SZZReader only.
//+------------+-----------------------------------------------------+
#property copyright ""
#property link      ""
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  Blue
#property indicator_color2  Blue
//----
extern datetime FirstBarTime=0; // не менять!
extern int NUnits=10; // считать количество узлов ЗигЗага
//----                                      
double NumBars[];
double UpAndDn[];
double BarToBar[];
double Snake[];
//----
bool first=true,firstAlert=true;
datetime StartTime;
//----
//---------------------------------------------------------------------
double Navel(int Shift)
  {
// Тушка свечи должна больше чем тени влиять на цену свечи (?)
   return((5*Close[Shift]+2*Open[Shift]+High[Shift]+Low[Shift])/9);
  }
//+------------------------------------------------------------------+
void deinit()
  {
   return;
  }
//---------------------------------------------------------------------
int init()
  {
   IndicatorBuffers(4);
   SetIndexBuffer(0,NumBars);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,UpAndDn);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,BarToBar);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexEmptyValue(2,0.0);
   SetIndexBuffer(3,Snake);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexEmptyValue(3,0.0);
   return(0);
  }
//---------------------------------------------------------------------
void CalcSnake(int Pos)
  {
   Snake[Pos]=(Navel(Pos+1)+Navel(Pos)*2+Navel(Pos-1))/4;
   return;
  }
//---------------------------------------------------------------------
int start()
  {
   if(FirstBarTime==0) StartTime=Time[0];
   else StartTime=FirstBarTime;
   int n=iBarShift(Symbol(),Period(),StartTime);
   Snake[n]=(Navel(n)*3+Navel(n+1)*2+Navel(n+2))/6;
   BarToBar[n]=Snake[n];
   int i=n+1;
   BarToBar[i]=0;
   CalcSnake(i);
   while(Snake[n]==Snake[i])
     { i++; CalcSnake(i); BarToBar[i]=0; }
   int nu=0;
   NumBars[nu]=1.0*n;
   if(Snake[n]>Snake[i]) UpAndDn[nu]=1.0;
   else UpAndDn[nu]=-1.0;
   int k=n;
   while(nu<NUnits+2)
     {
      if(UpAndDn[nu]>0)
        {
         while(Snake[i-1]>=Snake[i] && i<Bars-3)
           {
            i++;
            CalcSnake(i);
            BarToBar[i]=0;
           }
         if(i==Bars-3)
           {
            if(firstAlert==true)
              {
               Alert("i=Bars-3 && nu<NUnits");
               firstAlert=false;
              }
            return(0);
           }
         BarToBar[i-1]=Snake[i-1];
         if(nu==0) k++;
         else if(nu<NUnits+1)
           {
            k=iHighest(NULL,0,MODE_HIGH,i-k-1,k);
            NumBars[nu]=1.0*k;
            k++;
           }
         nu++;
         UpAndDn[nu]=-1.0;
        }
      if(UpAndDn[nu]<0)
        {
         while(Snake[i-1]<=Snake[i] && i<Bars-3)
           {
            i++;
            CalcSnake(i);
            BarToBar[i]=0;
           }
         if(i==Bars-3)
           {
            if(firstAlert==true)
              {
               Alert("i=Bars-3 && nu<NUnits");
               firstAlert=false;
              }
            return(0);
           }
         BarToBar[i-1]=Snake[i-1];
         if(nu==0) k++;
         else if(nu<NUnits+1)
           {
            k=iLowest(NULL,0,MODE_LOW,i-k-1,k);
            NumBars[nu]=1.0*k;
            k++;
           }
         nu++;
         UpAndDn[nu]=1.0;
        }
     }
   for(i=NUnits+1;i<NUnits+4;i++)
     {
      UpAndDn[i]=0;
      NumBars[i]=0;
     }
   return(0);
  }
//---------------------------------------------------------------------
