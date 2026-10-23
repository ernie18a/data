// SwingColorPro Candles Live - Perplexity
// Closed bars use causal ATR reversal. Bar 0 is provisional, not a fixed signal.
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property version "3.10"
#property copyright "Perplexity"
input bool PaintLiveCandle=true;
input int ATRPeriod=14;
input double ReversalATR=1.50;
input int MaxCandles=0; // 0: all eligible loaded history
input int BodyWidthPercent=75;
input color BuyColor=clrLimeGreen;
input color SellColor=clrRed;
input string InstanceID="A";
double State[];
string prefix;
datetime last=0;
int closedDirection=1;
double closedExtreme=0;
int OnInit(){
 if(ATRPeriod<2 || ReversalATR<=0 || MaxCandles<0 || BodyWidthPercent<10 || BodyWidthPercent>95)return(INIT_PARAMETERS_INCORRECT);
 prefix="PC_SwingLive_"+InstanceID+"_";
 SetIndexBuffer(0,State);ArraySetAsSeries(State,true);
 SetIndexStyle(0,DRAW_NONE);SetIndexEmptyValue(0,EMPTY_VALUE);
 SetIndexLabel(0,"Regime +1/-1; bar 0 provisional");
 IndicatorShortName("SwingPro Candles Live 3.10");return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){ObjectsDeleteAll(0,prefix);}
void Candle(datetime t,double o,double h,double l,double c,color col){
 int seconds=PeriodSeconds();if(seconds<=0)seconds=Period()*60;
 int half=(int)MathMax(1,seconds*BodyWidthPercent/200.0);
 string id=prefix+IntegerToString((int)t),w=id+"W",b=id+"B";
 if(ObjectFind(0,w)<0)ObjectCreate(0,w,OBJ_TREND,0,t,l,t,h);
 ObjectMove(0,w,0,t,l);ObjectMove(0,w,1,t,h);
 ObjectSetInteger(0,w,OBJPROP_RAY_RIGHT,false);
 ObjectSetInteger(0,w,OBJPROP_COLOR,col);
 ObjectSetInteger(0,w,OBJPROP_WIDTH,1);
 ObjectSetInteger(0,w,OBJPROP_BACK,false);
 ObjectSetInteger(0,w,OBJPROP_SELECTABLE,false);
 double top=MathMax(o,c),bottom=MathMin(o,c);
 if(top-bottom<_Point){top+=_Point*0.5;bottom-=_Point*0.5;}
 datetime left=(datetime)(t-half),right=(datetime)(t+half);
 if(ObjectFind(0,b)<0)ObjectCreate(0,b,OBJ_RECTANGLE,0,left,top,right,bottom);
 ObjectMove(0,b,0,left,top);ObjectMove(0,b,1,right,bottom);
 ObjectSetInteger(0,b,OBJPROP_COLOR,col);
 ObjectSetInteger(0,b,OBJPROP_FILL,true);
 ObjectSetInteger(0,b,OBJPROP_BACK,false);
 ObjectSetInteger(0,b,OBJPROP_SELECTABLE,false);
}
void Live(datetime t,double o,double h,double l,double c){
 if(!PaintLiveCandle){
  string id=prefix+IntegerToString((int)t);
  ObjectDelete(0,id+"W");ObjectDelete(0,id+"B");State[0]=EMPTY_VALUE;return;
 }
 // Reset to the CLOSED state every tick; intrabar flips never accumulate.
 int d=closedDirection;
 double atr=iATR(NULL,0,ATRPeriod,0);if(atr<=0)atr=_Point;
 if(d>0 && closedExtreme-c>=ReversalATR*atr)d=-1;
 else if(d<0 && c-closedExtreme>=ReversalATR*atr)d=1;
 State[0]=d;
 Candle(t,o,h,l,c,d>0?BuyColor:SellColor);
}
int OnCalculate(const int n,const int prev,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tv[],const long &vol[],const int &spread[]){
 ArraySetAsSeries(time,true);ArraySetAsSeries(open,true);ArraySetAsSeries(high,true);ArraySetAsSeries(low,true);ArraySetAsSeries(close,true);
 if(n<ATRPeriod+3)return(0);
 if(prev>0 && last==time[0]){Live(time[0],open[0],high[0],low[0],close[0]);return(n);}
 last=time[0];
 if(prev==0)ObjectsDeleteAll(0,prefix);
 int oldest=n-ATRPeriod-1;
 int firstDraw=(MaxCandles==0?oldest:MathMin(oldest,MaxCandles));
 int d=(close[oldest]>=open[oldest]?1:-1);
 double extreme=close[oldest];
 for(int i=oldest;i>=1;i--){
  double atr=iATR(NULL,0,ATRPeriod,i);if(atr<=0)atr=_Point;
  if(d>0){
   if(extreme-close[i]>=ReversalATR*atr){d=-1;extreme=close[i];}
   else extreme=MathMax(extreme,close[i]);
  }else{
   if(close[i]-extreme>=ReversalATR*atr){d=1;extreme=close[i];}
   else extreme=MathMin(extreme,close[i]);
  }
  State[i]=d;
  if(i<=firstDraw)Candle(time[i],open[i],high[i],low[i],close[i],d>0?BuyColor:SellColor);
 }
 if(MaxCandles>0 && firstDraw+1<n){
  string id=prefix+IntegerToString((int)time[firstDraw+1]);ObjectDelete(0,id+"W");ObjectDelete(0,id+"B");
 }
 closedDirection=d;closedExtreme=extreme;
 Live(time[0],open[0],high[0],low[0],close[0]);
 ChartRedraw();return(n);
}
