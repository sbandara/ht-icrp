ht-icrp
=======

High throughput caspase-8 activity assay for the PE Operetta.

- Coat 96-well plate (COSTAR <a href="http://www.sigmaaldrich.com/catalog/product/sigma/cls3603">
  3603</a>) with 50 uL rat tail collagen
  (Corning <a href="http://catalog2.corning.com/Lifesciences/en-US/Shopping/ProductDetails.aspx?productid=354236(Lifesciences)">#354236</a>, dilute 1:100 in PBS or distilled water) for
  2 hours or overnight. Wash 3x with 200 uL PBS or distilled
  water. Let dry in TC hood.
- Seed into up to 36 wells 5000 IC-RP reporter HeLas per well
  in 100 uL imaging media (DMEM w/out phenol red, Life Tech.
  <a href="http://www.lifetechnologies.com/order/catalog/product/21063029">
  21063-029</a> plus 10% FBS). Fill surrounding wells with PBS. Let
  sit in TC hood for 20 minutes before moving plate into incubator.
- Image cells between 12 and 24 hours after seeding. Add drugs
  or other perturbations in at least 100 uL live imaging media
  and gently mix by aspiration. 

Export images to cluster with LSF support and initiate analysis
with ./icrp_launch.sh after after adjusting launch parameters
in that file.
