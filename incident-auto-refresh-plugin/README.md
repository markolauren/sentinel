# Security Page Auto Refresh Extension

A Chrome/Edge browser extension that automatically refreshes the Microsoft Security incidents page at configurable intervals by clicking the page's refresh button.

## Features

- ✅ Automatically clicks the "Refresh" button on Microsoft Security incidents pages
- ⚙️ Configurable refresh intervals (1-60 minutes)
- 🎛️ Easy toggle to enable/disable auto-refresh
- 🔘 Manual refresh button for immediate refresh
- 📊 Works on both `security.microsoft.com/incidents` and `mto.security.microsoft.com/incidents`

## Installation

### Chrome / Edge (Developer Mode)

1. **Download the Extension**
   - Download `security-refresh-extension.zip`
   - Extract the ZIP file to a permanent location (e.g., `C:\Extensions\security-refresh-extension\`)
   - **Important:** Don't delete this folder after installation - the browser needs it!

2. **Open Extension Management Page**
   - **Chrome**: Navigate to `chrome://extensions/`
   - **Edge**: Navigate to `edge://extensions/`

3. **Enable Developer Mode**
   - Toggle the "Developer mode" switch in the top-right corner

4. **Load the Extension**
   - Click "Load unpacked"
   - Browse to and select the extracted `security-refresh-extension` folder
   - The extension should now appear in your extensions list

5. **Pin the Extension** (Optional)
   - Click the puzzle piece icon in the browser toolbar
   - Find "Security Page Auto Refresh"
   - Click the pin icon to keep it visible

## Usage

### Configuration

1. **Click the extension icon** in your browser toolbar
2. **Toggle "Enable Auto-Refresh"** to start automatic refreshing
3. **Select refresh interval** from the dropdown (1-60 minutes)
4. **Click "Save Settings"** to apply changes

### Features

- **Enable/Disable**: Toggle the auto-refresh functionality on/off
- **Refresh Interval**: Choose how often the page should refresh
- **Refresh Now**: Manually trigger a refresh immediately
- **Status Display**: Shows current state (Active/Disabled) and interval

### How It Works

The extension runs a content script on Microsoft Security incidents pages that:
1. Finds the "Refresh" button on the page (looks for `<span class="ms-Button-label">Refresh</span>`)
2. Clicks the button automatically at your configured interval
3. Respects the button's disabled state (won't click if disabled)

## Files Structure

```
security-refresh-extension/
├── manifest.json          # Extension configuration
├── content.js            # Main logic for auto-refresh
├── background.js         # Background service worker
├── popup.html           # Extension popup UI
├── popup.css            # Popup styling
├── popup.js             # Popup functionality
├── icons/               # Extension icons
│   ├── icon16.png
│   ├── icon48.png
│   ├── icon128.png
│   └── icon.svg         # Source icon (vector)
└── README.md           # This file
```

## Customization

### Changing Refresh Intervals

Edit `popup.html` to modify the available interval options:

```html
<select id="intervalSelect">
  <option value="1">1 minute</option>
  <option value="5" selected>5 minutes</option>
  <!-- Add more options here -->
</select>
```

### Changing Target Pages

Edit `manifest.json` to add or modify the pages where the extension works:

```json
"content_scripts": [
  {
    "matches": [
      "https://security.microsoft.com/incidents*",
      "https://your-domain.com/page*"
    ],
    ...
  }
]
```

### Custom Icons

Replace the placeholder PNG files in the `icons/` folder with your own:
- `icon16.png` - 16x16 pixels
- `icon48.png` - 48x48 pixels  
- `icon128.png` - 128x128 pixels

You can use the provided `icon.svg` as a template or create your own.

To convert SVG to PNG, use:
- Online tools: cloudconvert.com, convertio.co
- Inkscape: `inkscape icon.svg --export-png=icon128.png -w 128 -h 128`
- ImageMagick: `convert -background none icon.svg -resize 128x128 icon128.png`

## Troubleshooting

### Extension doesn't work
1. Make sure you're on a supported page (security.microsoft.com/incidents)
2. Reload the page after installing the extension
3. Check that auto-refresh is enabled in the extension popup
4. Open browser DevTools (F12) and check Console for error messages

### Refresh button not found
- The page structure may have changed
- Check the console for `[Security Refresh]` log messages
- The button might be using a different class name or structure

### Settings not saving
- Check that you have an internet connection (uses Chrome Sync storage)
- Try clicking "Save Settings" button after changing options

## Privacy & Permissions

This extension requires:
- **storage**: To save your refresh interval preferences
- **activeTab**: To interact with the current tab for manual refresh
- **host_permissions**: To run on Microsoft Security pages

The extension:
- ✅ Only runs on specified Microsoft Security pages
- ✅ Stores settings locally/in your Chrome sync
- ✅ Does not collect or transmit any data
- ✅ Does not access any other websites

## Development

### Debugging

Open the browser console (F12) on the incidents page to see debug logs:
- `[Security Refresh] Content script loaded`
- `[Security Refresh] Settings loaded - Enabled: true, Interval: 5 min`
- `[Security Refresh] Clicking refresh button`

### Testing

1. Navigate to a Microsoft Security incidents page
2. Open the extension popup
3. Enable auto-refresh with a short interval (1 minute)
4. Watch the console for refresh events
5. Verify the page content updates after each interval

## License

This is a custom tool for personal/organizational use. Feel free to modify as needed.

## Credits

Created for automating Microsoft Security portal monitoring.
