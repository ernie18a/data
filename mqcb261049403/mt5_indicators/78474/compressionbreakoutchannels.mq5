//+------------------------------------------------------------------+
//|                                  CompressionBreakoutChannels.mq5 |
//|                                                     Bruno Myrrha |
//+------------------------------------------------------------------+
//| Purpose:      Finds volatility compressions from the deviation of|
//|               the range-normalized close, boxes each one as a    |
//|               channel with ATR edge bands, and marks the close   |
//|               that breaks it. Inside the live channels it shows  |
//|               volume as text and as candles from the midline, and|
//|               a gauge of the current volume delta on the right.  |
//| Failure mode: Buy and sell volume come from the bars of a lower  |
//|               timeframe; where that history is missing the split |
//|               reads zero. The bar in progress is recalculated on |
//|               every tick from the last confirmed state.          |
//| Dependencies: none (chart objects and indicator buffers)         |
//| Part of:      CompressionBreakoutChannels indicator              |
//+------------------------------------------------------------------+

#property copyright "Bruno Nunes Myrrha Ribeiro"
#property link      "https://www.mql5.com/en/users/bruno_myrrha"
#property version   "1.01"
#property description "Volatility compression channels with breakout arrows, volume split"
#property description "inside the channel and a volume delta gauge."
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   4
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGreen
#property indicator_label1  "Volume above open;Volume above high;Volume above low;Volume above close"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrRed
#property indicator_label2  "Volume below open;Volume below high;Volume below low;Volume below close"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGreen
#property indicator_width3  2
#property indicator_label3  "Bullish breakout"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  2
#property indicator_label4  "Bearish breakout"

//+------------------------------------------------------------------+
//| Option lists                                                     |
//+------------------------------------------------------------------+
enum ENUM_VOLUME_VIEW               // what the volume readouts show
  {
   VOLUME_OFF=0,                    // off
   VOLUME_TOTAL=1,                  // total volume
   VOLUME_SPLIT=2,                  // buy and sell volume
   VOLUME_DELTA=3                   // buy minus sell volume
  };
enum ENUM_ALERTS                    // which events raise an alert
  {
   ALERT_OFF,                       // off
   ALERT_BREAKS,                    // breakouts
   ALERT_ALL                        // breakouts and new channels
  };

//+------------------------------------------------------------------+
//| Inputs: channels                                                 |
//+------------------------------------------------------------------+
input group "Channels"
input bool InpNested     = false;   // allow nested channels
input bool InpBodyBreak  = true;    // break on the body midpoint (strong close)
input int  InpRangeBars  = 100;     // normalization length, bars
input int  InpSqueezeLen = 14;      // squeeze detection length, bars

//+------------------------------------------------------------------+
//| Inputs: volume                                                   |
//+------------------------------------------------------------------+
input group "Volume"
input ENUM_VOLUME_VIEW InpVolumeView   = VOLUME_SPLIT;  // volume readout
input ENUM_TIMEFRAMES  InpVolumeSource = PERIOD_M1;     // buy and sell split from timeframe
input double           InpVolumeScale  = 0.5;           // volume candle height, 0.1 to 2.0

//+------------------------------------------------------------------+
//| Inputs: colors and alerts                                        |
//+------------------------------------------------------------------+
input group "Colors"
input color InpBullTint = C'24,158,118';   // bullish
input color InpBearTint = C'206,64,84';    // bearish
input group "Alerts"
input ENUM_ALERTS InpAlerts = ALERT_OFF;   // alerts

//+------------------------------------------------------------------+
//| Engine constants                                                 |
//+------------------------------------------------------------------+
#define NO_VALUE     EMPTY_VALUE    // a series value that does not exist
#define SPREAD_BARS  14             // bars of the deviation window
#define FLOW_BARS    20             // bars of the volume average
#define MIN_SQUEEZE  10             // a squeeze must last more bars than this
#define KEEP_BOXES   166            // broken channels kept on the chart
#define GAUGE_STEPS  21             // segments of the delta gauge

//+------------------------------------------------------------------+
//| Settings the engine runs with                                    |
//+------------------------------------------------------------------+
struct ChannelRules
  {
   bool              nested;        // channels may overlap
   bool              bodyBreak;     // break on the body midpoint
   int               rangeBars;     // bars of the high-low range
   int               squeezeLen;    // bars of the peak and trough scan
   int               view;          // VOLUME_TOTAL, _SPLIT or _DELTA
   bool              candles;       // build the volume candles
   bool              readout;       // build the volume text
   double            scale;         // volume candle height factor
  };

//+------------------------------------------------------------------+
//| One channel: geometry, life and its volume readout               |
//+------------------------------------------------------------------+
struct ChannelBox
  {
   long              id;            // unique id, names the objects
   int               fromBar;       // bar of the left edge
   int               toBar;         // bar of the right edge
   double            top;           // channel high
   double            bottom;        // channel low
   double            band;          // edge band height, half an ATR
   bool              alive;         // not broken yet
   int               tagBand;       // readout band: 0 none, 1 top, 2 bottom
   double            tagA;          // first readout number
   double            tagB;          // second readout number (split)
  };

//+------------------------------------------------------------------+
//| What one bar produced                                            |
//+------------------------------------------------------------------+
struct BarOutcome
  {
   bool              formed;        // a channel was created
   bool              bullish;       // a channel broke up
   bool              bearish;       // a channel broke down
   double            bullAt;        // arrow price of the up break
   double            bearAt;        // arrow price of the down break
   double            hiO;           // candle above the midline: open
   double            hiH;           // high
   double            hiL;           // low
   double            hiC;           // close
   double            loO;           // candle below the midline: open
   double            loH;           // high
   double            loL;           // low
   double            loC;           // close
   double            fade;          // total view: candle transparency
   double            delta;         // buy minus sell volume of the bar
  };

//+------------------------------------------------------------------+
//| Price series derived from the bars, cached by bar index          |
//+------------------------------------------------------------------+
class CSqueezeSeries
  {
public:
   int               first;         // first index the cache covers
   double            level[];       // close placed inside its range
   double            spread[];      // deviation of that level
   double            rise[];        // recency of the deviation peak
   double            fall[];        // recency of the deviation trough
   double            range[];       // average true range
   double            flow[];        // average volume
   //--- sizes the cache, keeping the values already filled
   void              Size(const int bars);
   //--- empties the cache and sets its first index
   void              Reset(const int bars,const int from);
   //--- fills bar i from the prices and from bar i-1
   void              Fill(const int i,const ChannelRules &r,const double &high[],
                          const double &low[],const double &close[],
                          const double &volume[]);
  };

//+------------------------------------------------------------------+
//| Everything the drawings are built from                           |
//+------------------------------------------------------------------+
class CChannelBook
  {
public:
   ChannelBox        boxes[];       // channels, oldest first
   int               lastTurn;      // bar of the last squeeze start
   bool              deltaSet;      // delta range started
   double            deltaTop;      // highest delta since the start
   double            deltaFloor;    // lowest delta since the start
   bool              buying;        // direction carried across intrabars
   double            lastPrice;     // close of the previous intrabar
   long              nextId;        // id of the next channel
   //--- empties the book
   void              Clear(void);
   //--- takes a full copy of another book
   void              CopyFrom(const CChannelBook &src);
  };

//+------------------------------------------------------------------+
//| Grows every cache array to the number of bars                    |
//+------------------------------------------------------------------+
void CSqueezeSeries::Size(const int bars)
  {
   int had=ArraySize(level);
   if(had>=bars)
      return;
   ArrayResize(level,bars,4096);
   ArrayResize(spread,bars,4096);
   ArrayResize(rise,bars,4096);
   ArrayResize(fall,bars,4096);
   ArrayResize(range,bars,4096);
   ArrayResize(flow,bars,4096);
   for(int k=had; k<bars; k++)
     {
      level[k]=NO_VALUE;
      spread[k]=NO_VALUE;
      rise[k]=NO_VALUE;
      fall[k]=NO_VALUE;
      range[k]=NO_VALUE;
      flow[k]=NO_VALUE;
     }
  }

//+------------------------------------------------------------------+
//| Empties the cache and moves its first index                      |
//+------------------------------------------------------------------+
void CSqueezeSeries::Reset(const int bars,const int from)
  {
   ArrayResize(level,0);
   ArrayResize(spread,0);
   ArrayResize(rise,0);
   ArrayResize(fall,0);
   ArrayResize(range,0);
   ArrayResize(flow,0);
   Size(bars);
   first=from;
  }

//+------------------------------------------------------------------+
//| Fills one bar of every derived series                            |
//+------------------------------------------------------------------+
void CSqueezeSeries::Fill(const int i,const ChannelRules &r,const double &high[],
                          const double &low[],const double &close[],
                          const double &volume[])
  {
   level[i]=NO_VALUE;
   spread[i]=NO_VALUE;
   rise[i]=NO_VALUE;
   fall[i]=NO_VALUE;
   range[i]=NO_VALUE;
   flow[i]=NO_VALUE;
//--- close inside the high-low range of the last bars
   if(i-r.rangeBars+1>=0)
     {
      double hi=high[i],lo=low[i];
      for(int k=i-r.rangeBars+1; k<i; k++)
        {
         hi=MathMax(hi,high[k]);
         lo=MathMin(lo,low[k]);
        }
      if(hi>lo)
         level[i]=(close[i]-lo)/(hi-lo);
     }
//--- population deviation of that level
   bool whole=(i-SPREAD_BARS+1>=first);
   double sum=0;
   for(int k=i-SPREAD_BARS+1; k<=i && whole; k++)
     {
      whole=(level[k]!=NO_VALUE);
      sum+=level[k];
     }
   if(whole)
     {
      double mean=sum/SPREAD_BARS,acc=0;
      for(int k=i-SPREAD_BARS+1; k<=i; k++)
         acc+=(level[k]-mean)*(level[k]-mean);
      spread[i]=MathSqrt(acc/SPREAD_BARS);
     }
//--- how recent the deviation peak and trough are, 1 = this bar
   whole=(i-r.squeezeLen>=first);
   for(int k=i-r.squeezeLen; k<=i && whole; k++)
      whole=(spread[k]!=NO_VALUE);
   if(whole)
     {
      int peak=0,trough=0;
      double most=spread[i],least=spread[i];
      for(int k=1; k<=r.squeezeLen; k++)
        {
         if(spread[i-k]>most)
           {
            most=spread[i-k];
            peak=k;
           }
         if(spread[i-k]<least)
           {
            least=spread[i-k];
            trough=k;
           }
        }
      rise[i]=(double)(r.squeezeLen-peak)/r.squeezeLen;
      fall[i]=(double)(r.squeezeLen-trough)/r.squeezeLen;
     }
//--- Wilder average of the true range
   int    n=r.squeezeLen;
   double tr=high[i]-low[i];
   if(i>0)
      tr=MathMax(tr,MathMax(MathAbs(high[i]-close[i-1]),MathAbs(low[i]-close[i-1])));
   if(i>first && range[i-1]!=NO_VALUE)
      range[i]=(tr+(n-1)*range[i-1])/n;
   else
      if(i-n+1>=first)
        {
         double acc=0;
         for(int k=i-n+1; k<=i; k++)
           {
            double t=high[k]-low[k];
            if(k>0)
               t=MathMax(t,MathMax(MathAbs(high[k]-close[k-1]),MathAbs(low[k]-close[k-1])));
            acc+=t;
           }
         range[i]=acc/n;
        }
//--- average volume
   if(i-FLOW_BARS+1>=0)
     {
      double acc=0;
      for(int k=i-FLOW_BARS+1; k<=i; k++)
         acc+=volume[k];
      flow[i]=acc/FLOW_BARS;
     }
  }

//+------------------------------------------------------------------+
//| Resets the book to empty                                         |
//+------------------------------------------------------------------+
void CChannelBook::Clear(void)
  {
   ArrayResize(boxes,0);
   lastTurn=-1;
   deltaSet=false;
   deltaTop=0;
   deltaFloor=0;
   buying=true;
   lastPrice=NO_VALUE;
   nextId=1;
  }

//+------------------------------------------------------------------+
//| Copies every channel and counter of another book                 |
//+------------------------------------------------------------------+
void CChannelBook::CopyFrom(const CChannelBook &src)
  {
   ArrayCopy(boxes,src.boxes);
   ArrayResize(boxes,ArraySize(src.boxes));
   lastTurn=src.lastTurn;
   deltaSet=src.deltaSet;
   deltaTop=src.deltaTop;
   deltaFloor=src.deltaFloor;
   buying=src.buying;
   lastPrice=src.lastPrice;
   nextId=src.nextId;
  }

//+------------------------------------------------------------------+
//| Splits the volume of a run of intrabars into buy and sell        |
//+------------------------------------------------------------------+
void SplitVolume(CChannelBook &book,const double &open[],const double &close[],
                 const double &volume[],const int from,const int count,
                 double &buy,double &sell)
  {
   buy=0;
   sell=0;
   for(int k=from; k<from+count; k++)
     {
      if(close[k]>open[k])
         book.buying=true;
      else
         if(close[k]<open[k])
            book.buying=false;
         else
            if(book.lastPrice!=NO_VALUE && close[k]>book.lastPrice)
               book.buying=true;
            else
               if(book.lastPrice!=NO_VALUE && close[k]<book.lastPrice)
                  book.buying=false;
      if(book.buying)
         buy+=volume[k];
      else
         sell-=volume[k];
      book.lastPrice=close[k];
     }
  }

//+------------------------------------------------------------------+
//| Index of the newest live channel, or -1                          |
//+------------------------------------------------------------------+
int NewestLive(const CChannelBook &book)
  {
   for(int k=ArraySize(book.boxes)-1; k>=0; k--)
      if(book.boxes[k].alive)
         return(k);
   return(-1);
  }

//+------------------------------------------------------------------+
//| True when no live channel overlaps the price range               |
//+------------------------------------------------------------------+
bool RoomFor(const CChannelBook &book,const double top,const double bottom)
  {
   for(int k=0; k<ArraySize(book.boxes); k++)
      if(book.boxes[k].alive && top>book.boxes[k].bottom && bottom<book.boxes[k].top)
         return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//| Drops the oldest broken channels beyond the limit                |
//+------------------------------------------------------------------+
void TrimBook(CChannelBook &book)
  {
   int dead=0;
   for(int k=ArraySize(book.boxes)-1; k>=0; k--)
     {
      if(book.boxes[k].alive)
         continue;
      if(++dead>KEEP_BOXES)
         ArrayRemove(book.boxes,k,1);
     }
  }

//+------------------------------------------------------------------+
//| Empties an outcome                                               |
//+------------------------------------------------------------------+
void ClearOutcome(BarOutcome &out)
  {
   out.formed=false;
   out.bullish=false;
   out.bearish=false;
   out.bullAt=NO_VALUE;
   out.bearAt=NO_VALUE;
   out.hiO=NO_VALUE;
   out.hiH=NO_VALUE;
   out.hiL=NO_VALUE;
   out.hiC=NO_VALUE;
   out.loO=NO_VALUE;
   out.loH=NO_VALUE;
   out.loL=NO_VALUE;
   out.loC=NO_VALUE;
   out.fade=0;
   out.delta=0;
  }

//+------------------------------------------------------------------+
//| Sets one volume candle from the midline by a signed height       |
//+------------------------------------------------------------------+
void SetCandle(const double mid,const double rise,double &o,double &h,double &l,
               double &c)
  {
   o=mid;
   c=mid+rise;
   h=MathMax(mid,mid+rise);
   l=MathMin(mid,mid+rise);
  }

//+------------------------------------------------------------------+
//| Builds the volume candles from the newest live channel           |
//+------------------------------------------------------------------+
void BuildCandles(const CChannelBook &book,const ChannelRules &r,const double avg,
                  const double total,const double buy,const double sell,
                  BarOutcome &out)
  {
   int k=NewestLive(book);
   if(k<0 || !r.candles || avg==NO_VALUE || avg<=0)
      return;
   double mid=(book.boxes[k].top+book.boxes[k].bottom)/2;
   double unit=(book.boxes[k].top-book.boxes[k].bottom)*r.scale/4/avg;
   if(r.view==VOLUME_TOTAL)
     {
      SetCandle(mid,total*unit,out.hiO,out.hiH,out.hiL,out.hiC);
      SetCandle(mid,-total*unit,out.loO,out.loH,out.loL,out.loC);
      out.fade=MathMax(20,MathMin(80,80-(total/avg-0.5)*40));
      return;
     }
   if(r.view==VOLUME_SPLIT)
     {
      SetCandle(mid,buy*unit,out.hiO,out.hiH,out.hiL,out.hiC);
      SetCandle(mid,sell*unit,out.loO,out.loH,out.loL,out.loC);
      return;
     }
   double d=buy+sell;
   SetCandle(mid,d>=0 ? MathAbs(d)*unit : 0,out.hiO,out.hiH,out.hiL,out.hiC);
   SetCandle(mid,d>=0 ? 0 : -MathAbs(d)*unit,out.loO,out.loH,out.loL,out.loC);
  }

//+------------------------------------------------------------------+
//| Applies one bar: squeeze start, new channel, breaks, readouts    |
//+------------------------------------------------------------------+
void StepChannels(CChannelBook &book,const CSqueezeSeries &ser,const ChannelRules &r,
                  const int i,const double &open[],const double &high[],
                  const double &low[],const double &close[],const double &volume[],
                  const double buy,const double sell,BarOutcome &out)
  {
   ClearOutcome(out);
   bool known=(i>=1 && ser.rise[i]!=NO_VALUE && ser.rise[i-1]!=NO_VALUE);
   bool turnDown=known && ser.fall[i]>ser.rise[i] && ser.fall[i-1]<=ser.rise[i-1];
   bool turnUp=known && ser.rise[i]>ser.fall[i] && ser.rise[i-1]<=ser.fall[i-1];
   if(turnDown)
      book.lastTurn=i;
   int span=(book.lastTurn>=0) ? MathMax(i-book.lastTurn,1) : 1;
//--- delta range since the squeeze start
   double delta=buy+sell;
   out.delta=delta;
   if(!book.deltaSet)
     {
      book.deltaSet=true;
      book.deltaTop=delta;
      book.deltaFloor=delta;
     }
   if(turnDown)
     {
      book.deltaTop=delta;
      book.deltaFloor=delta;
     }
   book.deltaTop=MathMax(book.deltaTop,delta);
   book.deltaFloor=MathMin(book.deltaFloor,delta);
//--- a squeeze that lasted long enough becomes a channel
   if(turnUp && span>MIN_SQUEEZE && ser.range[i]!=NO_VALUE)
     {
      double top=high[i],bottom=low[i];
      for(int k=i-span+1; k<i; k++)
        {
         top=MathMax(top,high[k]);
         bottom=MathMin(bottom,low[k]);
        }
      if(r.nested || RoomFor(book,top,bottom))
        {
         ChannelBox b;
         ZeroMemory(b);
         b.id=book.nextId++;
         b.fromBar=i-span;
         b.toBar=i;
         b.top=top;
         b.bottom=bottom;
         b.band=ser.range[i]/2;
         b.alive=true;
         int n=ArraySize(book.boxes);
         ArrayResize(book.boxes,n+1,64);
         book.boxes[n]=b;
         out.formed=true;
        }
     }
//--- walk the live channels from the newest; a break skips the next one
   double price=r.bodyBreak ? (close[i]+open[i])/2 : close[i];
   bool   skip=false;
   for(int k=ArraySize(book.boxes)-1; k>=0; k--)
     {
      if(!book.boxes[k].alive)
         continue;
      if(skip)
        {
         skip=false;
         continue;
        }
      if(price>book.boxes[k].top)
        {
         out.bullAt=book.boxes[k].bottom;
         out.bullish=true;
         book.boxes[k].alive=false;
         skip=true;
         continue;
        }
      if(price<book.boxes[k].bottom)
        {
         out.bearAt=book.boxes[k].top;
         out.bearish=true;
         book.boxes[k].alive=false;
         skip=true;
         continue;
        }
      book.boxes[k].toBar=i;
      if(!r.readout)
         continue;
      double mid=(book.boxes[k].top+book.boxes[k].bottom)/2;
      book.boxes[k].tagBand=(price>mid) ? 2 : 1;
      book.boxes[k].tagA=(r.view==VOLUME_TOTAL) ? volume[i] : (r.view==VOLUME_SPLIT) ? buy : delta;
      book.boxes[k].tagB=(r.view==VOLUME_SPLIT) ? sell : 0;
     }
   TrimBook(book);
   BuildCandles(book,r,ser.flow[i],volume[i],buy,sell,out);
  }

//+------------------------------------------------------------------+
//| Gauge pointer price on the newest live channel, or NO_VALUE      |
//+------------------------------------------------------------------+
double GaugeLevel(const CChannelBook &book,const BarOutcome &out)
  {
   int k=NewestLive(book);
   if(k<0 || out.bullish || out.bearish)
      return(NO_VALUE);
   double top=book.boxes[k].top,bottom=book.boxes[k].bottom;
   if(top==bottom || book.deltaTop==book.deltaFloor)
      return(NO_VALUE);
   double tilt=-200*((out.delta-book.deltaFloor)/(book.deltaTop-book.deltaFloor)-0.5);
   tilt=MathMax(MathMin(tilt,100),-100);
   return(top-(tilt+100)/200*(top-bottom));
  }

//+------------------------------------------------------------------+
//| Drawing constants                                                |
//+------------------------------------------------------------------+
#define TAG          "CBC_"         // prefix of every chart object
#define HISTORY      5000           // bars processed on load
#define WARMUP       500            // series bars computed before them
#define POINTER_SIZE 10             // gauge pointer font size
#define TEXT_SIZE    7              // volume text font size
#define SHADES       13             // gray levels of the total view
#define SHADE_BASE   2              // palette index of the first gray

ChannelRules    g_rules;            // engine settings
CSqueezeSeries  g_series;           // derived series
CChannelBook    g_done;             // book after the last closed bar
CChannelBook    g_view;             // book including the bar in progress
int             g_doneBar=-1;       // last closed bar applied
datetime        g_doneTime=0;       // time of that bar
double          g_volume[];         // tick volume as double
ENUM_TIMEFRAMES g_source;           // timeframe of the intrabars
bool            g_selfSource;       // the chart bar is its own intrabar
int             g_waits=0;          // retries while history loads
bool            g_gap=false;        // an intrabar request failed
string          g_drawn[];          // objects drawn on the last render
datetime        g_alerted=0;        // bar of the last alert batch
//--- indicator buffers
double          g_hiO[],g_hiH[],g_hiL[],g_hiC[],g_hiTint[];
double          g_loO[],g_loH[],g_loL[],g_loC[],g_loTint[];
double          g_bull[],g_bear[];

//+------------------------------------------------------------------+
//| Blends a color over another (opacity in percent)                 |
//+------------------------------------------------------------------+
color Blend(const color top,const color under,const double opacity)
  {
   double a=MathMax(0,MathMin(100,opacity))/100.0;
   int    r=(int)MathRound((top&0xFF)*a+(under&0xFF)*(1-a));
   int    g=(int)MathRound(((top>>8)&0xFF)*a+((under>>8)&0xFF)*(1-a));
   int    b=(int)MathRound(((top>>16)&0xFF)*a+((under>>16)&0xFF)*(1-a));
   return((color)(r|(g<<8)|(b<<16)));
  }

//+------------------------------------------------------------------+
//| Chart background color                                           |
//+------------------------------------------------------------------+
color Back(void)
  {
   return((color)ChartGetInteger(0,CHART_COLOR_BACKGROUND));
  }

//+------------------------------------------------------------------+
//| Chart foreground color                                           |
//+------------------------------------------------------------------+
color Fore(void)
  {
   return((color)ChartGetInteger(0,CHART_COLOR_FOREGROUND));
  }

//+------------------------------------------------------------------+
//| Number in thousands with one decimal, as "12.3K"                 |
//+------------------------------------------------------------------+
string Thousands(const double value)
  {
   double k=MathRound(value/100.0)/10.0;
   if(k==0)
      k=0;
   string text=DoubleToString(k,1);
   if(StringSubstr(text,StringLen(text)-2)==".0")
      text=StringSubstr(text,0,StringLen(text)-2);
   return(text+"K");
  }

//+------------------------------------------------------------------+
//| Records an object name as drawn on this render                   |
//+------------------------------------------------------------------+
void Keep(const string name)
  {
   int n=ArraySize(g_drawn);
   ArrayResize(g_drawn,n+1,256);
   g_drawn[n]=name;
  }

//+------------------------------------------------------------------+
//| Creates or moves a filled rectangle in the background            |
//+------------------------------------------------------------------+
void PutBox(const string name,const datetime t1,const double p1,const datetime t2,
            const double p2,const color tint)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_RECTANGLE,0,t1,p1,t2,p2);
      ObjectSetInteger(0,name,OBJPROP_FILL,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t1);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,p1);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,t2);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,p2);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| Creates or moves a line segment                                  |
//+------------------------------------------------------------------+
void PutLine(const string name,const datetime t1,const double p1,const datetime t2,
             const double p2,const color tint,const ENUM_LINE_STYLE style,
             const int width)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TREND,0,t1,p1,t2,p2);
      ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t1);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,p1);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,t2);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,p2);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| Creates or moves a text label                                    |
//+------------------------------------------------------------------+
void PutText(const string name,const datetime t,const double price,const string text,
             const color tint,const ENUM_ANCHOR_POINT anchor,const int points)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TEXT,0,t,price);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,price);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,points);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| Draws one channel: shaded slices, midline and volume text        |
//+------------------------------------------------------------------+
void DrawChannel(const ChannelBox &b,const datetime &time[])
  {
   string   base=TAG+IntegerToString(b.id);
   datetime t1=time[b.fromBar],t2=time[b.toBar];
   color    back=Back(),fore=Fore();
//--- the box and both bands overlap: cut them into slices of one color each
   double edge[4];
   edge[0]=b.bottom;
   edge[1]=b.top;
   edge[2]=b.top-b.band;
   edge[3]=b.bottom+b.band;
   ArraySort(edge);
   int slice=0;
   for(int k=0; k<3; k++)
     {
      if(edge[k+1]<=edge[k])
         continue;
      double m=(edge[k]+edge[k+1])/2;
      color  tint=back;
      if(m>=b.bottom && m<=b.top)
         tint=Blend(fore,tint,10);
      if(m>=b.top-b.band && m<=b.top)
         tint=Blend(InpBearTint,tint,30);
      if(m>=b.bottom && m<=b.bottom+b.band)
         tint=Blend(InpBullTint,tint,30);
      PutBox(base+"Z"+IntegerToString(slice++),t1,edge[k+1],t2,edge[k],tint);
     }
   double mid=(b.top+b.bottom)/2;
   PutLine(base+"M",t1,mid,t2,mid,Blend(fore,back,50),STYLE_DASH,1);
   if(b.tagBand==0)
      return;
   string text=(g_rules.view==VOLUME_SPLIT) ? Thousands(b.tagA)+"/"+Thousands(b.tagB) :
               Thousands(b.tagA);
   double at=(b.tagBand==1) ? b.top-b.band/2 : b.bottom+b.band/2;
   PutText(base+"T",t2,at,text,Blend(fore,back,70),ANCHOR_RIGHT,TEXT_SIZE);
  }

//+------------------------------------------------------------------+
//| Draws the delta gauge to the right of the newest live channel    |
//+------------------------------------------------------------------+
void DrawGauge(const CChannelBook &book,const BarOutcome &now,const datetime last)
  {
   int k=NewestLive(book);
   if(k<0 || now.bullish || now.bearish)
      return;
   double top=book.boxes[k].top,bottom=book.boxes[k].bottom;
   if(top==bottom)
      return;
   int      step=PeriodSeconds(_Period);
   datetime x=last+2*step;
   double   seg=(top-bottom)/GAUGE_STEPS;
   for(int s=0; s<GAUGE_STEPS; s++)
     {
      double y1=top-s*seg;
      double y2=top-(s+1)*seg;
      double w=MathMax(0,MathMin(1,(y1-bottom)/(top-bottom)));
      PutLine(TAG+"G"+IntegerToString(s),x,y1,x,y2,Blend(InpBullTint,InpBearTint,w*100),
              STYLE_SOLID,4);
     }
   double at=GaugeLevel(book,now);
   if(at!=NO_VALUE)
      PutText(TAG+"GP",last+3*step,at,ShortToString(0x25C4),Fore(),ANCHOR_LEFT,POINTER_SIZE);
  }

//+------------------------------------------------------------------+
//| Redraws everything from a book and removes stale objects         |
//+------------------------------------------------------------------+
void Render(const CChannelBook &book,const BarOutcome &now,const datetime &time[],
            const int last)
  {
   string before[];
   ArrayCopy(before,g_drawn);
   ArrayResize(g_drawn,0,256);
   for(int k=0; k<ArraySize(book.boxes); k++)
      DrawChannel(book.boxes[k],time);
   DrawGauge(book,now,time[last]);
   for(int k=0; k<ArraySize(before); k++)
     {
      bool still=false;
      for(int j=0; j<ArraySize(g_drawn) && !still; j++)
         still=(g_drawn[j]==before[k]);
      if(!still)
         ObjectDelete(0,before[k]);
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Deletes every object of the indicator                            |
//+------------------------------------------------------------------+
void Wipe(void)
  {
   ObjectsDeleteAll(0,TAG);
   ArrayResize(g_drawn,0);
  }

//+------------------------------------------------------------------+
//| Sets the candle palette: two tints and the gray levels           |
//+------------------------------------------------------------------+
void Palette(void)
  {
   color back=Back(),fore=Fore();
   for(int p=0; p<2; p++)
     {
      PlotIndexSetInteger(p,PLOT_COLOR_INDEXES,SHADE_BASE+SHADES);
      PlotIndexSetInteger(p,PLOT_LINE_COLOR,0,InpBullTint);
      PlotIndexSetInteger(p,PLOT_LINE_COLOR,1,InpBearTint);
      for(int s=0; s<SHADES; s++)
         PlotIndexSetInteger(p,PLOT_LINE_COLOR,SHADE_BASE+s,Blend(fore,back,20+5*s));
     }
  }

//+------------------------------------------------------------------+
//| Writes one bar of the indicator buffers                          |
//+------------------------------------------------------------------+
void WriteBar(const int i,const BarOutcome &out)
  {
   g_hiO[i]=out.hiO;
   g_hiH[i]=out.hiH;
   g_hiL[i]=out.hiL;
   g_hiC[i]=out.hiC;
   g_loO[i]=out.loO;
   g_loH[i]=out.loH;
   g_loL[i]=out.loL;
   g_loC[i]=out.loC;
   double shade=SHADE_BASE+MathRound((100-out.fade-20)/5);
   g_hiTint[i]=(g_rules.view==VOLUME_TOTAL) ? shade : 0;
   g_loTint[i]=(g_rules.view==VOLUME_TOTAL) ? shade : 1;
   g_bull[i]=out.bullAt;
   g_bear[i]=out.bearAt;
  }

//+------------------------------------------------------------------+
//| Buy and sell volume of a chart bar from its intrabars            |
//+------------------------------------------------------------------+
void BarVolume(CChannelBook &book,const int i,const datetime &time[],
               const double &open[],const double &close[],double &buy,double &sell)
  {
   double o[],c[],v[];
   if(g_selfSource)
     {
      ArrayResize(o,1);
      ArrayResize(c,1);
      ArrayResize(v,1);
      o[0]=open[i];
      c[0]=close[i];
      v[0]=g_volume[i];
      SplitVolume(book,o,c,v,0,1,buy,sell);
      return;
     }
   MqlRates rates[];
   int got=CopyRates(_Symbol,g_source,time[i],time[i]+PeriodSeconds(_Period)-1,rates);
   if(got<=0)
     {
      if(got<0)
         g_gap=true;
      buy=0;
      sell=0;
      return;
     }
   ArrayResize(o,got);
   ArrayResize(c,got);
   ArrayResize(v,got);
   for(int k=0; k<got; k++)
     {
      o[k]=rates[k].open;
      c[k]=rates[k].close;
      v[k]=(double)rates[k].tick_volume;
     }
   SplitVolume(book,o,c,v,0,got,buy,sell);
  }

//+------------------------------------------------------------------+
//| Sends the alerts of a closed bar                                 |
//+------------------------------------------------------------------+
void Announce(const BarOutcome &out,const datetime bar)
  {
   if(bar<=g_alerted)
      return;
   g_alerted=bar;
   string head=_Symbol+" "+StringSubstr(EnumToString(_Period),7)+": ";
   if(InpAlerts==ALERT_ALL && out.formed)
      Alert(head+"new breakout channel");
   if(InpAlerts!=ALERT_OFF && out.bullish)
      Alert(head+"bullish breakout of the channel");
   if(InpAlerts!=ALERT_OFF && out.bearish)
      Alert(head+"bearish breakout of the channel");
  }

//+------------------------------------------------------------------+
//| Indicator initialization: settings, buffers and palette          |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(InpRangeBars<1 || InpSqueezeLen<1 || InpVolumeScale<0.1 || InpVolumeScale>2.0)
     {
      Print("lengths must be at least 1 and the volume scale 0.1 to 2.0");
      return(INIT_PARAMETERS_INCORRECT);
     }
   g_rules.nested=InpNested;
   g_rules.bodyBreak=InpBodyBreak;
   g_rules.rangeBars=InpRangeBars;
   g_rules.squeezeLen=InpSqueezeLen;
   g_rules.view=(InpVolumeView==VOLUME_OFF) ? VOLUME_SPLIT : (int)InpVolumeView;
   g_rules.candles=(InpVolumeView!=VOLUME_OFF);
   g_rules.readout=(InpVolumeView!=VOLUME_OFF);
   g_rules.scale=InpVolumeScale;
   g_source=(InpVolumeSource==PERIOD_CURRENT) ? _Period : InpVolumeSource;
   g_selfSource=(PeriodSeconds(g_source)>=PeriodSeconds(_Period));
   SetIndexBuffer(0,g_hiO,INDICATOR_DATA);
   SetIndexBuffer(1,g_hiH,INDICATOR_DATA);
   SetIndexBuffer(2,g_hiL,INDICATOR_DATA);
   SetIndexBuffer(3,g_hiC,INDICATOR_DATA);
   SetIndexBuffer(4,g_hiTint,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,g_loO,INDICATOR_DATA);
   SetIndexBuffer(6,g_loH,INDICATOR_DATA);
   SetIndexBuffer(7,g_loL,INDICATOR_DATA);
   SetIndexBuffer(8,g_loC,INDICATOR_DATA);
   SetIndexBuffer(9,g_loTint,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(10,g_bull,INDICATOR_DATA);
   SetIndexBuffer(11,g_bear,INDICATOR_DATA);
   for(int p=0; p<4; p++)
      PlotIndexSetDouble(p,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(2,PLOT_ARROW,233);
   PlotIndexSetInteger(3,PLOT_ARROW,234);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,12);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,-12);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,InpBullTint);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,InpBearTint);
   Palette();
   g_doneBar=-1;
   g_waits=0;
   g_done.Clear();
   Wipe();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator deinitialization: removes the drawings                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   Wipe();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Timer: asks for a full recalculation once the history is there   |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   EventKillTimer();
   ChartSetSymbolPeriod(0,_Symbol,_Period);
  }

//+------------------------------------------------------------------+
//| Chart events: the palette follows the chart colors               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
      Palette();
  }

//+------------------------------------------------------------------+
//| Indicator iteration: confirms closed bars, previews the open one |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],const long &volume[],
                const int &spread[])
  {
   if(rates_total<3)
      return(0);
//--- the intrabars must be loaded before the first pass
   if(!g_selfSource && !SeriesInfoInteger(_Symbol,g_source,SERIES_SYNCHRONIZED) && g_waits<30)
     {
      g_waits++;
      iBars(_Symbol,g_source);
      EventSetTimer(1);
      return(0);
     }
   ArrayResize(g_volume,rates_total,4096);
   g_series.Size(rates_total);
//--- history changed or first run: start again from a bounded window
   if(prev_calculated==0 || g_doneBar<0 || g_doneBar>rates_total-2 || time[g_doneBar]!=g_doneTime)
     {
      Wipe();
      g_done.Clear();
      int start=MathMax(1,rates_total-HISTORY);
      int from=MathMax(0,start-WARMUP);
      g_series.Reset(rates_total,from);
      ArrayInitialize(g_hiO,EMPTY_VALUE);
      ArrayInitialize(g_hiH,EMPTY_VALUE);
      ArrayInitialize(g_hiL,EMPTY_VALUE);
      ArrayInitialize(g_hiC,EMPTY_VALUE);
      ArrayInitialize(g_loO,EMPTY_VALUE);
      ArrayInitialize(g_loH,EMPTY_VALUE);
      ArrayInitialize(g_loL,EMPTY_VALUE);
      ArrayInitialize(g_loC,EMPTY_VALUE);
      ArrayInitialize(g_hiTint,0);
      ArrayInitialize(g_loTint,0);
      ArrayInitialize(g_bull,EMPTY_VALUE);
      ArrayInitialize(g_bear,EMPTY_VALUE);
      for(int k=0; k<rates_total; k++)
         g_volume[k]=(double)tick_volume[k];
      for(int k=from; k<start; k++)
         g_series.Fill(k,g_rules,high,low,close,g_volume);
      g_doneBar=start-1;
      g_alerted=time[rates_total-2];
     }
   for(int k=MathMax(0,prev_calculated-1); k<rates_total; k++)
      g_volume[k]=(double)tick_volume[k];
   BarOutcome out;
   for(int i=g_doneBar+1; i<=rates_total-2; i++)
     {
      double buy,sell;
      g_series.Fill(i,g_rules,high,low,close,g_volume);
      BarVolume(g_done,i,time,open,close,buy,sell);
      StepChannels(g_done,g_series,g_rules,i,open,high,low,close,g_volume,buy,sell,out);
      WriteBar(i,out);
      if(i==rates_total-2)
         Announce(out,time[i]);
     }
   g_doneBar=rates_total-2;
   g_doneTime=time[g_doneBar];
//--- the bar in progress is applied to a copy, never to the confirmed book
   double buyNow,sellNow;
   g_view.CopyFrom(g_done);
   g_series.Fill(rates_total-1,g_rules,high,low,close,g_volume);
   BarVolume(g_view,rates_total-1,time,open,close,buyNow,sellNow);
   StepChannels(g_view,g_series,g_rules,rates_total-1,open,high,low,close,g_volume,buyNow,sellNow,out);
   WriteBar(rates_total-1,out);
   Render(g_view,out,time,rates_total-1);
//--- intrabars still loading: draw what there is and start again shortly
   if(g_gap && g_waits<30)
     {
      g_gap=false;
      g_waits++;
      g_doneBar=-1;
      EventSetTimer(1);
      return(0);
     }
   g_gap=false;
   return(rates_total);
  }
//+------------------------------------------------------------------+
