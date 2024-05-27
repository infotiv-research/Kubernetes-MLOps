import torch


def bsFunc():
    print("cuda available: " + str(torch.cuda.is_available()))
    print("number of gpus: " + str(torch.cuda.device_count()))
    return None


bsFunc()
