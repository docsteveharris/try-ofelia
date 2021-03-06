
# Modelling proof of principle
# https://m-clark.github.io/R-models/

model_vars <- c('tt', 'y', 'mrn')
nonmodel_vars <- setdiff(names(mdt), model_vars)
timeconstant_vars <- c('mrn', 'ward', 'room', 'wardi', 'bed', 'bedi', 'label' )

# model
mmix <- lmer(y ~ tt + (1+rcs(tt, 3)|mrn), data=mdt)

# Use augment to rapidly build in sample predictions
rdt <- augment(mmix)
setnames(rdt,'.fitted', 'yhat')
sdt <- tibble(mdt[,nonmodel_vars,with=FALSE])
sdt <- bind_cols(sdt,rdt)
sdt <- sdt %>% select(c(nonmodel_vars, model_vars, yhat))
setDT(sdt)

# build predictions out of sample (i.e for the last x hours)
new_data <- data.table(expand.grid(tt=wwindow:0, mrn=unique(sdt$mrn), label=llabel, new_data=TRUE))
pdt <- data.table(yhat=predict(mmix, new_data))
pdt <- bind_cols(pdt,new_data)
udt <- unique(sdt[,timeconstant_vars, with=FALSE])
udt <- udt[pdt, on=c('mrn==mrn', 'label==label')]
mdt <- rbindlist(list(sdt,udt),fill=TRUE)
mdt[is.na(new_data), new_data := FALSE]
mdt[new_data==TRUE, observation_datetime := now() + dhours(tt) ]

# Thinking about recency # variable ordering
# mdt[order(-observation_datetime), ti := seq_len(.N), by=.(mrn, label) ]
# flag vitals that have not been measured for some time
setorder(mdt,mrn,label,-tt) # for the side effect of sorting
mdt[new_data==FALSE, ti := seq_len(.N), by=.(mrn,label)]
mdt[new_data==FALSE, tlast := -1 * max(tt), by=.(mrn,label)]
mdt[new_data==TRUE, tlast := NA]
Hmisc::describe(mdt$tlast)


if (debug) {
  # inspect
  # focus on who have not had a measurement in the last 8 hours
  choose_mrn <- unique(mdt[new_data==FALSE & tlast > 8,.(mrn)])
  gdt <- choose_mrn[mdt, on='mrn',nomatch=0]
  ggplot(gdt, aes(x=tt, group=mrn)) +
    geom_point(aes(y=y), colour='blue', size=0.1) +
    geom_line(data=gdt[new_data==TRUE], aes(y=yhat, colour=new_data)) +
    geom_line(data=gdt[new_data==FALSE], aes(y=yhat, colour=new_data)) +
    facet_wrap(~mrn) +
    # coord_cartesian(xlim=c(-24,0)) +
    ylab(llabel) +
    xlab('Time from now (Hours)') +
    theme_minimal()
}
