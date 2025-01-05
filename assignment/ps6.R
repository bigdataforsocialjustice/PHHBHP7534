
data("gss08") # LCA lca = glca(item(DEFECT, HLTH, RAPE, POOR, SINGLE, NOMORE) ~ 1, data = gss08, nclass = 3, n.init = 1) summary(lca) # LCA with covariate(s) lcr = glca(item(DEFECT, HLTH, RAPE, POOR, SINGLE, NOMORE) ~ AGE, data = gss08, nclass = 3, n.init = 1) summary(lcr) coef(lcr)
