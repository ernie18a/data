//+------------------------------------------------------------------+
//|                                                      iCanvas.mqh |
//|                                    Copyright 2018, Nikolai Semko |
//|                         https://www.mql5.com/ru/users/nikolay7ko |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Nikolai Semko"
#property link      "https://www.mql5.com/ru/users/nikolay7ko"
#property link      "SemkoNV@bk.ru"  
#property version   "1.35"
#ifndef  _Comment
#define _Comment Canvas.Comm
#define _X Canvas.X
#define _Y Canvas.Y
#define _TimePos Canvas.TimePos
#define _Bar Canvas.Bar
#define _Price Canvas.Price
#define _CommXY(x,y,str) Canvas.TextPosition(x,y);\
Canvas.Comm(str);
#define _Font Canvas.CurentFont
#define _PixelSet Canvas.PixelSet
#define _MouseX W.MouseX
#define _MouseY W.MouseY
#define _MouseBar W.MouseBar
#define _Width W.Width
#define _Height W.Height
#define _Left_bar W.Left_bar
#define _Right_bar W.Right_bar
#define _BarsInWind W.BarsInWind

#define protected public
#include <Canvas\Canvas.mqh>
#undef protected

int Ceil (double x) { return (x-(int)x>0)?(int)x+1:(int)x; }
int Round(double x) { return (x>0)?(int)(x+0.5):(int)(x-0.5);}
int Floor(double x) { return (x>0)?(int)x:((int)x-x>0)?(int)x-1:(int)x; }
union argb {uint clr; uchar c[4];};

enum mouse_status {
NO_PRESSED,
LEFT_BUTTON_PRESSED,
RIGHT_BUTTON_PRESSED,
LEFT_AND_RIGHT_BUTTONS_PRESSED,
KEY_PRESSED
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Window
  {
   long              ChartId;     // current window identifier
   uint              Color;       // window background color
   int               Width;       // window width
   int               Height;      // window height
   int               height[];    // sub_windows height
   int               Left_bar;    // number of the leftmost bar in the window
   double            Right_bar;   // number of the rightmost bar in the window
   double            Total_bars;  // the maximum number of bars in the window
   int               BarsInWind;  // number of visible bars in the window
   double            Y_min;       // The minimum value of the price in the window
   double            Y_max;       // The maximum value of the price in the window
   double            dy_pix;      // price change for one pixel
   int               dx_pix;      // changing the number of bars per pixel
   int               MouseX;      // coordinate X of the current position of the mouse pointer
   int               MouseY;      // coordinate Y of the current position of the mouse pointer
   double            MouseBar;    // the current bar position of the mouse pointer 
   double            MousePrice;  // the current price of the mouse pointer
   datetime          MouseTime;   // the current time of the mouse pointer
   mouse_status      MouseStatus; // 5 values: NO_PRESSED, LEFT_BUTTON_PRESSED,RIGHT_BUTTON_PRESSED, LEFT_AND_RIGHT_BUTTONS_PRESSED, KEY_PRESSED
   int               IdEvent;     // id value of the last event
   long              lparam;      // last lparam
   int               MouseSubWin; // number of the subwindow in which the mouse pointer is located
   int               WindowsTotal;// total subwindows, including the main window
   int               SubWin;      // current subwindow
   datetime          time[];      // array of opening time of all visible bars in the window
  };

Window W;
bool              OnChart=false;    // Sign of the presence in the program's body of the OnChartEvent event handler
                                    // A sign that the OnChartEvent event handler is in the body of the program
bool              OnZ=true;
int               WidOld,HeiOld[];
int               sizeArr=0;
int               StartBar=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class B17 {  public: B17() {}; ~B17() { if(CheckPointer(Canvas)!=POINTER_INVALID) delete Canvas; for(int i=0;i<ArraySize(iC);i++) if(CheckPointer(iC[i])!=POINTER_INVALID) delete iC[i]; }};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class iCanvas : public CCanvas
  {
private:
   datetime          T[1];
   double            Pr[1];
   bool              FullWinCanvW; // using full window canvas by width
   bool              FullWinCanvH; // using full window canvas by height
public:
                     iCanvas(long chart_id=0,int Xpos=0,int Ypos=0,string Name="iCanvas",int width=0,int height=0,ENUM_COLOR_FORMAT formatCF=COLOR_FORMAT_ARGB_NORMALIZE,int subwin=-1);
                    ~iCanvas() { Destroy(); ChartRedraw();};
   double            X(double bar){return((double)W.Left_bar-bar)*W.dx_pix;}; //The X coordinate by the bar number. The bar number must be of type double, otherwise, the bar will be interpreted as time.
   double            X(datetime Time)                                         //The X coordinate by the time.
     { double b=wBarShift(Time,W.time,_Period); return X(b);  };
    // { double b=iBarShift(_Symbol,_Period,Time); return X(b);  };
   double            Y(double Price) {if(W.dy_pix==0) W.dy_pix=1; return((W.Y_max-Price)/W.dy_pix); }; //The Y coordinate by the price.
   double            Price(int y)     {return (W.Y_max-y*(W.Y_max-W.Y_min)/W.Height);};       // Price by the Y coordinate
   double            Bar(double x) {return((double)W.Left_bar+1-x/(double)W.dx_pix);};   // bar number by coordinate X                                                                      
   datetime          TimePos(double x)                                                           // time by coordinate X 
     {
      double B=Bar(x);
      //T[0]=iTime(_Symbol,_Period,(int)B);
      if(B<0) T[0]=datetime(W.time[W.BarsInWind-1]-(long)B*PeriodSeconds());
      else if(B<W.Right_bar || B>W.Left_bar) T[0]=iTime(_Symbol,_Period,(int)B);
      else T[0]=W.time[W.BarsInWind-Floor(B)-1+(int)W.Right_bar];
      return T[0]+int((double)PeriodSeconds()*(1-B+(int)B));
     };
   double            Close(int x)     {CopyClose(_Symbol,_Period,int(Bar(x)),1,Pr); return Pr[0];};
   double            Open(int x)      {CopyOpen(_Symbol,_Period,int(Bar(x)),1,Pr); return Pr[0];};
   double            High(int x)      {CopyHigh(_Symbol,_Period,int(Bar(x)),1,Pr); return Pr[0];};
   double            Low(int x)       {CopyLow(_Symbol,_Period,int(Bar(x)),1,Pr); return Pr[0];};
   bool              FullWinCanvWidth()  {return FullWinCanvW;};                              // using full window canvas by width  
   bool              FullWinCanvHeight() {return FullWinCanvH;};                              // using full window canvas by height   
   void              Comm(string text) {TextOut(TextPosX,TextPosY,text,TextColor); TextPosY+=StepTextLine;}; // Print comment
   void              TextPosition(int x,int y) {TextPosX=x; TextPosY=y;};                                    // Setting the XY position for comment output in pixels
   void              CurentFont(string FontName="Courier New",int size=18,int LineStep=20,color clr=clrDarkOrchid,double transp=1.0);  // Set font options for comment. LineStep - step between lines. transp - transparency from 0 to 1                                                                                                                                        
   void              TextPosition(double x,double y) // Setting the XY position for outputting comments as a percentage of the width and height of the window
     {
      if(x>100) x=100; else if(x<0) x=0; TextPosX=Round(x*W.Width/100);
      if(y>100) y=100; else if(y<0) y=0; TextPosY=Round(y*W.Height/100);
     };
   void              LineD(double x1,double y1,double x2,double y2,const uint clr);
   void              SetBack(const bool bck) {ObjectSetInteger(m_chart_id,m_objname,OBJPROP_BACK,bck);} // Set canvas behind the chart or in front of the chart
   bool              MoveCanvas(const int x,const int y);
   int               TextPosX;      // Position X for comment text
   int               TextPosY;      // Position Y for comment text
   int               StepTextLine;  // line spacing for comment
   uint              TextColor;     // Font color for comment
   ENUM_PROGRAM_TYPE ProgType;
   int               SubWin;
   long              Handle;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
iCanvas::iCanvas(long chart_id=0,int Xpos=0,int Ypos=0,string Name="iCanvas",int width=0,int height=0,ENUM_COLOR_FORMAT formatCF=COLOR_FORMAT_ARGB_NORMALIZE,int subwin=-1)
  {
   ResetLastError();
   ProgType=(ENUM_PROGRAM_TYPE)MQLInfoInteger(MQL_PROGRAM_TYPE);
   if(chart_id==0) chart_id=ChartID();
   int size_iC=ArraySize(iC);
   if(size_iC>0) if(CheckPointer(iC[size_iC-1])==POINTER_INVALID) {ArrayResize(iC,size_iC-1); size_iC--;}
   W.WindowsTotal=(int)ChartGetInteger(W.ChartId,CHART_WINDOWS_TOTAL);
   if(subwin<0) { if(ProgType==PROGRAM_INDICATOR) SubWin=ChartWindowFind(); else SubWin=0;}
   else if(subwin<W.WindowsTotal) SubWin=subwin; else SubWin=0;
   if(CheckPointer(Canvas)==POINTER_INVALID)
     {
      W.ChartId=chart_id;
      ChartSetInteger(W.ChartId,CHART_EVENT_MOUSE_MOVE,true);
      GetWindowProperties(W);
      W.SubWin=SubWin;
      W.MouseX=W.Width/2;  W.MouseY=W.Height/2; W.MouseBar=Bar(W.MouseX); W.MousePrice=Close(W.MouseX);
      WidOld=W.Width; HeiOld[SubWin]=W.height[SubWin];
      W.MouseSubWin=XYToTimePrice(W.MouseX,W.MouseY,W.MouseTime,W.MousePrice);
     }

   if(width==0) {width=W.Width;   FullWinCanvW=true; Xpos=0;} else FullWinCanvW=false;
   if(height==0){height=W.height[SubWin]; FullWinCanvH=true; Ypos=0;} else FullWinCanvH=false;
   Name+=IntegerToString(rand())+IntegerToString(rand());
   Handle=ChartGetInteger(chart_id,CHART_WINDOW_HANDLE,SubWin);
   if(!CreateBitmapLabel(chart_id,SubWin,Name,Xpos,Ypos,width,height,formatCF))
      Print("Error creating canvas: ",GetLastError());
   else { ArrayResize(iC,size_iC+1); iC[size_iC]=GetPointer(this); }

   ChartSetInteger(m_chart_id,CHART_FOREGROUND,SubWin,false);        // 
   ObjectSetInteger(m_chart_id,m_objname,OBJPROP_BACK,false);

// ChartSetInteger(W.ChartId,CHART_CROSSHAIR_TOOL,false);  // turn off the crosshair
   TextPosX=20;
   TextPosY=100;
   StepTextLine=22;
   TextColor=clrDarkOrchid;
   CurentFont();
   Erase(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void    iCanvas::CurentFont(string FontName="Courier New",int size=18,int LineStep=20,color clr=clrDarkOrchid,double transp=1.0)
  {
   FontSet(FontName,size);
   if(transp>1) transp=1.0;
   if(transp<0) transp=0;
   StepTextLine=LineStep;
   TextColor=ColorToARGB(clr,uchar(255*transp+0.5));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void iCanvas::LineD(double x1,double y1,double x2,double y2,const uint clr)
  {
   if(fabs(x2-x1)<1.1 && fabs(y2-y1)<1.1) { PixelSet(Round(x2),Round(y2),clr); return;}
   if(x1!=x1 || x2!=x2 || y1!=y1 || y2!=y2) return;
   if(Round(x1)==Round(x2)) {LineVertical(Round(x1),Round(y1),Round(y2),clr); return; }
   if(Round(y1)==Round(y2)) {LineHorizontal(Round(x1),Round(x2),Round(y1),clr); return; }
   if(x1>x2) {double temp=x1; x1=x2; x2=temp; temp=y1; y1=y2; y2=temp; }
   if(x1>=m_width || x2<0 || (y1>=m_height && y2>=m_height) || (y1<0 && y2<0)) return;
   double dx=(x2-x1)/(y2-y1);
   double dy=(y2-y1)/(x2-x1);
   if(x1<0) { y1=y1-dy*x1; x1=0;}
   if(x2>=m_width-0.5) { y2=y2-dy*(x2-m_width+1); x2=m_width-1;}
   if(y2>y1)
     {
      if(y1<0) { x1=x1-dx*y1; y1=0;}
      if(y2>=m_height-0.5) { x2=x2-dx*(y2-m_height+1); y2=m_height-1;}
     }
   else
     {
      if(y2<0) { x2=x2-dx*y2; y2=0;}
      if(y1>=m_height-0.5) { x1=x1-dx*(y1-m_height+1); y1=m_height-1;}
     }
   if(fabs(dx)>=1) for(double x=x1,y=y1; x<=x2; x++,y+=dy) PixelSet(Round(x),Round(y),clr);
   else if(y2>y1)  for(double y=y1,x=x1; y<=y2; y++,x+=dx) PixelSet(Round(x),Round(y),clr);
   else            for(double y=y2,x=x2; y<=y1; y++,x+=dx) PixelSet(Round(x),Round(y),clr);
  }
  
bool iCanvas::MoveCanvas(const int x,const int y)
{
 if(ObjectSetInteger(m_chart_id,m_objname,OBJPROP_XDISTANCE,x) && ObjectSetInteger(m_chart_id,m_objname,OBJPROP_YDISTANCE,y))  return(true);
 else return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int XYToTimePrice(int x,int y,datetime &Time,double &Price,int id=0) // returns the number of the subwindow in which X, Y (cursor) is located, if -1 is outside the window
  {
   static int Hei[10];
   static double y_min[10];
   static double y_max[10];
   static bool ChartChange=true;
   static bool nofirst=false;
   static int Cur_wind=-1;
   if(sizeArr>W.BarsInWind || sizeArr<1) return Cur_wind;
   if(!nofirst) {ChartChange=true; nofirst=true;}
   if(id==CHARTEVENT_CHART_CHANGE) {ChartChange=true; return(Cur_wind);}
   if(ChartChange) // if there was a chat change after the last calculation
     {
      if(W.WindowsTotal>10) {Print("Too many subwindows"); return(-1);}
      Hei[0]=W.height[0];
      for(int i=1;i<W.WindowsTotal;i++) Hei[i]=W.height[i]+Hei[i-1]+2;
      y_min[0]=W.Y_min;  y_max[0]=W.Y_max;
      if(W.WindowsTotal>0) for(int i=1;i<W.WindowsTotal;i++)
        {
         y_min[i]=(i==W.SubWin)?W.Y_min:ChartGetDouble(W.ChartId,CHART_PRICE_MIN, i);                         // Max. price on the screen
         y_max[i]=(i==W.SubWin)?W.Y_max:ChartGetDouble(W.ChartId,CHART_PRICE_MAX, i);                         // Min. price on the screen
        }
     }
   if(x>(W.Width+1) || x<0 || y<0 || y>=(Hei[W.WindowsTotal-1]+1)) return(-1);  // exit if the point (x, y) outside the screen
   Cur_wind=-1;
   if(y>=0 && y<=Hei[0]) Cur_wind=0;
   else if(W.WindowsTotal>1) for(int i=1;i<W.WindowsTotal;i++) if(y>(Hei[i-1]+1) && y<=Hei[i]) { Cur_wind=i; break; }
   if(Cur_wind>=0)
     {
      if(Cur_wind>0) y=y-Hei[Cur_wind-1]-2;
      int hh=Hei[Cur_wind];
      if(Cur_wind>0) hh-=Hei[Cur_wind-1]+2;
      if(hh!=0) Price=y_min[Cur_wind]+(hh-y)*(y_max[Cur_wind]-y_min[Cur_wind])/hh;

      double B=W.Left_bar+1-x/(double)W.dx_pix;
      datetime TT;
      if(B<0) TT=datetime(W.time[W.BarsInWind-1]-(long)B*PeriodSeconds());
      else if(B<W.Right_bar || B>W.Left_bar) TT=iTime(_Symbol,_Period,(int)B);
      else { int i=W.BarsInWind-Floor(B)-1+(int)W.Right_bar; if (i>=0 && i<ArraySize(W.time)) TT=W.time[i]; else TT=iTime(_Symbol,_Period,(int)B); } 
      Time= TT+int((double)PeriodSeconds()*(1-B+(int)B));
     }
   ChartChange=false;
   return Cur_wind;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetWindowProperties(Window &w)
  {
   static ENUM_TIMEFRAMES lastTF=0;
   static int oldLB=w.Left_bar;
   static double oldRB=w.Right_bar;
   int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);
   W.WindowsTotal=(int)ChartGetInteger(W.ChartId,CHART_WINDOWS_TOTAL);
   w.Color=(uint)ChartGetInteger(W.ChartId,CHART_COLOR_BACKGROUND);
   w.Width=(int)ChartGetInteger(W.ChartId,CHART_WIDTH_IN_PIXELS);
   w.Left_bar=(int)ChartGetInteger(W.ChartId,CHART_FIRST_VISIBLE_BAR);
   if (w.Left_bar>=max_bars) w.Left_bar=max_bars-1;
   w.Y_min=ChartGetDouble(W.ChartId,CHART_PRICE_MIN);
   w.Y_max=ChartGetDouble(W.ChartId,CHART_PRICE_MAX); if(w.Y_max==0) w.Y_max=1;
   ArrayResize(w.height,W.WindowsTotal);
   ArrayResize(HeiOld,W.WindowsTotal);
   for(int i=0; i<W.WindowsTotal;i++) w.height[i]=(int)ChartGetInteger(W.ChartId,CHART_HEIGHT_IN_PIXELS,i);
   w.Height=w.height[0];
   if((w.Y_max-w.Y_min)!=0 && w.Height!=0) w.dy_pix=(w.Y_max-w.Y_min)/w.Height;
   w.dx_pix=int(1<<ChartGetInteger(W.ChartId,CHART_SCALE));// how many pixels between the bars (from 1 to 32)
   w.Total_bars=(double)w.Width/w.dx_pix;
   w.Right_bar=w.Left_bar-w.Total_bars;
   if(w.Right_bar<0) w.Right_bar=0;
   int oldBIW=w.BarsInWind;
   w.BarsInWind=w.Left_bar-(int)w.Right_bar+1;
   if(oldRB!=w.Right_bar || oldLB!=w.Left_bar || lastTF!=_Period) sizeArr=CopyTime(NULL,_Period,(int)w.Right_bar,w.BarsInWind,w.time);
   lastTF=_Period;
   oldLB=w.Left_bar;
   oldRB=w.Right_bar;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyChartEvent(long id,const long &lparam,const double &dparam,const string &sparam) {}  // Fake function
void SetOnChart(long x) {OnChart=false; OnZ=false;}                                         // Fake function

iCanvas *iC[];
iCanvas *Canvas=new iCanvas;
B17 d17;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if (sparam=="0") W.MouseStatus=NO_PRESSED;
   else if (sparam=="1") W.MouseStatus=LEFT_BUTTON_PRESSED;
   else if (sparam=="2") W.MouseStatus=RIGHT_BUTTON_PRESSED;
   else if (sparam=="3") W.MouseStatus=LEFT_AND_RIGHT_BUTTONS_PRESSED;
   else W.MouseStatus=KEY_PRESSED;
   W.IdEvent=id;
   W.lparam=lparam;
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      W.MouseX=(int)lparam;
      W.MouseY=(int)dparam;
      W.MouseBar=(double)W.Left_bar+1-(double)W.MouseX/(double)W.dx_pix;
      W.MouseSubWin=XYToTimePrice(W.MouseX,W.MouseY,W.MouseTime,W.MousePrice,id);
      if(W.MouseSubWin>0) for(int i=0;i<W.MouseSubWin;i++) W.MouseY=W.MouseY-W.height[i]-2;
     }
   if(id==CHARTEVENT_CHART_CHANGE) ChartChanged();
   if(OnZ) SetOnChart(sizeArr);
   if(OnChart) MyChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
void ChartChanged()
  {
   static int preWinTotal=W.WindowsTotal;
   //if(CheckPointer(Canvas)!=POINTER_INVALID) {delete Canvas; Canvas=new iCanvas;}
   GetWindowProperties(W);
   if(preWinTotal!=W.WindowsTotal) for(int i=ArraySize(iC)-1; i>=0; i--) if(CheckPointer(iC[i])!=POINTER_INVALID) if(iC[i].SubWin>=W.WindowsTotal) iC[i].SubWin--;
   for(int i=ArraySize(iC)-1; i>=0; i--)
     {
      if(CheckPointer(iC[i])!=POINTER_INVALID)
         {if(iC[i].FullWinCanvWidth())
           {
            if(iC[i].FullWinCanvHeight())
              {
               if(W.Width!=WidOld || W.height[iC[i].SubWin]!=HeiOld[iC[i].SubWin]) {iC[i].Resize(W.Width,W.height[iC[i].SubWin]); HeiOld[iC[i].SubWin]=W.height[iC[i].SubWin];}
              }
            else {if(W.Width!=WidOld) {iC[i].Resize(W.Width,iC[i].Height()); }}
           }
      else
        {
         if(iC[i].FullWinCanvHeight())
            if(W.height[iC[i].SubWin]!=HeiOld[iC[i].SubWin]) {iC[i].Resize(iC[i].Width(),W.height[iC[i].SubWin]); HeiOld[iC[i].SubWin]=W.height[iC[i].SubWin];}
        }
      } else ArrayRemove(iC,i,1);
     }
   WidOld=W.Width;
   preWinTotal=W.WindowsTotal;
   XYToTimePrice(0,0,W.MouseTime,W.MousePrice,CHARTEVENT_CHART_CHANGE);
  }
//+------------------------------------------------------------------+
double wBarShift(datetime t,datetime &arr[],ENUM_TIMEFRAMES tf)
  {
   static ENUM_TIMEFRAMES lastTF=tf;
   int size=ArraySize(arr);
   int PerSec=PeriodSeconds(tf);
   int cur,Start=0;
   int fin=size-1;
   static datetime last_t=(W.Right_bar==0 && tf==_Period)?arr[fin]:(TimeCurrent()-GetTickCount()/1000);
  
   if (t>arr[0] && t<arr[fin] && tf==_Period) 
   if(tf>PERIOD_D1)
     while(true)
     {
      cur=(Start+fin)/2;
      if(t<arr[cur]) {if(t>=arr[cur-1]) return(size+(int)W.Right_bar-cur-double(t-arr[cur-1])/PerSec);    fin=cur;} 
      else           {if(t< arr[cur+1]) return(size-1+(int)W.Right_bar-cur-double(t-arr[cur])/PerSec); if(Start==cur) return(0); Start=cur;}
     }
     else
   while(true)
     {
      cur=(Start+fin)/2;
      if(t<arr[cur]) {if(t>=arr[cur-1]) return(size+(int)W.Right_bar-cur-double(t%PerSec)/PerSec);    fin=cur;} 
      else           {if(t< arr[cur+1]) return(size-1+(int)W.Right_bar-cur-double(t%PerSec)/PerSec); if(Start==cur) return(0); Start=cur;}
      if((arr[fin]-arr[Start])==((fin-Start)*PerSec))
         return(size-1+(int)W.Right_bar-Start-(double(t-arr[Start])/PerSec));
     }
   datetime tc1;
   if (W.Right_bar==0 && tf==_Period) 
   tc1=arr[fin];
     else 
      {
        if(tf==lastTF) tc1 = GetTickCount()/1000+last_t; 
          else 
           {
             tc1=TimeCurrent();
             last_t=tc1-GetTickCount()/1000;
             lastTF=tf;
           }   
        tc1=tc1-tc1%PerSec;
      }
   if(t>=tc1) return double(tc1-t)/PerSec; 
        int ib=iBarShift(_Symbol,tf,t);
        if (tf<PERIOD_W1) return(ib-double(t%PerSec)/PerSec);
        else return(ib-double(t-iTime(_Symbol,tf,ib))/PerSec);
  }
//+------------------------------------------------------------------+

#define OnChartEvent SetOnChart(int x) {OnChart=true;  OnZ=false;}\
void MyChartEvent
//+------------------------------------------------------------------+
#endif