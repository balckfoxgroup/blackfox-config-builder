# Black Fox Config Builder — User Guide (English)

**Black Fox Config Builder** is designed to make it easier to access your VPN management panel (3x-ui) and create configs from your phone.

With this app, users no longer need to log in through a browser and manually build configs when managing the panel on a smartphone — they can create the configs they need quickly and easily.

## Part 1: Connect to the panel (Connection)

To use the app, you must first connect to your 3x-ui panel.

Get the required information from **Panel Login Info** in Black Fox VPN Installer and enter it in the fields below:

- **Panel URL:** Panel address
- **Username:** Panel username
- **Password:** Panel password
- **API Key (optional):** If provided, connection and config creation may be slightly faster.
- **Sub URI (optional):** This field is not required.

After filling in the details, click **Connect**.

If the connection succeeds, the status indicator at the top turns green and displays **Connected**.

**Other options**

- **Save:** Save login details for future use.
- **Delete:** Clear saved credentials.
- **Disconnect:** End the connection to the panel.

![Panel connection and single config](assets/screenshots/en-connection-single.png)

## Part 2: Create a single config

To create a new config, open the **Single** section.

Fill in the following details:

- **Config name:** Enter your preferred config name.
- **Traffic (GB):** Set the allowed usage volume in gigabytes.
- **Duration (days):** Enter the config validity period in days.
- **Inbound:** From the Inbound list, select the port through which this config will connect to the internet.

After completing the fields, click **Create config**.

After a successful build, the following information is displayed:

- Config link (VLESS)
- Subscription link
- Config QR code
- Subscription QR code

You can copy the link or use it by scanning the QR code.

Finally, use **Clear page** to remove the displayed information.

## Part 3: Create bulk configs (Bulk)

If you want to create multiple configs with the same settings, open the **Bulk** section.

Enter the following details:

- **Base name:** Prefix for config names
- **Traffic (GB):** Traffic limit per config
- **Duration (days):** Validity period per config
- **Count:** Number of configs to create

After entering the details, click **Create bulk configs**.

All generated links are shown at the bottom of the page and can be copied or sent to users.

## Part 4: Config list (List)

This section shows a list of all configs created with Black Fox Config Builder.

Through the three-dot menu next to each config, you can access management options such as editing.

## Part 5: Settings

The following options are available in Settings:

1. **Change app language** — You can change the application language from this section.
2. **App update** — The app checks for updates automatically with your permission. A manual update option is also available when needed.
3. **Log** — This section shows a log of operations performed in the app. If a problem occurs, you can review the last few lines and search them on Google to find a likely cause.

![Bulk config creation and settings](assets/screenshots/en-bulk-settings.png)
