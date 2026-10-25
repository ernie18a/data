//+------------------------------------------------------------------+
//|                                                          Arc.mq5 |
//|                                                    Semko Nikolai |
//|                         https://www.mql5.com/ru/users/nikolay7ko |
//+------------------------------------------------------------------+

#property copyright "Semko Nikolai"
#property version   "1.02"

#include <Canvas\Canvas.mqh>
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot ArcUp
#property indicator_label1  "ArcUp"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumOrchid
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot ArcDown
#property indicator_label2  "ArcDown"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- indicator buffers
struct Polynom3
  {
   double            A;
   double            B;
   double            C;
   double            D;
   double            Y[4];
   int               Bar[4];
   datetime          Time[4];
  };
double         ArcUpBuffer[];
double         ArcDownBuffer[];
Polynom3 P1,P2;

CCanvas        C;
int            click=0;
int Width;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int ButW=60;
int ButR=20;
int Shift=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArraySetAsSeries(ArcUpBuffer,true);
   ArraySetAsSeries(ArcDownBuffer,true);
   SetIndexBuffer(0,ArcUpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ArcDownBuffer,INDICATOR_DATA);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   ArrayInitialize(ArcUpBuffer,EMPTY_VALUE);
   ArrayInitialize(ArcDownBuffer,EMPTY_VALUE);
   ChartSetInteger(0,CHART_BRING_TO_TOP,false);
   Shift=int(ChartGetInteger(0,CHART_WIDTH_IN_BARS)-ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR)-2);
   if(Shift<0) Shift=0;
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   Width=(ushort)ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS);
   if(!C.CreateBitmapLabel("ArcButton",Width-ButW-10,10,ButW,ButW,COLOR_FORMAT_ARGB_NORMALIZE))
     { Print("Error creating canvas: ",GetLastError()); return(-1); }
   DrawButton(C,ButW,ButR,clrViolet,80);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ArrayInitialize(ArcUpBuffer,EMPTY_VALUE);
   ArrayInitialize(ArcDownBuffer,EMPTY_VALUE);
   C.Destroy();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   if(prev_calculated<rates_total)
     {
      if(prev_calculated<=0)
         if(click==0)
           {
            ArrayInitialize(ArcUpBuffer,EMPTY_VALUE);
            ArrayInitialize(ArcDownBuffer,EMPTY_VALUE);
            return(rates_total);
           }
      else
        {
         for(int i=0;i<click;i++)
           {
            P1.Bar[i]=iBarShift(NULL,0,P1.Time[i])+Shift;
            P2.Bar[i]=iBarShift(NULL,0,P2.Time[i])+Shift;
           }
         if(ABC(P1)) DrawPolynom3(P1,ArcUpBuffer);
         if(ABC(P2)) DrawPolynom3(P2,ArcDownBuffer);
         return(rates_total);
        }
      int d=rates_total-prev_calculated;
      for(int i=0; i<3;i++) {P1.Bar[i]+=d; P2.Bar[i]+=d;}
      for(int i=(d-1); i>=0;i--)
        {
         P1.D-=2*P1.C;
         ArcUpBuffer[i]=ArcUpBuffer[i+1]-P1.D;
         P2.D-=2*P2.C;
         ArcDownBuffer[i]=ArcDownBuffer[i+1]-P2.D;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   static datetime t;
   static double y=0;
   static int bar=0;
   static int window=0;
   static bool editUp=false;
   static bool editDown=false;
   static uchar editN=0;
   static bool In=false;
   static int rad=ButR;
   static bool ChartChange=false;
   int i;
   if(id==CHARTEVENT_CHART_CHANGE) ChartChange=true;
   if(click==0 && ChartChange)
     {
      Shift=int(ChartGetInteger(0,CHART_WIDTH_IN_BARS)-ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR)-2);
      if(Shift<0) Shift=0;
      PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
      PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
      ChartChange=false;
     }
   if(id==CHARTEVENT_CLICK)
     {
      if(In)
        {
         click=0;
         ArrayInitialize(ArcUpBuffer,EMPTY_VALUE);
         ArrayInitialize(ArcDownBuffer,EMPTY_VALUE);
        }
      else
        {
         if(click==4)
           {
            if(editUp)
              {
               editUp=false;
               PlotIndexSetInteger(0,PLOT_LINE_STYLE,STYLE_SOLID);
               PlotIndexSetInteger(0,PLOT_LINE_WIDTH,3);
               ChartRedraw();
              }
            else if(editDown)
              {
               editDown=false;
               PlotIndexSetInteger(1,PLOT_LINE_STYLE,STYLE_SOLID);
               PlotIndexSetInteger(1,PLOT_LINE_WIDTH,3);
               ChartRedraw();
              }
            else
              {
               ChartXYToTimePrice(ChartID(),(int)lparam,(int)dparam,window,t,y);
               if(t!=0) bar=iBarShift(NULL,0,t);
               double y_pix=5*(ChartGetDouble(ChartID(),CHART_PRICE_MAX)-ChartGetDouble(ChartID(),CHART_PRICE_MIN))/ChartGetInteger(ChartID(),CHART_HEIGHT_IN_PIXELS);
               if(fabs(y-ArcUpBuffer[bar+Shift])<y_pix)
                 {
                  editUp=true;
                  PlotIndexSetInteger(0,PLOT_LINE_STYLE,STYLE_DOT);
                  PlotIndexSetInteger(0,PLOT_LINE_WIDTH,1);
                  ChartRedraw();
                  if(fabs(bar-P1.Bar[0]+Shift)<6) editN=0; else if((P1.Bar[2]-Shift+3)>bar) editN=2; else editN=1;
                 }
               if(fabs(y-ArcDownBuffer[bar+Shift])<y_pix)
                 {
                  editDown=true;
                  PlotIndexSetInteger(1,PLOT_LINE_STYLE,STYLE_DOT);
                  PlotIndexSetInteger(1,PLOT_LINE_WIDTH,1);
                  ChartRedraw();
                  if(fabs(bar-P2.Bar[0]+Shift)<6) editN=0; else if((P2.Bar[2]-Shift+3)>bar) editN=2; else editN=1;
                 }
              }
           }
         if(click<4)
           {
            P1.Y[click]=y;
            P1.Bar[click]=bar+Shift;
            P1.Time[click]=t;
            if(click==3)
              {
               double h=y-ArcUpBuffer[bar+Shift];
               for(i=0; i<3; i++)
                 {
                  P2.Bar[i]=P1.Bar[i];
                  P2.Y[i]=P1.Y[i]+h;
                  P2.Time[i]=P1.Time[i];
                 }
              }
            click++;
           }

        }
     }
   if(id==CHARTEVENT_MOUSE_MOVE && lparam>=0 && dparam>=0)
     {
      if(lparam>(Width-ButW-20) && dparam<(ButW+20))
        {
         In=true;
         double dist=sqrt(pow(Width-10-ButW/2-lparam,2)+pow(10+ButW/2-dparam,2));
         if(dist<ButR*1.5)
           {
            rad=(int)(ButR+0.5*ButR*(1-dist/(ButR*1.5)));
            uchar tr=(uchar)(80+(255-50)*(1-dist/(ButR*1.5)));
            if(tr<80) tr=255;
            DrawButton(C,ButW,rad,clrViolet,tr);
           }
        }
      else
        {
         In=false;
         if(rad!=ButR) { DrawButton(C,ButW,ButR,clrViolet,80); rad=ButR;}
        }
      if(click<4 || editUp || editDown)
        {

         ChartXYToTimePrice(ChartID(),(int)lparam,(int)dparam,window,t,y);
         if(t!=0) bar=iBarShift(NULL,0,t);
         if(click<3)
           {
            P1.Y[click]=y;
            P1.Bar[click]=bar+Shift;
            P1.Time[click]=t;
           }
         if(click==1 && P1.Bar[1]<P1.Bar[0])
           {
            if(P1.Bar[1]>P1.Bar[0]) { P1.Bar[2]=P1.Bar[1]; P1.Bar[1]=P1.Bar[0]; P1.Bar[0]=P1.Bar[2];P1.Y[2]=P1.Y[1]; P1.Y[1]=P1.Y[0]; P1.Y[0]=P1.Y[2];}
            P1.D=0;
            if(P1.Bar[0]!=P1.Bar[1]) P1.D=(P1.Y[0]-P1.Y[1])/(P1.Bar[0]-P1.Bar[1]);
            ArrayInitialize(ArcUpBuffer,EMPTY_VALUE);
            ArcUpBuffer[P1.Bar[1]]=P1.Y[1];
            if(P1.Bar[0]>P1.Bar[1]) for(i=P1.Bar[1]+1; i<=P1.Bar[0]; i++) ArcUpBuffer[i]=ArcUpBuffer[i-1]+P1.D;
            ChartRedraw();
           }
         if((click==2 && P1.Bar[2]<P1.Bar[1]) || editUp)
           {
            if(editUp) {P1.Bar[editN]=bar+Shift; P1.Y[editN]=y; P1.Time[editN]=t;}
            if(ABC(P1)) DrawPolynom3(P1,ArcUpBuffer);
            ChartRedraw();
            P1.D=P1.B+P1.C;
            if(!editUp) {P2.A=P1.A; P2.B=P1.B; P2.C=P1.C;}
           }
         if(editDown)
           {
            P2.Bar[editN]=bar+Shift; P2.Y[editN]=y; P2.Time[editN]=t;
            if(ABC(P2)) DrawPolynom3(P2,ArcDownBuffer);
            ChartRedraw();
            P2.D=P2.B+P2.C;
           }

         if(click==3)
           {
            ArrayInitialize(ArcDownBuffer,EMPTY_VALUE);
            P2.A=P1.A-ArcUpBuffer[bar+Shift]+y;
            ArcDownBuffer[0]=P2.A;
            P2.D=P2.B+P2.C;
            for(i=1; i<=P1.Bar[0]; i++)
              {
               ArcDownBuffer[i]=ArcDownBuffer[i-1]+P2.D;
               P2.D+=2*P2.C;
              }
            ChartRedraw();
            P2.D=P2.B+P2.C;
           }
        }
     }
  }
//+------------------------------------------------------------------+

void DrawButton(CCanvas &Button,int X,int R,ulong clr,uchar alfa)
  {
   ulong col=ColorToARGB((color)clr,alfa);
   Button.Erase(0);
   Button.FillCircle(X/2,X/2,R,(color)col);
   int k1=(int)round((double)R/1.5);
   int k2=(int)round((double)R/5);
   int k3=(int)round((double)R/3);
   Button.Arc(X/2,X/2,k1-1,k1-1,M_PI/2,0,ColorToARGB(clrDarkCyan,220));
   Button.FillTriangle(X/2+k1,X/2-k3,X/2+k1-k2,X/2,X/2+k1+k2,X/2,ColorToARGB(clrDarkCyan,220));
   Button.Update();
  }
//+------------------------------------------------------------------+

bool ABC(Polynom3 &p)
  {
   double zn=(p.Bar[2]*p.Bar[2]-p.Bar[1]*p.Bar[1])*(p.Bar[0]-p.Bar[2])-(p.Bar[2]*p.Bar[2]-p.Bar[0]*p.Bar[0])*(p.Bar[1]-p.Bar[2]);
   if(zn!=0)
     {
      p.C=((p.Y[0]-p.Y[2])*(p.Bar[1]-p.Bar[2])-(p.Y[1]-p.Y[2])*(p.Bar[0]-p.Bar[2]))/zn;
      p.B=(p.Y[1]-p.Y[2]+p.C*(p.Bar[2]*p.Bar[2]-p.Bar[1]*p.Bar[1]))/(p.Bar[1]-p.Bar[2]);
      p.A=p.Y[2]-p.B*p.Bar[2]-p.C*p.Bar[2]*p.Bar[2];
      return (true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
void DrawPolynom3(Polynom3 &p,double &buff[])
  {
   int size=MathMin(ArraySize(buff),p.Bar[0]+1);
   ArrayInitialize(buff,EMPTY_VALUE);
   buff[0]=p.A;
   p.D=p.B+p.C;
   for(int i=1; i<=p.Bar[0]; i++)
     {
      buff[i]=buff[i-1]+p.D;
      p.D+=2*p.C;
     }
  }
//+------------------------------------------------------------------+
