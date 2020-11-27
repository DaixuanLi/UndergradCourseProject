from __future__ import division
import numpy as np


class EuclideanLoss(object):
    def __init__(self, name):
        self.name = name

    def forward(self, input, target):
        # TODO START
        '''Your codes here'''
        # 对input先进行归一化，再带入target计算
        max_ = np.max(input, axis=1, keepdims=True)
        softmax_input = input - max_
        softmax_input = np.exp(softmax_input)
        softmax_input = softmax_input / np.sum(softmax_input, axis=1, keepdims=True)
        self.loss = loss = np.mean(np.sum((softmax_input - target) ** 2, axis=1)) / 2
        return loss
        # TODO END

    def backward(self, input, target):
        # TODO START
        '''Your codes here'''
        batch_size = input.shape[0]
        max_ = np.max(input, axis=1, keepdims=True)
        softmax_input = input - max_
        softmax_input = np.exp(softmax_input)
        softmax_input = softmax_input / np.sum(softmax_input, axis=1, keepdims=True)
        self.grad = grad = 1 / batch_size * softmax_input * (softmax_input - target - np.sum(softmax_input * (softmax_input - target), axis=1, keepdims=True)) # ?
        return grad
        # TODO END


class SoftmaxCrossEntropyLoss(object):
    def __init__(self, name):
        self.name = name

    def forward(self, input, target):
        # TODO START
        '''Your codes here'''
        max_ = np.max(input, axis=1, keepdims=True)
        softmax_input = input - max_
        softmax_input = np.exp(softmax_input)
        softmax_input = softmax_input / np.sum(softmax_input, axis=1, keepdims=True)
        clip = np.clip(softmax_input, 1e-32, 1e32)
        self.loss = loss = -np.mean(np.sum(target * np.log(clip), axis=1))
        return loss
        # TODO END

    def backward(self, input, target):
        # TODO START
        '''Your codes here'''
        max_ = np.max(input, axis=1, keepdims=True)
        softmax_input = input - max_
        softmax_input = np.exp(softmax_input)
        softmax_input = softmax_input / np.sum(softmax_input, axis=1, keepdims=True)
        clip = np.clip(softmax_input, 1e-32, 1e32)
        batch_size = input.shape[0]
        self.grad = grad = 1 / batch_size * (-target + clip)
        return grad
        # TODO END


class HingeLoss(object):
    def __init__(self, name, threshold=0.5):
        self.name = name
        self.Delta = threshold

    def forward(self, input, target):
        # TODO START
        '''Your codes here'''
        max_ = np.max(input, axis=1, keepdims=True)
        softmax_input = input - max_
        softmax_input = np.exp(softmax_input)
        softmax_input = softmax_input / np.sum(softmax_input, axis=1, keepdims=True)
        minus = softmax_input[target == 1.0][:, np.newaxis]
        loss = np.ones_like(target) * self.Delta - minus + softmax_input
        loss[target == 1.0] = 0
        loss[loss < 0] = 0
        loss = np.sum(loss)
        self.loss = loss
        return loss
        # TODO END

    def backward(self, input, target):
        # TODO START
        '''Your codes here'''
        max_ = np.max(input, axis=1, keepdims=True)
        softmax_input = input - max_
        softmax_input = np.exp(softmax_input)
        softmax_input = softmax_input / np.sum(softmax_input, axis=1, keepdims=True)
        minus = softmax_input[target == 1.0][:, np.newaxis]
        loss = np.ones_like(target) * self.Delta - minus + softmax_input
        loss[target == 1.0] = 0
        v1 = 1 * (loss > 0)
        v2 = -1 * np.sum(v1, axis=1, keepdims=True)
        batch_size = input.shape[0]
        grad = 1 / batch_size * (v2 * target + v1)
        self.grad = grad = - np.sum(grad * softmax_input, axis=1, keepdims=True) * softmax_input + softmax_input * grad
        return grad
        # TODO END

