
setwd("~/git.repos/extract-seq-flanking-read/runs/out/brad")
files = list.files(pattern = ".txt$")

all.patterns = c("5p06", "5p07", "5p08", "5p14", "5p15", "5p16", "5p20", "5p21", "5p25")

for (pattern in all.patterns) {
  print(pattern)
  file.subset <- files[grepl(pattern, files)]
  md <- data.frame()
  for (file in file.subset) {
    frqs <- cbind(file = file, read.table(file, sep = "\t", header = T))
    md   <- rbind(md, melt(frqs, id=c("file", "X")))
  }
  mean.frqs <- cast(md, X~variable, mean)
  mean.frqs[, 2:ncol(mean.frqs)] <- round(mean.frqs[, 2:ncol(mean.frqs)] * 100, 1)
  colnames(mean.frqs) <- c("base", -(ncol(mean.frqs) - 1):-1)
  write.table(mean.frqs, paste0(pattern, ".summary.txt"),
              quote = F, sep = "\t", row.names = F)
}

