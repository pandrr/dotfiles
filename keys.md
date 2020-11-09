
use xkeysnail to map cmd+x keys to ctrl keys



4. Create a systemd service for xkeysnail to run automatically on the background:

    ```
    cd /etc/systemd/system && sudo nano xkeysnail.service
    ```

5. Insert the following code to the service config and edit the path to the provided config file:
    ```
    [Unit]
    Description=xkeysnail

    [Service]
    Type=simple
    KillMode=process
    ExecStart=/usr/bin/sudo /usr/bin/xkeysnail --quiet --watch /path/to/your/config-macos.py
    ExecStop=/usr/bin/sudo /usr/bin/killall xkeysnail
    Restart=on-failure
    RestartSec=3
    Environment=DISPLAY=:0

    [Install]
    WantedBy=graphical.target
    ```

6. Enable the xkeysnail service:
    ```
    sudo systemctl enable xkeysnail
    ```

7. Start the xkeysnail service:
    ```
    sudo systemctl start xkeysnail
    ```


## Troubleshooting 
- To check if the xkeysnail service is running properly, run:
  ```
  sudo systemctl status xkeysnail
  ```

- If you encounter errors like `Xlib.error.DisplayConnectionError: Can't connect to display ":0.0": b'No protocol specified\n'`, make sure you have `xhost` package installed and try:
  ```
  sudo xhost + && sudo systemctl restart xkeysnail
  ```



