function [backlog, arrival, departure] = slotted_aloha(m, T, lambda, qr)

% State of the nodes
% 0: Idle
% 1: Transmitting
% 2: Backlogged
state = zeros(1,m);
transmission_slot = zeros(1,m);
backlog = zeros(1,T);
arrival = zeros(1,T);
departure = zeros(1,T);
meanDelay = 0;
arrivedPckts = 0;
transmPckts = 0;
qa = 1 - exp(-lambda/m);

t = 0;
while t < T
    t = t + 1;
    
    for i = 1:m
        if state(i) == 0
            % Arrival at node i?
            if rand() <= qa
                state(i) = 1;
                transmission_slot(i) = t;
                arrivedPckts = arrivedPckts + 1;
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
        delay = t - transmission_slot(transmitting_node);
        meanDelay = meanDelay + (1/transmPckts)*(delay - meanDelay);
    end
    
    arrival(t) = arrivedPckts;
    departure(t) = transmPckts;
end

fprintf('\nqa: %.3f,\nTransmitted packets: %u,\nMean delay: %.0f\n',qa,transmPckts,meanDelay);