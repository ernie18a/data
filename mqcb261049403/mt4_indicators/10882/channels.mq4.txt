//+------------------------------------------------------------------+
//|                                                     channels.mq4 |
//|                                                      Nikolay 7ko |
//|                          https://www.mql5.com/ru/users/nikolay7ko|
//+------------------------------------------------------------------+

#property strict

#property copyright "Nikolai Semko SemkoNV@bk.ru"
class CDebuggerFix { } ExtDebuggerFix;

#property  indicator_chart_window
#property  indicator_buffers 2

//---- indicator parameters

extern int     StartBar    =  0;         // from what point the data analysis begins, 0 - from the current one.
extern int     BarAnalys   =  400;       // the number of bars for analysis in each period up to and including daytime. Not more than 2000!
extern double  k_width     =  4;         // channel width factor
extern int     accuracy    =  50;        // accuracy of modeling 1-no accuracy, if BarAnalys-max. accuracy. The higher the accuracy, the slower the indicator
extern double  Filter      =  0.55;      // filter the depth of forming a new channel, it is advisable to use the range 0.382-0.618
extern double  MinWidth    =  0;         // the minimum average weighted channel width in points, (with smaller width channels will not be formed)
extern double  MaxWidth    =  10000;     // the maximum average weighted channel width in points, (with a wider width channels will not be formed)
extern bool    Ray         =  true;      // a sign of continuation of the channel; true - ray, false - segment
extern bool    MaxMin      =  true;      // To build a channel taking into account extreme extremes?
                                         // -true - Yes. For the construction to pass through extreme extremes, the width coefficient k_width should be large, for example 100
                                         // -false - No. In this case, the upper and lower boundary of the channel is equidistant from the central axis of the channel (the center of the "mass")
extern bool    color_fill  =  true;      // Fill channels?

//---- indicator buffers

double     Channels[1000];
double     Wid[];
double     Vertical[];

double     Width[2000];
double     WidthU[2000];
double     WidthD[2000];
double     ChannelR[2000];
double     ChannelL[2000];
double     Channel[20][9];

int preBars=0;
int p[9]={43200,10080,1440,240,60,30,15,5,1};
int FinishL;
int tick=0;
int bar=0;
int b=0;
int key=0;
double sumPlus=0;
double sumMinus=0;
double yOptR,yOptL;
int prexL=0;
int prexR=0;
double ma=0;
int  prevxR=-5;
int  prevp=0;
int prevper=-5;
double sum1=0;
double sum2=0;
double curdeltaMax=-10000;
double curdeltaMin=10000;
int Start=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
   ObjectDelete("channels_start");
   for(int i=0;i<20;i++)
     {
      ObjectDelete("LineChannel9_"+DoubleToStr(i,0));
      ObjectDelete("LineChannel9_"+DoubleToStr(i,0)+" UP");
      ObjectDelete("LineChannel9_"+DoubleToStr(i,0)+" DOWN");
      ObjectDelete("LineChannel9_"+DoubleToStr(i,0)+" TRIUP");
      ObjectDelete("LineChannel9_"+DoubleToStr(i,0)+" TRIDown");
      ObjectDelete("Vertical_9_"+DoubleToStr(i,0));
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- drawing settings
   IndicatorDigits(Digits+1);

//---- indicator buffers mapping
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,Wid);
   SetIndexBuffer(1,Vertical);
//---- indicator buffers mapping

// SetIndexBuffer(0,Canals);
//   IndicatorDigits(20);

//---- initialization done
   return(INIT_SUCCEEDED);
  }
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

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
//LoadHist();
   int i;
   if(StartBar!=0 && Start==0) Start=StartBar;

   int j=AllChannels();
   Channels[0]=j;                                       //Number of generated channels

   if(j>0)
     {
      for(i=0; i<j; i++)
        {
         Channels[7*i+1] = Channel[i][0];                //Width
         Channels[7*i+2] = Channel[i][1];                //The current i-left channel boundary
         Channels[7*i+3] = Channel[i][2];                //Channel formation period
         Channels[7*i+4] = Channel[i][3];                //yOptR
         Channels[7*i+5] = Channel[i][4];                //yOptL
         Channels[7*i+6] = Channel[i][5]/Point;          //increment in points per bar every minute or channel angle, positive-up, negative-down
         Channels[7*i+7] = Channel[i][6];                //length in current period bars
         Channels[7*i+8] = Channel[i][7];                //Width Up
         Channels[7*i+9] = Channel[i][8];                //Width Doun
        }
      BildCanals(j);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   double y;
   int j,i;
   int      window=0;
   datetime ttt;
   if(id==CHARTEVENT_KEYDOWN) key=(int)lparam;
   if(id==CHARTEVENT_MOUSE_MOVE && key==17)// pressed the CTRL key
     {
      ChartXYToTimePrice(0,(int)lparam,(int)dparam,window,ttt,y);
      if(ttt!=0) Start=iBarShift(NULL,0,ttt,false);
      j=AllChannels();
      Channels[0]=j;                                     //Number of generated channels

      if(j>0)
        {
         for(i=0; i<j; i++)
           {
            Channels[7*i+1] = Channel[i][0];                //Width
            Channels[7*i+2] = Channel[i][1];                //The current i-left channel boundary
            Channels[7*i+3] = Channel[i][2];                //Channel formation period
            Channels[7*i+4] = Channel[i][3];                //yOptR
            Channels[7*i+5] = Channel[i][4];                //yOptL
            Channels[7*i+6] = Channel[i][5]/Point;          //increment in points per bar every minute or channel angle, positive-up, negative-down
            Channels[7*i+7] = Channel[i][6];                //length in current period bars
            Channels[7*i+8] = Channel[i][7];                //Width Up
            Channels[7*i+9] = Channel[i][8];                //Width Doun
           }
         BildCanals(j);
        }
     }
  }
//+------------------------------------------------------------------+
///////////////////////////// Functions///////////////////////////////
//+------------------------------------------------------------------+

int BildCanals(int j)//Data about the channels are in the array Channel[20][7]
  {
   string name;
   datetime x1,x2;
   double y1,y2;
   int i;
   int  color_i2[40]= // 
    {
      0x339966,0xFF33CC,0x3399FF,0xFF9920,0x993333,0xFF0066,0x66CCFF,0x9933CC,0x336600,0x006699,
      0xCC0099,0x33CCCC,0x6633FF,0x00FF66,0xCC99FF,0x3333FF,0x666633,0xCC66CC,0x00CCFF,0x996666,
      0xFF6666,0x0000FF,0xCC6666,0x006600,0x660099,0x66FF66,0xFFCC00,0x6666FF,0xFFFF33,0xCC0000,
      0x33FFFF,0xCC33FF,0x33FF33,0x9999FF,0x996600,0x333399,0x99CC99,0x0066CC,0xCC9900,0x00CCCC
    };
   int color_i[40]=
    {
      0x194C33,0x7F1966,0x14C97F,0x7F4C10,0x4C1919,0x7F0033,0x33667F,0x4C1966,0x193300,0x00334C,
      0x66004C,0x196666,0x33197F,0x007F33,0x664C7F,0x19197F,0x333319,0x663366,0x00667F,0x4C3333,
      0x7F3333,0x00007F,0x663333,0x003300,0x33004C,0x337F33,0x7F6600,0x33337F,0x7F7F19,0x660000,
      0x197F7F,0x66197F,0x197F19,0x4C4C7F,0x4C3300,0x1914C9,0x466C4C,0x003366,0x664C00,0x006666
    };
   for(i=j;i<20;i++)
     {
      ObjectDelete("LineChannel9_"+DoubleToStr(i,0));
      ObjectDelete("LineChannel9_"+DoubleToStr(i,0)+" UP");
      ObjectDelete("LineChannel9_"+DoubleToStr(i,0)+" DOWN");
      ObjectDelete("Vertical_9_"+DoubleToStr(i,0));
      ObjectDelete("LineChannel9_"+DoubleToStr(i,0)+" TRIUP");
      ObjectDelete("LineChannel9_"+DoubleToStr(i,0)+" TRIDown");
      Channel[i][2]=0;
      Channel[i][1]=0;
      Channel[i][0]=0;
     }
// Comment("Number of channels = ",j);
// string comm="Number of channels = ";
// comm=comm+(string)j;
// for(i=0; i<j; i++)
//   { comm=comm+"\n"+"Channel № "+DoubleToStr((i+1),0)+" : Width - "+DoubleToStr(Channel[i][0],0)+", channel length -  "+DoubleToStr(Channel[i][6],0)+" bars for the period "+DoubleToStr(Channel[i][2],0);}
// Comment(comm);

   for(i=0; i<j; i++)
     {
      x1 = iTime(NULL,0,Start);
      y1 = Channel[i][3];
      y2 = Channel[i][4];
      if(iTime(NULL,0,(Bars-1))<=iTime(NULL,(int)Channel[i][2],(int)Channel[i][1]))
        {
         x2=iTime(NULL,(int)Channel[i][2],(int)Channel[i][1]);
        }
      else
        {
         x2=iTime(NULL,0,(Bars-1));
         if(Channel[i][6]!=0) y2=y1-((iBarShift(NULL,(int)Channel[i][2],x2,FALSE)-iBarShift(NULL,(int)Channel[i][2],x1,FALSE))/Channel[i][6])*(y1-Channel[i][4]);
        }

      name="LineChannel9_"+DoubleToStr(i,0);
      if(ObjectFind(name)==-1)
        {
         if(!ObjectCreate(name,OBJ_TREND,0,x2,y2,x1,y1)) Comment("Error 0 = ",GetLastError());
         ObjectSet(name,OBJPROP_RAY,FALSE);
         ObjectSet(name,OBJPROP_COLOR,color_i[i]);
         ObjectSet(name,OBJPROP_STYLE,STYLE_DOT);
         ObjectSet(name,OBJPROP_RAY,Ray);

         if(MaxMin==true)
            ObjectCreate(name+" UP",OBJ_TREND,0,x2,(y2+Point*Channel[i][7]),x1,(y1+Point*Channel[i][7]));
         else
            ObjectCreate(name+" UP",OBJ_TREND,0,x2,(y2+k_width*Point*Channel[i][0]),x1,(y1+k_width*Point*Channel[i][0]));
         ObjectSet(name+" UP",OBJPROP_RAY,FALSE);
         ObjectSet(name+" UP",OBJPROP_COLOR,color_i[i]);
         ObjectSet(name+" UP",OBJPROP_STYLE,STYLE_DASH);
         ObjectSet(name+" UP",OBJPROP_RAY,Ray);

         if(MaxMin==true)
            ObjectCreate(name+" DOWN",OBJ_TREND,0,x2,(y2+Point*Channel[i][8]),x1,(y1+Point*Channel[i][8]));
         else
            ObjectCreate(name+" DOWN",OBJ_TREND,0,x2,(y2-k_width*Point*Channel[i][0]),x1,(y1-k_width*Point*Channel[i][0]));
         ObjectSet(name+" DOWN",OBJPROP_RAY,FALSE);
         ObjectSet(name+" DOWN",OBJPROP_COLOR,color_i[i]);
         ObjectSet(name+" DOWN",OBJPROP_STYLE,STYLE_DASH);
         ObjectSet(name+" DOWN",OBJPROP_RAY,Ray);

         if(color_fill==true)
           {
            ObjectCreate(name+" TRIUP",OBJ_TRIANGLE,0,x2,(y2+Point*Channel[i][7]),x1,(y1+Point*Channel[i][7]),x2,(y2+Point*Channel[i][8]));
            ObjectSet(name+" TRIUP",OBJPROP_COLOR,color_i2[i]);
            ObjectCreate(name+" TRIDown",OBJ_TRIANGLE,0,x1,(y1+Point*Channel[i][7]),x1,(y1+Point*Channel[i][8]),x2,(y2+Point*Channel[i][8]));
            ObjectSet(name+" TRIDown",OBJPROP_COLOR,color_i2[i]);
           }

         if(!ObjectCreate("Vertical_9_"+DoubleToStr(i,0),OBJ_VLINE,0,x2,8)) Comment("Ошибка 0 = ",GetLastError());
         ObjectSet("Vertical_9_"+DoubleToStr(i,0),OBJPROP_COLOR,color_i[i]);
         ObjectSet("Vertical_9_"+DoubleToStr(i,0),OBJPROP_STYLE,STYLE_DOT);
        }
      else
        {
         if(!ObjectMove(name,0,x2,y2)) Comment("Ошибка 1 = ",GetLastError());
         if(!ObjectMove(name,1,x1,y1)) Comment("Ошибка 2 = ",GetLastError());

         if(MaxMin==true)
           {
            ObjectMove(name+" UP",0,x2,y2+Point*Channel[i][7]);
            ObjectMove(name+" UP",1,x1,y1+Point*Channel[i][7]);

            ObjectMove(name+" DOWN",0,x2,y2+Point*Channel[i][8]);
            ObjectMove(name+" DOWN",1,x1,y1+Point*Channel[i][8]);

            if(color_fill==true)
              {
               ObjectMove(name+" TRIUP",0,x2,(y2+Point*Channel[i][7]));
               ObjectMove(name+" TRIUP",1,x1,(y1+Point*Channel[i][7]));
               ObjectMove(name+" TRIUP",2,x2,(y2+Point*Channel[i][8]));

               ObjectMove(name+" TRIDown",0,x1,(y1+Point*Channel[i][7]));
               ObjectMove(name+" TRIDown",1,x1,(y1+Point*Channel[i][8]));
               ObjectMove(name+" TRIDown",2,x2,(y2+Point*Channel[i][8]));
              }
           }
         else
           {
            ObjectMove(name+" UP",0,x2,y2+k_width*Point*Channel[i][0]);
            ObjectMove(name+" UP",1,x1,y1+k_width*Point*Channel[i][0]);

            ObjectMove(name+" DOWN",0,x2,y2-k_width*Point*Channel[i][0]);
            ObjectMove(name+" DOWN",1,x1,y1-k_width*Point*Channel[i][0]);
           }
        }

     }
   return(0);
  }
////////////////////////////////////////////////////////
int AllChannels()
  {
   int i1=0,i2,i3,jj,sdv,err=0;
   int k=0;
   int i=0;
   int lastper;
   int St,Fin;
   datetime S,F,prevS,CurStart;
   int lastmin;
   double lmin=1000000;
   double premin=0;
   lastper=9;

   CurStart=iTime(NULL,Period(),Start);
   if(Start==0) CurStart=iTime(NULL,1,0);
   int l5=iBarShift(NULL,p[0],CurStart,FALSE)+BarAnalys;
   if(iBars(NULL,p[0])<l5) l5=iBars(NULL,p[0])-1;
   prevS=iTime(NULL,p[0],l5);
   if(prevS==0) {err=GetLastError(); Print("Error iTime ",err," ",(iBarShift(NULL,p[0],CurStart,FALSE)));}
   ArrayInitialize(Vertical,0);
   ArrayInitialize(Wid,0);

   for(jj=0;jj<lastper;jj++)
     {
      if(jj==8) // if the minute period
         S = CurStart;
      else S=iTime(NULL,p[jj+1],(iBarShift(NULL,p[jj+1],CurStart,FALSE)+BarAnalys));
      F=prevS;
      prevS=S;
      St=iBarShift(NULL,p[jj],CurStart,FALSE);
      Fin=iBarShift(NULL,p[jj],F,FALSE);

      if(St==0 && Fin==0)  return(0);
      sdv=(iBarShift(NULL,p[jj],S,FALSE))-St-7;
      if(jj!=8) {ArrWidth(St,Fin,sdv,p[jj]); }
      else  {ArrWidth(St,Fin,0,p[jj]);}
      lastmin=Fin+1;
      if(jj==0) lmin=10000000;
      if(jj==0) premin=Width[Fin-St-1];
      if(Fin>iBarShift(NULL,p[jj],S,FALSE))
         for(i=Fin-1; i>(iBarShift(NULL,p[jj],S,FALSE))-1; i--)
           {
            int hhh=iBarShift(NULL,p[jj],S,FALSE);
            if(iTime(NULL,0,Bars-1)<=iTime(NULL,p[jj],i))
              {
               i3=iBarShift(NULL,0,iTime(NULL,p[jj],i),FALSE);
               for(i2=0;i2<=p[jj]/Period();i2++)
                 {
                  if((i3-i2)>=0) Wid[i3-i2]=Width[i-St];
                  if(i!=St && Wid[i3-i2]==0)
                    {
                     printf("width for some reason is zero");
                    }
                 }
              }
            if(Width[i-St]<lmin) {lmin=Width[i-St];lastmin=i;}

            if(i>St) if(Width[i-St]<=Width[i-St-1] && Width[i-St]<=Width[i-St+1])
               if(lastmin==i)
                 {
                  if(Width[i-St]<premin*Filter && Width[i-St]>MinWidth && Width[i-St]<MaxWidth)
                    {
                     if(i1>0) for(k=0; k<i1; k++)
                       {
                        if(Width[i-St]!=0) if((Channel[k][0]/Width[i-St])<1.2 && (Channel[k][0]/Width[i-St])>0.8) i1=k;
                       }
                     if(iTime(NULL,0,Bars-1)<=iTime(NULL,p[jj],i)) Vertical[i3]=Width[i-St];
                     Channel[i1][0]= Width[i-St];                                //Width Up
                     Channel[i1][1]= i;                                          //The current i-left channel boundary
                     Channel[i1][2]= p[jj];                                      //Period
                     Channel[i1][3]= ChannelR[i-St];                             //yOptR
                     Channel[i1][4]= ChannelL[i-St];                             //yOptL
                     if((i-St)*p[jj]!=0) 
                     Channel[i1][5]=(ChannelR[i-St]-ChannelL[i-St])/((i-St)*p[jj]);  //bar increment
                     Channel[i1][6]=(i-St);                                      //length in bars
                     Channel[i1][7]= WidthU[i-St];                               //Width Up
                     Channel[i1][8]= WidthD[i-St];                               //Width Down
                     premin=Width[i-St];
                     i1++;
                    }
                 }
           }

     }
   return(i1);
  }
//////////////////////////////////////////////////////////////////////
double ArrWidth(int Start1,int Finish,int Sdvig,int per) // constructing an array of the width of the central line from Start1 to Finish
  {
   Width[0]=0;
   if(Sdvig<0) Sdvig=0;
   yOptR=iOpen(NULL,per,Start1);

   int d,i1,i;
   double dC,dR,dL;
   int p1=0;
   int lnz=Sdvig;
   for(i=(1+Sdvig); i<(Finish-Start1); i++)
     {
      if(accuracy!=0) p1=(int)MathFloor((i-1)/accuracy);
      i=i+p1;
      Width[i]=MinChannel2(Start1,i+Start1,per);
     // if(Width[i]<1) Print(per," ",Start1," ",i+Start1);

      if(MaxMin==true)
        {
         if( k_width*Width[i]<curdeltaMax/Point) WidthU[i]=(curdeltaMax/Point+k_width*Width[i])/2; else WidthU[i]=curdeltaMax/Point;
         if(-k_width*Width[i]>curdeltaMin/Point) WidthD[i]=(curdeltaMin/Point-k_width*Width[i])/2; else WidthD[i]=curdeltaMin/Point;
        }
      ChannelL[i]  = yOptL;
      ChannelR[i]  = yOptR;
      d=i-lnz;
      if(d!=0)
        {
         dC=(Width[i]-Width[lnz])/d;
         dR=(ChannelR[i]-ChannelR[lnz])/d;
         dL=(ChannelL[i]-ChannelL[lnz])/d;
        }
      else {dC=0;dR=0; dL=0;}
      if(d>1)
         for(i1=1;i1<d;i1++)
           {
            Width[lnz+i1]=Width[lnz+i1-1]+dC;
            ChannelL[lnz+i1]  = ChannelL[lnz+i1-1]+dL;
            ChannelR[lnz+i1]  = ChannelR[lnz+i1-1]+dR;
           }
      lnz=i;
     }
   return(0);
  }
///////////////////////////////////////////////////////
double MinChannel2(int xR,int xL,int per)
  {
   int n,p3,p2=xL-xR;
   double j1,j2,j3,d;

   p3=2*p2+1;
   j1 = p3 + 1;
   j2 = p3*(p3+1)/2;
   j3 = p3*(p3+1)*(2*p3+1)/6;


   if(prevxR!=xR || prevper!=per)
     {
      prevp=0;
      sum1=0;
      sum2=0;
     }

   for(n=prevp; n<=p2; n++)
     {
      sum2+=iHigh(NULL,per,n+xR)+iLow(NULL,per,n+xR);

      if(iOpen(NULL,per,n+xR)>=iClose(NULL,per,n+xR))
         sum1+=iHigh(NULL,per,n+xR)*2*n+iLow(NULL,per,n+xR)*(2*n+1);
      else
         sum1+=iLow(NULL,per,n+xR)*2*n+iHigh(NULL,per,n+xR)*(2*n+1);
     }

   prevxR=xR;
   prevp=p2+1;
   prevper=per;
   d=(j2*sum2-j1*sum1)/(j2*j2-j1*j3);
   yOptR = (sum1-j3*d)/j2;
   yOptL = d*2*p2+yOptR;

   return(SumPlus2(xL,xR,yOptR,yOptL,per)/(p2+1));
  }
///////////////////////////////////////////////////////

double SumPlus2(int xL1,int xR1,double yR1,double yL1,int per)
  {
   double curLinePrice,curdelta,curdeltaH,curdeltaL,delta=0;
   curdeltaMax=-100000;
   curdeltaMin=100000;
   int i = xR1;
   if(xL1==xR1)return(0);
   delta = (yL1-yR1)/(xL1-xR1);
   curLinePrice=yR1;
   sumPlus=0;
   while(i<=xL1)
     {
      curdelta=iOpen(NULL,per,i)-curLinePrice;
      curdeltaH = iHigh(NULL,per,i) - curLinePrice;
      curdeltaL = iLow(NULL,per,i) - curLinePrice;
      if(curdeltaMax<curdeltaH) curdeltaMax=curdeltaH;
      if(curdeltaMin>curdeltaL) curdeltaMin=curdeltaL;
      if(curdelta>0) sumPlus=sumPlus+curdelta;
      curLinePrice=curLinePrice+delta;
      i++;
     }
   return(sumPlus/Point);
  }
////////////////////////////////////////////////////////////////////////////////////
void LoadHist()
  {
   int iPeriod[9];
   iPeriod[0]=1;
   iPeriod[1]=5;
   iPeriod[2]=15;
   iPeriod[3]=30;
   iPeriod[4]=60;
   iPeriod[5]=240;
   iPeriod[6]=1440;
   iPeriod[7]=10080;
   iPeriod[8]=43200;
   for(int iii=0;iii<9;iii++)
     {
      datetime open=iTime(Symbol(),iPeriod[iii],0);
      int error=GetLastError();
      while(error==4066)
        {
         Comment("Historical data was not uploaded for ",iPeriod[iii]," period, you need to reboot the indicator or go to another timeframe");
         Sleep(10000);
         open = iTime(Symbol(), iPeriod[iii], 0);
         error=GetLastError();
        }
     }
  }
//+------------------------------------------------------------------+
