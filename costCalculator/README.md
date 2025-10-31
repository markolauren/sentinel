## Sentinel cost calculator (unofficial)

<img width="1525" height="765" alt="image" src="https://github.com/user-attachments/assets/48332ec1-f924-4f86-8930-383b196d4e1e" />
<br/><br/>

**Quick user guide**
	
1)	In Calculator -sheet, set your Sentinel region & currency 
2)	Refresh the pricing data from source by using CTRL-ALT-F5 (uses https://prices.azure.com/api/retail/prices). In case prompted to trust source, accept.
3)	Set the amount of your M365 E5 licenses (E5/A5/F5) in order to include the benefits in calculation
4)	Set the amount of your Defender for Servers P2 in order to include the benfits in calculation
5)	Fill in orange cells with your daily ingestion under analytics log sources and data lake log source as well as retention
6)	Fill in estimated summary rules for data lake sources. x % indicates how much the summary rule produces outcome, which is written to analytics table.
<br/><br/>

**Outcome**

<img width="464" height="281" alt="image" src="https://github.com/user-attachments/assets/c06d3b16-00e6-4745-b193-1e20fa2ecdf6" />
<img width="1505" height="946" alt="image" src="https://github.com/user-attachments/assets/0216d1e1-ad2f-4ae3-8a8c-a4cddcc1bebb" />
<img width="1500" height="947" alt="image" src="https://github.com/user-attachments/assets/9a17daae-5627-4877-bc96-16fc5b9c1a86" />
<br/><br/>

**FAQ**

How much am I entitled to ingest free using M365 E5 benefit?
> See xx GB/day free with M365 E5 benefit (used through "Entra" and "Defender XDR" log source)

How much am I entitled to ingest free using Defender for Servers P2 benefit?
> See xx GB/day free with MDSp2 benefit (used through "Windows Servers" log source)

How much am I ingesting to analytics per day and what ingestion tier is used in calculation?
> See xx GB/day of billable analytics ingest per day   ====> 100 GB Commitment Tier Capacity Reservation

Is the data lake compression used in calculation?
> Yes. 6:1, 83% compression. Meaning 600GB in, 100GB in storage. Also taken into account for long-term retention for analytics sources.

How the data lake ingestion price is calculated?
> Data lake ingestion ($0.05) + Data lake processing ($0.10), roughly $0.15 alltogether across all data lake sources.

What long-term retention means?
> Once the analytics log source retention ends, it can be moved to long-term retention. Once onboarded to data lake, it's also used for long-term retention. 6:1 compression is applied. 600GB in analytics will be 100GB in long-term retention (data lake).

What prices are being used in calculation?
> Prices are updated on-demand from official Azure pricing API, by choosing CTRL-ALT-F5. Prices are shown in top of the Calculator -sheet.
