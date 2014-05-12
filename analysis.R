library(data.table)
library(ggplot2)
library(reshape)

theme_set(theme_bw())

d = read.delim("mail_metadata.tsv", header=FALSE,
    col.names=c("flags", "timestamp", "precedence", "google"))

d$timestamp <- as.POSIXct(d$timestamp, tz="UTC",
                          origin=as.POSIXct("1970-01-01 00:00:00"))

# limit the dataset to emails sent post timestamp
d <- d[d$timestamp > as.POSIXct("2004-04-01 00:00:00"),]

d$week <- cut(d$timestamp, breaks="weeks")

# list and then drop list mail
table(d$precedence)
d <- d[is.na(d$precedence),]
d$precedence <- NULL

d$replied <- grepl('R', d$flags)

google.by.week <- function (d) {
    setDT(d)

    weeks <- d[,list(total=length(google), google=table(google)["TRUE"]), by=week]

    # drop things
    weeks <- weeks[weeks$total > 1,]
    weeks$google.prop <- weeks$google / weeks$total

    weeks$week <- as.Date(as.character(weeks$week))

    return(weeks)
}

# find proportions per year
replied <- google.by.week(d[d$replied,])
replied <- replied[complete.cases(replied),]

replied.tbl <- as.data.frame(
    tapply(replied$google, substr(as.character(replied$week), 1, 4), sum) /
    tapply(replied$total, substr(as.character(replied$week), 1, 4), sum))

colnames(replied.tbl) <- "prop.google"
replied.tbl$year <- row.names(replied.tbl)
row.names(replied.tbl) <- NULL

ggplot(data=replied.tbl) + aes(x=year, y=prop.google) +
    geom_bar(stat="identity")

replied.tbl

# Graph #1: Emails from Google Over Time
#######################################################

raw.data <- google.by.week(d)
raw.data$google.prop <- NULL

raw.data <- melt(raw.data, id.var="week")


pdf(file="emails_gmail_over_time.pdf", width=10, height=6)

ggplot(data=raw.data) + aes(x=week, y=value, color=variable, group=variable) +
    geom_point() +
    stat_smooth(method="loess", show_guide=FALSE) +
    scale_color_discrete("", breaks=c("total", "google"),
                         labels=c("All Emails", "From Google")) +
    scale_x_date("Date") +
    scale_y_continuous("Number of Emails")

dev.off()

# Graph #2: Proportions of Email from Google
#######################################################

prop.data <- rbind(cbind(google.by.week(d), subset="All Email"),
                   cbind(google.by.week(d[d$replied]), subset="Email with Replies"))


pdf(file="emails_gmail_prop_over_time.pdf", width=10, height=8)

ggplot(data=prop.data) + aes(x=week, y=google.prop, size=total, group=subset) +
    geom_point() + facet_grid(subset~.) +
    scale_y_continuous("Proportion from Google", limits=c(0,1)) +
    scale_x_date("Date") +
    scale_size("Emails") +
    stat_smooth(method="loess", show_guide=FALSE) 

dev.off()
