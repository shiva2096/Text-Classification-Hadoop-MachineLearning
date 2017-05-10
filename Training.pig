A = load '/Project/*' using PigStorage('|') as (eid:int,sender:chararray,content:chararray,class:chararray);
C = group A by class;
T = foreach C generate group as type,(DOUBLE)COUNT(A) as noofmails;
G = GROUP A ALL;
Tc = foreach G generate (DOUBLE)COUNT(A) as totalcount;
op1 = foreach T generate 'same' as key,type,noofmails;
op2 = foreach Tc generate 'same' as key,totalcount;
op3 = join op1 by key,op2 by key;
P = foreach op3 generate op1::type as type,op1::noofmails/op2::totalcount as probability;

op4 = foreach A generate FLATTEN(TOKENIZE(content)) as word;
op5 = DISTINCT op4;
op6 = group op5 ALL;
DicCount = foreach op6 generate (DOUBLE)COUNT(op5) as dcount;
Dictionary = op5;

op7 = foreach A generate class,FLATTEN(TOKENIZE(content)) as word;
op8 = group op7 by class;
WordCount = foreach op8 generate group as type,(DOUBLE)COUNT(op7) as wcount;

op9 = group op7 by (class,word);
ClassWCount = foreach op9 generate group.class as type,group.word as word,(DOUBLE)COUNT(op7) as calssWCount;

op10 = foreach WordCount generate 'same' as key,type,wcount;
op11 = foreach DicCount generate 'same' as key,dcount;
op12 = join op10 by key,op11 by key;
Denominator = foreach op12 generate op10::type as type,(DOUBLE)(op10::wcount + op11::dcount) as classdenominator;

WCPositive = filter ClassWCount by type=='p';
WCNegative = filter ClassWCount by type=='n';

op13 = foreach Dictionary generate word,(DOUBLE)0 as cnt;
op14 = join op13 by word LEFT,WCPositive by word;
PDicCount = foreach op14 generate op13::word as word,(DOUBLE)(op13::cnt + WCPositive::calssWCount) as pWCount;

Pa = filter PDicCount by pWCount is not null;
Pb = filter PDicCount by pWCount is null;
Pb1 = foreach Pb generate word,(DOUBLE)0 as pWCount;
PCount = UNION Pa,Pb1;

op15 = join op13 by word LEFT,WCNegative by word;
NDicCount = foreach op15 generate op13::word as word,(DOUBLE)(op13::cnt + WCNegative::calssWCount) as nWCount;

Na = filter NDicCount by nWCount is not null;
Nb = filter NDicCount by nWCount is null;
Nb1 = foreach Nb generate word,(DOUBLE)0 as nWCount;
NCount = UNION Na,Nb1;

SPLIT Denominator INTO pDenominator if type=='p',nDenominator if type=='n';

op16 = foreach pDenominator generate 'same' as key,classdenominator as cd;
op17 = foreach PCount generate 'same' as key,word,pWCount;
op18 = join op16 by key,op17 by key;
PWordProbability = foreach op18 generate op17::word as word,(DOUBLE)((op17::pWCount + 1)/op16::cd) as pWProb;

op19 = foreach nDenominator generate 'same' as key,classdenominator as cd;
op20 = foreach NCount generate 'same' as key,word,nWCount;
op21 = join op19 by key,op20 by key;
NWordProbability = foreach op21 generate op20::word as word,(DOUBLE)((op20::nWCount + 1)/op19::cd) as nWProb;

op22 = join PWordProbability by word,NWordProbability by word;
DicProb = foreach op22 generate PWordProbability::word as word,PWordProbability::pWProb as pProb,NWordProbability::nWProb as nProb;

store P into '/ProjectData/NewMailProbability' using PigStorage('|');store DicProb into '/ProjectData/NewDictionary' using PigStorage('|');



