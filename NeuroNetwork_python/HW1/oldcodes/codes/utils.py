from __future__ import division
from __future__ import print_function
import numpy as np
from datetime import datetime
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from pandas.core.frame import DataFrame

def onehot_encoding(label, max_num_class):
    encoding = np.eye(max_num_class)
    encoding = encoding[label]
    return encoding


def calculate_acc(output, label):
    correct = np.sum(np.argmax(output, axis=1) == label)
    return correct / len(label)


def LOG_INFO(msg):
    now = datetime.now()
    display_now = str(now).split(' ')[1][:-3]
    print(display_now + ' ' + msg)

def lc_plot(train_loss_list,train_acc_list,test_loss_list,test_acc_list,name):
    iter_list = list(np.arange(0,len(train_loss_list)))+list(np.arange(0,len(test_loss_list)))
    type_list = ['Train']*len(train_loss_list)+['Test']*len(test_loss_list)

    colors = ['windows blue', 'watermelon']
    palette = sns.xkcd_palette(colors)
    pdf = PdfPages('plot' + name + '.pdf')
    plt.figure(figsize=(20, 6.5))
    sns.set(style="whitegrid")



    ax1 = plt.subplot(1,2,1)

    loss_frame = {'Iteration':iter_list,
                  'Loss':train_loss_list+test_loss_list,
                  'Dataset':type_list
                  }
    loss_frame = DataFrame(loss_frame)

    g = sns.lineplot(x="Iteration", y="Loss", hue='Dataset', style='Dataset',
                     data=loss_frame, legend='full', err_style='bars', palette=palette, linewidth=2,
                     err_kws={'elinewidth': 2},ax=ax1)

    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)
    plt.xlabel("Iteration", fontsize=12)
    plt.ylabel("Loss", fontsize=12)
    leg = g.legend(loc='lower left', fontsize=12)
    for legobj in leg.legendHandles:
        legobj.set_linewidth(2.0)


    ax1 = plt.subplot(1, 2, 2)

    loss_frame = {'Iteration': iter_list,
                  'Acc': train_acc_list + test_acc_list,
                  'Dataset': type_list
                  }
    loss_frame = DataFrame(loss_frame)


    g = sns.lineplot(x="Iteration", y="Acc", hue='Dataset', style='Dataset',
                     data=loss_frame, legend='full', err_style='bars', palette=palette, linewidth=2,
                     err_kws={'elinewidth': 2}, ax=ax1)

    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)
    plt.xlabel("Iteration", fontsize=12)
    plt.ylabel("Acc", fontsize=12)
    leg = g.legend(loc='lower right', fontsize=12)
    for legobj in leg.legendHandles:
        legobj.set_linewidth(2.0)


    pdf.savefig(bbox_inches='tight')
    pdf.close()
    plt.show()

