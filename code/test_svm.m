
close all;

num_classes = 12;

selected_class = 2;

find_models = true;
train_model = true;

if false
    c = parcluster('local');
    c.NumWorkers = 8;
    parpool(c, c.NumWorkers);
end

if find_models
    [model, model2] = get_models(train_samples, train_labels, selected_class);
else
   model = train_samples{2028}; 
   model2 = train_samples{20}; 
end

%% train SVM
if train_model
    [X, Y] = obtain_distances_and_labels(train_samples, train_labels, model, selected_class);
    num_ones = length(Y(Y==1))
    num_zeros = length(Y(Y==0))
    fprintf('fitting svm \n');
    
    c=[0 1; 3 0];
    SVMModel = fitcsvm(X, Y,'KernelFunction','linear','Cost',c);
end

fprintf('obtain test samples \n');
[X, Y] = obtain_distances_and_labels(test_samples, test_labels, model, selected_class);

fprintf('predict \n');
y_pred = predict(SVMModel, X);

Evaluate(Y, y_pred)

function [X, Y] = obtain_distances_and_labels(samples, labels, model, selected_class)
    X = zeros(length(samples), 1);
    Y = zeros(length(samples), 1);
    
    parfor i = 1:length(samples)
        X(i) = dtw(model, samples{i}, 1);
        if labels(i) == selected_class
            Y(i) = 1;
        end
    end
end

function [model, model2] = get_models(samples, labels, selected_class)
    for i=1:length(samples)
        if labels(i) == selected_class
            model = samples{i};
            model_idx = i;
            break;
        end
    end

    for i=fix(length(samples)/2):length(samples)
        if labels(i) == selected_class
            model2 = samples{i};
            model2_idx = i;
        end
    end
end