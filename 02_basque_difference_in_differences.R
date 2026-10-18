# Did ETA terrorism slow the Basque economy? Three identification strategies
# Katie-Rose Chubb
#
# Data: data/basque.csv, per capita GDP (thousands of 1986 USD) for 17 Spanish
# regions, 1955 to 1997. Treatment: onset of ETA terrorism in the Basque Country,
# dated to 1973. Source: Abadie and Gardeazabal (2003), via Imai (2017) QSS.

basque <- read.csv("data/basque.csv")

# ---- Descriptives -------------------------------------------------------
cat("Years:", range(basque$year), "\n")
cat("GDP per capita: mean", round(mean(basque$gdpcap, na.rm = TRUE), 2),
    " median", round(median(basque$gdpcap, na.rm = TRUE), 2),
    " IQR", round(IQR(basque$gdpcap, na.rm = TRUE), 2),
    " SD", round(sd(basque$gdpcap, na.rm = TRUE), 2),
    " N", nrow(basque), "\n")

# ---- The four groups ----------------------------------------------------
basque_pre_treat  <- subset(basque, year <  1973 & region == "Basque Country")
basque_post_treat <- subset(basque, year >= 1973 & region == "Basque Country")
basque_pre_ctrl   <- subset(basque, year <  1973 & region != "Basque Country")
basque_post_ctrl  <- subset(basque, year >= 1973 & region != "Basque Country")

groups <- list(
  "Basque pre-1973"   = basque_pre_treat$gdpcap,
  "Basque post-1973"  = basque_post_treat$gdpcap,
  "Control pre-1973"  = basque_pre_ctrl$gdpcap,
  "Control post-1973" = basque_post_ctrl$gdpcap
)
for (g in names(groups)) {
  x <- groups[[g]]
  cat(sprintf("%-18s mean %5.2f  median %5.2f  SD %4.2f  n %3d\n", g,
              mean(x, na.rm = TRUE), median(x, na.rm = TRUE),
              sd(x, na.rm = TRUE), sum(!is.na(x))))
}

# ---- Strategy 1: cross-section (post period only) -----------------------
cs_diff <- mean(basque_post_treat$gdpcap) - mean(basque_post_ctrl$gdpcap)
cat("\nCross-section (Basque minus control, post-1973):", round(cs_diff, 2), "\n")

# ---- Strategy 2: before and after (Basque only) -------------------------
ba_diff <- mean(basque_post_treat$gdpcap) - mean(basque_pre_treat$gdpcap)
cat("Before-and-after (Basque post minus pre):", round(ba_diff, 2), "\n")

# ---- Strategy 3: difference in differences ------------------------------
ctrl_change  <- mean(basque_post_ctrl$gdpcap)  - mean(basque_pre_ctrl$gdpcap)
treat_change <- mean(basque_post_treat$gdpcap) - mean(basque_pre_treat$gdpcap)
did          <- treat_change - ctrl_change
cat("Control change:", round(ctrl_change, 2),
    " Basque change:", round(treat_change, 2),
    " DiD:", round(did, 2), "thousand 1986 USD\n")

# ---- Parallel trends check ----------------------------------------------
# DiD assumes the Basque Country would have tracked the other regions without
# ETA. We cannot prove that, but we can look at whether the two lines were
# moving together before 1973.
yearly <- aggregate(gdpcap ~ year + I(region == "Basque Country"), data = basque,
                    FUN = mean, na.rm = TRUE)
names(yearly) <- c("year", "basque", "gdpcap")

dir.create("output", showWarnings = FALSE)
png("output/basque_parallel_trends.png", width = 900, height = 600, res = 120)
plot(yearly$year[yearly$basque], yearly$gdpcap[yearly$basque], type = "l", lwd = 2,
     col = "#D7191C", ylim = range(yearly$gdpcap),
     xlab = "Year", ylab = "GDP per capita (thousands of 1986 USD)",
     main = "Basque Country versus the rest of Spain, 1955 to 1997")
lines(yearly$year[!yearly$basque], yearly$gdpcap[!yearly$basque], lwd = 2, col = "#2C7BB6")
abline(v = 1973, lty = 2, col = "gray40")
text(1973, max(yearly$gdpcap), "ETA onset", pos = 4, cex = 0.8, col = "gray40")
legend("topleft", bty = "n", legend = c("Basque Country", "Other regions (mean)"),
       col = c("#D7191C", "#2C7BB6"), lwd = 2)
dev.off()
