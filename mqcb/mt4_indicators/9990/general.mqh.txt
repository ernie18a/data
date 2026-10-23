
#property copyright "Emilio Stefano Reale FxTrading"

int dSunday = 0;
int dMonday = 1;
int dThesday = 2;
int dWednesday = 3;
int dThursday = 4;
int dFiriday = 5;
int dSauturday = 6;


#import "general.ex4"
   bool printErr();
   void MyPrint(string str);
   string ErrDesc();
   void SoundMessage(bool SellOrBuy);
   void MBox(string str);
   void drawLabel(string id, string text, int fsize, color fcolor, int x,int y,string font="Arial",int window = 0);
   void NdxLabel(string id, string text, int fsize, color fcolor, int x, double y, string font="Arial",int window = 0);
   void BLLabel(string text);
   int LabelText(int xOffset, int yOffset, string text, int iCorner);
   int CalcMagic();
   int SetBit(int value, int bit);
   bool CheckBit(int value, int bit);
   double ComputePip(int ratio = 1);
   double PipCommission(double commission);
   double commissions();
   datetime dayTime(int h, int m);
   datetime yearTime(int y, int mo, int d, int h, int m);
   string MagicString();
   bool isDownTrend(double m1, double m2);
   bool isUpTrend(double m1, double m2);
   bool isLateral(double m1, double m2);
   int BollingerRange(double v1, double v2, double _pipratio = 1);
   void FileComment(string strComment);
   string ExpertName();
   void WriteLOG(string descr, string value);
   void DeleteLine(string name);
   void CreateLine(string name, int shift1, double val1, int shift2, double val2, int window);
   void CreateSimpleLine(string name, int shift1, double val1, int shift2, double val2, int window);
   void CreateTLRay(string name, int shift1, double val1, int shift2, double val2, int window);
   void CreateLineEx(
      string name, int shift1, double val1, int shift2, double val2, int window, bool ray, double style, double mycolor
      );
   double LineValue(string name, int shift);
   double LineValueP(string name, int shift, int prec);
   int digits();
   double LineValueDgtPip(string name, int shift);
   string ServerTime();
   double   cHigh(int shift);
   double cHighEx(int frame, int shift);
   double   cLow(int shift);
   double cLowEx(int frame, int shift);
   double   cClose(int shift);
   double cCloseEx(int frame, int shift);
   double   cOpen(int shift);
   double cOpenEx(int frame, int shift);
   double   cVolume(int shift);
   double cVolumeEx(int frame, int shift);
   datetime cTime(int shift);
   datetime cTimeEx(int frame, int shift);
   int cBShift(datetime bartime);
   int cBShiftEx(int frame, datetime bartime);
   double RSI(int RSI_PERIOD, int shift);
   double cRSI(int period, int shift);
   void incDArray(double &a[], double v);
   void incIArray(int &a[], int v);
   void HighArray(double &a[], int p);
   void LowArray(double &a[], int p);
   double DivByZero(double dividendo, double divisore);
   double ADX_PLUSDI(int period, int price, int shift);
   double ADX_MINUSDI(int period, int price, int shift);
   double ADX_MAIN(int period, int price, int shift);
   double cADX_MAIN(int period, int shift);
   double cADX_PDI(int period, int shift);
   double cADX_MDI(int period, int shift);
   double TLM(double x1, double y1, double x2, double y2);
   double LWMA(int period, int applied_price, int shift);
   double EMA(int period, int shift);
   double SMA(int period, int shift);
   double EMAClose(int period, int shift);
   double SMMA (int period, int applied_price, int shift);
   double EMAOpen(int period, int shift);
   double EMAMedian(int period, int shift);
   double SMAClose(int period, int shift);
   double SMAMedian(int period, int shift);
   double SMAOpen(int period, int shift);
   double norD(double value, int precision);
   bool Up(int p1, int p2, int shift);
   bool Down(int p1, int p2, int shift);
   bool UpCross(int p1, int p2, int shift);
   bool DownCross(int p1, int p2, int shift);
   double cStochK(int K, int D, int slowing, int shift);
   double cStochD(int K, int D, int slowing, int shift);
   double cBollUpper(int period, int deviation, int bandShift, int shift);
   double cBollLower(int period, int deviation, int bandShift, int shift);
   double cSar(int shift);
   double cEnvelopesUpper(int period, double deviation);
   double cEnvelopesLower(int period, double deviation);
   double cEnvelopesEx(int period, int method,int ma_shift, int applied_price, double deviation, int mode, int shift);
   double cIchimokuTS(int ts, int ks, int ssb, int shift);
   double cIchimokuKS(int ts, int ks, int ssb, int shift);
   double cIchimokuSSA(int ts, int ks, int ssb, int shift);
   double cIchimokuSSB(int ts, int ks, int ssb, int shift);
   double cIchimokuCS(int ts, int ks, int ssb, int shift);
   double cIchimokuEx(int ts, int ks, int ssb, int mode, int shift);
   double cAC(int shift);
   double cACEx(int timeframe, int shift);
   double cOBV(int shift);
   double cOBVEx(int timeframe, int shift);
   double cMFI(int shift);
   double cMFIEx( int timeframe, int period, int shift);
   double cMACDm(int fastema, int slowema, int signalperiod, int shift);
   double cMACDs(int fastema, int slowema, int signalperiod, int shift);
   double cRVIm(int shift);
   double cRVIs(int shift);
   double cOSMA(int shift);
   double cBullsEx(int period, int shift);
   bool osmaUp(int shift);
   bool osmaDw(int shift);
   double cMomentum(int shift);
   bool momentumUp(int shift);
   bool momentumDw(int shift);
   bool isGreenAC(int shift);
   bool isRedAC(int shift);
   bool _MyBuy(int disaster_sl, int disaster_tp, double lots, int magicnumber, int slippage, color clr);
   bool _MySell(int disaster_sl, int disaster_tp, double lots, int magicnumber, int slippage, color clr);
   double _pip(double commissions);
   void PlaySymbolAudio();
   void Play(string file);
   void PlaySymbolAudioAlert();
   void DeleteObjects();
   int magicfile(string filename, string separator);
   double commissionsfile(string filename, string symbol, string separator);
   void SetGbIfNotExist(string name, double value);
   double GetGb(string name, double defaultValue);
   void SetGb (string name , double value);
   int OpenOrder(int type, double pointmul, int StopLoss, int Slippage, string ExpertComment, int MagicNumber, int NumberOfTries, double Lots, int triessleep);
   double Trend3Period(int period, int ema, int shift);
   int Trend3Daily(int EMAS, int EMAM, int EMAL, int shift, int s_spread);

   bool GetOrdByTicket(int ticket);
   int GetOrdType(int ticket);
   double GetOrdPrice(int ticket);
   void OrdCloseAllEx(int magic, bool chkMagic, int Slip, int Wait);
   void OrdCloseAll(int magic, bool chkMagic, int Slip);
   double CalcPIPVal(double PIP, double value);
   int ONum(int mn, bool chkMn);
   void push(int &array[], int value);
   int pop(int &array[]);
   void Push(int value);
   int Pop();
   void init_order_stack();
   int OrderStackCount();
   int GetLastOrderTicket();
   int PointProfit(int order_ticket);
   int CountOrders(int magic);
   int _IsTradeAllowed( int MaxWaiting_sec = 30 );
   void AlertError();
   string ErrorDescription(int error_code);
   int RGB(int red_value,int green_value,int blue_value);
   bool CompareDoubles(double number1,double number2);
   string DoubleToStrMorePrecision(double number,int precision);
   string IntegerToHexString(int integer_number);
   double spread();
   void myPivotEx(string symbol, int period, int shift, double &s1, double &ap, double &s2, double &s3, double &r1, double &r2, double &r3);
   void DrawHLine(string name, double value, int shift, color clr, int style);
   void DailyPivot(string symbol, double &ap, double &s1, double &s2, double &s3, double &r1, double &r2, double &r3, bool draw);
   int calcHigherPeriod( int period = 0);

   // math functions 
   double DivByZero(int a, int b) ;

   // date & time functions
   // le date sono espresse come secondi che passano dall 1/1/1900
   void TimeSpan(datetime d1, datetime d2, int &d, int &h, int &m, int &s);
   double GetNeccessaryLotsWithRisk(int riskPercent, double sl, double price, int& error);

#import



