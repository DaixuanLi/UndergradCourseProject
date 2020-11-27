from network import Network
from utils import LOG_INFO, lc_plot
from layers import Relu, Sigmoid, Linear, Gelu
from loss import EuclideanLoss, SoftmaxCrossEntropyLoss, HingeLoss
from solve_net import train_net, test_net
from load_data import load_mnist_2d
import time

NAME = "2layersSigmoid.Cross"
train_data, test_data, train_label, test_label = load_mnist_2d('data')

# Your model defintion here
# You should explore different model architecture
model = Network()
model.add(Linear('fc0', 784, 500, 0.01, 'sigmoid', 'act0'))
model.add(Linear('fc1', 500, 256, 0.01, 'sigmoid', 'act1'))
model.add(Linear('fc2', 256, 10,  0.01, None,   'act2'))

loss = SoftmaxCrossEntropyLoss(name='loss')

# Training configuration
# You should adjust these hyperparameters
# NOTE: one iteration means model forward-backwards one batch of samples.
#       one epoch means model has gone through all the training samples.
#       'disp_freq' denotes number of iterations in one epoch to display information.

config = {
    'learning_rate': 0.1,
    'weight_decay': 0.0005,
    'momentum': 0.9,
    'batch_size': 500,
    'max_epoch': 50,
    'disp_freq': 50,
    'test_epoch': 5
}

start_time = time.time()
train_loss_list, train_acc_list = [], []
test_loss_list, test_acc_list = [], []
for epoch in range(config['max_epoch']):
    LOG_INFO('Training @ %d epoch...' % (epoch))
    

    tr_l, tr_ac, te_l, te_ac = train_net(model, loss, config, train_data, train_label, config['batch_size'], config['disp_freq'], test_data, test_label)
    train_loss_list += tr_l
    train_acc_list += tr_ac
    test_loss_list += te_l
    test_acc_list += te_ac

    if epoch % config['test_epoch'] == 0:
        print('\n')
        LOG_INFO('Testing @ %d epoch...' % (epoch))
        t_l, t_ac = test_net(model, loss, test_data, test_label, config['batch_size'])
        print("loss:{}, acc:{}".format(str(t_l),str(t_ac)))
        # print("loss:{}, acc:{}".format(str(test_loss_list[-1]),str(test_acc_list[-1])))
        print('\n')
print("\n")
print("time consumed:", str(time.time() - start_time))
print('Best Test Acc:{}'.format(str(max(test_acc_list))))

lc_plot(train_loss_list,train_acc_list,test_loss_list,test_acc_list,NAME)
