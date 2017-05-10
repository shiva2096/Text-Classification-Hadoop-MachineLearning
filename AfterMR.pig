A = load '/MROutput/part-r*' using PigStorage('\t') as (eno:int,pProb:double,nProb:double);
B = load '/ProjectData/MailProbability' using PigStorage('|') as (type:chararray,mProb:double);
B1 = foreach B generate 'same' as key,type,mProb; 
split B1 into Bp if type=='p',Bn if type=='n';
A1 = foreach A generate 'same' as key,eno,pProb,nProb;

J = join A1 by key,Bp by key,Bn by key;
P = foreach J generate A1::eno as eno,(Double)(A1::pProb * Bp::mProb) as PVnb,(DOUBLE)(A1::nProb * Bn::mProb) as NVnb;
Yes = filter P by PVnb>NVnb;
No = filter P by NVnb>PVnb;
I = load '/Input/*' using PigStorage('|') as (eid:int,sender:chararray,content:chararray);
JYes = join Yes by eno,I by eid;
JNo = join No by eno,I by eid;
YesMails = foreach JYes generate Yes::eno,I::sender,I::content;
NoMails = foreach JNo generate No::eno,I::sender,I::content;
store YesMails into '/HotelBookingMails';store NoMails into '/OtherMails';

