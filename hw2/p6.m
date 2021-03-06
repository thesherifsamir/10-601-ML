clear all; close all;
% p6 of homework2 - text classification
load('handout.mat');
load('dictionary.mat');





% some useful variables
n = size(Xtrain, 1); 
V = size(Xtrain, 2); % num features (different types of words)


% to make a prediction, the priors are learned from the given 
% training data, and the conditional probabilities are learned as well 

% extract onion and economist articles
onion_a = Ytrain==0;
econ_a = Ytrain==1;

onions = Xtrain(onion_a,:);
econs = Xtrain(econ_a,:);

% calculate priors 
num_onions = size(onions,1);
num_econs = size(econs,1);

prior_onion = num_onions/n;
prior_econ = num_econs/n;

priors = [prior_onion prior_econ];

% calculate conditional probabilities
%-probability word occurs given article class
num_words_total_onion = sum(sum(onions));
num_words_total_econ = sum(sum(econs));
num_words_onion = sum(onions,1);
num_words_econ = sum(econs,1);

% use additive smoothing - smoothing operator that as alpha -> infinity 
% approximates uniform distribution sampling. a.k.a laplace smoothing

alpha = 1; % smoothing parameter
d = V; % num_outcomes
p_w_given_onion = (num_words_onion+alpha)./(num_words_total_onion+(alpha*d));
p_w_given_econ = (num_words_econ+alpha)./(num_words_total_econ+(alpha*d));


% create struct housing the probabilities

model = struct('priors',priors, 'conditionals_onion',p_w_given_onion, ...
               'conditionals_econ', p_w_given_econ);
           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test data

% useful variables
m = size(Xtest,1);
V = size(Xtest,2);

% extract probabilities from model
priors = model.priors;
conditionals_onion = model.conditionals_onion;
conditionals_econ = model.conditionals_econ;
priors_onion = priors(1);
priors_econ = priors(2);

% calc log probabilities to avoid small numbers
log_cond_o = log(conditionals_onion);
log_cond_e = log(conditionals_econ);
log_prior_o = log(priors(1));
log_prior_e = log(priors(2));



Pred_nb = zeros(m,1); % vector of predictions for each of test documents

% loop over each training document, calculating probability
for i=1:m
    % calc q=num_words in test document
    q = sum(Xtest(i,:),2);
    document = Xtest(i,:);
    const2 = sum(log(factorial(document)),2);
    const1 = log(double(factorial(uint32(q)))); % convert to uint32 to have more 
                                        % digits for calculation (avoid inf)
    
    % calculate and add the terms that vary with priors and conditional
    % probabilities.
    pred_o = sum(document.*log_cond_o) + log_prior_o + const1 - const2;
    pred_e = sum(document.*log_cond_e) + log_prior_e + const1 - const2;
    

    if (pred_e>pred_o)
        Pred_nb(i) = 1;
    end
    
    
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% p6b-computes the top 5 words that discriminate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lg_ratio = log(p_w_given_econ./p_w_given_onion);
%sorted_r = sort(lg_ratio);
%largest_n = sorted_r(1:5);
%indices = find(lg_ratio, largest_n);

