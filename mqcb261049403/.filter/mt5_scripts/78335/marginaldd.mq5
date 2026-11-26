//+------------------------------------------------------------------+
//|                                                   MarginalDD.mq5 |
//|                  Copyright 2026, Cristian David Castillo Arrieta |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Cristian David Castillo Arrieta"
#property link      "https://www.mql5.com"
#property version   "1.10"
#property description "Measures how much each configuration adds to the realized drawdown."
#property script_show_inputs

//--- data source for the analysis
enum ENUM_MDD_SOURCE
  {
   SOURCE_DEMO=0,                                  // Built-in demonstration portfolio
   SOURCE_ACCOUNT=1,                               // Trading deals of the current account
   SOURCE_CSV=2                                    // CSV file in MQL5\Files
  };
//--- how account deals are grouped into configurations
enum ENUM_MDD_GROUP
  {
   GROUP_MAGIC=0,                                  // One configuration per magic number
   GROUP_MAGIC_SYMBOL=1                            // One configuration per magic and symbol
  };
//--- diagnostic flag assigned to each configuration
enum ENUM_MDD_FLAG
  {
   FLAG_NEUTRAL=0,                                 // No flag raised
   FLAG_OFFSET=1,                                  // Profit, DD deeper without it
   FLAG_OVERWEIGHT=2,                              // Profit, risk share >> profit share
   FLAG_LOSS_HEDGE=3,                              // Loss, DD deeper without it
   FLAG_DRAG=4                                     // Loss, DD shallower without it
  };

//--- input parameters
input ENUM_MDD_SOURCE InpSource=SOURCE_DEMO;       // Data source
input ENUM_MDD_GROUP  InpGroupBy=GROUP_MAGIC;      // Grouping of account deals
input datetime        InpFromDate=D'2020.01.01';   // First date of account history
input string          InpCsvFile="MarginalDD.csv"; // CSV file (Date,Config,Profit), UTF-8
input int             InpMinDays=60;               // Technical minimum of days in the calendar
input int             InpRobustDays=250;           // Days below which results are PRELIMINARY
input int             InpEpisodes=3;               // Deepest drawdown episodes for Worst3%
input double          InpExcessShare=10.0;         // Var% minus Net% (points) for OVERWEIGHT
input double          InpImproveMin=5.0;           // Net/DD gain (%) without it for OVERWEIGHT
input double          InpMaxWindowShare=35.0;      // Episode share (%) that triggers a check
input double          InpCompTarget=5.0;           // Compression giving a full score (> 1)
input double          InpNeffTarget=8.0;           // Contributors for a full score (> 1)
input double          InpDragTol=0.25;             // DRAG share giving a zero score (> 0)
input double          InpRetDDTarget=6.0;          // Net/DD giving a full score (> 0)
input double          InpWCompression=1.0;         // Weight: drawdown compression (>= 0)
input double          InpWSpread=1.0;              // Weight: risk spread (>= 0)
input double          InpWDrag=1.0;                // Weight: drag penalty (>= 0)
input double          InpWRetDD=1.0;               // Weight: net profit / drawdown (>= 0)
input double          InpGradeAPlus=90.0;          // Minimum score for A+
input double          InpGradeA=80.0;              // Minimum score for A
input double          InpGradeB=70.0;              // Minimum score for B
input double          InpGradeC=60.0;              // Minimum score for C
input double          InpGradeD=50.0;              // Minimum score for D

//--- results for one configuration
struct SConfigResult
  {
   string            name;                         // Configuration label
   double            net;                          // Realized net result over the sample
   double            ddAlone;                      // Standalone realized maximum drawdown
   double            ddWithout;                    // Portfolio realized max DD without it
   double            netWithout;                   // Portfolio net result without it
   double            addedDD;                      // Portfolio DD minus DD without it
   double            windowShare;                  // Share of the deepest episode's loss
   double            episodeShare;                 // Share of the K deepest episodes
   double            varShare;                     // Euler share of portfolio variance
   double            profitShare;                  // Share of portfolio net profit
   int               flag;                         // ENUM_MDD_FLAG value
   int               stable;                       // 1 stable, 0 unstable, -1 not tested
  };

//--- raw records before they are aggregated into the daily matrix
datetime      g_recDay[];                          // Calendar day of each record
string        g_recKey[];                          // Configuration label of each record
double        g_recPnl[];                          // Realized result of each record
//--- aggregated daily matrix
string        g_names[];                           // Configuration labels
datetime      g_days[];                            // Calendar: all weekdays included
double        g_pnl[];                             // Daily P&L, index = config * days + day
int           g_nCfg=0;                            // Number of configurations
int           g_nDays=0;                           // Number of days in the calendar
uint          g_rng=0;                             // Xorshift32 state for the demo
SConfigResult g_res[];                             // Results, one per configuration

//+------------------------------------------------------------------+
//| Adds one raw record. The time is truncated to midnight, so all   |
//| records of one trade-server calendar day fall into one cell.     |
//+------------------------------------------------------------------+
void AddRecord(const datetime time,const string key,const double pnl)
  {
   int n=ArraySize(g_recDay);
   ArrayResize(g_recDay,n+1,4096);
   ArrayResize(g_recKey,n+1,4096);
   ArrayResize(g_recPnl,n+1,4096);
   g_recDay[n]=(datetime)((long)time/86400*86400); // truncate to midnight
   g_recKey[n]=key;
   g_recPnl[n]=pnl;
  }
//+------------------------------------------------------------------+
//| Checks the input ranges that the formulas depend on              |
//+------------------------------------------------------------------+
bool ValidateInputs()
  {
   string err="";
   if(InpMinDays<2)
      err="InpMinDays must be at least 2";
   if(InpRobustDays<InpMinDays)
      err="InpRobustDays must not be below InpMinDays";
   if(InpEpisodes<1)
      err="InpEpisodes must be at least 1";
   if(InpExcessShare<0.0 || InpImproveMin<0.0 || InpMaxWindowShare<=0.0)
      err="InpExcessShare and InpImproveMin must be >= 0, InpMaxWindowShare > 0";
   if(InpCompTarget<=1.0 || InpNeffTarget<=1.0)
      err="InpCompTarget and InpNeffTarget must be greater than 1";
   if(InpDragTol<=0.0 || InpRetDDTarget<=0.0)
      err="InpDragTol and InpRetDDTarget must be greater than 0";
   if(InpWCompression<0.0 || InpWSpread<0.0 || InpWDrag<0.0 || InpWRetDD<0.0)
      err="Score weights must not be negative";
   if(InpWCompression+InpWSpread+InpWDrag+InpWRetDD<=0.0)
      err="At least one score weight must be positive";
   if(!(InpGradeAPlus>=InpGradeA && InpGradeA>=InpGradeB && InpGradeB>=InpGradeC &&
        InpGradeC>=InpGradeD))
      err="Grade boundaries must decrease from A+ to D";
   if(err!="")
      Print("Error: ",err);
   return(err=="");
  }
//+------------------------------------------------------------------+
//| Returns the next uniform number in (0, 1) from xorshift32        |
//+------------------------------------------------------------------+
double NextUniform()
  {
   g_rng^=(g_rng<<13);
   g_rng^=(g_rng>>17);
   g_rng^=(g_rng<<5);
   return(((double)g_rng+0.5)/4294967296.0);
  }
//+------------------------------------------------------------------+
//| Returns a standard normal number (Box-Muller transform)          |
//+------------------------------------------------------------------+
double NextGauss()
  {
   double u1=NextUniform();
   double u2=NextUniform();
   return(MathSqrt(-2.0*MathLog(u1))*MathCos(2.0*M_PI*u2));
  }
//+------------------------------------------------------------------+
//| Builds a reproducible demo book of 12 configurations that share  |
//| four market factors over 520 trading days.                       |
//+------------------------------------------------------------------+
bool LoadDemo()
  {
//--- label, mean daily result, volatility, factor, factor loading, activity
   string names[12]={"EURUSD H1 A","EURUSD H4 B","GBPUSD H1 A","GBPUSD H4 B",
                     "AUDUSD H1 A","USDJPY H1 A","XAUUSD H1 A","XAUUSD M30 B",
                     "US500 H1 A","US500 H4 B","NAS100 H1 A","USDCHF H4 A"};
   double mu[12]   ={3.6,2.8,3.2,2.4,-0.8,2.8,6.0,5.6,3.6,2.8,4.0,2.0};
   double sigma[12]={60,45,65,40,50,55,150,140,70,55,80,40};
   int    fac[12]  ={0,0,0,0,0,3,1,1,2,2,2,3};
   double beta[12] ={0.55,0.55,0.55,0.40,0.30,0.20,0.80,0.80,0.60,-0.45,0.60,0.20};
   double act[12]  ={0.70,0.55,0.65,0.50,0.60,0.60,0.75,0.80,0.65,0.55,0.70,0.50};
   g_rng=20261012; // fixed seed: same report every run
   datetime day=D'2024.01.01';
   for(int d=0; d<520; d++)
     {
      //--- skip weekends so the calendar looks like a trading calendar
      MqlDateTime dt;
      TimeToStruct(day,dt);
      while(dt.day_of_week==0 || dt.day_of_week==6)
        {
         day+=86400;
         TimeToStruct(day,dt);
        }
      //--- four shared factors: FX majors, gold, US indices, yen and franc
      double f[4];
      for(int k=0; k<4; k++)
         f[k]=NextGauss();
      for(int c=0; c<12; c++)
        {
         double e=NextGauss();
         double u=NextUniform();
         double pnl=0.0;
         //--- the configuration trades on this day only with probability act[c]
         if(u<act[c])
            pnl=mu[c]/act[c]+sigma[c]*(beta[c]*f[fac[c]]+MathSqrt(1.0-beta[c]*beta[c])*e);
         AddRecord(day,names[c],pnl);
        }
      day+=86400;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Binary search of a position in the sorted map [position, magic]. |
//| Returns the magic, -1 for a position opened by several magics,   |
//| or 0 when the position is not in the map.                        |
//+------------------------------------------------------------------+
long FindOpeningMagic(const long &map[][2],const long pos)
  {
   int lo=0,hi=ArrayRange(map,0)-1;
   while(lo<=hi)
     {
      int mid=(lo+hi)/2;
      if(map[mid][0]==pos)
         return(map[mid][1]);
      if(map[mid][0]<pos)
         lo=mid+1;
      else
         hi=mid-1;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Reads the trading deals of the account and groups them. The      |
//| result of a deal is profit + swap + commission + fee, so entry   |
//| deals add their costs and exit deals add their realized profit.  |
//+------------------------------------------------------------------+
bool LoadAccount()
  {
//--- the whole history is selected, so a position opened before InpFromDate is still found
   if(!HistorySelect(0,TimeCurrent()))
     {
      Print("Error: HistorySelect failed, code ",GetLastError());
      return(false);
     }
   int total=HistoryDealsTotal();
//--- first pass: [position, magic] of every entry deal with a non-zero magic
   long raw[][2];
   int  nRaw=0;
   for(int i=0; i<total; i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0 || HistoryDealGetInteger(ticket,DEAL_ENTRY)!=DEAL_ENTRY_IN)
         continue;
      long magicIn=HistoryDealGetInteger(ticket,DEAL_MAGIC);
      if(magicIn==0)
         continue;
      ArrayResize(raw,nRaw+1,1024);
      raw[nRaw][0]=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
      raw[nRaw][1]=magicIn;
      nRaw++;
     }
   ArraySort(raw); // sorts the rows by position
//--- one row per position; -1 marks a position opened by different magics
   long map[][2];
   int  nMap=0,mixed=0;
   for(int i=0; i<nRaw; i++)
     {
      if(nMap>0 && map[nMap-1][0]==raw[i][0])
        {
         if(map[nMap-1][1]!=raw[i][1] && map[nMap-1][1]!=-1)
           {
            map[nMap-1][1]=-1;
            mixed++;
           }
         continue;
        }
      ArrayResize(map,nMap+1,1024);
      map[nMap][0]=raw[i][0];
      map[nMap][1]=raw[i][1];
      nMap++;
     }
//--- second pass: one record per trading deal inside the selected period
   int reassigned=0,unassigned=0;
   for(int i=0; i<total; i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
         continue;
      //--- keep trading deals only: balance, credit and bonus entries are skipped
      long type=HistoryDealGetInteger(ticket,DEAL_TYPE);
      if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
         continue;
      datetime time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      if(time<InpFromDate)
         continue;
      double pnl=HistoryDealGetDouble(ticket,DEAL_PROFIT)+
                 HistoryDealGetDouble(ticket,DEAL_SWAP)+
                 HistoryDealGetDouble(ticket,DEAL_COMMISSION)+
                 HistoryDealGetDouble(ticket,DEAL_FEE);
      long   magic=HistoryDealGetInteger(ticket,DEAL_MAGIC);
      string key="";
      //--- a manual close has magic 0: use the magic of the deal that opened the position
      if(magic==0)
        {
         long found=FindOpeningMagic(map,HistoryDealGetInteger(ticket,DEAL_POSITION_ID));
         if(found>0)
           {
            magic=found;
            reassigned++;
           }
         else
           {
            key=(found==-1 ? "Magic 0 mixed" : "Magic 0 unassigned");
            unassigned++;
           }
        }
      if(key=="")
         key="Magic "+IntegerToString(magic);
      if(InpGroupBy==GROUP_MAGIC_SYMBOL)
         key+=" "+HistoryDealGetString(ticket,DEAL_SYMBOL);
      AddRecord(time,key,pnl);
     }
//--- report every attribution compromise in the log
   if(reassigned>0)
      PrintFormat("Note: %d magic-0 deals were assigned to their opening magic",reassigned);
   if(unassigned>0)
      PrintFormat("Warning: %d magic-0 deals have no single opening magic; "+
                  "they form their own configuration",unassigned);
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_NETTING)
      PrintFormat("Warning: netting account; %d positions were opened by several magics, "+
                  "so their results cannot be split exactly",mixed);
   return(true);
  }
//+------------------------------------------------------------------+
//| Splits one CSV line into fields. A separator inside double       |
//| quotes belongs to the field, and "" inside quotes is one quote.  |
//+------------------------------------------------------------------+
int SplitCsv(const string line,const ushort sep,string &fields[])
  {
   ArrayResize(fields,0,8);
   string cur="";
   bool   inQuotes=false;
   int    len=StringLen(line);
   for(int i=0; i<len; i++)
     {
      ushort ch=StringGetCharacter(line,i);
      if(ch=='"')
        {
         if(inQuotes && i+1<len && StringGetCharacter(line,i+1)=='"')
           {
            cur+="\"";
            i++;
           }
         else
            inQuotes=!inQuotes;
         continue;
        }
      if(ch==sep && !inQuotes)
        {
         int k=ArraySize(fields);
         ArrayResize(fields,k+1,8);
         fields[k]=cur;
         cur="";
         continue;
        }
      cur+=ShortToString(ch);
     }
   int k=ArraySize(fields);
   ArrayResize(fields,k+1,8);
   fields[k]=cur;
   return(k+1);
  }
//+------------------------------------------------------------------+
//| Converts a number field into a double. In a comma-separated file |
//| a comma can only appear inside quotes, so it groups thousands    |
//| and the dot is the decimal point. In a semicolon-separated file  |
//| the last of the two marks is the decimal point and the other one |
//| groups thousands. Returns false unless the text is one number.   |
//+------------------------------------------------------------------+
bool ParseNumber(string text,const bool commaDecimal,double &value)
  {
   StringReplace(text," ","");
   StringReplace(text,ShortToString(0x00A0),"");  // non-breaking space
   StringReplace(text,"'","");
   StringReplace(text,ShortToString(0x2212),"-"); // Unicode minus sign
   bool negative=false;
   int  len=StringLen(text);
   if(len>2 && StringGetCharacter(text,0)=='(' && StringGetCharacter(text,len-1)==')')
     {
      negative=true;
      text=StringSubstr(text,1,len-2);
     }
   int lastDot=-1,lastComma=-1;
   for(int i=0; i<StringLen(text); i++)
     {
      ushort ch=StringGetCharacter(text,i);
      if(ch=='.')
         lastDot=i;
      if(ch==',')
         lastComma=i;
     }
   if(commaDecimal && lastComma>lastDot)
     {
      StringReplace(text,".","");                 // dots group thousands
      StringReplace(text,",",".");
     }
   else
      StringReplace(text,",","");                 // commas group thousands
//--- an optional leading minus, digits, at most one dot, at least one digit
   int digits=0,dots=0;
   len=StringLen(text);
   for(int i=0; i<len; i++)
     {
      ushort ch=StringGetCharacter(text,i);
      if(ch>='0' && ch<='9')
         digits++;
      else
         if(ch=='.')
            dots++;
         else
            if(!(ch=='-' && i==0))
               return(false);
     }
   if(digits==0 || dots>1)
      return(false);
   value=StringToDouble(text);
   if(negative)
      value=-value;
   return(true);
  }
//+------------------------------------------------------------------+
//| Reads a UTF-8 CSV with the header Date,Config,Profit. The        |
//| separator (comma or semicolon) is taken from the header.         |
//+------------------------------------------------------------------+
bool LoadCsv()
  {
   int h=FileOpen(InpCsvFile,FILE_READ|FILE_TXT|FILE_ANSI,'\t',CP_UTF8);
   if(h==INVALID_HANDLE)
     {
      Print("Error: cannot open ",InpCsvFile," in MQL5\\Files, code ",GetLastError());
      return(false);
     }
   int    line=0;
   int    skipped=0;
   ushort sep=',';
   while(!FileIsEnding(h))
     {
      //--- in FILE_TXT mode, FileReadString returns one whole line
      string s=FileReadString(h);
      line++;
      StringTrimLeft(s);
      StringTrimRight(s);
      if(line==1)
        {
         //--- drop a UTF-8 byte order mark; a semicolon in the header sets the separator
         StringReplace(s,ShortToString(0xFEFF),"");
         if(StringFind(s,";")>=0)
            sep=';';
         continue;
        }
      if(s=="")
         continue;                     // blank line
      string parts[];
      if(SplitCsv(s,sep,parts)!=3)
        {
         skipped++;
         continue;
        }
      for(int k=0; k<3; k++)
        {
         StringTrimLeft(parts[k]);
         StringTrimRight(parts[k]);
        }
      StringReplace(parts[0],"-","."); // 2024-01-05 is read as 2024.01.05
      datetime t=StringToTime(parts[0]);
      double   pnl=0.0;
      if(t<=0 || parts[1]=="" || !ParseNumber(parts[2],sep==';',pnl))
        {
         skipped++;
         continue;
        }
      AddRecord(t,parts[1],pnl);
     }
   FileClose(h);
   if(skipped>0)
      PrintFormat("Note: %d malformed CSV rows were skipped",skipped);
   return(true);
  }
//+------------------------------------------------------------------+
//| Binary search of a day in the sorted array g_days                |
//+------------------------------------------------------------------+
int FindDay(const datetime day)
  {
   int lo=0,hi=g_nDays-1;
   while(lo<=hi)
     {
      int mid=(lo+hi)/2;
      if(g_days[mid]==day)
         return(mid);
      if(g_days[mid]<day)
         lo=mid+1;
      else
         hi=mid-1;
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//| Aggregates the raw records into a configuration x day matrix.    |
//| The calendar holds every weekday from the first to the last      |
//| record, plus any weekend day with records, so days without       |
//| trades enter the statistics as zero results.                     |
//+------------------------------------------------------------------+
bool BuildMatrix()
  {
   int n=ArraySize(g_recDay);
   if(n==0)
      return(false);
//--- sorted copy of the record days, used for the range and for weekend days
   datetime tmp[];
   ArrayCopy(tmp,g_recDay);
   ArraySort(tmp);
   ArrayResize(g_days,0,1024);
   int j=0;
   for(datetime day=tmp[0]; day<=tmp[n-1]; day+=86400)
     {
      MqlDateTime dt;
      TimeToStruct(day,dt);
      bool weekday=(dt.day_of_week>=1 && dt.day_of_week<=5);
      while(j<n && tmp[j]<day)
         j++;
      bool hasRecord=(j<n && tmp[j]==day);
      if(weekday || hasRecord)
        {
         int k=ArraySize(g_days);
         ArrayResize(g_days,k+1,1024);
         g_days[k]=day;
        }
     }
   g_nDays=ArraySize(g_days);
//--- list of unique configuration labels, in order of first appearance
   ArrayResize(g_names,0,64);
   int idx[];
   ArrayResize(idx,n);
   for(int i=0; i<n; i++)
     {
      int found=-1;
      for(int c=0; c<ArraySize(g_names); c++)
         if(g_names[c]==g_recKey[i])
           {
            found=c;
            break;
           }
      if(found<0)
        {
         found=ArraySize(g_names);
         ArrayResize(g_names,found+1,64);
         g_names[found]=g_recKey[i];
        }
      idx[i]=found;
     }
   g_nCfg=ArraySize(g_names);
//--- several records of one configuration on one day are summed
   ArrayResize(g_pnl,g_nCfg*g_nDays);
   ArrayInitialize(g_pnl,0.0);
   for(int i=0; i<n; i++)
     {
      int d=FindDay(g_recDay[i]);
      g_pnl[idx[i]*g_nDays+d]+=g_recPnl[i];
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Maximum drawdown of a daily P&L series, measured in money from   |
//| the running peak of the cumulative curve (which starts at zero). |
//| peak = last day before the decline (-1 = start), trough = bottom |
//+------------------------------------------------------------------+
double MaxDrawdown(const double &x[],int &peak,int &trough)
  {
   double eq=0.0,top=0.0,dd=0.0;
   int    topIdx=-1;
   peak=-1;
   trough=-1;
   for(int i=0; i<ArraySize(x); i++)
     {
      eq+=x[i];
      if(eq>top)
        {
         top=eq;
         topIdx=i;
        }
      if(top-eq>dd)
        {
         dd=top-eq;
         peak=topIdx;
         trough=i;
        }
     }
   return(dd);
  }
//+------------------------------------------------------------------+
//| Splits the curve of x into drawdown episodes (from a peak to the |
//| next recovery) and returns the k deepest ones, deepest first.    |
//+------------------------------------------------------------------+
int DeepestEpisodes(const double &x[],const int k,int &peaks[],int &troughs[],double &depths[])
  {
   double ep[],ed[];
   int    ePk[],eTr[];
   int    nEp=0;
   double eq=0.0,top=0.0,depth=0.0;
   int    topIdx=-1,trIdx=-1;
   int    n=ArraySize(x);
   for(int i=0; i<=n; i++)
     {
      bool closeNow=(i==n);
      if(i<n)
        {
         eq+=x[i];
         if(eq>=top)
            closeNow=true; // recovery or a new high ends an episode
         else
            if(top-eq>depth)
              {
               depth=top-eq;
               trIdx=i;
              }
        }
      if(closeNow && depth>0.0)
        {
         ArrayResize(ed,nEp+1,64);
         ArrayResize(ePk,nEp+1,64);
         ArrayResize(eTr,nEp+1,64);
         ed[nEp]=depth;
         ePk[nEp]=topIdx;
         eTr[nEp]=trIdx;
         nEp++;
         depth=0.0;
        }
      if(i<n && eq>top)
        {
         top=eq;           // same peak rule as MaxDrawdown()
         topIdx=i;
        }
     }
//--- selection of the k deepest episodes
   int m=MathMin(k,nEp);
   ArrayResize(peaks,m);
   ArrayResize(troughs,m);
   ArrayResize(depths,m);
   bool used[];
   ArrayResize(used,nEp);
   ArrayInitialize(used,false);
   for(int s=0; s<m; s++)
     {
      int best=-1;
      for(int e=0; e<nEp; e++)
         if(!used[e] && (best<0 || ed[e]>ed[best]))
            best=e;
      used[best]=true;
      peaks[s]=ePk[best];
      troughs[s]=eTr[best];
      depths[s]=ed[best];
     }
   return(m);
  }
//+------------------------------------------------------------------+
//| Copies days [from, to) of one configuration, or of the whole     |
//| portfolio when c = -1, into x                                    |
//+------------------------------------------------------------------+
void GetSeries(const int c,const int from,const int to,double &x[])
  {
   ArrayResize(x,to-from);
   ArrayInitialize(x,0.0);
   for(int d=from; d<to; d++)
      for(int k=0; k<g_nCfg; k++)
         if(c<0 || c==k)
            x[d-from]+=g_pnl[k*g_nDays+d];
  }
//+------------------------------------------------------------------+
//| Sum of a series                                                  |
//+------------------------------------------------------------------+
double SumOf(const double &x[])
  {
   double s=0.0;
   for(int i=0; i<ArraySize(x); i++)
      s+=x[i];
   return(s);
  }
//+------------------------------------------------------------------+
//| Sample covariance of two series of the same length               |
//+------------------------------------------------------------------+
double Covariance(const double &x[],const double &p[])
  {
   int    n=ArraySize(x);
   double mx=SumOf(x)/n,mp=SumOf(p)/n,s=0.0;
   for(int i=0; i<n; i++)
      s+=(x[i]-mx)*(p[i]-mp);
   return(s/(n-1));
  }
//+------------------------------------------------------------------+
//| Leave-one-out DD, Euler share and profit share of configuration  |
//| c over the days [from, to). Returns false when the portfolio has |
//| no variance in that range; netP receives the portfolio result.   |
//+------------------------------------------------------------------+
bool Contribution(const int c,const int from,const int to,
                  double &added,double &varShare,double &profitShare,double &netP)
  {
   double p[],x[],rest[];
   GetSeries(-1,from,to,p);
   GetSeries(c,from,to,x);
   ArrayResize(rest,to-from);
   for(int d=0; d<to-from; d++)
      rest[d]=p[d]-x[d];
   int pk,tr;
   added=MaxDrawdown(p,pk,tr)-MaxDrawdown(rest,pk,tr);
   netP=SumOf(p);
   profitShare=(netP>0.0 ? SumOf(x)/netP : 0.0);
   double varP=Covariance(p,p);
   if(varP<=0.0)
      return(false);
   varShare=Covariance(x,p)/varP;
   return(true);
  }
//+------------------------------------------------------------------+
//| Computes every measure, flag and stability check                 |
//+------------------------------------------------------------------+
void Analyze(const double ddP,const double netP,const int wFrom,const int wTo,
             const int &epPk[],const int &epTr[],const double epSum)
  {
   ArrayResize(g_res,g_nCfg);
   double ratioP=(netP>0.0 ? netP/ddP : 0.0);
   int    half=g_nDays/2;
   bool   halves=(half>=InpMinDays);          // each half must meet the minimum
   double x[],rest[],p[];
   GetSeries(-1,0,g_nDays,p);
   for(int c=0; c<g_nCfg; c++)
     {
      int pk,tr;
      GetSeries(c,0,g_nDays,x);
      g_res[c].name=g_names[c];
      g_res[c].net=SumOf(x);
      g_res[c].ddAlone=MaxDrawdown(x,pk,tr);
      ArrayResize(rest,g_nDays);
      for(int d=0; d<g_nDays; d++)
         rest[d]=p[d]-x[d];
      g_res[c].ddWithout=MaxDrawdown(rest,pk,tr);
      g_res[c].netWithout=netP-g_res[c].net;
      double dummy=0.0;
      Contribution(c,0,g_nDays,g_res[c].addedDD,g_res[c].varShare,g_res[c].profitShare,dummy);
      //--- result inside the deepest episode and inside the K deepest episodes
      double inWin=0.0,inEp=0.0;
      for(int d=wFrom; d<=wTo; d++)
         inWin+=x[d];
      for(int e=0; e<ArraySize(epPk); e++)
         for(int d=epPk[e]+1; d<=epTr[e]; d++)
            inEp+=x[d];
      g_res[c].windowShare=-inWin/ddP;
      g_res[c].episodeShare=-inEp/epSum;
      //--- flags: the sign of the result first, then the drawdown effect
      bool overweight=false;
      if(netP>0.0)
        {
         double excess=100.0*(g_res[c].varShare-g_res[c].profitShare);
         bool   better=false;
         if(g_res[c].ddWithout<=0.0)
            better=(g_res[c].netWithout>0.0); // removal leaves no realized drawdown
         else
            better=(g_res[c].netWithout/g_res[c].ddWithout>(1.0+InpImproveMin/100.0)*ratioP);
         overweight=(excess>InpExcessShare || better);
        }
      if(g_res[c].net<=0.0)
         g_res[c].flag=(g_res[c].addedDD>0.0 ? FLAG_DRAG : FLAG_LOSS_HEDGE);
      else
         if(overweight)
            g_res[c].flag=FLAG_OVERWEIGHT;
         else
            g_res[c].flag=(g_res[c].addedDD<0.0 ? FLAG_OFFSET : FLAG_NEUTRAL);
      //--- stability: the flag's evidence must hold in both halves of the sample
      g_res[c].stable=-1;
      if(halves && g_res[c].flag!=FLAG_NEUTRAL)
        {
         double a1=0,v1=0,s1=0,n1=0,a2=0,v2=0,s2=0,n2=0;
         bool ok1=Contribution(c,0,half,a1,v1,s1,n1);
         bool ok2=Contribution(c,half,g_nDays,a2,v2,s2,n2);
         bool same=false;
         if(g_res[c].flag==FLAG_OVERWEIGHT)
            same=(ok1 && ok2 && n1>0.0 && n2>0.0 && v1>s1 && v2>s2);
         else
            same=(a1*g_res[c].addedDD>0.0 && a2*g_res[c].addedDD>0.0);
         g_res[c].stable=(same ? 1 : 0);
        }
     }
  }
//+------------------------------------------------------------------+
//| Clamps a value to the [0, 1] interval                            |
//+------------------------------------------------------------------+
double Clamp01(const double v)
  {
   return(MathMax(0.0,MathMin(1.0,v)));
  }
//+------------------------------------------------------------------+
//| Converts a 0-100 score into a letter grade                       |
//+------------------------------------------------------------------+
string Grade(const double score)
  {
   if(score>=InpGradeAPlus)
      return("A+");
   if(score>=InpGradeA)
      return("A");
   if(score>=InpGradeB)
      return("B");
   if(score>=InpGradeC)
      return("C");
   if(score>=InpGradeD)
      return("D");
   return("F");
  }
//+------------------------------------------------------------------+
//| Text label of a flag                                             |
//+------------------------------------------------------------------+
string FlagText(const int f)
  {
   switch(f)
     {
      case FLAG_OFFSET:
         return("OFFSET");
      case FLAG_OVERWEIGHT:
         return("OVERWEIGHT");
      case FLAG_LOSS_HEDGE:
         return("LOSS-HEDGE");
      case FLAG_DRAG:
         return("DRAG");
     }
   return("-");
  }
//+------------------------------------------------------------------+
//| Text label of a stability result                                 |
//+------------------------------------------------------------------+
string StableText(const int s)
  {
   if(s==1)
      return("yes");
   if(s==0)
      return("no");
   return("-");
  }
//+------------------------------------------------------------------+
//| Prints the contribution table, sorted by drawdown added          |
//+------------------------------------------------------------------+
void PrintTable(const bool hasProfit,int &order[])
  {
   ArrayResize(order,g_nCfg);
   for(int c=0; c<g_nCfg; c++)
      order[c]=c;
   for(int i=0; i<g_nCfg-1; i++)
      for(int j=i+1; j<g_nCfg; j++)
         if(g_res[order[j]].addedDD>g_res[order[i]].addedDD)
           {
            int t=order[i];
            order[i]=order[j];
            order[j]=t;
           }
   Print("--- Contribution by configuration (sorted by drawdown added) ---");
   PrintFormat("%-13s %9s %8s %8s %6s %7s %6s %6s  %-10s %s","Config","Net","DDalone",
               "DDadded","Worst%",StringFormat("Worst%d%%",InpEpisodes),"Var%","Net%",
               "Flag","Stable");
   for(int i=0; i<g_nCfg; i++)
     {
      int    c=order[i];
      string netShare="   n/a";
      if(hasProfit)
         netShare=StringFormat("%6.1f",100.0*g_res[c].profitShare);
      PrintFormat("%-13s %9.2f %8.2f %8.2f %6.1f %7.1f %6.1f %s  %-10s %s",g_res[c].name,
                  g_res[c].net,g_res[c].ddAlone,g_res[c].addedDD,100.0*g_res[c].windowShare,
                  100.0*g_res[c].episodeShare,100.0*g_res[c].varShare,netShare,
                  FlagText(g_res[c].flag),StableText(g_res[c].stable));
     }
  }
//+------------------------------------------------------------------+
//| Computes and prints the heuristic composite score                |
//+------------------------------------------------------------------+
void PrintScore(const double sumAlone,const double ddP,const double netP,const bool prelim)
  {
//--- effective number of risk contributors from the positive Euler shares
   double sumPos=0.0,sumSq=0.0;
   int    nDrag=0;
   for(int c=0; c<g_nCfg; c++)
     {
      sumPos+=MathMax(g_res[c].varShare,0.0);
      if(g_res[c].flag==FLAG_DRAG)
         nDrag++;
     }
   for(int c=0; c<g_nCfg && sumPos>0.0; c++)
     {
      double w=MathMax(g_res[c].varShare,0.0)/sumPos;
      sumSq+=w*w;
     }
   double nEff=(sumSq>0.0 ? 1.0/sumSq : 0.0);
   double dragShare=(double)nDrag/g_nCfg;
//--- four dimensions, each scaled to [0, 1]; the weights are non-negative
   double sComp =Clamp01((sumAlone/ddP-1.0)/(InpCompTarget-1.0));
   double sSprd =Clamp01((nEff-1.0)/(InpNeffTarget-1.0));
   double sDrag =Clamp01(1.0-dragShare/InpDragTol);
   double sRetDD=Clamp01((netP/ddP)/InpRetDDTarget);
   double wSum  =InpWCompression+InpWSpread+InpWDrag+InpWRetDD;
   double score =100.0*(InpWCompression*sComp+InpWSpread*sSprd+
                        InpWDrag*sDrag+InpWRetDD*sRetDD)/wSum;
   Print("--- Composite score (heuristic, no statistical interpretation) ---");
   PrintFormat("Drawdown compression %.2fx -> %.2f",sumAlone/ddP,sComp);
   PrintFormat("Risk spread (effective contributors %.2f of %d) -> %.2f",nEff,g_nCfg,sSprd);
   PrintFormat("Drag penalty (%d of %d configurations flagged DRAG) -> %.2f",
               nDrag,g_nCfg,sDrag);
   PrintFormat("Net profit / realized max drawdown %.2f -> %.2f",netP/ddP,sRetDD);
   PrintFormat("Score %.1f / 100, grade %s%s",score,Grade(score),
               (prelim ? " (PRELIMINARY)" : ""));
  }
//+------------------------------------------------------------------+
//| Prints the review list in the order of the table. Only flags     |
//| that hold in both halves of the sample lead to a review item.    |
//+------------------------------------------------------------------+
void PrintReview(const int &order[])
  {
   Print("--- Review list (in-sample diagnostics, not trading instructions) ---");
   int nRec=0;
   for(int i=0; i<g_nCfg; i++)
     {
      int c=order[i];
      SConfigResult r=g_res[c];
      if(r.flag!=FLAG_NEUTRAL && r.stable==0)
        {
         PrintFormat("- %s: %s does not hold in both halves of the sample; no conclusion",
                     r.name,FlagText(r.flag));
         nRec++;
         continue;
        }
      string tag=(r.stable==1 ? "" : " (stability not tested)");
      if(r.flag==FLAG_DRAG)
         PrintFormat("- Review %s (DRAG%s): net %.2f, realized DD without it %.2f",
                     r.name,tag,r.net,r.ddWithout);
      if(r.flag==FLAG_LOSS_HEDGE)
         PrintFormat("- Review %s (LOSS-HEDGE%s): net %.2f, but realized DD without it %.2f",
                     r.name,tag,r.net,r.ddWithout);
      if(r.flag==FLAG_OVERWEIGHT)
         PrintFormat("- Review the size of %s (OVERWEIGHT%s): "+
                     "%.1f%% of variance, %.1f%% of net",
                     r.name,tag,100.0*r.varShare,100.0*r.profitShare);
      if(r.flag!=FLAG_NEUTRAL && r.flag!=FLAG_OFFSET)
         nRec++;
      //--- a past concentration is reported only when it holds across several episodes
      if(100.0*r.windowShare>InpMaxWindowShare && 100.0*r.episodeShare>InpMaxWindowShare)
        {
         PrintFormat("- Check %s: %.1f%% of the deepest and %.1f%% of the %d deepest episodes",
                     r.name,100.0*r.windowShare,100.0*r.episodeShare,InpEpisodes);
         nRec++;
        }
     }
   if(nRec==0)
      Print("- No configuration raised a stable flag under the current thresholds");
   Print("Note: realized (closed) results only; confirm any change out of sample");
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print("=== Marginal Drawdown Contribution Analyzer 1.10 ===");
   if(!ValidateInputs())
      return;
//--- load the selected source and build the daily matrix
   bool ok=false;
   if(InpSource==SOURCE_DEMO)
      ok=LoadDemo();
   else
      if(InpSource==SOURCE_ACCOUNT)
         ok=LoadAccount();
      else
         ok=LoadCsv();
   if(!ok || !BuildMatrix())
     {
      Print("Error: no data was loaded");
      return;
     }
   PrintFormat("Data: %d configurations, %d days (%s to %s)",g_nCfg,g_nDays,
               TimeToString(g_days[0],TIME_DATE),TimeToString(g_days[g_nDays-1],TIME_DATE));
   Print("Granularity: realized result (profit + swap + commission + fee) per "+
         "configuration and server calendar day; floating P&L is not included");
   if(g_nCfg<2 || g_nDays<InpMinDays)
     {
      PrintFormat("Error: at least 2 configurations and %d days are required",InpMinDays);
      return;
     }
   bool prelim=(g_nDays<InpRobustDays);
   if(prelim)
      PrintFormat("PRELIMINARY: %d days is below InpRobustDays (%d); "+
                  "flags are indicative only",
                  g_nDays,InpRobustDays);
//--- portfolio curve, its realized drawdown and its deepest episodes
   double port[];
   GetSeries(-1,0,g_nDays,port);
   double netP=SumOf(port);
   int    pk,tr;
   double ddP=MaxDrawdown(port,pk,tr);
   if(ddP<=0.0)
     {
      Print("Error: the portfolio has no realized drawdown in this sample");
      return;
     }
   int    epPk[],epTr[];
   double epDepth[];
   int    nEp=DeepestEpisodes(port,InpEpisodes,epPk,epTr,epDepth);
   double epSum=0.0;
   for(int e=0; e<nEp; e++)
      epSum+=epDepth[e];
   Analyze(ddP,netP,pk+1,tr,epPk,epTr,epSum);
//--- portfolio summary
   double sumAlone=0.0;
   for(int c=0; c<g_nCfg; c++)
      sumAlone+=g_res[c].ddAlone;
   PrintFormat("Portfolio: net %.2f, realized max drawdown %.2f (%s to %s)",netP,ddP,
               TimeToString(g_days[pk>=0 ? pk : 0],TIME_DATE),
               TimeToString(g_days[tr],TIME_DATE));
   PrintFormat("Sum of standalone drawdowns %.2f, compression %.2fx; "+
               "%d deepest episodes: %.2f",
               sumAlone,sumAlone/ddP,nEp,epSum);
   int order[];
   PrintTable(netP>0.0,order);
//--- the score and the profit-based rules need a positive portfolio result
   if(netP>0.0)
      PrintScore(sumAlone,ddP,netP,prelim);
   else
      Print("Diagnostic mode: the portfolio result is not positive; "+
            "Net%, OVERWEIGHT and the score are not computed");
   PrintReview(order);
  }
//+------------------------------------------------------------------+
