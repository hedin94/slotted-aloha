%%%%%%%%%%%%%%%%%%%%
%% Slotted ALOHA  %%
%%%%%%%%%%%%%%%%%%%%
m = 100;
T = 1000;
lambda = exp(-1);
qr = 0.01;
[backlog, arrival, departure] = slotted_aloha(m,T,lambda,qr);

%% Backlog
figure
plot(backlog);
title('Backlog {\lambda=1/e, q_r=0.01}');
xlabel('slot');
ylabel('backlogged nodes');
x = 1:T;

%% Arrival and departure of packets
figure
plot(x,arrival,x,departure);
title('Arrival and departure {\lambda=1/e, q_r=0.01}');
xlabel('slot');
ylabel('packets');
legend('arrivals','departures');

%% Histogram of backlog
figure
histogram(backlog);
title('Histogram of backlogged nodes');
xlabel('backlogged nodes');

%% Steady-states of the Markov chain
tbl = tabulate(backlog);
N = sum(tbl(1:end,1).*(tbl(1:end,3)/100));
D = N/lambda;

%% Attempt rate
qa = 1 - exp(-lambda/m);
G = attempt_rate(m, backlog, qa, qr);
figure
subplot(3,1,1);
plot(x,backlog);
title('Backlog');
xlabel('slot');
ylabel('backlogged nodes');
subplot(3,1,2);
plot(x,G);
title('Attempt rate');
xlabel('slot');

% Probability of success
G = attempt_rate(m, backlog, qa, qr);
Ps = G.*exp(-G);
Ps_avg = mean(Ps);
subplot(3,1,3);
plot(x,Ps);
title('Probability of success');
xlabel('slot');

%%
Pnew = (m-backlog)*qa;
figure
plot(x,Ps,x,Pnew);
title('Probability of new arrivals');

%%
G_theory = attempt_rate(m,0:m,qa,qr);
Ps_theory = G_theory.*exp(-G_theory);
Pnew_theory = (m-(0:m))*qa;
figure
plot(0:m,Ps_theory,0:m,Pnew_theory);
Ps_avg_theory = mean(Ps_theory);

%%
Dn_theory = Pnew_theory - Ps_theory;
figure
subplot(2,1,1);
plot(0:m,Ps_theory,0:m,Pnew_theory);
subplot(2,1,2);
plot(0:m,Dn_theory,0:m,zeros(1,m+1));

%% Assignment 5
m = 100;
T = 1000;
lambda = 1/2;
qr = 0.01;
[backlog, arrival, departure] = slotted_aloha(m,T,lambda,qr);

figure
plot(backlog);
title('Backlog {\lambda=1/2, q_r=0.01}');
xlabel('slot');
ylabel('backlogged nodes');
x = 1:T;
figure
plot(x,arrival,x,departure);
title('Arrival and departure {\lambda=1/2, q_r=0.01}');
xlabel('slot');
ylabel('packets');
legend('arrivals','departures');

%% Assignment 6
m = 100;
T = 1000;
lambda = exp(-1);
qr = 0.1;
[backlog, arrival, departure] = slotted_aloha(m,T,lambda,qr);

figure
plot(backlog);
title('Backlog {\lambda=1/e, q_r=0.1}');
xlabel('slot');
ylabel('backlogged nodes');
figure
plot(x,arrival,x,departure);
title('Arrival and departure {lambda=1/e, q_r=0.1}');
xlabel('slot');
ylabel('packets');
legend('arrivals','departures');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pseudo-Bayesian Stabilization  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m = 100;
T = 1000;
x = 1:T;
lambda = exp(-1);
[backlog, backlog_estimate, arrival, departure, W] = stabilized_slotted_aloha(m,T,lambda);
 
%% Backlog and backlog estimate
figure
plot(x,backlog,x,backlog_estimate(1:1000));
title('Backlog');
xlabel('slot');
ylabel('backlogged nodes');

%% Arrival and departure
figure
plot(x,arrival,x,departure);
title('Arrival and departure');
xlabel('slot');
ylabel('packets');
legend('arrivals','departures');

%% Histogram of backlog
figure
histogram(backlog);
title('Histogram of backlogged nodes');

%% Steady-states of the Markov chain
tbl = tabulate(backlog);
N = sum(tbl(1:end,1).*(tbl(1:end,3)/100));
D = N/lambda;

%% Backlog, Attempt rate, and Probabiliy of success
qa = 1 - exp(-lambda/m);
G = attempt_rate(m, backlog, qa, qr);
figure
subplot(3,1,1);
plot(x,backlog);
title('Backlog');
xlabel('slot');
ylabel('backlogged nodes');
subplot(3,1,2);
plot(x,G);
title('Attempt rate');

% Probability of success
G = attempt_rate(m, backlog, qa, qr);
Ps = G.*exp(-G);
Ps_avg = mean(Ps);
subplot(3,1,3);
plot(x,Ps);
title('Probability of success');

%% Probability of new arrivals
Pnew = (m-backlog)*qa;
figure
plot(x,Ps,x,Pnew);
title('Probability of new arrivals');

%% Theoretical calculations
G_theory = attempt_rate(m,0:m,qa,qr);
Ps_theory = G_theory.*exp(-G_theory);
Pnew_theory = (m-(0:m))*qa;
figure
plot(0:m,Ps_theory,0:m,Pnew_theory);
Ps_avg_theory = mean(Ps_theory);

%% Approximate delay analysis
lambda = 0.05:0.05:0.35;
W_theory = average_delay(lambda);
figure
plot(lambda,W_theory);
title('');
xlabel('arrival rate {\lambda}')
ylabel('delay')

%% Average delay from simulation
lambda = 0.05:0.05:0.35;
W = zeros(1,length(lambda));
for i = 1:length(lambda)
    [backlog, backlog_estimate, arrival, departure, Wi] = stabilized_slotted_aloha(m,T,lambda(i));
    W(i) = Wi;
end
plot(lambda,W_theory, lambda,W);
title('Theoretical delay vs Simulation delay');
xlabel('arrival rate {\lambda}')
ylabel('delay')
legend('theoretical delay', 'simulated delay');
