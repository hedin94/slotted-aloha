function [backlog, backlog_estimate, arrival, departure, W] = stabilized_slotted_aloha(m, T, lambda)

% State of a nodes
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
arrivedPckts = 0;
transmPckts = 0;

% Calculate the probability of arrival
qa = 1 - exp(-lambda/m);

% Simulate for T slots
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
        % Is node_i IDLE?
        if state(i) == 0
            % Packet arrive at node_i with probability qa
            if rand() <= qa
                state(i) = 2;
                transmission_slot(i) = t;
                arrivedPckts = arrivedPckts + 1;
                arrival_slot(arrivedPckts) = t;
                backlog(t) = backlog(t) + 1;
            end
        else            
            % Node i is backlogged
            % Retransmit with probability qr
            if rand() <= qr
                state(i) = 1;
            else
                % Node_i did not retransmit
                % and stays backlogged
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
    end
    
    % Estimate backlog for slot t+1
    if transmissions <= 1
        backlog_estimate(t+1) = max(lambda, backlog_estimate(t) + lambda - 1);
    else
        backlog_estimate(t+1) = backlog_estimate(t) + lambda + 1/(exp(1)-2);
    end
    
    % Store packet arrivals and departures
    % at time slot t
    arrival(t) = arrivedPckts;
    departure(t) = transmPckts;
end

% Calculate mean delay
W = departure_slot(1:transmPckts) - arrival_slot(1:transmPckts);
W = mean(W);

fprintf('\n=========================\n')
fprintf('Simulation finished\n')
fprintf('Nodes: %u\n',m);
fprintf('Slots %u\n',T);
fprintf('lambda: %.3f\n',lambda);
fprintf('qa: %.3f\n',qa);
fprintf('Arrived packets: %u\n',arrivedPckts);
fprintf('Transmitted packets: %u\n',transmPckts);
fprintf('Mean delay: %.3f\n',W);
fprintf('=========================\n')