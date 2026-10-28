//+------------------------------------------------------------------+
//| PortfolioScorer.mq5                                              |
//| Copyright 2026                                                   |
//| https://forge.mql5.io                                            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property script_show_inputs
#property description "Multi-EA Portfolio Scorer: Correlation, "
#property description "Coverage, and Diversity Analysis"

//--- Input parameters
input string InpFileList   = "EA_EUR.csv,EA_NDX.csv,EA_XAU.csv,EA_OIL.csv,EA_JPY.csv"; // CSV file list
input string InpSeparator  = ",";                           // File separator
input int    InpMinDays    = 60;                            // Min trading days
input double InpCorrThresh = 0.35;                          // Corr threshold
input double InpWeightCorr = 0.50;                          // Correlation weight
input double InpWeightCov  = 0.25;                          // Coverage weight
input double InpWeightDiv  = 0.25;                          // Diversity weight

//+------------------------------------------------------------------+
//| Data structures                                                  |
//+------------------------------------------------------------------+
struct SEAData
  {
   string         name;
   double         dailyPnL[];
   int            tradeHours[];
   int            tradeDays[];
   int            totalDays;
   double         netProfit;
   double         maxDD;
  };

struct SCoverageResult
  {
   int            hoursActive;
   int            daysActive;
   int            hourMap[24];
   int            dayMap[5];
   double         coverageScore;
  };

struct SPortfolioScore
  {
   double         corrScore;
   double         coverScore;
   double         diversityScore;
   double         compositeScore;
   string         grade;
   int            highCorrPairs;
   double         avgAbsCorr;
  };

//--- Global variables
SEAData g_eaData[];
int     g_numEAs     = 0;
double  g_corrMatrix[];
int     g_matrixSize = 0;

//+------------------------------------------------------------------+
//| Load daily P&L data from a CSV file                              |
//+------------------------------------------------------------------+
bool LoadEAData(string filename, SEAData &data)
  {
   data.name       = filename;
   data.totalDays  = 0;
   data.netProfit  = 0;
   data.maxDD      = 0;

   int handle = FileOpen(filename,
                         FILE_READ|FILE_CSV|FILE_ANSI,
                         ',');
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error: Cannot open %s. Code: %d",
                  filename, GetLastError());
      return false;
     }

   //--- Skip header line
   if(!FileIsEnding(handle))
     {
      while(!FileIsLineEnding(handle)
            && !FileIsEnding(handle))
         FileReadString(handle);
     }

   double tempPnL[];
   int    tempHours[];
   int    tempDays[];
   int    count = 0;

   while(!FileIsEnding(handle))
     {
      string dateStr = FileReadString(handle);
      if(dateStr == "")
         break;

      double pnl    = FileReadNumber(handle);
      int    hour   = (int)FileReadNumber(handle);
      int    wkday  = (int)FileReadNumber(handle);

      count++;
      ArrayResize(tempPnL,   count, 100);
      ArrayResize(tempHours, count, 100);
      ArrayResize(tempDays,  count, 100);

      tempPnL[count - 1]   = pnl;
      tempHours[count - 1] = hour;
      tempDays[count - 1]  = wkday;

      data.netProfit += pnl;
     }

   FileClose(handle);

   if(count < InpMinDays)
     {
      PrintFormat("Warning: %s has only %d days "
                  "(minimum: %d)",
                  filename, count, InpMinDays);
      return false;
     }

   ArrayResize(data.dailyPnL,    count);
   ArrayResize(data.tradeHours,  count);
   ArrayResize(data.tradeDays,   count);
   ArrayCopy(data.dailyPnL,   tempPnL);
   ArrayCopy(data.tradeHours, tempHours);
   ArrayCopy(data.tradeDays,  tempDays);
   data.totalDays = count;

   //--- Calculate max drawdown
   double peak = 0, equity = 0;
   for(int i = 0; i < count; i++)
     {
      equity += data.dailyPnL[i];
      if(equity > peak)
         peak = equity;
      double dd = (peak > 0)
                  ? (peak - equity) / peak * 100.0
                  : 0;
      if(dd > data.maxDD)
         data.maxDD = dd;
     }

   PrintFormat("Loaded %s: %d days | Net: $%.2f "
               "| MaxDD: %.2f%%",
               filename, count,
               data.netProfit, data.maxDD);
   return true;
  }

//+------------------------------------------------------------------+
//| Calculate Pearson correlation coefficient                        |
//+------------------------------------------------------------------+
double CalcPearsonCorrelation(
   const double &seriesA[],
   const double &seriesB[],
   int length)
  {
   if(length < 2)
      return 0.0;

   double meanA = 0, meanB = 0;
   for(int i = 0; i < length; i++)
     {
      meanA += seriesA[i];
      meanB += seriesB[i];
     }
   meanA /= length;
   meanB /= length;

   double covAB = 0, varA = 0, varB = 0;

   for(int i = 0; i < length; i++)
     {
      double dA = seriesA[i] - meanA;
      double dB = seriesB[i] - meanB;
      covAB += dA * dB;
      varA  += dA * dA;
      varB  += dB * dB;
     }

   double denom = MathSqrt(varA * varB);
   if(denom < 1e-10)
      return 0.0;

   return covAB / denom;
  }

//+------------------------------------------------------------------+
//| Build full NxN correlation matrix                                |
//+------------------------------------------------------------------+
void BuildCorrelationMatrix()
  {
   g_matrixSize = g_numEAs;
   ArrayResize(g_corrMatrix,
               g_matrixSize * g_matrixSize);
   ArrayInitialize(g_corrMatrix, 0.0);

   for(int i = 0; i < g_numEAs; i++)
     {
      for(int j = 0; j < g_numEAs; j++)
        {
         if(i == j)
           {
            g_corrMatrix[i * g_matrixSize + j] = 1.0;
            continue;
           }
         int len = MathMin(g_eaData[i].totalDays,
                           g_eaData[j].totalDays);
         double r = CalcPearsonCorrelation(
                       g_eaData[i].dailyPnL,
                       g_eaData[j].dailyPnL,
                       len);
         g_corrMatrix[i * g_matrixSize + j] = r;
        }
     }

   //--- Print matrix
   PrintFormat("\n=== CORRELATION MATRIX (%d EAs) ===",
               g_numEAs);

   string header = "            ";
   for(int j = 0; j < g_numEAs; j++)
     {
      string shortName = g_eaData[j].name;
      if(StringLen(shortName) > 8)
         shortName = StringSubstr(shortName, 0, 8);
      header += StringFormat("%-10s", shortName);
     }
   Print(header);

   for(int i = 0; i < g_numEAs; i++)
     {
      string shortName = g_eaData[i].name;
      if(StringLen(shortName) > 8)
         shortName = StringSubstr(shortName, 0, 8);
      string row = StringFormat("%-12s", shortName);

      for(int j = 0; j < g_numEAs; j++)
        {
         double val =
            g_corrMatrix[i * g_matrixSize + j];
         string flag = "";
         if(i != j
            && MathAbs(val) >= InpCorrThresh)
            flag = "*";
         row += StringFormat("%+.3f%s    ",
                             val, flag);
        }
      Print(row);
     }
   Print("(* = above threshold)");
  }

//+------------------------------------------------------------------+
//| Analyze trading coverage by hour and weekday                     |
//+------------------------------------------------------------------+
SCoverageResult AnalyzeCoverage()
  {
   SCoverageResult result;
   ArrayInitialize(result.hourMap, 0);
   ArrayInitialize(result.dayMap,  0);

   for(int ea = 0; ea < g_numEAs; ea++)
     {
      bool hourSeen[24];
      bool daySeen[5];
      ArrayInitialize(hourSeen, false);
      ArrayInitialize(daySeen,  false);

      for(int i = 0; i < g_eaData[ea].totalDays; i++)
        {
         int h = g_eaData[ea].tradeHours[i];
         int d = g_eaData[ea].tradeDays[i];

         if(h >= 0 && h < 24 && !hourSeen[h])
           {
            hourSeen[h] = true;
            result.hourMap[h]++;
           }
         if(d >= 0 && d < 5 && !daySeen[d])
           {
            daySeen[d] = true;
            result.dayMap[d]++;
           }
        }
     }

   result.hoursActive = 0;
   result.daysActive  = 0;

   for(int h = 0; h < 24; h++)
      if(result.hourMap[h] > 0)
         result.hoursActive++;

   for(int d = 0; d < 5; d++)
      if(result.dayMap[d] > 0)
         result.daysActive++;

   double hourRatio = result.hoursActive / 24.0;
   double dayRatio  = result.daysActive / 5.0;
   result.coverageScore =
      hourRatio * 0.70 + dayRatio * 0.30;

   //--- Print coverage
   Print("\n=== COVERAGE ANALYSIS ===");
   PrintFormat("Hours covered: %d/24 | Days: %d/5",
               result.hoursActive,
               result.daysActive);

   string hourBar = "Hour Map:  ";
   for(int h = 0; h < 24; h++)
     {
      if(result.hourMap[h] == 0)
         hourBar += ".";
      else
         hourBar += IntegerToString(
                       MathMin(result.hourMap[h], 9));
     }
   Print(hourBar);
   Print("           000000000011111111112222");
   Print("           012345678901234567890123");

   string dayNames[] =
      {"Mon","Tue","Wed","Thu","Fri"};
   for(int d = 0; d < 5; d++)
      PrintFormat("  %s: %d EAs active",
                  dayNames[d], result.dayMap[d]);

   PrintFormat("Coverage Score: %.3f",
               result.coverageScore);

   return result;
  }

//+------------------------------------------------------------------+
//| Detect asset family from EA file name                            |
//+------------------------------------------------------------------+
string DetectAssetFamily(string eaName)
  {
   string upper = eaName;
   StringToUpper(upper);

   if(StringFind(upper, "EUR") >= 0 ||
      StringFind(upper, "GBP") >= 0 ||
      StringFind(upper, "JPY") >= 0 ||
      StringFind(upper, "AUD") >= 0 ||
      StringFind(upper, "CHF") >= 0 ||
      StringFind(upper, "NZD") >= 0 ||
      StringFind(upper, "CAD") >= 0)
      return "FOREX";

   if(StringFind(upper, "NDX") >= 0 ||
      StringFind(upper, "SPX") >= 0 ||
      StringFind(upper, "DAX") >= 0 ||
      StringFind(upper, "NJ225") >= 0 ||
      StringFind(upper, "NAS") >= 0)
      return "INDICES";

   if(StringFind(upper, "XAU") >= 0 ||
      StringFind(upper, "XAG") >= 0 ||
      StringFind(upper, "GOLD") >= 0)
      return "METALS";

   if(StringFind(upper, "OIL") >= 0 ||
      StringFind(upper, "XTI") >= 0 ||
      StringFind(upper, "BRENT") >= 0 ||
      StringFind(upper, "XNG") >= 0)
      return "ENERGY";

   if(StringFind(upper, "AMZN") >= 0 ||
      StringFind(upper, "TSLA") >= 0 ||
      StringFind(upper, "NVDA") >= 0 ||
      StringFind(upper, "AAPL") >= 0 ||
      StringFind(upper, "GOOGL") >= 0 ||
      StringFind(upper, "XLV") >= 0 ||
      StringFind(upper, "XLP") >= 0)
      return "STOCKS";

   return "OTHER";
  }

//+------------------------------------------------------------------+
//| Calculate composite portfolio score                              |
//+------------------------------------------------------------------+
SPortfolioScore CalcPortfolioScore(
   SCoverageResult &coverage)
  {
   SPortfolioScore score;

   //=== 1. Correlation Score ===
   double sumAbsCorr = 0;
   int    pairCount  = 0;
   score.highCorrPairs = 0;

   for(int i = 0; i < g_numEAs; i++)
      for(int j = i + 1; j < g_numEAs; j++)
        {
         double r = g_corrMatrix[
                       i * g_matrixSize + j];
         sumAbsCorr += MathAbs(r);
         pairCount++;
         if(MathAbs(r) >= InpCorrThresh)
            score.highCorrPairs++;
        }

   score.avgAbsCorr = (pairCount > 0)
                       ? sumAbsCorr / pairCount
                       : 0;
   score.corrScore =
      MathMax(0, (1.0 - score.avgAbsCorr * 2.0))
      * 100;

   //=== 2. Coverage Score ===
   score.coverScore = coverage.coverageScore * 100;

   //=== 3. Diversity Score ===
   string families[];
   int numFamilies = 0;

   for(int i = 0; i < g_numEAs; i++)
     {
      string family =
         DetectAssetFamily(g_eaData[i].name);
      bool found = false;
      for(int f = 0; f < numFamilies; f++)
         if(families[f] == family)
           { found = true; break; }

      if(!found)
        {
         numFamilies++;
         ArrayResize(families, numFamilies);
         families[numFamilies - 1] = family;
        }
     }

   score.diversityScore =
      MathMin(numFamilies * 20.0, 100.0);

   //=== 4. Composite ===
   score.compositeScore =
      score.corrScore      * InpWeightCorr +
      score.coverScore     * InpWeightCov  +
      score.diversityScore * InpWeightDiv;

   //=== 5. Grade ===
   if(score.compositeScore >= 90)
      score.grade = "A+";
   else if(score.compositeScore >= 80)
      score.grade = "A";
   else if(score.compositeScore >= 70)
      score.grade = "B";
   else if(score.compositeScore >= 60)
      score.grade = "C";
   else if(score.compositeScore >= 50)
      score.grade = "D";
   else
      score.grade = "F";

   return score;
  }

//+------------------------------------------------------------------+
//| Check if a file exists in MQL5/Files                             |
//+------------------------------------------------------------------+
bool FileExist(string filename)
  {
   int h = FileOpen(filename,
                    FILE_READ|FILE_CSV|FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;
   FileClose(h);
   return true;
  }

//+------------------------------------------------------------------+
//| Simple pseudo-random generator (seed-based)                      |
//+------------------------------------------------------------------+
double g_rndSeed = 0;

double PseudoRandom()
  {
   g_rndSeed = MathMod(
      g_rndSeed * 1103515245 + 12345,
      2147483648);
   return g_rndSeed / 2147483648.0;
  }

//+------------------------------------------------------------------+
//| Generate Gaussian from uniform using Box-Muller                  |
//+------------------------------------------------------------------+
double RandGauss(double mean, double stddev)
  {
   double u1 = MathMax(PseudoRandom(),
                       1e-10);
   double u2 = PseudoRandom();
   double z  = MathSqrt(-2.0 * MathLog(u1))
               * MathCos(2.0 * M_PI * u2);
   return mean + z * stddev;
  }

//+------------------------------------------------------------------+
//| Generate a sample CSV file for one EA                            |
//+------------------------------------------------------------------+
void GenerateSampleCSV(string filename,
                       double bias,
                       double vol,
                       int &hours[],
                       int &days[],
                       int numDays)
  {
   int handle = FileOpen(filename,
      FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error creating %s",
                  filename);
      return;
     }

   FileWriteString(handle,
      "Date,DailyPnL,"
      "TradeHour,TradeWeekday\n");

   MqlDateTime dt;
   dt.year = 2024;
   dt.mon  = 1;
   dt.day  = 2;
   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;

   datetime current =
      StructToTime(dt);
   int written = 0;
   int numHours = ArraySize(hours);
   int numDaysArr = ArraySize(days);

   while(written < numDays)
     {
      TimeToStruct(current, dt);
      int wday = dt.day_of_week;

      //--- Skip weekends
      if(wday == 0 || wday == 6)
        {
         current += 86400;
         continue;
        }

      //--- Check if this day is active
      int mappedDay = wday - 1;
      bool dayActive = false;
      for(int d = 0;
          d < numDaysArr; d++)
         if(days[d] == mappedDay)
           {dayActive = true; break;}

      if(!dayActive)
        {
         current += 86400;
         continue;
        }

      double pnl = RandGauss(bias, vol);
      pnl = NormalizeDouble(pnl, 2);
      int h = hours[
         (int)MathMod(written, numHours)];

      FileWriteString(handle,
         StringFormat(
            "%04d.%02d.%02d,"
            "%.2f,%d,%d\n",
            dt.year, dt.mon, dt.day,
            pnl, h, mappedDay));

      written++;
      current += 86400;
     }

   FileClose(handle);
   PrintFormat(
      ">> Auto-generated sample: %s "
      "(%d days)", filename, numDays);
  }

//+------------------------------------------------------------------+
//| Generate all sample CSVs if missing                              |
//+------------------------------------------------------------------+
bool EnsureSampleFiles(string &fileList[],
                       int numFiles)
  {
   //--- Check if ALL files exist
   bool allExist = true;
   for(int i = 0; i < numFiles; i++)
     {
      string fname = fileList[i];
      StringTrimLeft(fname);
      StringTrimRight(fname);
      if(!FileExist(fname))
        {allExist = false; break;}
     }

   if(allExist)
      return true;

   //--- Some files missing: generate samples
   Print("");
   Print(">> CSV files not found in "
         "MQL5\\Files\\");
   Print(">> Generating sample data "
         "for demonstration...");
   Print("");

   g_rndSeed = (double)GetTickCount();

   //--- Define 5 sample EA profiles
   //    Each has: bias, volatility,
   //    active hours, active weekdays
   struct SEAProfile
     {
      string name;
      double bias;
      double vol;
      int    hours[7];
      int    numH;
      int    days[5];
      int    numD;
     };

   SEAProfile profiles[5];

   //--- EA_EUR: London session forex
   profiles[0].name = "EA_EUR.csv";
   profiles[0].bias = 1.2;
   profiles[0].vol  = 8.0;
   profiles[0].numH = 7;
   profiles[0].numD = 5;
   int eurH[] = {8,9,10,11,12,13,14};
   int eurD[] = {0,1,2,3,4};
   ArrayCopy(profiles[0].hours, eurH);
   ArrayCopy(profiles[0].days, eurD);

   //--- EA_NDX: NY session index
   profiles[1].name = "EA_NDX.csv";
   profiles[1].bias = 1.5;
   profiles[1].vol  = 12.0;
   profiles[1].numH = 7;
   profiles[1].numD = 5;
   int ndxH[] = {14,15,16,17,18,19,20};
   int ndxD[] = {0,1,2,3,4};
   ArrayCopy(profiles[1].hours, ndxH);
   ArrayCopy(profiles[1].days, ndxD);

   //--- EA_XAU: Overlapping sessions
   profiles[2].name = "EA_XAU.csv";
   profiles[2].bias = 0.9;
   profiles[2].vol  = 9.5;
   profiles[2].numH = 7;
   profiles[2].numD = 5;
   int xauH[] = {6,7,8,9,14,15,16};
   int xauD[] = {0,1,2,3,4};
   ArrayCopy(profiles[2].hours, xauH);
   ArrayCopy(profiles[2].days, xauD);

   //--- EA_OIL: NY afternoon energy
   profiles[3].name = "EA_OIL.csv";
   profiles[3].bias = 0.7;
   profiles[3].vol  = 7.0;
   profiles[3].numH = 5;
   profiles[3].numD = 4;
   int oilH[] = {13,14,15,16,17,0,0};
   int oilD[] = {0,1,2,4,0};
   ArrayCopy(profiles[3].hours, oilH);
   ArrayCopy(profiles[3].days, oilD);

   //--- EA_JPY: Asian session forex
   profiles[4].name = "EA_JPY.csv";
   profiles[4].bias = 1.0;
   profiles[4].vol  = 6.0;
   profiles[4].numH = 6;
   profiles[4].numD = 5;
   int jpyH[] = {0,1,2,3,4,5,0};
   int jpyD[] = {0,1,2,3,4};
   ArrayCopy(profiles[4].hours, jpyH);
   ArrayCopy(profiles[4].days, jpyD);

   //--- Generate each file
   for(int p = 0; p < 5; p++)
     {
      int hArr[];
      ArrayResize(hArr,
         profiles[p].numH);
      for(int x = 0;
          x < profiles[p].numH; x++)
         hArr[x] = profiles[p].hours[x];

      int dArr[];
      ArrayResize(dArr,
         profiles[p].numD);
      for(int x = 0;
          x < profiles[p].numD; x++)
         dArr[x] = profiles[p].days[x];

      GenerateSampleCSV(
         profiles[p].name,
         profiles[p].bias,
         profiles[p].vol,
         hArr, dArr, 250);
     }

   //--- Update fileList to match
   ArrayResize(fileList, 5);
   fileList[0] = "EA_EUR.csv";
   fileList[1] = "EA_NDX.csv";
   fileList[2] = "EA_XAU.csv";
   fileList[3] = "EA_OIL.csv";
   fileList[4] = "EA_JPY.csv";

   Print("");
   Print(">> Sample files created in "
         "MQL5\\Files\\");
   Print(">> Replace them with your "
         "own backtest data for real "
         "analysis.");
   Print("");

   return true;
  }

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print("========================================");
   Print("  PORTFOLIO SCORER v1.0");
   Print("  Multi-EA Correlation & Coverage Tool");
   Print("========================================");

   //--- Parse file list
   string fileList[];
   ushort sep = StringGetCharacter(InpSeparator, 0);
   int numFiles = StringSplit(InpFileList, sep,
                              fileList);
   if(numFiles < 2)
     {
      Alert("Specify at least 2 EA CSV files.");
      return;
     }

   ArrayResize(g_eaData, numFiles);
   g_numEAs = 0;

   for(int i = 0; i < numFiles; i++)
     {
      string fname = fileList[i];
      StringTrimLeft(fname);
      StringTrimRight(fname);

      if(LoadEAData(fname, g_eaData[g_numEAs]))
         g_numEAs++;
     }

   if(g_numEAs < 2)
     {
      //--- Files not found: auto-generate
      Print(">> Not enough valid files. "
            "Auto-generating samples...");
      if(!EnsureSampleFiles(fileList,
            numFiles))
        {
         Alert("Could not generate "
               "sample files.");
         return;
        }

      //--- Retry loading with new files
      numFiles = ArraySize(fileList);
      ArrayResize(g_eaData, numFiles);
      g_numEAs = 0;

      for(int i = 0;
          i < numFiles; i++)
        {
         string fn = fileList[i];
         StringTrimLeft(fn);
         StringTrimRight(fn);
         if(LoadEAData(fn,
               g_eaData[g_numEAs]))
            g_numEAs++;
        }

      if(g_numEAs < 2)
        {
         Alert("Failed to load "
               "generated samples.");
         return;
        }
     }

   PrintFormat("\nSuccessfully loaded %d EAs.\n",
               g_numEAs);

   //--- Build correlation matrix
   BuildCorrelationMatrix();

   //--- Analyze coverage
   SCoverageResult coverage = AnalyzeCoverage();

   //--- Calculate score
   SPortfolioScore result =
      CalcPortfolioScore(coverage);

   //--- Final report
   Print("\n========================================");
   Print("  PORTFOLIO SCORE REPORT");
   Print("========================================");
   PrintFormat("  EAs in portfolio:    %d", g_numEAs);
   PrintFormat("  Avg |correlation|:   %.3f",
               result.avgAbsCorr);
   PrintFormat("  High-corr pairs:    %d",
               result.highCorrPairs);
   Print("----------------------------------------");
   PrintFormat("  Correlation Score:   %.1f / 100",
               result.corrScore);
   PrintFormat("  Coverage Score:      %.1f / 100",
               result.coverScore);
   PrintFormat("  Diversity Score:     %.1f / 100",
               result.diversityScore);
   Print("----------------------------------------");
   PrintFormat("  COMPOSITE SCORE:     %.1f / 100",
               result.compositeScore);
   PrintFormat("  GRADE:               %s",
               result.grade);
   Print("========================================");

   //--- Actionable recommendations
   Print("\n--- RECOMMENDATIONS ---");

   if(result.corrScore < 50)
      Print("!! CRITICAL: High inter-strategy "
            "correlation. Review the matrix and "
            "consider replacing correlated EAs.");

   if(result.highCorrPairs > 0)
      PrintFormat("   %d pair(s) exceed the %.2f "
                  "correlation threshold.",
                  result.highCorrPairs,
                  InpCorrThresh);

   if(result.coverScore < 70)
      Print(">> TIP: Add EAs active in uncovered "
            "hours/days to reduce blind spots.");

   if(result.diversityScore < 60)
      Print(">> TIP: Diversify across more asset "
            "classes (forex, metals, indices, "
            "stocks, energy).");

   if(result.compositeScore >= 80)
      Print("++ Portfolio is well-constructed. "
            "Maintain quality when adding new EAs.");

   Print("\n========================================");
   Print("  Scoring complete.");
   Print("========================================");
  }
//+------------------------------------------------------------------+