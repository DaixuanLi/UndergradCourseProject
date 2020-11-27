import torch.nn as nn
import torch.nn.functional as F
import torch
import os

class VAE(nn.Module):
    def __init__(self, num_channels, latent_dim):
        super(VAE, self).__init__()
        self.num_channels = num_channels
        self.latent_dim = latent_dim
        # Define the architecture of VAE here
        # TODO START
        self.enc_1 = nn.Conv2d(self.num_channels, 16, (3,3), 1, 1)
        self.enc_2 = nn.Conv2d(16, 32, (3,3), 2, 1)
        self.enc_3 = nn.Conv2d(32, 32, (3,3), 1, 1)
        self.enc_4 = nn.Conv2d(32, 16, (3,3), 2, 1)
        self.enc_5 = nn.Linear(16 * 8 * 8, 2 * self.latent_dim)
        self.enc_6 = nn.Linear(2 * self.latent_dim, 2 * self.latent_dim)

        self.dec_1 = nn.Linear(self.latent_dim, self.latent_dim)
        self.dec_2 = nn.Linear(self.latent_dim, 16 * 8 * 8)
        self.dec_3 = nn.ConvTranspose2d(16, 32, (3,3), 2, 1, 1)
        self.dec_4 = nn.ConvTranspose2d(32, 32, (3,3), 1, 1, 0)
        self.dec_5 = nn.ConvTranspose2d(32, 16, (3,3), 2, 1, 1)
        self.dec_6 = nn.ConvTranspose2d(16, 1, (3,3), 1, 1, 0)

        # TODO END

    def reparameterize(self, mu, log_var):
        '''
        *   Arguments:
            *   mu (torch.FloatTensor): [batch_size, latent_dim], parameters of the diagnoal Gaussian posterior q(z|x)
            *   log_var (torch.FloatTensor): [batch_size, latent_dim], parameters of the diagnoal Gaussian posterior q(z|x)
        *   Returns:
            *   reparameterized samples (torch.FloatTensor): [batch_size, latent_dim]
        '''
        # TODO START
        # reference: https://shenxiaohai.me/2018/10/20/pytorch-tutorial-advanced-02/
        std = torch.clip(torch.exp(log_var), -1e32, 1e32)
        eps = torch.randn_like(std)
        sampled_z = mu + eps * std
        return sampled_z
        # TODO END

    def forward(self, x=None, z=None):
        '''
        *   Arguments:
            *   x (torch.FloatTensor): [batch_size, 1, 32, 32]
            *   z (torch.FloatTensor): [batch_size, latent_dim]
        *   Returns:
            *   if `x` is not `None`, return a list:
                *   Reconstruction of `x` (torch.FloatTensor)
                *   mu (torch.FloatTensor): [batch_size, latent_dim], parameters of the diagnoal Gaussian posterior q(z|x)
                *   log_var (torch.FloatTensor): [batch_size, latent_dim], parameters of the diagnoal Gaussian posterior q(z|x)
            *  if `x` is `None`, return samples generated from the given `z` (torch.FloatTensor): [num_samples, 1, 32, 32]
        '''
        if x is not None:
            # TODO START
            x = F.relu(self.enc_1(x))
            x = F.relu(self.enc_2(x))
            x = F.relu(self.enc_3(x))
            x = F.relu(self.enc_4(x))
            x = x.reshape(x.size()[0], 16 * 8 * 8)
            x = F.relu(self.enc_5(x))
            x = self.enc_6(x)
            x = x.reshape(x.size()[0], 2, self.latent_dim)
            mu = x[:,0,:]
            log_var = x[:, 1, :]
            z = self.reparameterize(mu, log_var)
            z = F.relu(self.dec_1(z))
            z = self.dec_2(z)
            z = z.reshape(z.size()[0], 16, 8, 8)
            z = F.relu(self.dec_3(z))
            z = F.relu(self.dec_4(z))
            z = F.relu(self.dec_5(z))
            recon_x = F.sigmoid(self.dec_6(z))
            return recon_x, mu, log_var
            # TODO END
        else:
            assert z is not None
            # TODO START
            z = F.relu(self.dec_1(z))
            z = self.dec_2(z)
            z = z.reshape(z.size()[0], 16, 8, 8)
            z = F.relu(self.dec_3(z))
            z = F.relu(self.dec_4(z))
            z = F.relu(self.dec_5(z))
            gen_x = torch.sigmoid(self.dec_6(z))
            return gen_x
            # TODO END

    def restore(self, ckpt_dir):
        try:
            if os.path.exists(os.path.join(ckpt_dir, 'pytorch_model.bin')):
                path = os.path.join(ckpt_dir, 'pytorch_model.bin')
            else:
                path = os.path.join(ckpt_dir, str(max(int(name) for name in os.listdir(ckpt_dir))), 'pytorch_model.bin')
        except:
            return None
        self.load_state_dict(torch.load(path))
        return os.path.split(path)[0]

    def save(self, ckpt_dir, global_step):
        os.makedirs(os.path.join(ckpt_dir, str(global_step)), exist_ok=True)
        path = os.path.join(ckpt_dir, str(global_step), 'pytorch_model.bin')
        torch.save(self.state_dict(), path)
        return os.path.split(path)[0]
