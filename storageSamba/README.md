# Running samba for storage

While in the MLOps directory, run the following command:

```
sudo ./setupStorageSamba/setupSambaStorage.sh
```

### ATTENTION!

If your host name is not "storage" you need to go into /etc/samba/smb.conf,
scroll down to the \[sambashare\] section and change `force user = storage`
to `force user = your_host_username`, after you have run the script.

You can also so this by changing parts of the string `text` in `setupSambaStorage.sh`
before running it.

### Notes

Followed this [tutorial](https://www.makeuseof.com/set-up-network-shared-folder-ubuntu-with-samba/),
but had to change `force user = smbuser` to `force user = storage`.
