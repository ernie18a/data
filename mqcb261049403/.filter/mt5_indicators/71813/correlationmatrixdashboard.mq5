//+------------------------------------------------------------------+
//|                                   CorrelationMatrixDashboard.mq5 |
//|              Pearson Correlation Heatmap – On-Chart Bitmap Label |
//|                                      Uses MQL5 matrix.CorrCoef() |
//|              Draggable  |  _ Minimise  |  [] Restore  |  X Close |
//+------------------------------------------------------------------+
#property copyright   "Custom MQL5 Indicator"
#property version     "5.00"
#property indicator_chart_window
#property indicator_plots 0

#include <Canvas\Canvas.mqh>

//--- Inputs
input int  InpBars       = 50;   // Bars for correlation
input int  InpMaxSymbols = 12;   // Max symbols (≤ 12 for readability)
input int  InpPanelX     = 20;   // Starting X (px from left)
input int  InpPanelY     = 40;   // Starting Y (px from top)
input int  InpCellSize   = 46;   // Cell size in pixels (min 36, max 72)

//--- Timer
#define TIMER_SEC  10

//--- Font sizes (pts) — bigger than before for readability
#define FONT_CELL_LG  10   // cell value font when cell >= 44px
#define FONT_CELL_SM   8   // cell value font when cell < 44px
#define FONT_LABEL    9    // axis label font
#define FONT_TITLE    11   // title bar font
#define FONT_TF        9   // timeframe button font
#define FONT_LEGEND    8   // legend font

//--- Panel geometry
#define TITLE_H   28    // title bar height (taller = more readable)
#define BTN_SZ    20    // chrome button size
#define BTN_GAP    4    // gap between chrome buttons
#define MARGIN     8    // content margin
#define LABEL_W   80    // Y-axis label column width (wider for full names)
#define LABEL_H   26    // X-axis label row height
#define TF_H      34    // timeframe bar height
#define TF_BW     52    // TF button width  (4 buttons now)
#define TF_BH     22    // TF button height

//--- Number of timeframe buttons
#define TF_COUNT   4

//--- ARGB colours — brighter and higher contrast than v4
// Background / panel
#define C_BG         0xF2101418   // very dark navy
#define C_TITLEBAR   0xFF16202E   // slightly lighter navy for title
#define C_PANEL      0xF2131820   // panel body
#define C_BORDER     0xFF2E4060   // visible but not harsh border
#define C_GRID_LINE  0xFF1E2D42   // subtle grid divider

// Text
#define C_TITLETXT   0xFFECF0FF   // near-white title
#define C_LABEL      0xFFB0C4E0   // bright grey-blue labels  ← much brighter
#define C_CELLTXT    0xFFFFFFFF   // pure white cell values   ← was dim before
#define C_DIAGTXT    0xFF5A7090   // diagonal dash

// Active row/col highlight
#define C_ACTIVEHL   0xFF1A3050
#define C_ACTIVEEDGE 0xFF5AAAF0   // brighter highlight edge

// Cell fill colours — vivid, clear traffic-light palette
#define C_STPOS      0xFFD93030   // strong positive  r ≥  0.70  bright red
#define C_MODPOS     0xFFB04828   // moderate pos     r ∈ [0.40, 0.70) amber-red
#define C_NEUTRAL    0xFF1E7A3A   // low correlation  |r| < 0.40  bright green
#define C_MODNEG     0xFF2850A0   // moderate neg     r ∈(-0.70,-0.40] blue
#define C_STNEG      0xFF6020C0   // strong negative  r ≤ -0.70  purple
#define C_DIAG       0xFF18222E   // diagonal cell background

// TF buttons
#define C_BTNACT     0xFF3A7FCC   // selected TF button
#define C_BTNIDLE    0xFF1A2840   // unselected TF button
#define C_BTNTXT     0xFFE0ECFF

// Chrome
#define C_CHRBG      0xFF1A2840
#define C_CLOSERED   0xFFBB2828
#define C_CHRTXT     0xFFE0E0E0

//--- Named struct (MQL5 requires named structs)
struct LegendEntry { uint clr; string lbl; };

//+------------------------------------------------------------------+
class CCorrelationDashboard
  {
private:
   CCanvas         m_cv;
   string          m_obj;
   long            m_chart;

   int             m_px, m_py;
   int             m_pw, m_ph;
   int             m_pw_normal, m_ph_normal;
   int             m_cell;
   int             m_gx, m_gy;

   bool            m_mini;

   string          m_sym[];
   int             m_n;
   int             m_active;
   double          m_corr[];

   ENUM_TIMEFRAMES m_tf;
   string          m_tflbl[TF_COUNT];
   ENUM_TIMEFRAMES m_tfval[TF_COUNT];
   int             m_tfsel;

   bool            m_drag;
   int             m_ddx, m_ddy;

   bool            LoadSymbols();
   bool            BuildCorrMatrix();
   void            CalcNormalSize();
   void            ApplySize();
   void            Redraw();
   void            DrawTitleBar();
   void            DrawTFBar();
   void            DrawLabels();
   void            DrawGrid();
   void            DrawCell(int xi,int yi,double r,bool ar,bool ac);
   uint            CellColor(double r);
   string          ShortSym(string s);

   int  XClose()   { return m_pw - BTN_SZ - BTN_GAP; }
   int  XRestore() { return m_pw - BTN_SZ*2 - BTN_GAP*2; }
   int  XMin()     { return m_pw - BTN_SZ*3 - BTN_GAP*3; }
   int  YBtn()     { return (TITLE_H - BTN_SZ)/2; }
   int  XTFBtn(int k) { return MARGIN + k*(TF_BW+5); }

public:
                   CCorrelationDashboard();
                  ~CCorrelationDashboard();
   bool            Init(long chart);
   void            Deinit();
   void            Refresh();
   void            OnClick(int x,int y);
   void            OnMouseMove(int x,int y,bool lbtn);
  };

//+------------------------------------------------------------------+
CCorrelationDashboard::CCorrelationDashboard()
  {
   m_obj       = "CorrDash_BL_" + IntegerToString(ChartID());
   m_chart     = 0;
   m_px        = InpPanelX;
   m_py        = InpPanelY;
   m_pw        = 600;
   m_ph        = 500;
   m_pw_normal = 600;
   m_ph_normal = 500;
   m_cell      = MathMax(36, MathMin(72, InpCellSize));
   m_gx        = MARGIN + LABEL_W;
   m_gy        = TITLE_H + TF_H + LABEL_H + MARGIN;
   m_mini      = false;
   m_n         = 0;
   m_active    = -1;
   m_tfsel     = 0;   // default: D1
   m_drag      = false;
   m_ddx       = 0;
   m_ddy       = 0;

   // 4 timeframes: Daily, H4, H1, M15
   m_tflbl[0]="D1";  m_tfval[0]=PERIOD_D1;
   m_tflbl[1]="H4";  m_tfval[1]=PERIOD_H4;
   m_tflbl[2]="H1";  m_tfval[2]=PERIOD_H1;
   m_tflbl[3]="M15"; m_tfval[3]=PERIOD_M15;
   m_tf = m_tfval[m_tfsel];
  }

CCorrelationDashboard::~CCorrelationDashboard() { Deinit(); }

//+------------------------------------------------------------------+
bool CCorrelationDashboard::Init(long chart)
  {
   m_chart = chart;
   ObjectDelete(m_chart, m_obj);

   if(!m_cv.CreateBitmapLabel(m_chart, 0, m_obj,
                               m_px, m_py, m_pw, m_ph,
                               COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("CorrDash: CreateBitmapLabel failed. err=", GetLastError());
      return false;
     }

   ObjectSetInteger(m_chart, m_obj, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(m_chart, m_obj, OBJPROP_XDISTANCE,  m_px);
   ObjectSetInteger(m_chart, m_obj, OBJPROP_YDISTANCE,  m_py);
   ObjectSetInteger(m_chart, m_obj, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(m_chart, m_obj, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(m_chart, m_obj, OBJPROP_BACK,       false);
   ObjectSetInteger(m_chart, m_obj, OBJPROP_ZORDER,     10);

   Refresh();
   return true;
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::Deinit()
  {
   m_cv.Destroy();
   if(m_chart != 0) ObjectDelete(m_chart, m_obj);
   m_chart = 0;
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::CalcNormalSize()
  {
   int n    = (m_n > 0) ? m_n : 5;
   m_cell   = MathMax(36, MathMin(72, InpCellSize));

   m_pw_normal = MARGIN + LABEL_W + n*m_cell + MARGIN;
   m_ph_normal = TITLE_H + TF_H + LABEL_H + MARGIN + n*m_cell + MARGIN;

   if(m_pw_normal < 320) m_pw_normal = 320;
   if(m_ph_normal < 200) m_ph_normal = 200;

   m_gx = MARGIN + LABEL_W;
   m_gy = TITLE_H + TF_H + LABEL_H + MARGIN;
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::ApplySize()
  {
   if(m_cv.Width() != m_pw || m_cv.Height() != m_ph)
     {
      m_cv.Resize(m_pw, m_ph);
      ObjectSetInteger(m_chart, m_obj, OBJPROP_XSIZE, m_pw);
      ObjectSetInteger(m_chart, m_obj, OBJPROP_YSIZE, m_ph);
     }
  }

//+------------------------------------------------------------------+
bool CCorrelationDashboard::LoadSymbols()
  {
   int total = SymbolsTotal(true);
   int limit = MathMin(total, InpMaxSymbols);
   ArrayResize(m_sym, limit);
   m_n = 0; m_active = -1;
   string cur = Symbol();

   for(int k=0; k<total && m_n<limit; k++)
     {
      string s = SymbolName(k, true);
      if(iBars(s, m_tf) < InpBars+1) continue;
      m_sym[m_n] = s;
      if(s == cur) m_active = m_n;
      m_n++;
     }
   if(m_n < 2) { Print("CorrDash: need ≥2 valid symbols."); return false; }
   ArrayResize(m_sym, m_n);
   return true;
  }

//+------------------------------------------------------------------+
bool CCorrelationDashboard::BuildCorrMatrix()
  {
   int bars = InpBars;
   matrix R;
   R.Resize(bars, m_n);

   for(int col=0; col<m_n; col++)
     {
      double px[];
      ArraySetAsSeries(px, true);
      if(CopyClose(m_sym[col], m_tf, 0, bars+1, px) < bars+1)
        { Print("CorrDash: CopyClose failed for ", m_sym[col]); return false; }
      for(int row=0; row<bars; row++)
        {
         if(px[row+1] <= 0.0) return false;
         R[row][col] = MathLog(px[row] / px[row+1]);
        }
     }

   matrix C = R.CorrCoef(false);

   ArrayResize(m_corr, m_n*m_n);
   for(int i=0; i<m_n; i++)
      for(int j=0; j<m_n; j++)
         m_corr[i*m_n+j] = MathMax(-1.0, MathMin(1.0, C[i][j]));

   return true;
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::Refresh()
  {
   if(!LoadSymbols())     return;
   if(!BuildCorrMatrix()) return;

   CalcNormalSize();

   m_pw = m_pw_normal;
   m_ph = m_mini ? TITLE_H : m_ph_normal;

   ApplySize();
   Redraw();
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::Redraw()
  {
   m_cv.Erase(0x00000000);
   m_cv.FillRectangle(0, 0, m_pw-1, m_ph-1, C_PANEL);
   m_cv.Rectangle(0, 0, m_pw-1, m_ph-1, C_BORDER);

   DrawTitleBar();
   if(!m_mini)
     {
      DrawTFBar();
      DrawLabels();
      DrawGrid();
     }

   m_cv.Update();
   ChartRedraw(m_chart);
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::DrawTitleBar()
  {
   m_cv.FillRectangle(0, 0, m_pw-1, TITLE_H-1, C_TITLEBAR);
   m_cv.Line(0, TITLE_H-1, m_pw-1, TITLE_H-1, C_BORDER);

   // Title
   m_cv.FontSet("Arial Bold", FONT_TITLE, FW_BOLD);
   m_cv.TextOut(MARGIN+2, TITLE_H/2, "CORRELATION MATRIX", C_TITLETXT, TA_LEFT|TA_VCENTER);

   // Timeframe label next to title
   m_cv.FontSet("Arial", FONT_TF, FW_NORMAL);
   string tflabel = "  [" + m_tflbl[m_tfsel] + "]";
   m_cv.TextOut(MARGIN+2+140, TITLE_H/2, tflabel, C_BTNACT, TA_LEFT|TA_VCENTER);

   int by = YBtn();

   // --- Minimise [ _ ] ---
   int mx = XMin();
   m_cv.FillRectangle(mx, by, mx+BTN_SZ-1, by+BTN_SZ-1, C_CHRBG);
   m_cv.Rectangle(mx, by, mx+BTN_SZ-1, by+BTN_SZ-1, C_BORDER);
   m_cv.Line(mx+4, by+BTN_SZ-6, mx+BTN_SZ-5, by+BTN_SZ-6, C_CHRTXT);

   // --- Restore [] ---
   int rx2 = XRestore();
   m_cv.FillRectangle(rx2, by, rx2+BTN_SZ-1, by+BTN_SZ-1, C_CHRBG);
   m_cv.Rectangle(rx2, by, rx2+BTN_SZ-1, by+BTN_SZ-1, C_BORDER);
   m_cv.Rectangle(rx2+4, by+4, rx2+BTN_SZ-5, by+BTN_SZ-5, C_CHRTXT);
   if(m_mini)
      m_cv.FillRectangle(rx2+5, by+5, rx2+BTN_SZ-6, by+BTN_SZ-6, C_CHRTXT);

   // --- Close [X] ---
   int cx = XClose();
   m_cv.FillRectangle(cx, by, cx+BTN_SZ-1, by+BTN_SZ-1, C_CLOSERED);
   m_cv.Rectangle(cx, by, cx+BTN_SZ-1, by+BTN_SZ-1, C_BORDER);
   m_cv.Line(cx+4, by+4, cx+BTN_SZ-5, by+BTN_SZ-5, C_CHRTXT);
   m_cv.Line(cx+BTN_SZ-5, by+4, cx+4, by+BTN_SZ-5, C_CHRTXT);
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::DrawTFBar()
  {
   int ty = TITLE_H;
   m_cv.FillRectangle(1, ty, m_pw-2, ty+TF_H-1, C_BG);
   m_cv.Line(1, ty+TF_H-1, m_pw-2, ty+TF_H-1, C_BORDER);

   m_cv.FontSet("Arial Bold", FONT_TF, FW_BOLD);
   for(int k=0; k<TF_COUNT; k++)
     {
      int bx = XTFBtn(k);
      int by = ty + (TF_H-TF_BH)/2;
      bool sel = (k == m_tfsel);
      m_cv.FillRectangle(bx, by, bx+TF_BW-1, by+TF_BH-1, sel?C_BTNACT:C_BTNIDLE);
      m_cv.Rectangle(bx, by, bx+TF_BW-1, by+TF_BH-1, sel?C_ACTIVEEDGE:C_BORDER);
      m_cv.TextOut(bx+TF_BW/2, by+TF_BH/2, m_tflbl[k], C_BTNTXT, TA_CENTER|TA_VCENTER);
     }

   // --- Legend (5-colour scale, right-aligned) ---
   LegendEntry leg[5];
   leg[0].clr=C_STPOS;   leg[0].lbl="Hi+";
   leg[1].clr=C_MODPOS;  leg[1].lbl="Mo+";
   leg[2].clr=C_NEUTRAL; leg[2].lbl="Low";
   leg[3].clr=C_MODNEG;  leg[3].lbl="Mo-";
   leg[4].clr=C_STNEG;   leg[4].lbl="Hi-";

   m_cv.FontSet("Arial", FONT_LEGEND, FW_NORMAL);
   int lx = m_pw - MARGIN;
   int ly = ty + (TF_H-10)/2;
   int ew = 38;
   for(int k=4; k>=0; k--)
     {
      int ex = lx - (5-k)*ew;
      m_cv.FillRectangle(ex, ly, ex+10, ly+10, leg[k].clr);
      m_cv.Rectangle(ex, ly, ex+10, ly+10, C_BORDER);
      m_cv.TextOut(ex+12, ly, leg[k].lbl, C_LABEL, TA_LEFT|TA_TOP);
     }
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::DrawLabels()
  {
   m_cv.FontSet("Arial Bold", FONT_LABEL, FW_BOLD);

   for(int k=0; k<m_n; k++)
     {
      bool   act = (k == m_active);
      uint   tc  = act ? C_ACTIVEEDGE : C_LABEL;
      string lb  = ShortSym(m_sym[k]);

      // Y-axis (left)
      int ly = m_gy + k*m_cell + m_cell/2;
      if(act)
         m_cv.FillRectangle(1, m_gy+k*m_cell, MARGIN+LABEL_W-2,
                            m_gy+k*m_cell+m_cell-1, C_ACTIVEHL);
      m_cv.TextOut(MARGIN+LABEL_W-5, ly, lb, tc, TA_RIGHT|TA_VCENTER);

      // X-axis (top)
      int lx = m_gx + k*m_cell + m_cell/2;
      int ty = m_gy - LABEL_H/2;
      if(act)
         m_cv.FillRectangle(m_gx+k*m_cell, m_gy-LABEL_H,
                            m_gx+k*m_cell+m_cell-1, m_gy-1, C_ACTIVEHL);
      m_cv.TextOut(lx, ty, lb, tc, TA_CENTER|TA_VCENTER);
     }
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::DrawGrid()
  {
   for(int yi=0; yi<m_n; yi++)
      for(int xi=0; xi<m_n; xi++)
        {
         double r = m_corr[yi*m_n + xi];
         DrawCell(xi, yi, r, yi==m_active, xi==m_active);
        }
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::DrawCell(int xi,int yi,double r,bool ar,bool ac)
  {
   int cx  = m_gx + xi*m_cell;
   int cy  = m_gy + yi*m_cell;
   int cx2 = cx + m_cell - 1;
   int cy2 = cy + m_cell - 1;
   bool diag = (xi == yi);

   // --- Background fill ---
   uint fill;
   if(diag)
      fill = C_DIAG;
   else
     {
      fill = CellColor(r);
      // Brighten active row/col cells slightly
      if(ar || ac)
        {
         int rr = MathMin((int)((fill>>16)&0xFF)+25, 255);
         int gg = MathMin((int)((fill>> 8)&0xFF)+25, 255);
         int bb = MathMin((int)( fill     &0xFF)+35, 255);
         fill = 0xFF000000|((uint)rr<<16)|((uint)gg<<8)|(uint)bb;
        }
     }

   m_cv.FillRectangle(cx+1, cy+1, cx2-1, cy2-1, fill);

   // --- Border: thicker/brighter for active row/col ---
   uint edge = (ar||ac) ? C_ACTIVEEDGE : C_GRID_LINE;
   m_cv.Rectangle(cx+1, cy+1, cx2-1, cy2-1, edge);

   // --- Value text ---
   if(diag)
     {
      // Draw a subtle diagonal dash on diagonal cells
      m_cv.FontSet("Arial Bold", FONT_CELL_LG, FW_BOLD);
      m_cv.TextOut(cx+m_cell/2, cy+m_cell/2, "-", C_DIAGTXT, TA_CENTER|TA_VCENTER);
     }
   else
     {
      string vs = StringFormat("%.2f", r);
      // Choose font size based on cell size
      int fs = (m_cell >= 44) ? FONT_CELL_LG : FONT_CELL_SM;
      m_cv.FontSet("Arial Bold", fs, FW_BOLD);
      m_cv.TextOut(cx+m_cell/2, cy+m_cell/2, vs, C_CELLTXT, TA_CENTER|TA_VCENTER);
     }
  }

//+------------------------------------------------------------------+
//| CellColor – 5-band colour scale for clearer visual differentiation|
//+------------------------------------------------------------------+
uint CCorrelationDashboard::CellColor(double r)
  {
   if     (r >=  0.70)               return C_STPOS;    // strong positive  (red)
   else if(r >=  0.40)               return C_MODPOS;   // moderate positive (amber)
   else if(r >  -0.40)               return C_NEUTRAL;  // low correlation   (green)
   else if(r >  -0.70)               return C_MODNEG;   // moderate negative (blue)
   else                              return C_STNEG;    // strong negative   (purple)
  }

//+------------------------------------------------------------------+
string CCorrelationDashboard::ShortSym(string s)
  {
   // Strip common suffixes like "m", ".", "#" added by some brokers
   string clean = s;
   int len = StringLen(clean);
   if(len > 6)
     {
      string last = StringSubstr(clean, len-1, 1);
      if(last=="m"||last=="."||last=="#"||last=="+")
         clean = StringSubstr(clean, 0, len-1);
     }
   if(StringLen(clean) > 7) clean = StringSubstr(clean, 0, 7);
   return clean;
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::OnClick(int x, int y)
  {
   int rx = x - m_px;
   int ry = y - m_py;
   if(rx<0 || ry<0 || rx>=m_pw || ry>=m_ph) return;
   if(ry>=TITLE_H && m_mini) return;

   //--- Chrome buttons ---
   if(ry < TITLE_H)
     {
      int by = YBtn();
      if(ry < by || ry > by+BTN_SZ) return;

      if(rx >= XClose() && rx <= XClose()+BTN_SZ)
        { Deinit(); return; }

      if(rx >= XRestore() && rx <= XRestore()+BTN_SZ)
        {
         m_mini = !m_mini;
         m_pw = m_pw_normal;
         m_ph = m_mini ? TITLE_H : m_ph_normal;
         ApplySize(); Redraw(); return;
        }

      if(rx >= XMin() && rx <= XMin()+BTN_SZ)
        {
         if(!m_mini)
           {
            m_mini = true;
            m_pw   = m_pw_normal;
            m_ph   = TITLE_H;
            ApplySize(); Redraw();
           }
         return;
        }
      return;
     }

   //--- Timeframe buttons ---
   if(ry >= TITLE_H && ry < TITLE_H+TF_H)
     {
      for(int k=0; k<TF_COUNT; k++)
        {
         int bx = XTFBtn(k);
         int by = TITLE_H + (TF_H-TF_BH)/2;
         if(rx>=bx && rx<=bx+TF_BW && ry>=by && ry<=by+TF_BH)
           {
            if(m_tfsel != k) { m_tfsel=k; m_tf=m_tfval[k]; Refresh(); }
            return;
           }
        }
     }
  }

//+------------------------------------------------------------------+
void CCorrelationDashboard::OnMouseMove(int x, int y, bool lbtn)
  {
   if(!lbtn) { m_drag=false; return; }

   if(!m_drag)
     {
      int rx = x - m_px;
      int ry = y - m_py;
      if(rx<0 || ry<0 || rx>=m_pw || ry>=TITLE_H) return;
      if(rx >= XMin()) return;   // don't start drag on chrome buttons
      m_drag = true;
      m_ddx  = x - m_px;
      m_ddy  = y - m_py;
     }

   m_px = x - m_ddx;
   m_py = y - m_ddy;
   if(m_px < 0) m_px = 0;
   if(m_py < 0) m_py = 0;
   ObjectSetInteger(m_chart, m_obj, OBJPROP_XDISTANCE, m_px);
   ObjectSetInteger(m_chart, m_obj, OBJPROP_YDISTANCE, m_py);
   ChartRedraw(m_chart);
  }

//+------------------------------------------------------------------+
CCorrelationDashboard *g_dash = NULL;

int OnInit()
  {
   g_dash = new CCorrelationDashboard();
   if(!g_dash.Init(ChartID()))
     { delete g_dash; g_dash=NULL; return INIT_FAILED; }
   EventSetTimer(TIMER_SEC);
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 0);
   if(g_dash != NULL) { g_dash.Deinit(); delete g_dash; g_dash=NULL; }
  }

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
   if(prev_calculated==0 && g_dash!=NULL) g_dash.Refresh();
   return rates_total;
  }

void OnTimer()
  {
   if(g_dash != NULL) g_dash.Refresh();
  }

void OnChartEvent(const int id, const long &lp, const double &dp, const string &sp)
  {
   if(g_dash == NULL) return;
   switch(id)
     {
      case CHARTEVENT_CLICK:
         g_dash.OnClick((int)lp, (int)dp);
         break;
      case CHARTEVENT_MOUSE_MOVE:
         g_dash.OnMouseMove((int)lp, (int)dp, (bool)((int)sp & 1));
         break;
      case CHARTEVENT_CHART_CHANGE:
         g_dash.Refresh();
         break;
     }
  }
//+------------------------------------------------------------------+