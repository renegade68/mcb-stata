*! mcbhsus summary adapter 0.1.1 17nov2026
* Copyright 2026 Choonjoo Lee. Licensed under AFL-3.0; see LICENSE.
version 16.1
mata:
string scalar _mcbhsus_p011_version() { return("0.1.1"); }

/* One record per independent group. Reuse the 0.9.2 kernels;
   never synthesize or expand individual observations from summaries. */
void _mcbhsus_p011_analyze(string scalar meanvar, string scalar over,
    string scalar nvar, string scalar sdvar, real scalar supplied_mse,
    real scalar supplied_df, string scalar touse, string scalar best,
    string scalar method, real scalar level, real scalar usecache,
    string scalar tname, string scalar sname, string scalar cname,
    string scalar vname, string scalar bname)
{
    transmorphic colvector key
    real colvector ord,n,m,rawmeans,sd,d,p,other,seen,values,boundary,x
    string colvector labels,strings
    string scalar vl
    real matrix T,B
    real rowvector nr,q
    real scalar K,N,i,j,df,mse,origin,unit,lmse,physicalmse,sgn
    real scalar alpha,t,se,estimate,hit,miss,near,gs
    rawmeans=st_data(.,meanvar,touse)
    n=st_data(.,nvar,touse)
    if (st_isstrvar(over)) key=st_sdata(.,over,touse)
    else key=st_data(.,over,touse)
    ord=order(key,1)
    key=key[ord]; rawmeans=rawmeans[ord]; n=n[ord]
    K=rows(n)
    if (K<2 | K>50) _mcbhsu_p092_fail(459,"Summary input requires 2 through 50 groups")
    if (rows(panelsetup(key,1))!=K)
        _mcbhsu_p092_fail(459,"Each group must have exactly one selected summary row")
    if (any(rawmeans:>=.)) _mcbhsu_p092_fail(459,"Every selected group needs a finite mean")
    if (any(n:>=.) | any(n:<1) | any(n:!=floor(n)))
        _mcbhsu_p092_fail(459,"Group counts must be positive finite integers")
    N=sum(n)
    if (N>9007199254740991)
        _mcbhsu_p092_fail(459,"The total count exceeds the exact integer range")
    df=N-K
    if (df<1) _mcbhsu_p092_fail(2001,"No residual degrees of freedom: total n must exceed K")
    if (method=="tukeygap" & (df<2 | df>1000000))
        _mcbhsu_p092_fail(459,"method(tukeygap) requires residual df from 2 through 1,000,000")
    origin=min(rawmeans)/2+max(rawmeans)/2
    m=rawmeans:-origin
    if (sdvar!="") {
        sd=st_data(.,sdvar,touse); sd=sd[ord]
        for (i=1;i<=K;i++) {
            if (n[i]==1) {
                if (sd[i]!=0 & sd[i]<.)
                    _mcbhsu_p092_fail(459,"For n=1, sd() must be missing or zero")
                sd[i]=0
            }
            else if (sd[i]<0 | sd[i]>=.)
                _mcbhsu_p092_fail(459,"For n>1, sd() must be finite and nonnegative")
        }
        unit=max((max(abs(m)),max(sd)))
        if (unit<=0 | unit>=.) _mcbhsu_p092_fail(459,"No usable mean or within-group variation")
        x=sqrt(n:-1):*(sd:/unit)
        mse=quadcross(x,x)/df
    }
    else {
        if (supplied_df!=df)
            _mcbhsu_p092_fail(459,"For this one-way model, df() must equal sum(n)-K")
        unit=max((max(abs(m)),sqrt(supplied_mse)))
        if (unit<=0 | unit>=.) _mcbhsu_p092_fail(459,"The summary scale is outside the numeric range")
        mse=(sqrt(supplied_mse)/unit)^2
    }
    if (mse<=0 | mse>=.)
        _mcbhsu_p092_fail(459,"Positive pooled within-group variation within numeric range is required")
    m=m:/unit
    lmse=ln(mse)+2*ln(unit)
    physicalmse=exp(lmse)
    if (physicalmse<=0 | physicalmse>=.) physicalmse=.
    labels=strings=J(K,1,""); values=J(K,1,.)
    vl=st_varvaluelabel(over)
    for (i=1;i<=K;i++) {
        if (st_isstrvar(over)) {
            strings[i]=key[i]; labels[i]=strings[i]
            if (labels[i]=="") labels[i]="<empty string>"
        }
        else {
            values[i]=key[i]
            if (vl!="") labels[i]=st_vlmap(vl,values[i])
            else labels[i]=strtrim(strofreal(values[i],st_varformat(over)))
            if (labels[i]=="") labels[i]=strtrim(strofreal(values[i],st_varformat(over)))
        }
        if (strlen(labels[i])>32000 | strlen(strings[i])>32000)
            _mcbhsu_p092_fail(459,"Group keys and labels must be at most 32,000 bytes")
    }
    sgn=(best=="max" ? 1 : -1)
    m=sgn*m
    alpha=1-level/100
    d=p=J(K,1,.)
    hit=miss=0
    for (i=1;i<=K;i++) {
        other=selectindex((1::K):!=i)
        nr=(n[i],n[other]')
        seen=selectindex(n[1..i]:==n[i])
        if (rows(seen)>1) d[i]=d[seen[1]]
        else if (method=="tukeygap") d[i]=invtukeyprob(K,df,1-alpha)/sqrt(2)
        else {
            q=_mcbhsu_p092_getcrit(alpha,df,nr,(method=="constrained" ? 1 : 2),usecache)
            d[i]=q[1]
            hit=hit+q[2]
            miss=miss+1-q[2]
        }
        if (method=="constrained") {
            t=.
            for (j=1;j<=K;j++) if (i!=j) {
                se=sqrt(mse*(1/n[i]+1/n[j]))
                if (t>=.) t=(m[j]-m[i])/se
                else t=max((t,(m[j]-m[i])/se))
            }
            p[i]=_mcbhsu_p092_sf(t,df,nr)
        }
    }
    if (method=="constrained") {
        B=_mcbhsu_p092_bounds(m,n,mse,d)
        B=(B,B[,3])
        if (sgn<0) B=((-B[,2]),(-B[,1]),B[,3..4])
    }
    else if (method=="edwardshsu") B=_mcbhsu_p092_eh(m,n,mse,d)
    else {
        B=_mcbhsu_p092_tk(m,n,mse,d[1])
        B[,4]=J(K,1,.)
    }
    boundary=J(K,1,0)
    T=J(K,9,.)
    for (i=1;i<=K;i++) {
        other=selectindex((1::K):!=i)
        if (method=="constrained") {
            estimate=sgn*(m[i]-max(m[other]))*unit
            near=abs(p[i]-alpha)
            boundary[i]=(near<1e-6)
        }
        else {
            estimate=(max(m)-m[i])*unit
            gs=sqrt(mse/n[i])
            if (B[i,1]>0 & B[i,1]<1e-6*gs) boundary[i]=1
        }
        T[i,]=(n[i],rawmeans[i],sqrt(mse/n[i])*unit,estimate,
            B[i,1]*unit,B[i,2]*unit,p[i],B[i,3],d[i])
    }
    if (any(T[,2..6]:>=.))
        _mcbhsu_p092_fail(459,"Result exceeds numeric storage range; rescale the outcome")
    st_matrix(tname,T)
    st_matrix(sname,(N,K,df,physicalmse,sum(B[,3]),lmse,origin,unit,hit,miss))
    st_matrix(cname,B[,4])
    st_matrix(vname,values)
    st_matrix(bname,boundary)
    for (i=1;i<=K;i++) {
        st_local("mcb_group"+strofreal(i),labels[i])
        st_local("mcb_key"+strofreal(i),strings[i])
    }
}

end
