`valTable` <-
function (x, method = c("simple", "onedims", "clustpppca", "addNoise: additive", "swappNum"), measure = "mean", 
    clustermethod = "clara", aggr = 3, nc = 8, transf = "log", p=15, noise=15, w=1:dim(x)[2], delta=0.1) 
{
`prcompRob` <-
function (X, k = 0, sca = "mad", scores = TRUE) 
{
    ## Copyright: Croux and Filzmoser
    n <- nrow(X)
    p <- ncol(X)
    if (k == 0) {
        p1 <- min(n, p)
    }
    else {
        p1 <- k
    }
    S <- rep(1, p1)
    V <- matrix(1:(p * p1), ncol = p1, nrow = p)
    P <- diag(p)
    m <- apply(X, 2, median)
    Xcentr <- scale(X, center = m, scale = FALSE)
    for (k in 1:p1) {
        B <- Xcentr %*% P
        Bnorm <- sqrt(apply(B^2, 1, sum))
        A <- diag(1/Bnorm) %*% B
        Y <- A %*% P %*% t(X)
        if (sca == "mad") 
            s <- apply(Y, 1, mad)
        #if (sca == "tau") 
        #    s <- apply(Y, 1, scale.tau)
        #if (sca == "A") 
        #    s <- apply(Y, 1, scale.a)
        j <- order(s)[n]
        S[k] <- s[j]
        V[, k] <- A[j, ]
        if (V[1, k] < 0) 
            V[, k] <- (-1) * V[, k]
        P <- P - (V[, k] %*% t(V[, k]))
    }
    if (scores) {
        list(scale = S, loadings = V, scores = Xcentr %*% V)
    }
    else list(scale = S, loadings = V)
}


    m <- list()
    for (i in 1:length(method)) {
      print(paste("method", method[i], "will be applied"))
      flush.console() 
        if( method[i] %in% c("simple", "single", "onedims", "pca", 
    "pppca", "clustpca", "clustpppca", "mdav", "influence", "rmd", "clustmcdpca","mcdpca")){
        m[[i]] <- microaggregation(obj = x, method = method[i], 
            measure = measure, clustermethod = clustermethod, 
            aggr = aggr, nc = nc, transf = transf)
        }
        if( method[i] == "swappNum" ){ m[[i]] <- rankSwap(x, P=p) }
        if( substring(method[i],1,8) == "addNoise" ){
          m[[i]] <- addNoise(x, noise=noise, method=substring(method[i],11,nchar(method[i])))
        }
        if( method[i] == "dataGen" ){ 
          d <- dataGen(x, n=dim(x)[1])
          d <- list(x = x, xm = d)
          class(d) <- "micro"
          m[[i]] <- d
        }
        #print(i)
        #flush.console()

    }
    print("calculating summary statistics")
    flush.console()
    #save(m, file="mres.Rdata")
    s <- list()
    s <- lapply(m, summary, robCov = FALSE, robReg = FALSE)
    g <- data.frame(amean = round(s[[1]][[3]], 3), amedian = round(s[[1]][[4]], 
        3), aonestep = round(s[[1]][[5]], 3), devvar = round(s[[1]][[6]], 
        3), amad = round(s[[1]][[7]], 3), acov = round(s[[1]][[8]], 
        3), acor = round(s[[1]][[10]], 3), acors = round(s[[1]][[12]], 
        3), adlm = round(s[[1]][[13]], 3), apcaload = round(s[[1]][[15]], 
        3), apppcaload = round(s[[1]][[16]], 3), atotals = round(s[[1]][[19]], 
        3), pmtotals = round(s[[1]][[20]], 3),
        util1 = round(s[[1]][[21]], 3),
        deigenvalues = round(s[[1]][[22]], 3),
        risk0 = round(s[[1]][[23]], 3),
        risk1 = round(s[[1]][[24]], 3),
        risk2 = round(s[[1]][[25]], 3),
       wrisk1 = round(s[[1]][[26]], 3),
       wrisk2 = round(s[[1]][[27]], 3)       
        )
    if (length(s) > 1) {
        for (i in 2:length(s)) {
            g2 <- data.frame(amean = round(s[[i]][[3]], 3), amedian = round(s[[i]][[4]], 
                3), aonestep = round(s[[i]][[5]], 3), devvar = round(s[[i]][[6]], 
                3), amad = round(s[[i]][[7]], 3), acov = round(s[[i]][[8]], 
                3), acor = round(s[[i]][[10]], 3), acors = round(s[[i]][[12]], 
                3), adlm = round(s[[i]][[13]], 3), apcaload = round(s[[i]][[15]], 
                3), apppcaload = round(s[[i]][[16]], 3), atotals = round(s[[i]][[19]], 
                3), pmtotals = round(s[[i]][[20]], 3),
         util1 = round(s[[i]][[21]], 3),
        deigenvalues = round(s[[i]][[22]], 3),
        risk0 = round(s[[i]][[23]], 3),
        risk1 = round(s[[i]][[24]], 3),
        risk2 = round(s[[i]][[25]], 3),
       wrisk1 = round(s[[i]][[26]], 3),
       wrisk2 = round(s[[i]][[27]], 3)                 
                )
            g <- rbind(g, g2)
        }
    }
    g <- cbind(data.frame(method = method), g)
    g
}
