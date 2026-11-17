*! mcbhsu Mata implementation 0.9.2 17nov2026
* Copyright 2026 Choonjoo Lee. Licensed under AFL-3.0; see LICENSE.
version 16.1
mata:

string scalar _mcbhsu_p092_version() { return("0.9.2"); }

real scalar _mcbhsu_p092_z(real scalar z, real scalar w, real scalar d,
    real rowvector a, real rowvector b)
{
    real rowvector p
    p = normal((d*w :- a:*z):/b)
    if (min(p)==0) return(0)
    return(normalden(z)*exp(sum(ln(p))))
}

real scalar _mcbhsu_p092_u(real scalar u, real scalar d, real scalar df,
    real rowvector a, real rowvector b)
{
    class Quadrature scalar q
    real scalar w, p
    w = sqrt(invchi2(df,u)/df)
    q = Quadrature()
    q.setEvaluator(&_mcbhsu_p092_z())
    q.setLimits((-9,9))
    q.setArgument(1,w)
    q.setArgument(2,d)
    q.setArgument(3,a)
    q.setArgument(4,b)
    q.setAbstol(1e-10)
    q.setReltol(1e-9)
    p=q.integrate()
    if (!q.converged()) {
        errprintf("MCB inner numerical integration did not converge\n")
        _error(430)
    }
    return(p)
}

/* n[1] is the putative control; the other entries are the competitors.
   This is a ONE-SIDED maximum of correlated t statistics, not max(abs(t)). */
real scalar _mcbhsu_p092_cdf(real scalar d, real scalar df, real rowvector n)
{
    class Quadrature scalar q
    real rowvector a,b
    real scalar p
    if (cols(n)==2) return(1-ttail(df,d))
    a=sqrt(n[2..cols(n)]:/(n[1]:+n[2..cols(n)]))
    b=sqrt(n[1]:/(n[1]:+n[2..cols(n)]))
    q=Quadrature()
    q.setEvaluator(&_mcbhsu_p092_u())
    q.setLimits((0,1))
    q.setArgument(1,d)
    q.setArgument(2,df)
    q.setArgument(3,a)
    q.setArgument(4,b)
    q.setAbstol(1e-9)
    q.setReltol(1e-8)
    p=q.integrate()
    if (!q.converged()) {
        errprintf("MCB outer numerical integration did not converge\n")
        _error(430)
    }
    if (p<-.00000001 | p>1.00000001 | p>=.) _error(430)
    return(max((0,min((1,p)))))
}

/* Conditional t rectangle for the variables other than a putative maximum.
   Conditional covariance keeps a one-factor representation. */
real scalar _mcbhsu_p092_cz(real scalar z, real scalar w,
    real rowvector h, real rowvector a, real rowvector b)
{
    return(normalden(z)*exp(sum(lnnormal((h*w:-a*z):/b))))
}

real scalar _mcbhsu_p092_cu(real scalar u, real scalar df,
    real rowvector h, real rowvector a, real rowvector b)
{
    class Quadrature scalar q
    real scalar out
    q=Quadrature()
    q.setEvaluator(&_mcbhsu_p092_cz())
    q.setLimits((-9,9))
    q.setArgument(1,sqrt(invchi2(df,u)/df))
    q.setArgument(2,h)
    q.setArgument(3,a)
    q.setArgument(4,b)
    q.setAbstol(1e-9)
    q.setReltol(1e-8)
    out=q.integrate()
    if (!q.converged() | out>=.) _error(430)
    return(out)
}

real scalar _mcbhsu_p092_maximum(real scalar v,
    real scalar df, real scalar p, real rowvector a, real rowvector b,
    real scalar j)
{
    class Quadrature scalar q
    real scalar x,out
    real rowvector rho,h,aa,bb,sd,tails,ix
    x=invttail(df,p*v)
    if (x>=.) _error(430)
    ix=selectindex((1..cols(a)):!=j)
    rho=a[ix]*a[j]
    if (x>sqrt(df)) h=(1:-rho)*sqrt(df+1)/sqrt(1+(sqrt(df)/x)^2)
    else h=(1:-rho)*x/sqrt((df+x*x)/(df+1))
    aa=a[ix]*b[j]
    bb=b[ix]
    sd=sqrt(aa:^2+bb:^2)
    tails=ttail(df+1,h:/sd)
    if (cols(h)==1) return(ttail(df+1,-h[1]/sd[1]))
    if (sum(tails)<1e-10) return(1)
    if (min(ttail(df+1,-h:/sd))<1e-12) return(0)
    q=Quadrature()
    q.setEvaluator(&_mcbhsu_p092_cu())
    q.setLimits((0,1))
    q.setArgument(1,df+1)
    q.setArgument(2,h)
    q.setArgument(3,aa)
    q.setArgument(4,bb)
    q.setAbstol(1e-9)
    q.setReltol(1e-8)
    out=q.integrate()
    if (!q.converged() | out>=. | out< -1e-8 | out>1+1e-8) _error(430)
    return(max((0,min((1,out)))))
}

/* Direct survival: partition by the unique maximizing coordinate, scaled by a
   representable univariate t tail. No subtraction of a near-unit CDF. */
real scalar _mcbhsu_p092_sf(real scalar d, real scalar df, real rowvector n)
{
    class Quadrature scalar q
    real rowvector a,b,parts,seen
    real scalar p,out,j,part,m
    p=ttail(df,d)
    m=cols(n)-1
    if (m==1 | p==0) return(p)
    if (d<=0) return(1-_mcbhsu_p092_cdf(d,df,n))
    if (m>2 & m*p>=1e-5) {
        out=1-_mcbhsu_p092_cdf(d,df,n)
        if (out>=1e-5) return(out)
    }
    a=sqrt(n[2..cols(n)]:/(n[1]:+n[2..cols(n)]))
    b=sqrt(n[1]:/(n[1]:+n[2..cols(n)]))
    out=0
    parts=J(1,m,.)
    for (j=1;j<=m;j++) {
        seen=selectindex(n[2..j+1]:==n[j+1])
        if (cols(seen)>1) {
            parts[j]=parts[seen[1]]
            out=out+parts[j]
            continue
        }
        q=Quadrature()
        q.setEvaluator(&_mcbhsu_p092_maximum())
        q.setLimits((0,1))
        q.setArgument(1,df)
        q.setArgument(2,p)
        q.setArgument(3,a)
        q.setArgument(4,b)
        q.setArgument(5,j)
        q.setAbstol(1e-9)
        q.setReltol(1e-8)
        part=q.integrate()
        if (!q.converged() | part>=. | part< -1e-8 | part>1+1e-8) _error(430)
        parts[j]=max((0,min((1,part))))
        out=out+parts[j]
    }
    return(min((1,max((p,p*out)))))
}

real scalar _mcbhsu_p092_critical(real scalar alpha, real scalar df,
    real rowvector n)
{
    real scalar lo,hi,fl,fh,x,fx,it
    if (cols(n)==2) return(invttail(df,alpha))
    lo=invttail(df,alpha)
    hi=invttail(df,alpha/(cols(n)-1))
    fl=_mcbhsu_p092_cdf(lo,df,n)-(1-alpha)
    fh=_mcbhsu_p092_cdf(hi,df,n)-(1-alpha)
    if (fl>1e-7 | fh< -1e-7) _error(430)
    for (it=1;it<=70;it++) {
        x=(lo*fh-hi*fl)/(fh-fl)
        if (x<=lo+.05*(hi-lo) | x>=hi-.05*(hi-lo) | x>=.) x=(lo+hi)/2
        fx=_mcbhsu_p092_cdf(x,df,n)-(1-alpha)
        if (abs(fx)<1e-10 | hi-lo<1e-7) return(x)
        if (fx<0) {
            lo=x
            fl=fx
        }
        else {
            hi=x
            fh=fx
        }
    }
    errprintf("MCB critical-value search did not converge\n")
    _error(430)
    return(.)
}

/* P(max_j |T_j| <= d), with a common chi-square denominator. */
real scalar _mcbhsu_p092_z2(real scalar z, real scalar w, real scalar d,
    real rowvector a, real rowvector b)
{
    real rowvector lo,hi,p,ix
    lo=(-d*w :- a:*z):/b
    hi=( d*w :- a:*z):/b
    p=normal(hi)-normal(lo)
    ix=selectindex(lo:>0)
    if (cols(ix)) p[ix]=normal(-lo[ix])-normal(-hi[ix])
    if (min(p)<=0) return(0)
    return(normalden(z)*exp(sum(ln(p))))
}

real scalar _mcbhsu_p092_u2(real scalar u, real scalar d, real scalar df,
    real rowvector a, real rowvector b)
{
    class Quadrature scalar q
    real scalar p
    q=Quadrature()
    q.setEvaluator(&_mcbhsu_p092_z2())
    q.setLimits((-9,9))
    q.setArgument(1,sqrt(invchi2(df,u)/df))
    q.setArgument(2,d)
    q.setArgument(3,a)
    q.setArgument(4,b)
    q.setAbstol(1e-10)
    q.setReltol(1e-9)
    p=q.integrate()
    if (!q.converged()) _error(430)
    return(p)
}

real scalar _mcbhsu_p092_cdf2(real scalar d, real scalar df, real rowvector n)
{
    class Quadrature scalar q
    real rowvector a,b
    real scalar p
    if (d<=0) return(0)
    if (cols(n)==2) return(1-2*ttail(df,d))
    a=sqrt(n[2..cols(n)]:/(n[1]:+n[2..cols(n)]))
    b=sqrt(n[1]:/(n[1]:+n[2..cols(n)]))
    q=Quadrature()
    q.setEvaluator(&_mcbhsu_p092_u2())
    q.setLimits((0,1))
    q.setArgument(1,d)
    q.setArgument(2,df)
    q.setArgument(3,a)
    q.setArgument(4,b)
    q.setAbstol(1e-9)
    q.setReltol(1e-8)
    p=q.integrate()
    if (!q.converged() | p< -1e-8 | p>1+1e-8 | p>=.) _error(430)
    return(max((0,min((1,p)))))
}

real scalar _mcbhsu_p092_critical2(real scalar alpha, real scalar df,
    real rowvector n)
{
    real scalar lo,hi,fl,fh,x,fx,it
    if (cols(n)==2) return(invttail(df,alpha/2))
    lo=invttail(df,alpha/2)
    hi=invttail(df,alpha/(2*(cols(n)-1)))
    fl=_mcbhsu_p092_cdf2(lo,df,n)-(1-alpha)
    fh=_mcbhsu_p092_cdf2(hi,df,n)-(1-alpha)
    if (fl>1e-7 | fh< -1e-7) _error(430)
    for (it=1;it<=70;it++) {
        x=(lo*fh-hi*fl)/(fh-fl)
        if (x<=lo+.05*(hi-lo) | x>=hi-.05*(hi-lo) | x>=.) x=(lo+hi)/2
        fx=_mcbhsu_p092_cdf2(x,df,n)-(1-alpha)
        if (abs(fx)<1e-10 | hi-lo<1e-7) return(x)
        if (fx<0) {
            lo=x
            fl=fx
        }
        else {
            hi=x
            fh=fx
        }
    }
    _error(430)
    return(.)
}

/* Edwards and Hsu (1983), Theorem 1 (p. 966), normal-model
   Example 2 (p. 969), with the 1984 corrected calibration.
   Target: delta_i=max_j(mu_j)-mu_i >= 0, INCLUDING j=i.
   S restricts the LOWER bound only. The upper bound uses every j!=i;
   the zero diagonal implements the outer max(0,...).
   This is not the active final output of SAS %UMCB. */
real matrix _mcbhsu_p092_eh(real colvector m, real colvector n,
    real scalar mse, real colvector d)
{
    real scalar K,i,j,s
    real matrix lo,up,out
    real rowvector v
    real colvector S,ix
    K=rows(m)
    lo=up=J(K,K,0)
    S=J(K,1,1)
    for (i=1;i<=K;i++) for (j=1;j<=K;j++) if (i!=j) {
        s=sqrt(mse*(1/n[i]+1/n[j]))
        lo[i,j]=m[i]-m[j]-d[j]*s
        up[i,j]=m[i]-m[j]+d[j]*s
    }
    for (j=1;j<=K;j++) if (max(lo[,j])>0) S[j]=0
    if (!sum(S)) _error(430)
    ix=selectindex(S)
    out=J(K,4,.)
    for (i=1;i<=K;i++) {
        v=up[i,ix']
        v=v:*(v:<0)
        out[i,1]=-max(v)
        out[i,2]=-min(lo[i,])
        out[i,3]=(out[i,1]==0)
        out[i,4]=S[i]
    }
    return(out)
}

/* Conservative distance bounds projected from all-pairs Tukey-Kramer. */
real matrix _mcbhsu_p092_tk(real colvector m, real colvector n,
    real scalar mse, real scalar d)
{
    real scalar i,j,K,s
    real rowvector lo,up
    real matrix out
    K=rows(m)
    out=J(K,4,.)
    for (i=1;i<=K;i++) {
        lo=up=J(1,K,0)
        for (j=1;j<=K;j++) if (i!=j) {
            s=sqrt(mse*(1/n[i]+1/n[j]))
            lo[j]=m[j]-m[i]-d*s
            up[j]=m[j]-m[i]+d*s
        }
        out[i,]=(max(lo),max(up),max(lo)==0,max(lo)==0)
    }
    return(out)
}

/* SAS MCB endpoint construction. d_i belongs to control i.
   The lower endpoint therefore uses d_j, not d_i. */
real matrix _mcbhsu_p092_bounds(real colvector m, real colvector n,
    real scalar mse, real colvector d)
{
    real scalar K,i,j,s
    real matrix lo,up,out
    real colvector rawu,G,L,U
    K=rows(m)
    lo=up=J(K,K,.)
    for (i=1;i<=K;i++) for (j=1;j<=K;j++) if (i!=j) {
        s=sqrt(mse*(1/n[i]+1/n[j]))
        lo[i,j]=m[i]-m[j]-d[j]*s
        up[i,j]=m[i]-m[j]+d[i]*s
    }
    rawu=J(K,1,.)
    L=U=J(K,1,.)
    for (i=1;i<=K;i++) rawu[i]=min(select(up[i,],(1..K):!=i))
    G=rawu:>0
    for (i=1;i<=K;i++) {
        U[i]=max((0,rawu[i]))
        if (sum(G)==1 & G[i]) L[i]=0
        else L[i]=min(select(lo[i,],(1..K):!=i))
    }
    return((L,U,G))
}


/* Quantile cache is bounded and contains no observations or group labels. */
real rowvector _mcbhsu_p092_getcrit(real scalar alpha, real scalar df,
    real rowvector n, real scalar tail, real scalar usecache)
{
    pointer scalar P
    string scalar key
    real scalar q
    real rowvector canon
    canon=(n[1],sort(n[2..cols(n)]',1)')
    key=strofreal(tail)+"|"+strofreal(alpha,"%21x")+"|"+
        strofreal(df,"%21x")+"|"+invtokens(strofreal(canon,"%21x"))
    P=findexternal("_mcbhsu_p092_quantile_cache")
    if (P==NULL) {
        P=crexternal("_mcbhsu_p092_quantile_cache")
        *P=asarray_create("string")
    }
    if (usecache & asarray_contains(*P,key)) return((asarray(*P,key),1))
    if (tail==1) q=_mcbhsu_p092_critical(alpha,df,n)
    else q=_mcbhsu_p092_critical2(alpha,df,n)
    if (q>=.) _error(430)
    if (usecache) {
        if (asarray_elements(*P)>=200) *P=asarray_create("string")
        asarray(*P,key,q)
    }
    return((q,0))
}

void _mcbhsu_p092_clearcache()
{
    pointer scalar P
    P=findexternal("_mcbhsu_p092_quantile_cache")
    if (P!=NULL) *P=asarray_create("string")
}

void _mcbhsu_p092_fail(real scalar rc, string scalar message)
{
    st_local("mcb_error",message)
    _error(rc)
}

/* No sorting, encoding, value-label creation, or modification of user data. */
void _mcbhsu_p092_analyze(string scalar yvar, string scalar over,
    string scalar touse, string scalar best, string scalar method,
    real scalar level, real scalar usecache, string scalar tname,
    string scalar sname, string scalar cname, string scalar vname,
    string scalar bname)
{
    transmorphic colvector key
    real colvector y,ord,n,m,rawmeans,d,p,other,seen,values,yi,boundary
    string colvector labels,strings
    string scalar vl
    real matrix panels,T,B
    real rowvector nr,q
    real scalar K,N,i,j,df,mse,sse,origin,unit,lmse,physicalmse,sgn
    real scalar alpha,t,se,estimate,hit,miss,near,gs
    y=st_data(.,yvar,touse)
    if (st_isstrvar(over)) key=st_sdata(.,over,touse)
    else key=st_data(.,over,touse)
    ord=order(key,1)
    y=y[ord]
    key=key[ord]
    panels=panelsetup(key,1)
    K=rows(panels)
    N=rows(y)
    if (K<2) _mcbhsu_p092_fail(459,"At least two observed groups are required")
    if (K>50) _mcbhsu_p092_fail(459,"At most 50 groups are supported in this release candidate")
    df=N-K
    if (df<1) _mcbhsu_p092_fail(2001,"No residual degrees of freedom: N must exceed the number of groups")
    if (method=="tukeygap" & (df<2 | df>1000000))
        _mcbhsu_p092_fail(459,"method(tukeygap) requires residual degrees of freedom from 2 through 1,000,000")
    origin=min(y)/2+max(y)/2
    y=y:-origin
    unit=max(abs(y))
    if (unit<=0 | unit>=.) _mcbhsu_p092_fail(459,"The outcome has no usable variation")
    y=y:/unit
    n=m=J(K,1,.)
    labels=strings=J(K,1,"")
    values=J(K,1,.)
    sse=0
    vl=st_varvaluelabel(over)
    for (i=1;i<=K;i++) {
        yi=y[|panels[i,1]\panels[i,2]|]
        n[i]=rows(yi)
        m[i]=mean(yi)
        yi=yi:-m[i]
        sse=sse+quadcross(yi,yi)
        if (st_isstrvar(over)) {
            strings[i]=key[panels[i,1]]
            labels[i]=strings[i]
            if (labels[i]=="") labels[i]="<empty string>"
        }
        else {
            values[i]=key[panels[i,1]]
            if (vl!="") labels[i]=st_vlmap(vl,values[i])
            else labels[i]=strtrim(strofreal(values[i],st_varformat(over)))
            if (labels[i]=="") labels[i]=strtrim(strofreal(values[i],st_varformat(over)))
        }
        if (strlen(labels[i])>32000 | strlen(strings[i])>32000)
            _mcbhsu_p092_fail(459,"Group keys and labels must be at most 32,000 bytes")
    }
    mse=sse/df
    if (mse<=0 | mse>=.) _mcbhsu_p092_fail(459,"Positive pooled within-group variation is required")
    lmse=ln(mse)+2*ln(unit)
    physicalmse=exp(lmse)
    if (physicalmse<=0 | physicalmse>=.) physicalmse=.
    rawmeans=origin:+unit*m
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

string scalar _mcbhsu_p092_text(string scalar s)
{
    string scalar out,c
    real scalar i
    out=""
    for (i=1;i<=strlen(s);i++) {
        c=substr(s,i,1)
        if (c=="{") out=out+"{c -(}"
        else if (c=="}") out=out+"{c )-}"
        else out=out+c
    }
    return(out)
}

void _mcbhsu_p092_display(string scalar tname)
{
    real matrix T
    real scalar i
    string scalar status,label
    T=st_matrix(tname)
    printf("{txt}%6s %9s %13s %13s %13s %13s  %s\n",
        "Group","N","Mean","Estimate","Lower","Upper","Status")
    for (i=1;i<=rows(T);i++) {
        status=(T[i,8] ? "Retained" : "Excluded")
        printf("{res}%6s %9.0f %13.6g %13.6g %13.6g %13.6g  {txt}%s\n",
            "g"+strofreal(i),T[i,1],T[i,2],T[i,4],T[i,5],T[i,6],status)
    }
    printf("\n{txt}Group labels (full labels are returned and saved):\n")
    for (i=1;i<=rows(T);i++) {
        label=st_local("mcb_group"+strofreal(i))
        if (ustrlen(label)>100) label=usubstr(label,1,100)+"..."
        printf("{txt}g%g = %s\n",i,_mcbhsu_p092_text(label))
    }
}

/* Called only while a temporary RESULTS frame is current. */
void _mcbhsu_p092_export(string scalar tname, string scalar vname,
    string scalar cname, string scalar bname, string scalar lname)
{
    real matrix T
    real colvector id
    string colvector labels,keys,shortlabels
    real scalar i,j,K
    T=st_matrix(tname)
    K=rows(T)
    id=1::K
    labels=keys=J(K,1,"")
    for (i=1;i<=K;i++) {
        labels[i]=st_local("mcb_group"+strofreal(i))
        keys[i]=st_local("mcb_key"+strofreal(i))
    }
    st_store(.,"group_id",id)
    st_store(.,"group_value",st_matrix(vname))
    st_sstore(.,"group_string",keys)
    st_sstore(.,"group_label",labels)
    st_store(.,tokens("n mean se_mean estimate lower upper p_exclude candidate critical"),T)
    st_store(.,"control_candidate",st_matrix(cname))
    st_store(.,"near_boundary",st_matrix(bname))
    shortlabels=usubstr(labels,1,50)
    for (i=1;i<=K;i++) {
        for (j=1;j<=K;j++) if (i!=j & shortlabels[i]==shortlabels[j]) break
        if (j<=K) labels[i]=" [g"+strofreal(i)+"]"
        else labels[i]=""
    }
    for (i=1;i<=K;i++) shortlabels[i]=_mcbhsu_p092_text(shortlabels[i])+labels[i]
    st_vlmodify(lname,id,shortlabels)
    st_varvaluelabel("group_id",lname)
}

end
