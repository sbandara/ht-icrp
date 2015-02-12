ht-icrp
=======

**High throughput caspase-8 activity assay for the PE Operetta.**

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
  and gently mix by aspiration. Pre-imaging for 30 min before drug
  addition can help with maturation of fluorophores.

Export images to cluster with LSF support and initiate analysis
with <code>./icrp_launch.sh</code> after after adjusting launch parameters
within that file. After batch runs complete, use <code>mergesites.m</code>
to collect results from multisite runs, <code>r0merge.m</code> to attach
initial RFP fluorescence intensity values, or <code>stitchmat.m</code> to
connect traces from multiple rounds of imaging.
