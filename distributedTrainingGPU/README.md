# Distributed data parallel training with PyTorch

You will need at least 2 machines with cuda compatible gpus with pytorch and numpy installed on all, preferably in virtual environments.
You can run the test.py script to check if cuda is available on your machine.

For 2 machines:

- Download multinode.py and datautils.py on both machines
- cd into folder where you downloaded both python scripts
- On the first machine run:
  `torchrun --nproc_per_node=1 --nnodes=2 --node_rank=0 --rdzv_id=456 --rdzv_backend=c10d --rdzv_endpoint=<host IP>:<host port> multinode.py 50 10`
- On the second  machine run:
  `torchrun --nproc_per_node=1 --nnodes=2 --node_rank=1 --rdzv_id=456 --rdzv_backend=c10d --rdzv_endpoint=<host IP>:<host port> multinode.py 50 10 `
- Wait for the DDP to complete

If you have a cuda compatible gpu but the test script fails you might have to install the cuda toolkit from [here](https://developer.nvidia.com/cuda-downloads). After installing the cuda toolkit you must reboot the machine.
