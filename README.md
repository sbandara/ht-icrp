ht-icrp
=======

High throughput caspase-8 activity assay for the PE Operetta.

- Coat 96-well plate (COSTAR 3603) with 50 uL rat tail collagen
  (Corning #354236, dilute 1:100 in PBS or distilled water) for
  2 hours or overnight. Wash 3x with 200 uL PBS or distilled
  water. Let dry in TC hood.
- Seed into up to 36 wells 5000 IC-RP reporter HeLas per well
  in 100 uL imaging media (DMEM w/out phenol red, Life Tech.
  21063-029 plus 10% FBS). Fill surrounding wells with PBS. Let
  sit in TC hood for 20 minutes before moving plate into incuba-
  tor.
- Image cells between 12 and 24 hours after seeding. Add drugs
  or other perturbations in at least 100 uL live imaging media
  and gently mix by aspiration. 

Export images to cluster with LSF support and initiate analysis
with ./icrp_launch.sh after after adjusting launch parameters
in that file.
