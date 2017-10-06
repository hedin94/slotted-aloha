function W = average_delay(lambda)
    e = exp(1);
    W = (e - (1/2))./(1-lambda.*e) - (e-1)*(exp(lambda)-1)/(lambda.*(1-(e - 1)*(exp(lambda)-1)));