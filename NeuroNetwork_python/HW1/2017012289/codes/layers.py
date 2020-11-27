import numpy as np


class Layer(object):
    def __init__(self, name, trainable=False):
        self.name = name
        self.trainable = trainable
        self._saved_tensor = None

    def forward(self, input):
        pass

    def backward(self, grad_output):
        pass

    def update(self, config):
        pass

    def _saved_for_backward(self, tensor):
        '''The intermediate results computed during forward stage
        can be saved and reused for backward, for saving computation'''

        self._saved_tensor = tensor

class Relu(Layer):
    def __init__(self, name):
        super(Relu, self).__init__(name)

    def forward(self, input):
        # TODO START
        '''Your codes here'''
        grad = np.ones_like(input, np.float32)
        grad[input <  0] = 0.0
        self._saved_for_backward(grad)
        input[input < 0] = 0.0
        return input
        # TODO END

    def backward(self, grad_output):
        # TODO START
        '''Your codes here'''
        return grad_output * self._saved_tensor
        # TODO END

class Sigmoid(Layer):
    def __init__(self, name):
        super(Sigmoid, self).__init__(name)

    def forward(self, input):
        # TODO START
        '''Your codes here'''
        ret = 1 / (1 - np.exp(-input))
        self._saved_for_backward(ret)
        return ret
        # TODO END

    def backward(self, grad_output):
        # TODO START
        '''Your codes here'''
        inp = self._saved_tensor
        return inp * (1 - inp) * grad_output
        # TODO END

class Gelu(Layer):
    def __init__(self, name):
        super(Gelu, self).__init__(name)
        self.c0 = 0.044715
        self.c1 = np.sqrt(2.0 / np.pi)

    def forward(self, input):
        # TODO START
        '''Your codes here'''
        self._saved_for_backward(input)
        return 0.5 * input * (1 + np.tanh(self.c1 * (input + self.c0 * (input**3))))
        # TODO END

    def backward(self, grad_output):
        # TODO START
        '''Your codes here'''
        u = self._saved_tensor
        in_tanh = self.c1 * (u + self.c0 * (u**3))
        result = np.ones_like(in_tanh) * grad_output
        v = (-74 <= in_tanh) & (in_tanh <= 74)
        result[v] *= 0.5 * (1 + self.tanh(in_tanh[v])) + 0.5 * u[v] * (self.grad_tanh(in_tanh[v ])) * (self.c1 * (1 + 3 * self.c0 * u[v ] * u[v ]))
        return result
        # TODO END

    def tanh(self, x):
        a = np.exp(x)
        b = np.exp(-x)
        return (a-b) / (a+b)

    def grad_tanh(self, x):
        a = np.exp(x)
        b = np.exp(-x)
        return 4 / ((a+b)**2)
    

class Linear(Layer):
    def __init__(self, name, in_num, out_num, init_std, act_type, act_name):
        super(Linear, self).__init__(name, trainable=True)
        self.in_num = in_num
        self.out_num = out_num
        self.W = np.random.randn(in_num, out_num) * init_std
        self.b = np.zeros(out_num)

        self.grad_W = np.zeros((in_num, out_num))
        self.grad_b = np.zeros(out_num)

        self.diff_W = np.zeros((in_num, out_num))
        self.diff_b = np.zeros(out_num)

        self.act = act_type
        self.act_name = act_name
        try:
            assert self.act in ['sigmoid', 'relu', 'gelu', None]
        except:
            raise ValueError("supported activation type: sigmoid, relu, gelu and None.")
        if self.act == 'sigmoid':
            self.act_layer = Sigmoid(self.act_name)
        elif self.act == 'relu':
            self.act_layer = Relu(self.act_name)
        elif self.act == 'gelu':
            self.act_layer = Gelu(self.act_name)
        else:
            self.act_layer = None

    def forward(self, input):
        # TODO START
        '''Your codes here'''
        self._saved_for_backward(input)
        if self.act_layer:
            return self.act_layer.forward(np.matmul(input, self.W) + self.b)
        else:
            return np.matmul(input, self.W) + self.b
        # TODO END

    def backward(self, grad_output):
        # TODO START
        '''Your codes here'''
        inp = self._saved_tensor
        grad = grad_output
        if self.act_layer:
            grad = self.act_layer.backward(grad)
        # print("*** in backward ***")
        # print(grad)
        self.grad_b = np.sum(grad, axis=0) # sum by batch ?
        # print(self.grad_b)
        self.grad_W = np.matmul(inp.T, grad)
        # print(self.grad_W)
        grad = np.matmul(grad, self.W.T)
        # print(grad)
        # print("*** out backward ***")
        return grad
        # TODO END

    def update(self, config):
        mm = config['momentum']
        lr = config['learning_rate']
        wd = config['weight_decay']

        self.diff_W = mm * self.diff_W + (self.grad_W + wd * self.W)
        self.W = self.W - lr * self.diff_W

        self.diff_b = mm * self.diff_b + (self.grad_b + wd * self.b)
        self.b = self.b - lr * self.diff_b

# # test code
# test = Gelu("test")
# v = np.array([1.0, 2.0, 3.0, 4.0])
# delta_v = np.array([1e-5, 1e-5, 1e-5, 1e-5])
# print("test begin")
# print(test.forward(v))
# print(test.backward([1,1,1,1]))
# print((test.forward(v + delta_v) - test.forward(v)) / delta_v)

# # failed test
# # test = Linear("test",4 , 8, 1, 'relu', "test_act")
# # v = np.array([[1.0,2.0,3.0,4.0], [2.0,4.0,6.0,8.0]])
# # grad_v = np.array([[1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0]])
# # print(test.forward(v))
# # print(test.backward(grad_v))
