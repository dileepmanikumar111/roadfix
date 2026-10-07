# RoadFix — Smart Pothole Reporting & Road Safety Platform (India)

**Prototype — Demonstration Data**  
*Designed for India's Digital Road Safety Ecosystem*  
*(Civic-tech demonstration platform — not an official government application)*

---

## 🚦 Overview

**RoadFix** is a mobile-first civic-tech road safety platform built specifically for Indian urban and suburban infrastructure. It enables citizens to report potholes and hazardous road conditions with photo/video evidence and automated GPS coordinates, classifies damage using the **RoadVision AI Abstraction Layer**, prioritizes repairs using multi-factor risk scoring, and tracks municipal repairs through a transparent 9-stage lifecycle requiring **Citizen Verification** before closure.

---

## 🎨 Civic-Tech Design System & Color Palette

Designed according to civic-tech principles with India's digital ecosystem colors:

| Color | Hex Token | Usage |
|---|---|---|
| **White** | `#FFFFFF` | Background cards, crisp contrast surfaces |
| **Deep Blue** | `#000080` | Brand identity, primary headers, active role pills |
| **Saffron** | `#FF9933` | Hero callouts, priority accents, demo tour triggers |
| **Light Blue** | `#F2F6FF` | App page background, AI diagnostic panels |
| **Green** | `#138808` | Completed repairs, citizen verification approvals, positive status |
| **Warning** | `#F59E0B` | Medium severity alerts, standard queue items |
| **Danger** | `#D32F2F` | Critical hazard badges, pulsing map markers, emergency dispatch |

---

## 📱 Mobile-First Navigation

Bottom navigation bar with touch-optimized targets:
- **Home (`#nav-home`)**: Hero metrics, live safety radar, 4 KPI stats cards, recent road reports feed.
- **Map (`#nav-map`)**: Interactive Leaflet GIS map with pulsing critical hazard beacons, hotspot radius zones, and search/filters.
- **Report (`#nav-report`)**: Center highlighted action button to snap road photos (with automatic image compression), GPS location capture, category selector, and AI diagnostic scanner.
- **My Reports (`#nav-myreports`)**: Citizen's reported complaints, complaint timeline, and **Action Required** verification alerts.
- **Profile (`#nav-profile`)**: Citizen profile, civic point balance (🪙), 4 Civic Badges (*Pothole Spotter*, *Road Guardian*, *Civic Champion*, *Master Verifier*), and Supabase connection settings.

---

## 🌐 10 Indian Languages Centralized i18n

Centralized real-time language switcher with **zero page reload**:
1. **English** (en)
2. **Hindi** (hi) — हिंदी
3. **Telugu** (te) — తెలుగు
4. **Tamil** (ta) — தமிழ்
5. **Kannada** (kn) — ಕನ್ನಡ
6. **Malayalam** (ml) — മലയാളം
7. **Bengali** (bn) — বাংলা
8. **Marathi** (mr) — मराठी
9. **Gujarati** (gu) — ગુજરાતી
10. **Punjabi** (pa) — ਪੰਜਾਬੀ

---

## 🧠 RoadVision AI Abstraction Layer

- **Pothole Detection & Visual Bounding Box**: Computer-vision analysis calculating cavity dimensions (`depthCm`, `diameterCm`, `confidence%`).
- **Severity Classification**: `Low`, `Medium`, `High`, `Critical`.
- **Duplicate-Report Detection**: Spatial Haversine collision check against existing tickets within a 65m radius.
- **Fault-Tolerant Abstraction**: Built-in edge heuristic engine guarantees 100% functionality out of the box even when external AI APIs are offline or unconfigured.

---

## 📈 Smart Priority Scoring Algorithm

Calculates a priority score from 1 to 100:
$$\text{Priority} = (\text{AI Severity} \times 0.38) + (\text{Road/Traffic Weight} \times 0.25) + (\text{Sensitive Zone Bonus} \times 0.20) + (\text{Crowd Signals} \times 0.15)$$

- **Tier 1 (Score 90–99)**: Emergency Dispatch — 24 Hour SLA
- **Tier 2 (Score 75–89)**: Urgent Rectification — 48 Hour SLA
- **Tier 3 (Score 50–74)**: Standard Repair — 72 Hour SLA
- **Tier 4 (Score < 50)**: Routine Maintenance — 120 Hour SLA

---

## 🔄 9-Stage Complaint Lifecycle State Machine

1. **Reported** (Citizen uploads photo + GPS)
2. **AI Verified** (RoadVision AI detects bounding box, severity, depth)
3. **Authority Review** (Municipal officer evaluates triage queue)
4. **Assigned** (Contractor / Rapid Patch Squad assigned with materials & date)
5. **Repair Scheduled** (Scheduled in work roster)
6. **Repair In Progress** (Crew dispatched to site with rollers/asphalt)
7. **Repair Completed** (Before/After photographic proof uploaded)
8. **Citizen Verification** (Citizen inspects repair and approves/rejects)
9. **Closed** (Ticket closed, citizen awarded +50 Civic Points)

---

## 🏙️ Preloaded Demo Cities

Realistic road data for 8 major Indian metro regions:
- **Hyderabad** (GHMC — Hitec City Cyber Towers, Jubilee Hills Rd 36)
- **Visakhapatnam** (GVMC — RK Beach Promenade, MVP Colony)
- **Vijayawada** (VMC — MG Road Benz Circle)
- **Bengaluru** (BBMP — Outer Ring Road Marathahalli, Indiranagar 100ft Rd)
- **Chennai** (GCC — Anna Salai Gemini Flyover, OMR)
- **Mumbai** (BMC — Western Express Highway Goregaon, BKC)
- **Delhi** (MCD / PWD — Ring Road Ashram, Outer Ring Road)
- **Pune** (PMC — Hinjewadi Phase 1, FC Road)

---

## 🛠️ Supabase PostgreSQL Setup

The app works seamlessly out of the box with the local reactive persistent engine. To connect live Supabase:

1. Open your [Supabase Dashboard](https://supabase.com).
2. Go to the **SQL Editor** and run the provided [`supabase_schema.sql`](file:///c:/Users/user/OneDrive/Documents/New%20folder/supabase_schema.sql).
3. In the RoadFix web app, go to **Profile → Configure Supabase Credentials**.
4. Enter your Supabase Project URL and public Anon Key, then toggle **Enable live Supabase sync**.

---

## 🚀 Running Locally

```bash
# In the project directory:
python -m http.server 8080
```
Open **`http://localhost:8080`** in any modern web browser on desktop or mobile.

### Quick Demo Walkthrough for Judges
Click the **"🚀 Launch Demo Tour"** button at the top of the app to experience the entire citizen-to-closure lifecycle step-by-step!
