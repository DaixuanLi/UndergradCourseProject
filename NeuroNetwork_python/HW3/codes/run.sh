# python main.py --name=basic_rnn --num_epochs=30
# python main_gru.py --name=basic_gru --num_epochs=30
# python main_lstm.py --name=basic_lstm --num_epochs=30
# python main_gru.py --name=3layers_gru --layers=3 --num_epochs=30
python main_gru.py --name=basic_gru_t=0.8 --temperature=0.8 --num_epochs=30
python main_gru.py --name=basic_gru_topp --decode_strategy=top-p --max_probability=0.8 --num_epochs=30
python main_gru.py --name=basic_gru_topp_t=0.8 --decode_strategy=top-p --max_probability=0.8 --temperature=0.8 --num_epochs=30
