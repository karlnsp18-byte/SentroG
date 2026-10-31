# Sentro Ginhawa reports: analysis and recommendations

Reports may summarize recorded measurements and show changes over time. They must distinguish observations from clinical interpretation.

## Data captured
- Blood pressure: systolic/diastolic in mmHg
- Body temperature: °C
- Height: cm
- Weight: kg
- BMI: calculated from a paired height and weight measurement; retain the inputs and calculation timestamp
- Blood glucose: mg/dL or mmol/L, with fasting / before meal / after meal / random context and time since meal where known

## Report behavior
1. Show the date range, number of readings, missing measurements and source (kiosk or self-reported).
2. Show values, units, timestamps and trend direction. Do not infer a diagnosis from a single reading.
3. Compare only measurements with compatible units and context. Glucose interpretation must account for fasting/post-meal status; do not compare unlike contexts as if equivalent.
4. Use locally approved clinical thresholds and have a qualified clinician review the rule set before enabling personalized flags.
5. Give safe, general next steps (repeat an unexpected reading using the device instructions, keep a measurement log, discuss persistent patterns with a healthcare professional).
6. Display urgent-care instructions only from a clinician-approved protocol. Never let an algorithm reassure someone that urgent symptoms are safe.
7. Include a prominent note: educational information only, not a diagnosis or substitute for professional care.

## BMI
BMI = weight_kg / (height_m * height_m). Label adult BMI categories only for adults and state that BMI is a screening measure, not a diagnosis. Do not apply adult cutoffs to children/adolescents; those require age- and sex-specific growth references.

## Blood glucose
Store the measurement context, unit, device/source, and timestamp. A number without fasting/meal context is insufficient for many interpretations. Do not provide medication or insulin dose recommendations.

## Privacy
Health readings are sensitive personal data. Collect only necessary information, restrict records to the authenticated owner and authorized clinical roles, audit privileged access, encrypt transport, establish retention/deletion policies, and obtain appropriate informed consent.
