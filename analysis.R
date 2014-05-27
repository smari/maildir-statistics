library(data.table)
library(ggplot2)
library(reshape)

theme_set(theme_bw())

d <- read.delim("mail_metadata.tsv", header=FALSE,
    col.names=c("flags", "timestamp", "precedence", "big", "soc"))

d$timestamp <- as.POSIXct(d$timestamp, tz="UTC",
                          origin=as.POSIXct("1970-01-01 00:00:00"))

# limit the dataset to emails sent post timestamp
d <- d[d$timestamp > as.POSIXct("2008-04-01 00:00:00"),]
# d <- d[d$timestamp < as.POSIXct("2014-01-01 00:00:00"),]

d$week <- cut(d$timestamp, breaks="weeks")

# list and then drop list mail
table(d$precedence)
d <- d[is.na(d$precedence),]
d$precedence <- NULL

d$replied <- grepl('R', d$flags)

big.by.week <- function (d) {
    setDT(d)

    weeks <- d[,list(total=length(big), big=table(big)["TRUE"]), by=week]

    # drop things
    weeks <- weeks[weeks$total > 1,]
    weeks$big.prop <- weeks$big / weeks$total

    weeks$week <- as.Date(as.character(weeks$week))

    return(weeks)
}

# find proportions per year
replied <- big.by.week(d[d$replied,])
replied <- replied[complete.cases(replied),]

replied.tbl <- as.data.frame(
    tapply(replied$big, substr(as.character(replied$week), 1, 4), sum) /
    tapply(replied$total, substr(as.character(replied$week), 1, 4), sum))

colnames(replied.tbl) <- "prop.big"
replied.tbl$year <- row.names(replied.tbl)
row.names(replied.tbl) <- NULL

ggplot(data=replied.tbl) + aes(x=year, y=prop.big) +
    geom_bar(stat="identity")

replied.tbl

# Graph #1: Emails from big Over Time
#######################################################

raw.data <- big.by.week(d)
raw.data$big.prop <- NULL

raw.data <- melt(raw.data, id.var="week")


pdf(file="emails_gmail_over_time.pdf", width=10, height=6)

ggplot(data=raw.data) + aes(x=week, y=value, color=variable, group=variable) +
    geom_point() +
    stat_smooth(method="loess", show_guide=FALSE) +
    scale_color_discrete("", breaks=c("total", "big"),
                         labels=c("All Emails", "From large e-mail providers")) +
    scale_x_date("Date") +
    scale_y_continuous("Number of Emails")

dev.off()

# Graph #2: Proportions of Email from big
#######################################################

prop.data <- rbind(cbind(big.by.week(d), subset="All Email"),
                   cbind(big.by.week(d[d$replied]), subset="Email with Replies"))


pdf(file="emails_gmail_prop_over_time.pdf", width=10, height=8)

ggplot(data=prop.data) + aes(x=week, y=big.prop, size=total, group=subset) +
    geom_point() + facet_grid(subset~.) +
    scale_y_continuous("Proportion from large e-mail providers", limits=c(0,1)) +
    scale_x_date("Date") +
    scale_size("Emails") +
    stat_smooth(method="loess", show_guide=FALSE) 

dev.off()
