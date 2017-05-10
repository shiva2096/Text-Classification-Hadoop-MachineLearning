A = load '/Input/*' using PigStorage('|') as (eid:int,sender:chararray,content:chararray);
B = foreach A generate eid,FLATTEN(TOKENIZE(content)) as word;
R = load '/ProjectData/Dictionary/*' using PigStorage('|') as (word:chararray,pProb:double,nProb:double);
J = join B by word,R by word;
O = order J by B::eid;
Out = foreach O generate B::eid as eid,R::pProb as pProb,R::nProb as nProb;
store Out into '/MRInput' using PigStorage('\t');

