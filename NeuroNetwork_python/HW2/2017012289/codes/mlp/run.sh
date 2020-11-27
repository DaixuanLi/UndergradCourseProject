CUDA_VISIBLE_DEVICES=1 python main.py --use_bn=True --drop_rate=0.8 --num_epochs=50
CUDA_VISIBLE_DEVICES=1 python main.py --use_bn=True --drop_rate=0.5 --num_epochs=50
CUDA_VISIBLE_DEVICES=1 python main.py --use_bn=True --drop_rate=0.3 --num_epochs=50
CUDA_VISIBLE_DEVICES=1 python main.py --use_bn=True --drop_rate=0.1 --num_epochs=50
CUDA_VISIBLE_DEVICES=1 python main.py --use_bn=True --drop_rate=0 --num_epochs=50
CUDA_VISIBLE_DEVICES=1 python main.py --use_bn=False --drop_rate=0.1 --num_epochs=50
CUDA_VISIBLE_DEVICES=1 python main.py --use_bn=False --drop_rate=0 --num_epochs=50