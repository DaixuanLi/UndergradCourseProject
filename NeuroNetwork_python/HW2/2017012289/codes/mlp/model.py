# -*- coding: utf-8 -*-

import torch
from torch import nn
from torch.nn import init
from torch.nn.parameter import Parameter
class BatchNorm1d(nn.Module):
    # TODO START
    # Reference: https://pytorch.org/docs/stable/index.html
    def __init__(self, num_features, momentum:float=0.1, eps=1e-5,):
        super(BatchNorm1d, self).__init__()
        self.num_features = num_features
        self.momentum = momentum
        self.eps = eps

        # Parameters
        self.weight = Parameter(torch.ones(num_features))
        self.bias = Parameter(torch.zeros(num_features))
        
        # Store the average mean and variance
        self.register_buffer('running_mean', torch.zeros(num_features))
        self.register_buffer('running_var', torch.ones(num_features))
        self.register_buffer('num_batches_tracked', torch.tensor(0, dtype=torch.long))
        
        # Initialize your parameter
        self.reset_parameters()
    
    def reset_parameters(self):
        self.running_mean.zero_()
        self.running_var.fill_(1)
        self.num_batches_tracked.zero_()

    def forward(self, input):
        # input: [batch_size, num_feature_map * height * width]
        if self.momentum is None:
                exponential_av = 0.0
        else:
                exponential_av = self.momentum
        if self.num_batches_tracked is not None:
                self.num_batches_tracked = self.num_batches_tracked + 1
                if self.momentum is None:
                        exponential_av = 1.0 / float(self.num_batches_tracked)
                else:
                        exponential_av = self.momentum
        if self.training:
                bn_training = True
        else:
                bn_training = (self.running_mean is None) and (self.running_var is None)
        
        batch_mean = torch.mean(input,(0,1),keepdim=True)
        batch_var = torch.var(input,(0,1),keepdim=True)
        if bn_training:
                self.running_mean = self.running_mean * (1 - exponential_av) + batch_mean * exponential_av
                self.running_var = self.running_var * (1 - exponential_av) + batch_var * exponential_av
        else:
                batch_mean = self.running_mean
                batch_var = self.running_var
        output = (input - batch_mean) / torch.sqrt(batch_var + self.eps) * self.weight + self.bias        
        return output
    # TODO END

class Dropout(nn.Module):
    # TODO START
    def __init__(self, p=0.5):
        super(Dropout, self).__init__()
        self.p = p

    def forward(self, input):
        # input: [batch_size, num_feature_map * height * width]
        return input * torch.bernoulli((1 - self.p) * torch.ones_like(input))
    # TODO END

class Model(nn.Module):
    def __init__(self, drop_rate=0.5, use_bn=True):
        super(Model, self).__init__()
        # TODO START
        # Define your layers here
        self.use_bn = use_bn
        self.linear1 = nn.Linear(3072, 1536)
        self.norm1 = BatchNorm1d(1)
        self.relu1 = nn.ReLU()
        self.dropout1 = Dropout(drop_rate)
        self.linear2 = nn.Linear(1536, 10)
        # TODO END
        self.loss = nn.CrossEntropyLoss()

    def forward(self, x, y=None):
        # TODO START
        # the 10-class prediction output is named as "logits"
        x = self.linear1.forward(x)
        if self.use_bn:
            x = self.norm1.forward(x)
        x = self.relu1.forward(x)
        x = self.dropout1.forward(x)
        logits = self.linear2.forward(x)
        # TODO END

        pred = torch.argmax(logits, 1)  # Calculate the prediction result
        if y is None:
            return pred
        loss = self.loss(logits, y)
        correct_pred = (pred.int() == y.int())
        acc = torch.mean(correct_pred.float())  # Calculate the accuracy in this mini-batch

        return loss, acc
