
function [prev_Out,dieHIV_Out,incT_Out,dieTot_Out]=controlFunction(Xin,n,ps,beta2In,beta3In,beta4In,beta5In,miub,miu2In,miu3In,miu4In,miu5In,psi2In,psi3In,rho2In,rho4In,nRunIn)

    nRuns=nRunIn;

    clear prev incT dieTot dieHIV lambdaT inc dietotal dieHIV1 prev1;
    X=Xin;
    X(:,:,1)=Xin(:,:,1);

        for i=2:nRuns+1

        X(:,:,1)=X(:,:,i-1);

        lambdaT=n*ps*((beta2In*X(1,2,1)/100000)+(beta3In*X(1,3,1)/100000)+(beta4In*X(2,2,1)/100000)+beta5In*X(2,3,1)/100000);

        alpha=miub*X(1,1,1)+(miub+miu2In)*X(1,2,1)+(miub+miu3In)*X(1,3,1)+(miub+miu4In)*X(2,2,1)+(miub+miu5In)*X(2,3,1);

        [diffT,dieHIV1,dietotal,prev1,inc]=diffCalculator(X,lambdaT,miub,miu2In,miu3In,miu4In,miu5In,psi2In,psi3In,rho2In,rho4In,alpha);
        
        X(:,:,i)=X(:,:,1)+diffT(:,:,1);
        
        incT(i)=inc(1);
        dieTot(i)=dietotal(1);
        dieHIV(i)=dieHIV1(1);
        prev(i)=prev1(1);

        end

    incT_Out=incT;
    dieTot_Out=dieTot;
    dieHIV_Out=dieHIV;
    prev_Out=prev;
          
end
