//+------------------------------------------------------------------+
//|                                                         ATR.mq4 |
//+------------------------------------------------------------------+
 

// Plain trailing stop EA with ATR-based stop-loss.

#define LONG 1
#define SHORT 2

extern int ATR_Period=24;
extern int ATR_Multiplier=3;
extern int StartWith=1; // 1 - Short, 2 - Long
extern int Slippage=100;    // Tolerated slippage in pips

extern bool ECN_Mode=false; // Set to true if stop-loss should be added only after Position Open
extern int TakeProfit=0; // In your broker's pips

extern int Magic=123123123;

#include  <Convert.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ATRExpert
  {
public:

   double            wma,wma_p;  // linear Weighted Moving Average & Previous
   double            sma,sma_p;  // Simple Moving Average & Previous
   double            rsi;              // Relative Strength Indicator
   double rsi1,      rsi2;  // long chain rsi 1&2
   double rsi3,      rsi4;  // long chain rsi 3&4

   bool Signal(int cmd=EMPTY,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

 

      if(wma_p<sma_p && wma>sma &&   (rsi1<48 || rsi2<48 || rsi3<48 || rsi4<48) && cmd==OP_BUY) // MA crossed up
        {
         return 1;
        }

      if(wma_p>sma_p && wma<sma &&   (rsi1>52 || rsi2>52 || rsi3>52 || rsi4>52) && cmd==OP_SELL)
        {
         return 1;
        }
      return 0;

     }

   bool Update(int tf=PERIOD_M1)
     {

      double stochm=0;              // STOCHastic Main
      double stochm1=0, stochm2=0;  // long chain stochm 1&2
      double stochm3=0, stochm4=0;  // long chain stochm 3&4
      double stochs=0;              // STOCHastic Signal
      double stochs1=0, stochs2=0;  // long chain stochs 1&2
      double stochs3=0, stochs4=0;  // long chain stochs 3&4
      double  macdm=0;              // Moving Average Convergance Divergance Main
      double  macds=0;              // Moving Average Convergance Divergance Signal

      int tframe=Convert::TfToIndex(tf);

      int pos=0;             // leave room for moving average periods
      //pos=5;

      while(pos>=0)
        {
         wma_p=wma; // save previous calculations
         wma=iMA(Symbol(),tf,10,0,MODE_LWMA,PRICE_CLOSE,pos);

         sma_p=sma; // save previous calculations
         sma=iMA(Symbol(),tf,20,0,MODE_SMA,PRICE_CLOSE,pos);

         stochs=iStochastic(Symbol(),tf,10,6,6,0,1,1,pos);
         stochs=iStochastic(Symbol(),tf,10,6,6,0,1,1,pos+1);
         stochs=iStochastic(Symbol(),tf,10,6,6,0,1,1,pos+2);
         stochs=iStochastic(Symbol(),tf,10,6,6,0,1,1,pos+3);
         stochs=iStochastic(Symbol(),tf,10,6,6,0,1,1,pos+4);

         stochm=iStochastic(Symbol(),tf,10,6,6,0,1,0,pos);
         stochm1=iStochastic(Symbol(),tf,10,6,6,0,1,0,pos+1);
         stochm2=iStochastic(Symbol(),tf,10,6,6,0,1,0,pos+2);
         stochm3=iStochastic(Symbol(),tf,10,6,6,0,1,0,pos+3);
         stochm4=iStochastic(Symbol(),tf,10,6,6,0,1,0,pos+4);

         rsi=iRSI(Symbol(),tf,28,PRICE_CLOSE,pos);
         rsi1=iRSI(Symbol(),tf,28,PRICE_CLOSE,pos+1);
         rsi2=iRSI(Symbol(),tf,28,PRICE_CLOSE,pos+2);
         rsi3=iRSI(Symbol(),tf,28,PRICE_CLOSE,pos+3);
         rsi4=iRSI(Symbol(),tf,28,PRICE_CLOSE,pos+4);

         macdm=iMACD(Symbol(),tf,12,26,9,0,0,pos);
         macds=iMACD(Symbol(),tf,12,26,9,0,1,pos);

         pos--;

        }
     }
  };
//+------------------------------------------------------------------+
