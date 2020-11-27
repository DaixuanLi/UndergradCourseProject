import torch
from torch import nn
import torch.nn.functional as F

class RNNCell(nn.Module):
    def __init__(self, input_size, hidden_size):
        super().__init__()
        self.input_size = input_size
        self.hidden_size = hidden_size

        self.input_layer = nn.Linear(input_size, hidden_size)
        self.hidden_layer = nn.Linear(hidden_size, hidden_size, bias=False)

    def init(self, batch_size, device):
        #return the initial state
        return torch.zeros(batch_size, self.hidden_size, device=device)

    def forward(self, incoming, state):
        # flag indicates whether the position is valid. 1 for valid, 0 for invalid.
        output = (self.input_layer(incoming) + self.hidden_layer(state)).tanh()
        new_state = output # stored for next step
        return output, new_state

class GRUCell(nn.Module):
    def __init__(self, input_size, hidden_size):
        super().__init__()
        self.input_size = input_size
        self.hidden_size = hidden_size

        # TODO START
        # intialize weights and layers
        self.ir_layer = nn.Linear(input_size, hidden_size)
        self.iz_layer = nn.Linear(input_size, hidden_size)
        self.in_layer = nn.Linear(input_size, hidden_size)
        self.hr_layer = nn.Linear(hidden_size, hidden_size)
        self.hz_layer = nn.Linear(hidden_size, hidden_size)
        self.hn_layer = nn.Linear(hidden_size, hidden_size)
        # TODO END

    def init(self, batch_size, device):
        # TODO START
        # return the initial state
        return torch.zeros(batch_size, self.hidden_size, device=device)
        # TODO END

    def forward(self, incoming, state):
        # TODO START
        r = torch.sigmoid(self.ir_layer(incoming) + self.hr_layer(state))
        z = torch.sigmoid(self.iz_layer(incoming) + self.hz_layer(state))
        n = (self.in_layer(incoming) + r * self.hn_layer(state)).tanh()
        output = (1 - z) * n + z * state
        new_state = output
        # calculate output and new_state
        return output, new_state
        # TODO END

class LSTMCell(nn.Module):
    def __init__(self, input_size, hidden_size):
        super().__init__()
        self.input_size = input_size
        self.hidden_size = hidden_size

        # TODO START
        # intialize weights and layers
        self.ii_layer = nn.Linear(input_size, hidden_size)
        self.if_layer = nn.Linear(input_size, hidden_size)
        self.ig_layer = nn.Linear(input_size, hidden_size)
        self.io_layer = nn.Linear(input_size, hidden_size)
        self.hi_layer = nn.Linear(hidden_size, hidden_size)
        self.hf_layer = nn.Linear(hidden_size, hidden_size)
        self.hg_layer = nn.Linear(hidden_size, hidden_size)
        self.ho_layer = nn.Linear(hidden_size, hidden_size)
        # TODO END

    def init(self, batch_size, device):
        # TODO START
        # return the initial state (which can be a tuple)
        return torch.zeros(2, batch_size, self.hidden_size, device=device)
        # TODO END

    def forward(self, incoming, state): # 这里state需要是(h_t-1, c_t-1)
        # TODO START
        # calculate output and new_state
        i = torch.sigmoid(self.ii_layer(incoming) + self.hi_layer(state[0]))
        f = torch.sigmoid(self.if_layer(incoming) + self.hf_layer(state[0]))
        g = (self.ig_layer(incoming) + self.hg_layer(state[0])).tanh()
        o = torch.sigmoid(self.io_layer(incoming) + self.ho_layer(state[0]))
        new_c = f * state[1] + i * g
        new_h = o * new_c.tanh()
        output = new_h
        return output, (new_h, new_c)
        # TODO END