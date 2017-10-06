function [backlog, backlog_estimate, arrival, departure, W] = stabilized_slotted_aloha(m, T, lambda)

% State of the nodes
% 0: Idle
% 1: Transmitting
% 2: Backlogged
state = zeros(1,m);
transmission_slot = zeros(1,m);
backlog = zeros(1,T);
backlog_estimate = zeros(1,T+1);
arrival = zeros(1,T);
departure = zeros(1,T);
arrival_slot = zeros(1,T);
departure_slot = zeros(1,T);
meanDelay = 0;
arrivedPckts = 0;
transmPckts = 0;
qa = 1 - exp(-lambda/m);


t = 0;
while t < T
    t = t + 1;
    
    % Update retransmission rate (qr)
    if 0 <= backlog_estimate(t) && backlog_estimate(t) < 1
        qr = 1;
    else
        qr = 1/backlog_estimate(t);
    end
    
    for i = 1:m
        if state(i) == 0
            % Arrival at node i?
            if rand() <= qa
                state(i) = 2;
                transmission_slot(i) = t;
                arrivedPckts = arrivedPckts + 1;
                arrival_slot(arrivedPckts) = t;
                backlog(t) = backlog(t) + 1;
            end
        else            
            % Retransmission at node i?
            if rand() <= qr
                state(i) = 1;
            else
                state(i) = 2;
                backlog(t) = backlog(t) + 1;
            end
        end      
    end
    
    % How many nodes are transmitting?
    transmissions = 0;
    transmitting_node = -1;
    for i = 1:m
        if state(i) == 1
            transmissions = transmissions + 1;
            transmitting_node = i;
        end
    end
    
    % One node transmitting = SUCCESS
    if transmissions == 1
        state(transmitting_node) = 0;
        transmPckts = transmPckts + 1;
        departure_slot(transmPckts) = t;
        delay = t - arrival_slot(transmPckts);
        meanDelay = meanDelay + (1/transmPckts)*(delay - meanDelay);
    end
    
    % Estimate backlog for slot t+1
    if transmissions <= 1
        backlog_estimate(t+1) = max(lambda, backlog_estimate(t) + lambda - 1);
    else
        backlog_estimate(t+1) = backlog_estimate(t) + lambda + 1/(exp(1)-2);
    end
    
    arrival(t) = arrivedPckts;
    departure(t) = transmPckts;
end

W = departure_slot(1:transmPckts) - arrival_slot(1:transmPckts);
W = mean(W);

fprintf('\nqa: %.3f,\nTransmitted packets: %u,\nMean delay: %.0f\n',qa,transmPckts,W);