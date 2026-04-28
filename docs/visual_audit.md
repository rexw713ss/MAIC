# Visual Audit Checklist (Stitch vs Flutter)

## IDs audited

- `6229463e7ddf43e38ee846d123cb8e9d` (Schedule)
- `46fa95a755d345938e1ad99742c1a544` (Settings)
- `1ce512346edd421f866dab6f426511df` (Add Medication)
- `99703fc0ac284c7c921dd4302db74067` (Health Hub)
- `6554ad3de9d44faea3484db56dec3229` (Scan Prescription)

## Structural parity checks

- Shared top app bar uses `Inter`, primary blue brand title, avatar on left, bell icon on right.
- Spacing rhythm uses Stitch token cadence (`4 / 8 / 12 / 16 / 20 / 24`).
- Cards use rounded corners + soft shadow profile (`0 4 12` low-opacity black).
- Bottom navigation maps exactly to Home / Schedule / Add / Health / Settings tab taxonomy.
- Screen-specific primary layouts are preserved:
  - Schedule: horizontal date strip + Morning/Evening grouped medication cards.
  - Settings: title/subtitle + profile card + preference toggles + emergency contacts.
  - Add Medication: scan action + manual entry affordance + primary save button.
  - Health Hub: adherence summary + vitals bento-like grid cards.
  - Scan Prescription: full-screen camera feed treatment + centered scanner frame + bottom controls.

## Auto-fixes applied during audit

- Standardized inconsistent icon mappings to valid Cupertino icons.
- Removed non-const-only layout patterns that caused runtime/compile issues.
- Ensured screen hierarchy remains Cupertino-first and consistent with Home Dashboard style system.
