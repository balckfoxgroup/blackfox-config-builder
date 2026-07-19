# Black Fox Config Builder — User Guide (English)

**Product:** Black Fox Config Builder  
**Current version:** v1.1.3 (Build 7)  
**Download:** [Black-Fox-Config-Builder.apk](https://foxnext.net/downloads/Black-Fox-Config-Builder.apk)

**Black Fox Config Builder** makes it easier to access your VPN management panel (3X-UI) and create configs from your phone.

With this app, you no longer need the classic browser login workflow to build configs on a smartphone. You connect once with panel credentials and create single or bulk configs directly in the app.

**Requirements**

- Android 7.0 or newer (API 24+)  
- 3X-UI panel version **3.3.0 or newer**  
- Panel credentials from **Panel Login Info** in Black Fox Vpn Installer / BlackFox Vpn Android  

---

## Part 1: Connect to the panel (Connection)

Open the **Connection** tab.

Enter the details from **Panel Login Info**:

- **Panel URL:** Panel address  
- **Username:** Panel username  
- **Password:** Panel password  
- **API Key (optional):** If provided, connection and config creation may be faster. When an API Key is used, username/password fields can be disabled by the app.  
- **Sub URI (optional):** Not required  

Then tap **Connect**.

If the connection succeeds, the status indicator turns green and shows **Connected**.

**Other options**

- **Save:** Store login details for later use  
- **Delete:** Clear saved credentials  
- **Disconnect:** End the panel session  

If the panel version is older than 3.3.0, the app rejects the connection and asks you to update 3X-UI.

---

## Part 2: Create a single config (Single)

Open the **Single** tab.

Fill in:

- **Config name:** Preferred name, or use the random name helper  
- **Traffic (GB):** Allowed usage volume (unlimited is supported where offered)  
- **Duration (days):** Validity period (unlimited is supported where offered)  
- **Inbound:** Select **one or more** enabled inbounds from the multi-select list  

Tap **Create config**.

After a successful create, the app shows:

- Config link (VLESS)  
- Subscription link  
- Config QR code  
- Subscription QR code  

You can tap a QR/link area to copy, or scan the QR. Use **Clear page** when finished.

---

## Part 3: Create bulk configs (Bulk)

Open the **Bulk** tab when you need many configs with the same settings.

Enter:

- **Base name:** Prefix for generated names  
- **Traffic (GB):** Per config  
- **Duration (days):** Per config  
- **Count:** How many configs to create  
- **Inbound:** One or more inbounds (each selected inbound participates in creation)  

Tap **Create bulk configs**.

A progress indicator appears; you can stop the run. Generated links appear at the bottom for copy/share.

---

## Part 4: Config list (List)

The **List** tab shows configs created through Black Fox Config Builder on this device.

From the three-dot menu (or multi-select actions) you can:

- **Copy link**  
- **Delete from panel** (requires an active panel connection)  
- **Delete from list** (local history only)  

There is no in-app “edit config” flow in the current release.

---

## Part 5: Settings

Available options:

1. **Change language** — 10 languages: English, Persian, Russian, Chinese, German, Uzbek, Turkish, Indonesian, Ukrainian, Hindi  
2. **App update** — Startup check and manual check against dual hosts (`blackfoxupdate.ir` + `foxnext.net`). Force update is supported when the server requests it. Download file name: **Black-Fox-Config-Builder.apk**  
3. **Activity log** — View, copy, or clear recent operations for troubleshooting  

---

## Part 6: Contact

The **Contact** tab includes website, email, GitHub, and Telegram links (channel, support, purchase/service bot, group).

---

## Screenshots

![Panel connection and single config](assets/screenshots/en-connection-single.png)

![Bulk config and settings](assets/screenshots/en-bulk-settings.png)

---

© Black Fox Security Team
