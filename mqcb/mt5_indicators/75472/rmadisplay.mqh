//+------------------------------------------------------------------+
//|                                                   RmaDisplay.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23693 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23693"
#property version   "1.00"
#property strict

#include <RMA\RmaTypes.mqh>
#include <RMA\SignalEngine.mqh>
#include <RMA\TradeManager.mqh>

//+------------------------------------------------------------------+
//| CRmaDisplay - why a decision looks the way it does, on the chart.|
//|                                                                  |
//|  The question this answers is "why did it do that?", and it is   |
//|  answered in the place the question gets asked.                  |
//|  A status block carries the readings the last decision was made  |
//|  from, and every trade leaves an arrow at its entry, an arrow at |
//|  its exit, and a line between them whose colour is the result.   |
//|  Each of those objects carries the reason as its tooltip, so the |
//|  sentence that justified the trade is attached to the trade      |
//|  rather than to a timestamp in a spreadsheet.                    |
//|                                                                  |
//|  Nothing here is consulted by the strategy. If the whole class   |
//|  is switched off the EA trades identically, which is the         |
//|  property that makes it safe to draw as much as is useful.       |
//+------------------------------------------------------------------+
class CRmaDisplay
  {
private:
   bool              m_enabled;
   string            m_prefix;
   int               m_corner;
   int               m_x;
   int               m_y;
   int               m_line_height;
   int               m_font_size;
   string            m_font;
   color             m_key_color;
   color             m_value_color;
   int               m_rows;           // rows written on the last update

//--- the open trade, held so the exit can draw back to its entry.
   datetime          m_entry_time;
   double            m_entry_price;
   bool              m_entry_long;

   void              Label(const string tag,const int row,const int dx,
                           const string text,const color clr);
   void              Row(const int row,const string key,const string value,
                         const color clr);
   void              Backdrop(const int rows);
   string            Marker(const string kind,const datetime when) const;

public:
                     CRmaDisplay(void);

   bool              Init(const bool enabled,const string prefix,
                          const int corner,const int x,const int y,
                          const int font_size,const string font,
                          const color key_color,const color value_color);

   void              Update(const SRmaBar &b,const CSignalEngine &sig,
                            const CTradeManager &tm,const string note);
   void              MarkEntry(const datetime when,const double price,
                               const bool is_long,const string reason);
   void              MarkExit(const datetime when,const double price,
                              const double pips,const string reason);
   void              Destroy(const bool markers_too);
  };

//+------------------------------------------------------------------+
//| Construct switched off, so nothing draws before Init.            |
//+------------------------------------------------------------------+
CRmaDisplay::CRmaDisplay(void)
  {
   m_enabled     =false;
   m_prefix      ="RMA_";
   m_corner      =CORNER_LEFT_UPPER;
   m_x           =12;
   m_y           =20;
   m_line_height =14;
   m_font_size   =8;
   m_font        ="Consolas";
   m_key_color   =clrSilver;
   m_value_color =clrWhite;
   m_rows        =0;

   m_entry_time  =0;
   m_entry_price =0.0;
   m_entry_long  =false;
  }

//+------------------------------------------------------------------+
//| Store the layout and clear anything a previous run left behind.  |
//+------------------------------------------------------------------+
bool CRmaDisplay::Init(const bool enabled,const string prefix,
                       const int corner,const int x,const int y,
                       const int font_size,const string font,
                       const color key_color,const color value_color)
  {
   m_enabled     =enabled;
   m_prefix      =prefix;
   m_corner      =corner;
   m_x           =x;
   m_y           =y;
   m_font_size   =(font_size<6)?6:font_size;
   m_line_height =m_font_size*2-2;
   m_font        =font;
   m_key_color   =key_color;
   m_value_color =value_color;

//--- the status block only, so that markers drawn before a
//--- recompile survive one.
   ObjectsDeleteAll(0,m_prefix+"hud",0,-1);
   m_rows=0;
   return true;
  }

//+------------------------------------------------------------------+
//| Create or move one text label in the status block.               |
//+------------------------------------------------------------------+
void CRmaDisplay::Label(const string tag,const int row,const int dx,
                        const string text,const color clr)
  {
   string name=m_prefix+"hud_"+tag+"_"+IntegerToString(row);

   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
     }

   ObjectSetInteger(0,name,OBJPROP_CORNER,m_corner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,m_x+dx);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,m_y+row*m_line_height);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,m_font_size);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_FONT,m_font);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }

//+------------------------------------------------------------------+
//| One line of the status block: a name and a reading.              |
//+------------------------------------------------------------------+
void CRmaDisplay::Row(const int row,const string key,const string value,
                      const color clr)
  {
   Label("k",row,0,key,m_key_color);
   Label("v",row,m_font_size*13,value,clr);
  }

//+------------------------------------------------------------------+
//| A panel behind the text, sized to however many rows were used.   |
//+------------------------------------------------------------------+
void CRmaDisplay::Backdrop(const int rows)
  {
   string name=m_prefix+"hud_back";

   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,C'22,24,30');
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_COLOR,C'60,64,76');
     }

   ObjectSetInteger(0,name,OBJPROP_CORNER,m_corner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,m_x-8);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,m_y-8);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,m_font_size*36);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,rows*m_line_height+14);
  }

//+------------------------------------------------------------------+
//| Redraw the status block from the state the last bar produced.    |
//|  The note is the last thing the strategy declined to do and why. |
//|  It is the row that replaces most of what the log file was for:  |
//|  a chart that shows an obvious entry not being taken is only     |
//|  confusing until it also shows which filter refused it.          |
//+------------------------------------------------------------------+
void CRmaDisplay::Update(const SRmaBar &b,const CSignalEngine &sig,
                         const CTradeManager &tm,const string note)
  {
   if(!m_enabled)
      return;

   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   int row=0;

   Backdrop(11);

   Row(row++,"RMA",_Symbol+"  "+StringSubstr(EnumToString(_Period),7),m_value_color);

   Row(row++,"range regime",RmaRegimeName(b.regime),m_value_color);

   Row(row++,"f_w",StringFormat("%.3f   (%+.3f)",b.f_w,b.Diff()),m_value_color);

   Row(row++,"d_med_w / D_k",StringFormat("%+.3f   %.2f",b.d_med_w,b.d_k),m_value_color);

   Row(row++,"leg",EnumToString(sig.State()),m_value_color);

   if(tm.IsOpen())
     {
      double pips=tm.ProfitPips();
      string note=tm.IsPending()?"  (closing)":"";
      Row(row++,"position",StringFormat("%s  %s  %+.1f p%s",
                                        (tm.Type()==0)?"long":"short",
                                        DoubleToString(tm.EntryPrice(),digits),
                                        pips,note),
          (pips>=0.0)?clrLimeGreen:clrTomato);
     }
   if(!tm.IsOpen())
      Row(row++,"position","flat",m_key_color);

   string blocks="clear";
   if(sig.BlockLong() && sig.BlockShort())
      blocks="long and short held back";
   if(sig.BlockLong() && !sig.BlockShort())
      blocks="long held back";
   if(!sig.BlockLong() && sig.BlockShort())
      blocks="short held back";
   Row(row++,"adverse block",blocks,sig.BlockLong()||sig.BlockShort()?clrOrange:m_key_color);

   Row(row++,"trades",StringFormat("%d   win %.1f%%   net %+.1f p",
                                   tm.Trades(),tm.WinRate(),tm.NetPips()),
       (tm.NetPips()>=0.0)?clrLimeGreen:clrTomato);

   Row(row++,"last note",(note=="")?"-":note,m_key_color);

   m_rows=row;
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| A unique object name for one marker on one bar.                  |
//+------------------------------------------------------------------+
string CRmaDisplay::Marker(const string kind,const datetime when) const
  {
   return m_prefix+"mk_"+kind+"_"+IntegerToString((long)when);
  }

//+------------------------------------------------------------------+
//| Plant an arrow where a position was opened.                      |
//+------------------------------------------------------------------+
void CRmaDisplay::MarkEntry(const datetime when,const double price,
                            const bool is_long,const string reason)
  {
   m_entry_time  =when;
   m_entry_price =price;
   m_entry_long  =is_long;

   if(!m_enabled)
      return;

   string name=Marker("in",when);
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);

   ObjectCreate(0,name,is_long?OBJ_ARROW_BUY:OBJ_ARROW_SELL,0,when,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,is_long?clrDodgerBlue:clrTomato);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,
                   StringFormat("%s entry\n%s",is_long?"long":"short",reason));
  }

//+------------------------------------------------------------------+
//| Close the picture: an exit arrow and the line back to the entry. |
//|  The line is what makes a chart full of arrows readable. Its     |
//|  colour is the result and its tooltip is the reason, so a losing |
//|  run can be read off the chart without opening anything.         |
//+------------------------------------------------------------------+
void CRmaDisplay::MarkExit(const datetime when,const double price,
                           const double pips,const string reason)
  {
   if(!m_enabled)
      return;

   color result=(pips>=0.0)?clrLimeGreen:clrTomato;
   string tip=StringFormat("%s exit  %+.1f pips\n%s",
                           m_entry_long?"long":"short",pips,reason);

   string name=Marker("out",when);
   if(ObjectFind(0,name)>=0)
      ObjectDelete(0,name);

   ObjectCreate(0,name,OBJ_ARROW,0,when,price);
   ObjectSetInteger(0,name,OBJPROP_ARROWCODE,251);
   ObjectSetInteger(0,name,OBJPROP_COLOR,result);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tip);

   if(m_entry_time==0)
      return;

   string link=Marker("run",m_entry_time);
   if(ObjectFind(0,link)>=0)
      ObjectDelete(0,link);

   ObjectCreate(0,link,OBJ_TREND,0,m_entry_time,m_entry_price,when,price);
   ObjectSetInteger(0,link,OBJPROP_COLOR,result);
   ObjectSetInteger(0,link,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,link,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,link,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,link,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,link,OBJPROP_BACK,true);
   ObjectSetString(0,link,OBJPROP_TOOLTIP,tip);

   m_entry_time=0;
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Take the drawing down.                                           |
//|  The status block always goes: it describes a state that no      |
//|  longer exists. The markers only go on a genuine removal, so     |
//|  that a recompile or a timeframe change does not wipe the record |
//|  of what the EA has been doing all session.                      |
//+------------------------------------------------------------------+
void CRmaDisplay::Destroy(const bool markers_too)
  {
   ObjectsDeleteAll(0,m_prefix+"hud",0,-1);
   if(markers_too)
      ObjectsDeleteAll(0,m_prefix+"mk_",0,-1);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
