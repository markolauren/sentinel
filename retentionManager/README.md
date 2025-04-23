# retentionManager.ps1 (v1.0)
### 💡 PowerShell tool to configure total retention & interactive retention for Sentinel/Log Analytics tables

### Features
✅ Fetch Sentinel/Log analytics tables and retention configuration<br/>
✅ Use Filter & search <br/>
✅ Select & modify total retention and/or interactive retention for single or multiple tables at once.<br/>

![tables1](https://github.com/user-attachments/assets/359543e1-0e74-4173-844a-f759bc1595bb)


### Usage:

.\retentionManager.ps1 **-TenantID** xxxx-xxxx-xxxx-xxxx

- If not provided in command line, tool will ask your tenant id.
- Tool will ask to update Az Modules.
- Log in using your azure credentials + potential conditional access requirements apply. 
- Choose subscription.
- Choose Sentinel / Log analytics workspace.
- Work with your tables & retentions ⚙️
<br/>

### Filter & Choose (use crtl / shift)
![filter](https://github.com/user-attachments/assets/47f591d1-2093-49cc-8e80-d23fda38309e)

### Search & Choose (use crtl / shift)
![search](https://github.com/user-attachments/assets/5989d380-15be-4729-ad1a-257441f290cf)

### Modify
![modify](https://github.com/user-attachments/assets/849402d8-4c89-488d-bb09-b20f1619798f)

### Console view & Log
![console3](https://github.com/user-attachments/assets/319e0277-2159-412b-b23d-325fb9c4cbd4)
