library(ivd )

d <- lme4::sleepstudy

d$y <- c(scale(d$Reaction))

alpha <- ss_ranef_alpha(y = d$y, unit = d$Subject)

alpha
