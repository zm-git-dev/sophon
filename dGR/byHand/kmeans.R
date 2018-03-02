#!/usr/local/bin/R

require(ggplot2)

#pdf('plot.pdf')
x=read.table("distance.matrix")
y=as.matrix(x)
mm=as.dist(y)

mds=cmdscale(mm,k=2,eig=T)

out=kmeans(mm,3)

class1=c()
class2=c()
class3=c()	

len=length(out$cluster)

for (i in 1:len){
    tmp=as.numeric(out$cluster[i])
    if(tmp==1) {
    	              class1=c(class1,i)
		             }
			            else if(tmp==2) {
				              class2=c(class2,i)	   
					      				        }			      
													           else {
														   	     class3=c(class3,i)
															           } 
}

write.table(class1,file="class1.txt",sep="\t",row.names=F,col.names=F)
write.table(class2,file="class2.txt",sep="\t",row.names=F,col.names=F)
write.table(class3,file="class3.txt",sep="\t",row.names=F,col.names=F)
