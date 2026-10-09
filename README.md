

# Cross-Border Fuel Tourism in Argentina: The Implicit Subsidy Behind the Exchange Rate Gap

Stata code for my Master's thesis in Economics at Universidad Nacional de La Plata (UNLP)

---

## 1. Research question and empirical strategy

Argentine fuel prices follow the official exchange rate. When foreign exchange controls were reintroduced in September 2019, the gap between the official and the informal ("blue") exchange rate widened to between 40% and 120%. Measured at the informal rate, Argentine fuel became much cheaper than in neighboring countries, creating an incentive for their residents to cross the border and refuel in Argentina. The thesis estimates the effect of the exchange rate gap on fuel sales at Argentine gas stations near the borders with Bolivia, Brazil and Paraguay.

**Design.** Difference-in-differences comparing gas stations close to and far from the nearest border crossing, using a monthly panel of the universe of gas stations in the border provinces (Salta, Jujuy, Formosa, Chaco, Corrientes and Misiones).

- **Treatment group:** gas stations less than 50 km by road from the nearest border crossing.
- **Control group:** gas stations more than 200 km away.
- **Pre-period:** August 2017 to July 2019, when the exchange rate gap was close to zero. The sample starts after the end of the "barril criollo" domestic oil price policy.
- **Post-period:** September 2019 to mid-2022. The months when borders were closed due to COVID-19 (March 2020 to November 2021) are excluded from the static estimates.
- **Outcome:** monthly volume sold to final consumers (m3), normalized to 100 for each gas station in August 2019.
- **Estimation:** static DiD with gas station fixed effects, and a dynamic DiD (event study) relative to August 2019. Standard errors clustered at the gas station level. Each specification is estimated on a balanced panel, on stations with at least 40 of 59 monthly observations, and on the unbalanced panel.

Results are estimated for regular gasoline, premium gasoline and diesel, for all border countries together and for each country separately. The main distance measure is road distance computed with OpenStreetMap data and OSRM (Huber and Rust, 2016). Robustness checks use straight-line distance and driving time, shift the treatment threshold in 5 km steps, and drop one border crossing at a time.

**Main findings.** Sales at gas stations near the border increased by about 25 percentage points for regular gasoline, 23 for diesel and 36 for premium gasoline relative to stations far from the border. Effects are concentrated near Brazil and Paraguay, with no significant effect for regular gasoline near Bolivia.

---

## 2. How to run

**`1-master-tesis.do` is the master file.** It sets the working directory and calls every script in order, grouped in numbered sections. All calls are commented out with `*`, so it works as a map of the project. To run a step, uncomment its line.

Before running, update the `cd` local at the top of the master file with your own project folder. The master expects the scripts to be in a `dofiles/` subfolder and the data in `raw-data/` and `bases/` inside that project folder.

**Data are not included in this repository.**

---

## 3. Requirements

Stata 16 or later. SSC packages:

```stata
ssc install reghdfe, replace
ssc install ftools, replace
ssc install estout, replace
ssc install coefplot, replace
ssc install outreg2, replace
ssc install geodist, replace
ssc install distinct, replace
ssc install osrmtime, replace
```

`osrmtime` also requires a local installation of OSRM and the Argentina OpenStreetMap extract (see section 4.4).

---

## 4. Pipeline

The order follows `1-master-tesis.do`.

### 4.1. Exchange rates, data quality and regional prices

| Script | Description |
|---|---|
| `2-tc.do` | Imports daily official and parallel exchange rates, builds monthly series and the exchange rate gap, and plots them |
| `2.1-calidad-data.do` | Data quality check comparing prices in the administrative data with prices reported in local news |
| `figuras-lac.do` | Fuel price series for Argentina and neighboring countries |

### 4.2. Fuel price and volume data

| Script | Description |
|---|---|
| `3-importar.do` | Imports gas station prices and volumes for 2020-2022 and matches them with gas station coordinates |
| `4.1-prepara-bases-2005-2019.do` | Splits the 2005-2019 data into one database per fuel type and buyer type |
| `4.2-prepara-bases-2020-2022.do` | Same for 2020-2022 |
| `4.3-prepara-bases-pulidas.do` | Merges the cleaned databases for each buyer type (public, agriculture, transport, other) into one database per fuel |

Between steps 4.1-4.2 and 4.3, the master calls a set of cleaning scripts (`pulicion_*`) that remove duplicates and set up the panel for each fuel and buyer type. These scripts are not included in this repository.

### 4.3. Panel construction

| Script | Description |
|---|---|
| `5.1-prepara-panel.do` | Builds the regular gasoline panel and computes straight-line distances to border crossings |
| `5.2-prepara-panel.do` | Same for diesel |
| `5.3-prepara-panel.do` | Same for premium gasoline, recomputing straight-line distances with the final set of 31 border crossings |

### 4.4. Road distance and driving time

| Script | Description |
|---|---|
| `prepara-mapa-osm.do` | Prepares the Argentina OpenStreetMap file for OSRM |
| `prepara-combustible-pre-distancias.do` | Builds a cross-section with one observation per gas station and the coordinates of each border crossing |
| `distancias-EESS-frontera.do` | Computes road distance and driving time from each gas station to each border crossing, and keeps the minimum |

### 4.5. Descriptive figures

| Script | Description |
|---|---|
| `6-figuras-0-nafta.do`, `7-figuras-1-nafta.do` | Regular gasoline descriptives |
| `9-figuras-2-nafta.do` | Prices in USD against the official and parallel exchange rates |
| `9-figuras-3-nafta.do` | Volumes sold |
| `10-figuras-4-nafta.do` | Volumes by border crossing |
| `8-figuras-0-gasoil.do`, `11-figuras-1-gasoil.do` | Diesel descriptives, including prices against exchange rates |
| `graficos-provincias.do` | Figures by province (exploratory) |

### 4.6. Estimation

| Script | Description |
|---|---|
| `12-reg-nafta-v0.do`, `12-reg-gasoil-v0.do` | Static DiD, first version |
| `12-reg-nafta-v1.do` | Regular gasoline. Final version, including market share figures |
| `12-reg-gasoil-v1.do` | Diesel. Final version, including market share figures |
| `12-reg-nafta3-v0.do` | Premium gasoline. Final version |
| `9-reg-v0.do` | Early specification (deprecated) |
| `event-study.do` | Early event study by neighboring country (exploratory) |

### 4.7. Final figures and robustness

| Script | Description |
|---|---|
| `13-graph-diff-coef.do` | Coefficient plot with the main estimates for the three fuels and the three distance measures |
| `14-robustness-treat.do` | Robustness to the treatment group definition, shifting the distance threshold in 5 km steps |
| `15-robustness-pasos.do` | Robustness dropping one border crossing at a time |

### 4.8. Other scripts

| Script | Description |
|---|---|
| `tablas-jmp.do` | Descriptive tables of average and total sales by province |
| `mycodebook.do` | Helper program that stores the number of unique values per variable in a panel |
| `mini base.do` | Builds a reduced extract of the data for a specific request |

---

## 5. Data sources

| Source | Description |
|---|---|
| Secretaría de Energía, Ministry of Economy (Argentina), Decree 1104/2004 | Monthly prices and volumes sold by every gas station, by fuel and type of buyer, plus gas station coordinates |
| Ministry of Interior (Argentina) | Location of authorized border crossings. The analysis uses 10 year-round land crossings (3 with Bolivia, 4 with Brazil, 3 with Paraguay) |
| Central Bank of Argentina and Ámbito Financiero | Official and informal exchange rates |
| ANH (Bolivia), ANP (Brazil), CNE (Chile), Ministry of Industry and Commerce (Paraguay), ANCAP (Uruguay) | Fuel prices in neighboring countries |
| OpenStreetMap (Geofabrik) | Argentina road network, used to compute road distance and driving time |

---

## 6. Contact

Malena Dolcet. malenadolcet@gmail.com
