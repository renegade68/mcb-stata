*! mcbhsumargin 0.1.1 17nov2026
* Copyright 2026 Choonjoo Lee. Licensed under AFL-3.0; see LICENSE.
version 16.1
mata:
string scalar _mcbhsumargin_p011_version() { return("0.1.1"); }

/* Direct comparisons of stored doubles; no rounding or decision tolerance.
   0 uncertain, 1 within epsilon, 2 beyond epsilon. */
real matrix _mcbhsumargin_p011_classify(real matrix bounds,real scalar epsilon)
{
    real colvector L,U,decision,at
    if (cols(bounds)!=2 | !rows(bounds) | epsilon<0 | epsilon>=.)
        _mcbhsu_p092_fail(459,"epsilon() must be finite and nonnegative")
    L=bounds[,1]; U=bounds[,2]
    if (any(bounds:>=.) | any(L:<0) | any(U:<L))
        _mcbhsu_p092_fail(459,"Distance intervals must be finite with 0 <= lower <= upper")
    decision=(U:<=epsilon):+2*(L:>epsilon)
    at=(L:==epsilon):|(U:==epsilon)
    return((J(rows(L),1,epsilon),decision,at))
}

void _mcbhsumargin_p011_validate(string scalar tname,string scalar cname,
    string scalar vname,string scalar bname,string scalar metaname)
{
    real matrix T,C,V,B,M
    real scalar K
    T=st_matrix(tname); C=st_matrix(cname); V=st_matrix(vname)
    B=st_matrix(bname); M=st_matrix(metaname); K=rows(T)
    if (cols(T)!=9 | K<2 | K>50 | rows(M)!=1 | cols(M)!=4)
        _mcbhsu_p092_fail(459,"Unsupported MCB result dimensions")
    if (rows(C)!=K | cols(C)!=1 | rows(V)!=K | cols(V)!=1 | rows(B)!=K | cols(B)!=1)
        _mcbhsu_p092_fail(459,"Incomplete group metadata")
    if (any(T[,(1..6,8..9)]:>=.) | any(T[,1]:<1) | any(T[,1]:!=floor(T[,1])) |
        any(T[,3]:<0) | any(T[,4]:<0) | any(T[,9]:<=0))
        _mcbhsu_p092_fail(459,"Invalid distance result values")
    if (any((T[,8]:!=0):&(T[,8]:!=1)) | any(T[,8]:!=(T[,5]:==0)) |
        any((B:!=0):&(B:!=1)))
        _mcbhsu_p092_fail(459,"Invalid candidate or boundary indicators")
    if (any(M:>=.) | M[1]!=sum(T[,1]) | M[2]!=K | M[3]!=M[1]-K |
        M[3]<1 | M[4]<80 | M[4]>99.9)
        _mcbhsu_p092_fail(459,"Incomplete or inconsistent N, group count, df or confidence level")
}

/* Read only a results frame, never the user's current data. */
void _mcbhsumargin_p011_read(string scalar tname,string scalar cname,
    string scalar vname,string scalar bname,string scalar metaname)
{
    real matrix T
    real scalar i,K
    string colvector labels,keys
    T=st_data(.,tokens("n mean se_mean estimate lower upper p_exclude candidate critical"))
    K=rows(T)
    if (K<2 | K>50) _mcbhsu_p092_fail(459,"Saved results require 2 through 50 complete groups")
    if (any(st_data(.,"group_id"):!=(1::K)))
        _mcbhsu_p092_fail(459,"Saved group rows must retain their original complete order")
    st_matrix(tname,T)
    st_matrix(cname,st_data(.,"control_candidate"))
    st_matrix(vname,st_data(.,"group_value"))
    st_matrix(bname,st_data(.,"near_boundary"))
    st_matrix(metaname,(strtoreal(st_global("_dta[mcbhsu_N]")),K,
        strtoreal(st_global("_dta[mcbhsu_df]")),strtoreal(st_global("_dta[mcbhsu_level]"))))
    st_local("method",st_global("_dta[mcbhsu_method]"))
    st_local("best",st_global("_dta[mcbhsu_best]"))
    st_local("target",st_global("_dta[mcbhsu_target]"))
    st_local("engine_version",st_global("_dta[mcbhsu_version]"))
    st_local("input",st_global("_dta[mcbhsu_input]"))
    if (st_local("input")=="") st_local("input","raw")
    st_local("source_cmd",st_global("_dta[mcbhsumargin_source_cmd]"))
    st_local("source_version",st_global("_dta[mcbhsumargin_source_version]"))
    if (st_local("source_cmd")=="") {
        if (st_global("_dta[mcbhsus_version]")!="") {
            st_local("source_cmd","mcbhsus")
            st_local("source_version",st_global("_dta[mcbhsus_version]"))
        }
        else { st_local("source_cmd","mcbhsu"); st_local("source_version","0.9.2"); }
    }
    labels=st_sdata(.,"group_label"); keys=st_sdata(.,"group_string")
    for (i=1;i<=K;i++) {
        if (strlen(labels[i])>32000 | strlen(keys[i])>32000)
            _mcbhsu_p092_fail(459,"Group labels and keys must be at most 32,000 bytes")
        st_local("mcb_group"+strofreal(i),labels[i])
        st_local("mcb_key"+strofreal(i),keys[i])
    }
}

void _mcbhsumargin_p011_make(string scalar tname,string scalar outname,real scalar epsilon)
{
    real matrix T
    T=st_matrix(tname)
    st_matrix(outname,(T,_mcbhsumargin_p011_classify(T[,5..6],epsilon)))
}

void _mcbhsumargin_p011_display(string scalar outname)
{
    real matrix T
    real scalar i
    string scalar label,decision
    T=st_matrix(outname)
    printf("{txt}%6s %13s %13s %13s  %s\n","Group","Distance","Lower","Upper","Margin decision")
    for (i=1;i<=rows(T);i++) {
        decision=(T[i,11]==1 ? "Within epsilon" : (T[i,11]==2 ? "Beyond epsilon" : "Uncertain"))
        printf("{res}%6s %13.6g %13.6g %13.6g  {txt}%s\n","g"+strofreal(i),T[i,4],T[i,5],T[i,6],decision)
    }
    printf("\n{txt}Group labels (full labels are returned and saved):\n")
    for (i=1;i<=rows(T);i++) {
        label=st_local("mcb_group"+strofreal(i))
        if (ustrlen(label)>100) label=usubstr(label,1,100)+"..."
        printf("{txt}g%g = %s\n",i,_mcbhsu_p092_text(label))
    }
}
end
