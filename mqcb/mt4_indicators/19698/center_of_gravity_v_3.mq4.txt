//+------------------------------------------------------------------+
//|                                         Center of Gravity v 3.mq4|
//| Original Code from NG3110@latchess.com                           |                                    
//| Linuxser 2007 for TSD    http://www.forex-tsd.com/               |
//| Brooky-Indicators.com mod 2011                                   |
//| www.mql5.com/en/users/stiopa  mod 2018                           |
//+------------------------------------------------------------------+
#property  copyright "ANG3110@latchess.com"
#property strict
//---------ang_PR (Din)--------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 RoyalBlue
#property indicator_color2 Red
#property indicator_color3 LimeGreen
#property indicator_color4 Red
#property indicator_color5 LimeGreen
#property indicator_color6 Silver
#property indicator_color7 Silver
#property indicator_style1 2
#property indicator_style2 0
#property indicator_style3 0
#property indicator_style4 0
#property indicator_style5 0
#property indicator_style6 0
#property indicator_style7 0
#property indicator_style8 0
//Enumeration of named constants 

enum ENUM_SR
  {
   sr1=1,//S/R
   sr2=2,//Channel 
   sr3=3//Arcs 
  };
//------Input Parameters---------------------------------                                                 

extern string OrigCode = "NG3110 AT latchess.com";
extern string Mod1Code = "Linuxser AT www.forex-tsd.com";
extern string Mod2Code = "Brooky AT Brooky-Indicators.com";
extern string Mod3Code = "www.mql5.com/en/users/stiopa";
extern bool See_Prices=true;//See Prices
extern int bars_back=100;//Bars Back
input ENUM_SR m=3;//Method
extern int i=0;//Beginning
extern double kstd=0.1;//Multiplier 
extern int sName=1102;//Name
//------------------------------------------------------------------
string stRing="pr"+(string)sName;
string pips_Global="pips_Global"+Symbol();
double fx[],sqh[],sql[],stdh[],stdl[],stdh2[],stdl2[];
double ai[10,10],b[10],x[10],sx[20];
double sum,qq,mm,tt,sq,std;
int    ip,p,n,f,n_global=0,pips_global=0;
int    ii,jj,kk,ll,nn;
bool   ready_flag=false;
//+------------------------------------------------------------------+
//| Prepare object on chart                                          |
//+------------------------------------------------------------------+
void Prepare_Object()
  {
   if(ready_flag==true)return;
   p=bars_back;
   nn=m;
   Arrow(stRing,Time[p],fx[p],159,Red,2,DoubleToStr(p,0));
   ready_flag=true;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(ObjectFind(stRing)==0)
      bars_back=iBarShift(Symbol(),0,(datetime)ObjectGet(stRing,OBJPROP_TIME1));
   EventSetMillisecondTimer(100);
   IndicatorShortName("Center of Gravity");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,fx);
   SetIndexBuffer(1,sqh);
   SetIndexBuffer(2,sql);
   SetIndexBuffer(3,stdh);
   SetIndexBuffer(4,stdl);
   SetIndexBuffer(5,stdh2);
   SetIndexBuffer(6,stdl2);
//---
   return(INIT_SUCCEEDED);
  }
//+---------------------------------------------------------------------------------------------------------------+
//|The Deinit event is generated for Expert Advisors and indicators in the following cases:                       |
//|- before reinitialization due to the change of a symbol or chart period, to which the mql4 program is attached;|
//|- before reinitialization due to the change of input parameters;                                               |
//|- before unloading the mql4 program.                                                                           |
//+---------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(reason==1 || reason==5)
     {
      ObjectDelete(stRing);
      GlobalVariableDel(pips_Global);
     }
   for(int y=0; y<8; y++)
     {
      ObjectDelete("price"+(string)y);
     }
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
   if(bars_back>rates_total-1)
      bars_back=rates_total-2;
   mat();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(ready_flag==false)
     {
      mat();
     }
  }
//+------------------------------------------------------------------+
//| The heart of the code                                            |
//+------------------------------------------------------------------+
void mat()
  {
   if(ready_flag==false)Prepare_Object();
   int mi;
   p=bars_back;
   sx[1]=p+1;
   SetIndexDrawBegin(0,Bars-p-1);
   SetIndexDrawBegin(1,Bars-p-1);
   SetIndexDrawBegin(2,Bars-p-1);
   SetIndexDrawBegin(3,Bars-p-1);
   SetIndexDrawBegin(4,Bars-p-1);
   SetIndexDrawBegin(5,Bars-p-1);
   SetIndexDrawBegin(6,Bars-p-1);
//-sx----------------------------

   for(mi=1;mi<=nn*2-2;mi++)
     {
      sum=0;
      for(n=i;n<=i+p;n++)
        {
         sum+=MathPow(n,mi);
        }
      sx[mi+1]=sum;
     }
//-syx---------------------------

   for(mi=1;mi<=nn;mi++)
     {
      sum=0.00000;
      for(n=i;n<=i+p;n++)
        {
         if(mi==1)
            sum+=Close[n];
         else
            sum+=Close[n]*MathPow(n,mi-1);
        }
      b[mi]=sum;
     }
//-Matrix-------------------------

   for(jj=1;jj<=nn;jj++)
     {
      for(ii=1;ii<=nn;ii++)
        {
         kk=ii+jj-1;
         ai[ii,jj]=sx[kk];
        }
     }
//-Gauss-------------------------

   for(kk=1;kk<=nn-1;kk++)
     {
      ll=0;mm=0;
      for(ii=kk;ii<=nn;ii++)
        {
         if(MathAbs(ai[ii,kk])>mm)
           {
            mm=MathAbs(ai[ii,kk]);
            ll=ii;
           }
        }
      if(ll!=0)
      if(ll!=kk)
        {
         for(jj=1;jj<=nn;jj++)
           {
            tt=ai[kk,jj];
            ai[kk,jj]=ai[ll,jj];
            ai[ll,jj]=tt;
           }
         tt=b[kk];b[kk]=b[ll];b[ll]=tt;
        }
      for(ii=kk+1;ii<=nn;ii++)
        {
         qq=ai[ii,kk]/ai[kk,kk];
         for(jj=1; jj<=nn; jj++)
           {
            if(jj==kk)
               ai[ii,jj]=0;
            else
               ai[ii,jj]=ai[ii,jj]-qq*ai[kk,jj];
           }
         b[ii]=b[ii]-qq*b[kk];
        }
     }
   x[nn]=b[nn]/ai[nn,nn];
   for(ii=nn-1;ii>=1;ii--)
     {
      tt=0;
      for(jj=1;jj<=nn-ii;jj++)
        {
         tt=tt+ai[ii,ii+jj]*x[ii+jj];
         x[ii]=(1/ai[ii,ii])*(b[ii]-tt);
        }
     }
//-fx--------------------------

   for(n=i;n<=i+p;n++)
     {
      sum=0;
      for(kk=1;kk<=m;kk++)
        {
         sum+=x[kk+1]*MathPow(n,kk);
        }
      fx[n]=x[1]+sum;
     }
//-fx+iStdDev------------------

   double sTd[][8];
   int size=ArraySize(fx);
   ArrayResize(sTd,size);
   std=iStdDev(NULL,0,p,MODE_SMA,0,PRICE_CLOSE,i)*(kstd+(GlobalVariableGet(pips_Global)*0.01));
   for(n=i+p; n>=i; n--)
     {
      //----by price-----------------

      stdh2[n]=sTd[n,0]=fx[n]+std*5;    //Buffer(5,stdh2)/Silver
      stdh[n]=sTd[n,1]=fx[n]+std*3;     //Buffer(3,stdh)/Red
      sqh[n]=sTd[n,2]=fx[n]+std;        //Buffer(1,sqh)/Red
      sTd[n,3]=fx[n];                   //Buffer(0,fx)/Blue
      sql[n]=sTd[n,4]=fx[n]-std;        //Buffer(2,sql)/LimeGreen
      stdl[n]=sTd[n,5]=fx[n]-std*3;     //Buffer(4,stdl)/LimeGreen
      stdl2[n]=sTd[n,6]=fx[n]-std*5;    //Buffer(6,stdl2)/Silver

      if(See_Prices)
        {
         color clr[8]={Silver,Red,Red,Blue,LimeGreen,LimeGreen,Silver};
         for(int y=0; y<8; y++)
           {
            Arrow("price"+(string)y,Time[0],sTd[0,y],6,clr[y],1);
           }
        }
     }
   ObjectMove(stRing,0,Time[p],fx[p]);
  }
//+------------------------------------------------------------------+
//|OnChartEvent() is the handler of a group of ChartEvent events:    |
//|Press F1 in MetaEditor                                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_CLICK)
     {
      int window=0;
      datetime xd=0;
      double yd=0;
      ResetLastError();
      ChartXYToTimePrice(ChartID(),(int)lparam,(int)dparam,window,xd,yd);
      int bar=iBarShift(NULL,0,xd);
      if(bar==bars_back || (ScaleGet()<3 && (bar==bars_back-1 || bar==bars_back+1)))
         ObjectSet(stRing,OBJPROP_SELECTED,true);
      n_global++;
      bars_back=iBarShift(Symbol(),0,(datetime)ObjectGet(stRing,OBJPROP_TIME1));
      if(n_global>=2)
        {
         ObjectSet(stRing,OBJPROP_SELECTED,false);
         n_global=0;
         ready_flag=false;
        }
     }
   if(id==CHARTEVENT_KEYDOWN)
     {
      if(pips_global==0)
         pips_global=(int)GlobalVariableGet(pips_Global);
      if(lparam==49 || lparam==97)//key 1
        {
         pips_global++;
         ready_flag=false;
        }
      if(lparam==50 || lparam==98)//key 2
        {
         pips_global--;
         ready_flag=false;
        }
      GlobalVariableSet(pips_Global,pips_global);
     }
  }
//+------------------------------------------------------------------+
//| Arrow object                                                     |
//+------------------------------------------------------------------+
bool Arrow(const string name,datetime time,double price,const uchar code,const color colour,const int width,const string text="")
  {
   if(ObjectFind(name)!=-1) ObjectDelete(name);
   ResetLastError();
   if(!ObjectCreate(0,name,OBJ_ARROW,0,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(0,name,OBJPROP_ARROWCODE,code);
   ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,text);
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Get chart scale (from 0 to 5).                                   | 
//+------------------------------------------------------------------+ 
int ScaleGet(const long chart_ID=0)
  {
   long result=-1;
   ResetLastError();
   if(!ChartGetInteger(chart_ID,CHART_SCALE,0,result))
     {
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
   return((int)result);
  }
//+------------------------------------------------------------------+
