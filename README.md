# Bencana Gwencana

Flood response research and prototype — Apple Developer Academy Bali, 2026.
Six-week project with a five-person team, in partnership with a local
government agency in Bali.

**Status:** research phase. Problem statement not finalised. No
implementation decisions made.

---

## Who we're building for

People at risk of flooding in the urban metro area of south Bali
(Denpasar and surrounds).

This is a mixed population, and the reason people fail to act differs by
group — which is the distinction we're currently working through:

| Group | Why acting early is hard |
|---|---|
| Street vendors | Packing up costs a day's income |
| Renters / kos residents | Nowhere higher to put anything; few local ties |
| Shift workers | Not present — cannot act at all |
| Low-mobility households | Need another person, not a signal |
| Shop owners | Lost trade plus heavy stock to move |
| Long-term residents | Low cost — already read their own street well |

Not decided: whether we serve one of these groups, or the agency staff
who monitor and warn them.

---

## Problem space

The gap between a flood being detectable and people at risk actually
acting on it.

Warnings exist in parts of the metro area and are largely disregarded.
This is the thread we are currently pulling.

---

## What we know

**Confirmed (agency, Aug 2026)**
- Monitoring in the partner area is done by CCTV, watched by a person
- Likely no dedicated watcher — a worker is told to check during heavy rain
- Coverage varies by area: Denpasar has established systems, others
  (e.g. Legian) do not prioritise the topic and focus on aftermath
- Where warning systems exist, residents largely disregard them

**Confirmed (survivor interviews, n≈9)**
- People act immediately and independently; nobody waits for rescue
- Power and connectivity fail within minutes
- Help comes from whoever is nearby, not from designated responders
- Secondary disruption (power, supply, access, income) causes more
  reported harm than the water itself

**Inference — not confirmed**
- Vendors ignore warnings because packing up costs income (this is the
  agency's reading; no vendor has been interviewed)
- Residents trust their own judgement — watching the sky — over official
  warnings

---

## Open questions

Blocking:
- Can camera feeds be accessed programmatically, or only via a viewing app?
- Is footage retained? Can we access past flood events?
- How long between water crossing a threshold and anyone acting?
- Who has authority to issue a warning, and are they reachable at night?

Unresolved:
- Which at-risk group do we serve?
- Is anyone specifically checked on when a warning goes out?
- Why do some metro areas not prioritise flood detection?
- Has anyone asked residents why they don't respond?

---

## Ruled out, with reasons

| Direction | Why |
|---|---|
| Evacuation routing | Our evidence says the failure is road capacity, not wayfinding; lethal if wrong |
| Route-based hazard alerts | Sitata and GeoSure exist; Google Maps ships this natively |
| Serving tourists as primary users | Not re-recruitable for testing; least affected group in the Feb 2026 flood |
| Earthquake focus | No recruitable recent population; would require structural safety judgements |
| Tsunami focus | No channel exists in the decision window; untestable |

---

## Constraints

- ~4 weeks remaining
- Apple ecosystem only (project requirement) — the at-risk population is
  predominantly Android; stated limitation on testing validity
- Dry season: no live flood events before submission
- Anything safety-critical must not be relied on as a sole signal

---

## Decision log

Append-only. Date, decision, reason.

- 2026-08-XX — Pivoted from responders (RBTB) to survivors. Reason:
  responder partner reply rate too low to support prototype testing.
- 2026-08-XX — Committed to floods over earthquakes. Reason: recruitable
  population, recurring hazard, non-lethal failure modes.
- 2026-08-XX — Will not build flood reporting. Reason: PetaBencana
  incumbent.
- 2026-08-XX — Target narrowed to urban metro at-risk population.

---

## Repo

Private. Contains partner-provided material — do not make public without
agreement from the team and the partner agency.

No credentials, feed URLs, site locations, or staff names in the repo.
