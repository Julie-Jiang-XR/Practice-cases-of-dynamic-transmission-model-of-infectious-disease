
function [diffOut,dieHIV,dietotOut,prevOut,incOut]=diffCalculator(Xin,lambdaIn,miubIn,miu2In,miu3In,miu4In,miu5In,psi2In,psi3In,rho2In,rho4In,alpha)

    diffOut(1,1,1)=alpha-miubIn*Xin(1,1,1)-lambdaIn(1)*Xin(1,1,1);
    diffOut(1,2,1)=lambdaIn*Xin(1,1,1)-(miubIn+miu2In)*Xin(1,2,1)-psi2In*Xin(1,2,1)-rho2In*Xin(1,2,1);
    diffOut(1,3,1)=rho2In*Xin(1,2,1)-(miubIn+miu3In)*Xin(1,3,1)-psi3In*Xin(1,3,1);
    diffOut(2,2,1)=psi2In*Xin(1,2,1)-(miubIn+miu4In)*Xin(2,2,1)-rho4In*Xin(2,2,1);
    diffOut(2,3,1)=psi3In*Xin(1,3,1)+rho4In*Xin(2,2,1)-(miubIn+miu5In)*Xin(2,3,1);   
    
    %calucate prevalance, incidence, total die number, and HIV caused
    %mortality
    incOut=lambdaIn*Xin(1,1,1)/Xin(1,1,1);
    dietotOut=miubIn*Xin(1,1,1)+(miubIn+miu2In)*Xin(1,2,1)+(miubIn+miu3In)*Xin(1,3,1)+(miubIn+miu4In)*Xin(2,2,1)+(miubIn+miu5In)*Xin(2,3,1);
    dieHIV=miu2In*Xin(1,2,1)+miu3In*Xin(1,3,1)+miu4In*Xin(2,2,1)+miu5In*Xin(2,3,1);
    prevOut=(sum(Xin(:,2,1))+sum(Xin(:,3,1)))/sum(sum(Xin(:,:,1)));    

end
